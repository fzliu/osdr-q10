////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream fan-out implementation.
//
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_out #(

  // parameters

  parameter   NUM_FANOUT = 6,
  parameter   DATA_WIDTH = 256,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_FANOUT * DATA_WIDTH,
  localparam  SELECT_WIDTH = log2(NUM_FANOUT - 1),

  // bit width parameters

  localparam  NF = NUM_FANOUT - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WS = SELECT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input   [ NF:0]   s_axis_tuser,

  // master interace

  output  [ NF:0]   m_axis_tvalid,
  input   [ NF:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata

);

  `include "func_log2.vh"

  // internal registers

  reg     [ NF:0]   m_axis_tvalid_reg = 'b0;
  reg     [ WP:0]   m_axis_tdata_reg = 'b0;

  // slave interface

  assign s_axis_tready = m_axis_tready[s_axis_tuser];

  // master interface

  genvar n;
  generate
  for (n = 0; n < NUM_FANOUT; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    always @(posedge clk) begin
      if (rst | ~s_axis_tvalid | (n != s_axis_tuser)) begin
        m_axis_tvalid_reg[n] <= 'b0;
        m_axis_tdata_reg[n1:n0] <= 'b0;
      end else if ((n == s_axis_tuser) & s_axis_tready) begin
        m_axis_tvalid_reg[n] <= s_axis_tvalid;
        m_axis_tdata_reg[n1:n0] <= s_axis_tdata;
      end else begin
        m_axis_tvalid_reg[n] <= m_axis_tvalid[n];
        m_axis_tdata_reg[n1:n0] <= m_axis_tdata[n1:n0];
      end
    end
  end
  endgenerate

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
