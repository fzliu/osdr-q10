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
  input             s_axis_tlast,

  // master interace

  output  [ NF:0]   m_axis_tvalid,
  input   [ NF:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata,
  output  [ NF:0]   m_axis_tlast

);

  `include "log2_func.v"

  // internal registers

  reg     [ NF:0]   m_axis_tvalid_reg;
  reg     [ WP:0]   m_axis_tdata_reg;
  reg     [ NF:0]   m_axis_tlast_reg;

  // slave interface

  assign s_axis_tready = m_axis_tready[s_axis_tuser];

  // master interface

  generate
  genvar i;
  for (i = 0; i < NUM_FANOUT; i = i + 1) begin : fanout_gen
    localparam i0 = i * DATA_WIDTH;
    localparam i1 = i * DATA_WIDTH + WD;
    always @(posedge clk) begin
      if (rst | ~s_axis_tvalid | (i != s_axis_tuser)) begin
        m_axis_tvalid_reg[i] <= 'b0;
        m_axis_tdata_reg[i1:i0] <= 'b0;
        m_axis_tlast_reg[i] <= 'b0;
      end else if ((i == s_axis_tuser) & s_axis_tready) begin
        m_axis_tvalid_reg[i] <= s_axis_tvalid;
        m_axis_tdata_reg[i1:i0] <= s_axis_tdata;
        m_axis_tlast_reg[i] <= s_axis_tlast;
      end else begin
        m_axis_tvalid_reg[i] <= m_axis_tvalid[i];
        m_axis_tdata_reg[i1:i0] <= m_axis_tdata[i1:i0];
        m_axis_tlast_reg[i] <= m_axis_tlast[i];
      end
    end
  end
  endgenerate

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
