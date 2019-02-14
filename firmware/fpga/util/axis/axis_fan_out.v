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
  parameter   USE_FIFO = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_DEPTH = 32,
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
  wire    [ NF:0]   fanout_dest;

  /* Assign inputs.
   * If a FIFO is not requested, directly assign inputs to s_axis.
   */

  generate
  if (USE_FIFO) begin

    axis_fifo_async #(
      .MEMORY_TYPE (FIFO_TYPE),
      .DATA_WIDTH (DATA_WIDTH + NUM_FANOUT),
      .FIFO_DEPTH (FIFO_DEPTH),
      .READ_LATENCY (FIFO_LATENCY)
    ) axis_fifo_async (
      .s_axis_clk (s_axis_clk),
      .s_axis_rst (s_axis_rst),
      .m_axis_clk (m_axis_clk),
      .s_axis_tvalid (s_axis_tvalid),
      .s_axis_tready (s_axis_tready),
      .s_axis_tdata ({s_axis_tdata,
                      s_axis_tdest}),
      .m_axis_tvalid (fanout_valid),
      .m_axis_tready (fanout_ready),
      .m_axis_tdata ({fanout_data,
                      fanout_dest})
    );

  end else begin

    assign s_axis_tready = fanout_ready;
    assign fanout_valid = s_axis_tvalid;
    assign fanout_data = s_axis_tdata;

  end
  endgenerate

  /* Slave interface
   *
   */

  assign fanout_ready = m_axis_tready[fanout_dest];

  /* Master interface
   *
   */

  assign m_axis_tvalid = {{NF{1'b0}}, fanout_valid} << fanout_dest;
  assign m_axis_tdata = {NUM_FANOUT{fanout_data}};

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
