////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Detects peaks in a stream of complex absolute value data. If a peak is
// detected, it and its neighboring samples are transferred to the master
// AXI-stream interface.
//
// Parameters
// NUM_CHANNELS: total number of anchor channels (number of antennas)
// CHANNEL_WIDTH: total data width of each channel
// CABS_DELAY: number of clock cycles of delay for absolute value module
// BURST_LENGTH: length around detected peaks to store samples for
// PEAK_THRESH_MULT: minimum multiplier for detected peaks, must be 2^N
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  CABS_DELAY + BURST_LENGTH / 2 + 1
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   CABS_DELAY = 10,
  parameter   BOXCAR_DELAY = 2,
  parameter   BURST_LENGTH = 32,    // TODO(fzliu); ensure this = 2^N
  parameter   PEAK_THRESH_MULT = 8, // TODO(fzliu): ensure this = 2^N

  // derived parameters

  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  INDEX_WIDTH = log2(NUM_CHANNELS - 1),
  localparam  ABS_WIDTH = (WORD_WIDTH <= 16) ? 16 : 32,
  localparam  PAD_WIDTH = CHANNEL_WIDTH - ABS_WIDTH,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),

  localparam  CABS_SHIFT = NUM_CHANNELS * BURST_LENGTH / 2 + BOXCAR_DELAY,
  localparam  DATA_SHIFT = (CABS_DELAY + BOXCAR_DELAY) / NUM_CHANNELS + 1,

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WI = INDEX_WIDTH - 1,
  localparam  WB = ABS_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output            m_axis_tlast

);

  `include "func_log2.vh"
  `include "sign_ext.vh"

  // internal registers

  reg               has_peak = 'b0;

  // internal signals

  wire    [ WC:0]   s_axis_tdata_unpack [0:NC];
  wire              s_axis_frame;

  wire    [ WI:0]   chan_idx;

  wire    [ WW:0]   data_in_a;
  wire    [ WW:0]   data_in_b;
  wire    [ WB:0]   cabs_dout;

  wire    [ WC:0]   data_abs;
  wire    [ WC:0]   data_abs_avg;

  wire    [ WN:0]   mem_count;
  wire              mem_ready;
  wire              shift_ena;

  wire              m_axis_frame;

  /* Unpack input data.
   * As with axis_bit_corr, this is done for ease of use later on in this
   * module.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  /* Slave interface.
   * The slave interface for axis_peak_detn mimics that of axis_bit_corr. For
   * more details, refer to that module (stall signal has been removed).
   */

  assign s_axis_tready = (chan_idx == NC);
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  /* Counter logic.
   * The counter logic for axis_cabs_serial mimics that of axis_bit_corr. For
   * more details, refer to that module.
   */

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter_chan (
    .clk (clk),
    .rst (s_axis_frame),
    .ena (s_axis_tvalid),
    .value (chan_idx)
  );

  /* Absolute value instantiation.
   * The width of the absolute value module is set based on the input data
   * width.
   */

  assign data_in_a = s_axis_tdata_unpack[chan_idx][WW:0];
  assign data_in_b = s_axis_tdata_unpack[chan_idx][WC:(WW+1)];

  generate
  if (CHANNEL_WIDTH <= 32) begin

    math_cabs_16 #()
    math_cabs_16 (
      .clk (clk),
      .rst (1'b0),
      .ena (s_axis_tvalid),
      .dina (`SIGN_EXT(data_in_a,WORD_WIDTH,ABS_WIDTH)),
      .dinb (`SIGN_EXT(data_in_b,WORD_WIDTH,ABS_WIDTH)),
      .dout (cabs_dout)
    );

  end else begin

    math_cabs_32 #()
    math_cabs_32 (
      .clk (clk),
      .rst (1'b0),
      .ena (s_axis_tvalid),
      .dina (`SIGN_EXT(data_in_a,WORD_WIDTH,ABS_WIDTH)),
      .dinb (`SIGN_EXT(data_in_b,WORD_WIDTH,ABS_WIDTH)),
      .dout (cabs_dout)
    );

  end
  endgenerate

  /* Shift cabs data.
   * Because we want the peak to lie right in the center of the burst, we must
   * delay the input data by exactly BURST_LENGTH / 2 to ensure that the
   * has_peak signal is timed correctly. We also add the latency of the boxcar
   * filter to compensate for the extra delay introduced by that module.
   */

  shift_reg #(
    .WIDTH (CHANNEL_WIDTH),
    .DEPTH (CABS_SHIFT),
    .USE_RAM (1)
  ) shift_reg_data_abs (
    .clk (clk),
    .rst (1'b0),
    .ena (s_axis_tvalid),
    .din ({{PAD_WIDTH{1'b0}}, cabs_dout}),
    .dout (data_abs)
  );

  /* Peak detection logic.
   * The absolute value of each sample goes through a boxcar averager. If one of
   * the samples has a significantly higher value than the average of it and its
   * neighboring samples, then we have detected a peak.
   */

  filt_boxcar #(
    .DATA_WIDTH (CHANNEL_WIDTH),
    .NUM_CHANNELS (NUM_CHANNELS),
    .FILTER_LENGTH (BURST_LENGTH)
  ) filt_boxcar (
    .clk (clk),
    .rst (1'b0),
    .ena (s_axis_tvalid),
    .din ({{PAD_WIDTH{1'b0}}, cabs_dout}),
    .dout (data_abs_avg)
  );

  always @(posedge clk) begin
    if (s_axis_tvalid) begin
      has_peak <= data_abs > (data_abs_avg + 1'b1) * PEAK_THRESH_MULT;
    end else begin
      has_peak <= 'b0;
    end
  end

  /* Shift register control logic.
   * When a peak is detected, we reset the counter (from a default value of 32)
   * to 0, thereby restarting the upward counting process. This occurs each time
   * a new batch of data is framed by the master AXI-stream, and ends once the
   * counter's output value reaches BURST_LENGTH. Because a shift register is
   * not a circular buffer, we must also keep pusing data through even if a peak
   * has not yet been detected. This is done by adding a "write enable" to the
   * shift register control logic, as indicated. To prevent multiple burst_start
   * within a short period from continuously resetting the counter, we check to
   * make sure that the memory is not already valid.
   */

  counter #(
    .LOWER (0),
    .UPPER (BURST_LENGTH),
    .WRAPAROUND (0),
    .INIT_VALUE (BURST_LENGTH)
  ) counter_burst (
    .clk (clk),
    .rst (has_peak & ~mem_ready),
    .ena (m_axis_frame),
    .value (mem_count)
  );

  assign mem_ready = ~mem_count[WN];    // mem_count != BURST_LENGTH
  assign shift_ena = (m_axis_frame & mem_ready) |     // read enable
                     (s_axis_frame & ~mem_ready);    // write enable

  /* Master interface.
   * Since the absolute value module has its own delay, we make sure the depth
   * of the shift register is equal to the delay plus the BURST_LENGTH. This
   * way, when burst_start is asserted, the correlation data is aligned with the
   * absolute value data. Because axis_peak_detn is not meant to run at
   * exeedingly high clock speeds, the master AXI-stream is left unregistered.
   * When the counter reaches BURST_LENGTH - 1 (e.g. 31), tlast is asserted,
   * indicating that we have completed a full burst.
   */
  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (DATA_SHIFT + BURST_LENGTH),
    .USE_RAM (1)
  ) shift_reg_tdata (
    .clk (clk),
    .rst (1'b0),
    .ena (shift_ena),
    .din (mem_ready ? 'b0 : s_axis_tdata),
    .dout (m_axis_tdata)
  );

  assign m_axis_tvalid = mem_ready;
  assign m_axis_tlast = &(mem_count[WN-1:0]);

  ////////////////
  // SIMULATION //
  ////////////////

  wire    [ WI:0]   _wr_addr;
  reg     [ WB:0]   _cabs_out [0:NC];

  shift_reg #(
    .WIDTH (INDEX_WIDTH),
    .DEPTH (CABS_DELAY)
  ) shift_reg_wr_addr (
    .clk (clk),
    .rst (1'b0),
    .ena (s_axis_tvalid),
    .din (chan_idx),
    .dout (_wr_addr)
  );

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    always @(posedge clk) begin
      if (s_axis_tvalid) begin
        _cabs_out[_wr_addr] <= cabs_dout;
      end
    end
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
