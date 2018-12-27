////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream multi-channel peak detector. Uses a simple threshold
// algorithm to determine peak indices.
//
// enable  :  N/A
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 64,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESH_MULT = 8,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),
  localparam  ADDR_WIDTH = log2(BURST_LENGTH - 1),
  localparam  PEAK_THRESH_SHIFT = log2(PEAK_THRESH_MULT - 1),

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WA = ADDR_WIDTH - 1

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

  `include "log2_func.vh"

  // internal registers

  reg     [ WN:0]   mem_count = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;

  // internal signals

  wire    [ NC:0]   has_peak;
  wire    [ WD:0]   data_abs_avg;
  wire    [ WD:0]   s_axis_tdata_abs_d;

  wire              mem_ready;
  wire    [ WA:0]   mem_addr;
  wire    [ WD:0]   mem_dout;

  wire              m_axis_frame;

  // peak detection logic

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (BURST_LENGTH / 2)
  ) shift_reg (
    .clk (clk),
    .ena (1'b1),
    .din (s_axis_tdata_abs),
    .dout (s_axis_tdata_abs_d)
  );

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin : boxcar_gen
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    filt_boxcar #(
      .DATA_WIDTH (CHANNEL_WIDTH),
      .FILTER_POWER (ADDR_WIDTH)
    ) filt_boxcar (
      .clk (clk),
      .rst (1'b0),
      .ena (1'b1),
      .data_in (s_axis_tdata_abs[n1:n0]),
      .avg_out (data_abs_avg[n1:n0])
    );
  end
  endgenerate

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign has_peak[n] = (s_axis_tdata_abs_d[n1:n0] >
        (data_abs_avg[n1:n0] << PEAK_THRESH_SHIFT));
  end
  endgenerate

  // memory control logic

  assign mem_ready = (mem_count > 1'b0);
  assign mem_addr = (mem_count - 1'b1);

  always @(posedge clk) begin
    if (mem_count > 1'b0) begin
      mem_count <= mem_count - m_axis_frame;
    end else if (|has_peak) begin
      mem_count <= BURST_LENGTH;
    end else begin
      mem_count <= mem_count;
    end
  end

  // internal memory instantiation

  axis_to_mem #(
    .MEMORY_TYPE ("distributed"),
    .MEMORY_DEPTH (BURST_LENGTH),
    .DATA_WIDTH (DATA_WIDTH),
    .READ_LATENCY (0)
  ) axis_to_mem (
    .clk (clk),
    .rst (1'b0),
    .s_axis_tvalid (s_axis_tvalid & !mem_ready),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata (s_axis_tdata),
    .s_axis_tlast (1'b0),
    .addr (mem_addr),
    .dout (mem_dout)
  );

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    m_axis_tvalid_reg <= mem_ready;
    m_axis_tdata_reg <= mem_dout;
    m_axis_tlast_reg <= (mem_addr == 1'b1);
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

  // SIMULATION
  
  wire      [ WC:0]   _m_axis_tdata_unpack [0:NC];

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign _m_axis_tdata_unpack[n] = m_axis_tdata[n1:n0];
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
