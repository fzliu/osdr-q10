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
// latency :  0 cycles (default), FIFO_LATENCY (USE_FIFOs == 1)
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_out #(

  // parameters

  parameter   NUM_FANOUT = 6,
  parameter   DATA_WIDTH = 256,
  parameter   USE_FIFOS = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_DEPTH = 16,
  parameter   FIFO_LATENCY = 2,

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
  input   [ NF:0]   s_axis_tdest,

  // master interace

  output  [ NF:0]   m_axis_tvalid,
  input   [ NF:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata

);

  `include "func_log2.vh"

  // internal signals

  wire              fanout_valid;
  wire              fanout_ready;
  wire    [ WD:0]   fanout_data;

  // slave interface

  assign s_axis_tready = fanout_ready[s_axis_tdest];

  // master interface

  assign fanout_valid = {{NF{1'b0}}, s_axis_tvalid} << s_axis_tdest;
  assign fanout_data = {FANIN_WIDTH{s_axis_tdata}};

  // assign outputs

  generate
  if (USE_FIFOS) begin

    axis_fifo_async #(
      .MEMORY_TYPE (FIFO_TYPE),
      .DATA_WIDTH (DATA_WIDTH),
      .FIFO_DEPTH (FIFO_DEPTH),
      .READ_LATENCY (FIFO_LATENCY)
    ) axis_fifo_async (
      .s_axis_clk (s_axis_clk),
      .s_axis_rst (s_axis_rst),
      .m_axis_clk (m_axis_clk),
      .s_axis_tvalid (fanout_valid),
      .s_axis_tready (fanout_ready),
      .s_axis_tdata (fanout_data),
      .m_axis_tvalid (m_axis_tvalid),
      .m_axis_tready (m_axis_tready),
      .m_axis_tdata (m_axis_tdata)
    );

  end else begin

    assign fanout_ready = m_axis_tready;
    assign m_axis_tvalid = fanout_valid;
    assign m_axis_tdata = fanout_data;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
