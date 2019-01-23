////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream fan-out implementation. Unless a FIFO is used, this is a purely
// combinational block.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  0 cycles
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_out #(

  // parameters

  parameter   NUM_FANOUT = 6,
  parameter   DATA_WIDTH = 256,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_FANOUT * DATA_WIDTH,

  // bit width parameters

  localparam  NF = NUM_FANOUT - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,

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

  // slave interface

  assign s_axis_tready = m_axis_tready[s_axis_tuser];

  // master interface

  assign m_axis_tvalid = {{NF{1'b0}}, s_axis_tvalid} << s_axis_tuser;
  assign m_axis_tdata = {FANIN_WIDTH{s_axis_tdata}};

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
