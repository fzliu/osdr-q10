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

  // slave interface

  assign s_axis_tready = 1'b1;

  // peak detection logic

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

  genvar n;
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

  always @(posedge clk) begin
    has_peak_any_d <= |has_peak;
  end

  assign burst_start = |has_peak & ~has_peak_any_d & ~mem_ready;

  // control logic

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
                     (~s_axis_tvalid & ~mem_ready);   // write enable

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (BURST_LENGTH)
  ) shift_reg_data (
    .clk (clk),
    .rst (1'b0),
    .ena (shift_ena),
    .din (s_axis_tdata),
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
