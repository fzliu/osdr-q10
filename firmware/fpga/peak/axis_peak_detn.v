////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream quad-channel peak detector. Uses a simple threshold
// algorithm for now. The s_axis_tlast signal is ignored.
//
// enable  :  N/A
// reset   :  active-high
// latency :  2 cycles
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_detn #(

  // parameters

  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESHOLD = 65536,
  parameter   CHANNEL_WIDTH = 64,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  COUNT_WIDTH = log2(BURST_LENGTH),

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  WC = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input   [ WD:0]   s_axis_tdata_abs,
  input             s_axis_tlast,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output            m_axis_tlast

);

  `include "log2_func.v"

  // internal registers

  reg     [ WC:0]   m_axis_count = 'b0;
  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;
  reg     [  3:0]   has_peak;

  // internal signals

  wire    [ WD:0]   s_axis_tdata_d;
  wire              m_axis_frame;

  // absval peak condition

  generate
  genvar i;
  for (i = 0; i < 4; i = i + 1) begin : has_peak_gen
    localparam i0 = i * CHANNEL_WIDTH;
    localparam i1 = i * CHANNEL_WIDTH + WC;

    always @(posedge clk) begin
      if (s_axis_tvalid) begin
        has_peak[i] <= (s_axis_tdata_abs[i1:i0] > PEAK_THRESHOLD);
      end else begin
        has_peak[i] <= 'b0;
      end
    end

  end
  endgenerate

  // slave interface

  assign s_axis_tready = m_axis_tready;

  shift_reg #(
    .WIDTH (256),
    .DEPTH (BURST_LENGTH / 2)
  ) shift_reg (
    .clk (clk),
    .ena (s_axis_tvalid),
    .din (s_axis_tdata),
    .dout (s_axis_tdata_d)
  );

  // internal counter

  always @(posedge clk) begin
    if (rst) begin
      m_axis_count <= 'b0;
    end else if (|has_peak) begin
      m_axis_count <= BURST_LENGTH;
    end else if (|m_axis_count & m_axis_frame) begin
      m_axis_count <= m_axis_count - 1'b1;
    end else begin
      m_axis_count <= m_axis_count;
    end
  end

  // master (internal) interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_tready) begin
      m_axis_tvalid_reg <= s_axis_tvalid & |m_axis_count;
      m_axis_tdata_reg <= s_axis_tdata_d;
      m_axis_tlast_reg <= (m_axis_count == 1'b1);
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
