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
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESH_MULT = 8,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),
  localparam  ADDR_WIDTH = log2(BURST_LENGTH - 1),
  localparam  BOXCAR_WIDTH = CHANNEL_WIDTH / 2 + ADDR_WIDTH - 1,
  localparam  PEAK_THRESH_SHIFT = log2(PEAK_THRESH_MULT - 1),

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WA = ADDR_WIDTH - 1,
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

  reg               mem_ready = 'b0;
  reg               has_new_data = 'b0;
  reg               has_new_data_d = 'b0;
  reg               has_last_data = 'b0;
  reg               has_last_data_d = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;

  // internal signals

  wire              burst_start;
  wire    [ WD:0]   data_abs_avg;
  wire    [ WD:0]   s_axis_tdata_abs_d;

  wire    [ WA:0]   mem_addr;
  wire              mem_valid;

  wire              m_axis_frame;

  // peak detection logic

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (BURST_LENGTH / 2)
  ) shift_reg_data (
    .clk (clk),
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
      .FILTER_POWER (ADDR_WIDTH)
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

  // memory control logic

  counter #(
    .LOWER (0),
    .UPPER (BURST_LENGTH - 1),
    .WRAPAROUND (1)
  ) counter (
    .clk (clk),
    .rst (burst_start),
    .ena (mem_ready & m_axis_frame),
    .value (mem_addr)
  );

  always @(posedge clk) begin
    if (has_last_data) begin
      mem_ready <= 1'b0;
    end else if (burst_start) begin
      mem_ready <= 1'b1;
    end else begin
      mem_ready <= mem_ready;
    end
  end

  always @(posedge clk) begin
    if (mem_ready & m_axis_frame) begin
      has_new_data <= 1'b1;
      has_last_data <= &(mem_addr + 1'b1);
    end else if (burst_start) begin
      has_new_data <= 1'b1;
      has_last_data <= 1'b0;
    end else begin
      has_new_data <= 1'b0;
      has_last_data <= 1'b0;
    end
  end

  always @(posedge clk) begin
    has_new_data_d <= has_new_data;
    has_last_data_d <= has_last_data;
  end

  // internal memory instantiation

  axis_to_mem #(
    .MEMORY_TYPE ("block"),
    .MEMORY_DEPTH (BURST_LENGTH),
    .DATA_WIDTH (DATA_WIDTH),
    .READ_LATENCY (2)
  ) axis_to_mem (
    .clk (clk),
    .rst (1'b0),
    .s_axis_tvalid (s_axis_tvalid & !mem_ready),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata (s_axis_tdata),
    .s_axis_tlast (1'b0),
    .addr (mem_addr),
    .valid (mem_valid),   // ignore this signal
    .data (m_axis_tdata)
  );

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_frame) begin
      m_axis_tvalid_reg <= 1'b0;
      m_axis_tlast_reg <= 1'b0;
    end else if (has_new_data_d) begin
      m_axis_tvalid_reg <= 1'b1;
      m_axis_tlast_reg <= has_last_data_d;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tlast_reg <= m_axis_tlast;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

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
