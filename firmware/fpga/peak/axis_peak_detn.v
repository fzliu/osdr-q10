////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream quad-channel peak detector. Uses a simple threshold
// algorithm for now. The s_axis_tlast signal is ignored.
//
// enable  :  N/A
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   BURST_LENGTH = 32,
  parameter   CHANNEL_WIDTH = 64,
  parameter   PEAK_THRESH_MULT = 8,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),
  localparam  ADDR_WIDTH = log2(BURST_LENGTH - 1),
  localparam  PEAK_THRESH_SHIFT = log2(PEAK_THRESH_MULT - 1),

  // bit width parameters

  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WA = ADDR_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

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

  `include "log2_func.v"

  // internal registers

  reg     [ WN:0]   mem_count = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;

  // internal signals

  wire    [  3:0]   has_peak;
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
    .clk (rst),
    .ena (1'b1),
    .din (s_axis_tdata_abs),
    .dout (s_axis_tdata_abs_d)
  );

  generate
  genvar i;
  for (i = 0; i < 4; i = i + 1) begin: boxcar_gen
    localparam i0 = i * CHANNEL_WIDTH;
    localparam i1 = i0 + WC;

    filt_boxcar #(
      .DATA_WIDTH (CHANNEL_WIDTH),
      .FILTER_POWER (ADDR_WIDTH)
    ) filt_boxcar (
      .clk (clk),
      .rst (rst),
      .data_in (s_axis_tdata_abs[i1:i0]),
      .avg_out (data_abs_avg[i1:i0])
    );

    assign has_peak[i] = (s_axis_tdata_abs_d[i1:i0] >
        (data_abs_avg[i1:i0] << PEAK_THRESH_SHIFT));

  end
  endgenerate

  // memory control logic

  assign mem_ready = (mem_count > 1'b0);
  assign mem_addr = (mem_count - 1'b1);

  always @(posedge clk) begin
    if (rst) begin
      mem_count <= {COUNT_WIDTH{1'b0}};
    end else if (mem_count > 1'b0) begin
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
    .rst (rst),
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
    if (m_axis_tready) begin
      m_axis_tvalid_reg <= mem_ready;
      m_axis_tdata_reg <= mem_dout;
      m_axis_tlast_reg <= ~|mem_addr;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
      m_axis_tlast_reg <= m_axis_tlast;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
