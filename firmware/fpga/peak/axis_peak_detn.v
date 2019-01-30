////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream multi-channel peak detector. Uses a simple thresholm algorithm to
// determine peak indices.
//
// Parameters
// NUM_CHANNELS: total number of anchor channels (number of antennas)
// CHANNEL_WIDTH: total data width of each channel
// BURST_LENGTH: length around detected peaks to store samples for
// PEAK_THRESH_MULT: minimum multiplier for detected peaks, must be 2^N
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  BURST_LENGTH
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   BURST_LENGTH = 32,    // TODO(fzliu): ensure this = 2^N
  parameter   PEAK_THRESH_MULT = 8, // TODO(fzliu): ensure this = 2^N

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),
  localparam  BOXCAR_WIDTH = CHANNEL_WIDTH / 2 + COUNT_WIDTH - 1,
  localparam  PEAK_THRESH_SHIFT = log2(PEAK_THRESH_MULT - 1),

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WB = BOXCAR_WIDTH - 1

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input   [ WD:0]   s_axis_tdata_abs,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output            m_axis_tlast

);

  `include "func_log2.vh"

  // internal memories

  reg     [ WB:0]   thresh [0:NC];

  // internal registers

  reg     [ NC:0]   has_peak = 'b0;
  reg               has_peak_any_d = 'b0;

  // internal signals

  wire              burst_start;
  wire    [ WD:0]   data_abs_avg;
  wire    [ WD:0]   s_axis_tdata_abs_d;

  wire    [ WN:0]   mem_count;
  wire              mem_ready;
  wire              shift_ena;

  wire              m_axis_frame;

  /* Initialize thresholds.
   * This prevents x's from propagating through the logic during startup.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    initial begin
      thresh[n] = 'b0;
    end
  end
  endgenerate

  /* Slave interface.
   * The slave ready signal is set to a constant high value, indicating that
   * this module is always ready to process data. If a new peak is detected
   * before the existing one has been read by the downstream module, the new
   * peak is simply thrown away. This prevents the upstream modules from
   * stalling and should improve timing.
   */

  assign s_axis_tready = 1'b1;

  /* Peak detection logic.
   * The absolute value of each sample goes through a boxcar averager. If one of
   * the samples has a significantly higher value than the average of it and its
   * neighboring samples, then we have detected a peak.
   */

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (BURST_LENGTH / 2)
  ) shift_reg_data_abs (
    .clk (clk),
    .rst (1'b0),
    .ena (s_axis_tvalid),
    .din (s_axis_tdata_abs),
    .dout (s_axis_tdata_abs_d)
  );

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WB;
    filt_boxcar #(
      .DATA_WIDTH (BOXCAR_WIDTH),
      .FILTER_POWER (COUNT_WIDTH)
    ) filt_boxcar (
      .clk (clk),
      .rst (1'b0),
      .ena (s_axis_tvalid),
      .data_in (s_axis_tdata_abs[n1:n0]),
      .avg_out (data_abs_avg[n1:n0])
    );
  end
  endgenerate

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WB;
    always @(posedge clk) begin
      thresh[n] <= (data_abs_avg[n1:n0] + 1'b1) << PEAK_THRESH_SHIFT;
      has_peak[n] <= s_axis_tdata_abs_d[n1:n0] > thresh[n];
    end

  end
  endgenerate

  /* Burst start indicator.
   * When a peak is detected, burst_start will go high for a single clock cycle.
   * If a peak already exists in the output shift register, burst_start is not
   * asserted to prevent existing data from being overwritten.
   */

  always @(posedge clk) begin
    has_peak_any_d <= |has_peak;
  end

  assign burst_start = |has_peak & ~has_peak_any_d & ~mem_ready;

  /* Shift register control logic.
   * When a burst begins, we reset the counter (from a default value of 32) to
   * 0. This begins the upward counting process. This occurs each time a new
   * batch of data is framed by the master AXI-stream., and ends once the
   * counter's output value reaches BURST_LENGTH. Because a shift register is
   * not a circular buffer, we must also keep pusing data through even if a peak
   * has not yet been detected. This is done by adding a "write enable" to the
   * shift register control logic, as indicated.
   */

  counter #(
    .LOWER (0),
    .UPPER (BURST_LENGTH),
    .WRAPAROUND (0),
    .INIT_VALUE (BURST_LENGTH)
  ) counter (
    .clk (clk),
    .rst (burst_start),
    .ena (m_axis_frame),
    .value (mem_count)
  );

  assign mem_ready = ~mem_count[WN];    // mem_count != BURST_LENGTH
  assign shift_ena = (m_axis_frame & mem_ready) |     // read enable
                     (s_axis_tvalid & ~mem_ready);    // write enable

  /* Master interface.
   * Because axis_peak_detn is not meant to run at exeedingly high clock speeds,
   * the master AXI-stream is left unregistered. When the counter reaches
   * BURST_LENGTH - 1 (e.g. 31), tlast is asserted, indicating that there is no
   * more data left in the shift register.
   */
  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (BURST_LENGTH)
  ) shift_reg_data (
    .clk (clk),
    .rst (1'b0),
    .ena (shift_ena),
    .din (mem_ready ? 'b0 : s_axis_tdata),
    .dout (m_axis_tdata)
  );

  assign m_axis_tvalid = mem_ready;
  assign m_axis_tlast = &(mem_count[WN-1:0]);

  // SIMULATION

  wire      [ WC:0]   _s_axis_tdata_abs_unpack [0:NC];
  wire      [ WC:0]   _data_abs_avg_unpack [0:NC];

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign _s_axis_tdata_abs_unpack[n] = s_axis_tdata_abs[n1:n0];
    assign _data_abs_avg_unpack[n] = data_abs_avg[n1:n0];
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
