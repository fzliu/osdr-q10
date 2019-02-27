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
  parameter   USE_OUTPUT_FIFO = 0,
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

  wire    [ NF:0]   fanout_valid;
  wire    [ NF:0]   fanout_ready;
  wire    [ WP:0]   fanout_data;

  // slave interface

  assign s_axis_tready = fanout_ready[s_axis_tdest];

  // master interface

  assign fanout_valid = {{NF{1'b0}}, s_axis_tvalid} << s_axis_tdest;
  assign fanout_data = {NUM_FANOUT{s_axis_tdata}};

  // assign outputs

  genvar n;
  generate
  if (USE_OUTPUT_FIFO) begin

    for (n = 0; n < NUM_FANOUT; n = n + 1) begin
      localparam i0 = n * DATA_WIDTH, i1 = i0 + WD;
      axis_fifo_async #(
        .MEMORY_TYPE (FIFO_TYPE),
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH),
        .READ_LATENCY (FIFO_LATENCY)
      ) axis_fifo_async (
        .s_axis_clk (s_axis_clk),
        .s_axis_rst (s_axis_rst),
        .m_axis_clk (m_axis_clk),
        .s_axis_tvalid (fanout_valid[n]),
        .s_axis_tready (fanout_ready[n]),
        .s_axis_tdata (fanout_data[i1:i0]),
        .m_axis_tvalid (m_axis_tvalid[n]),
        .m_axis_tready (m_axis_tready[n]),
        .m_axis_tdata (m_axis_tdata[i1:i0])
      );
    end

  end else begin

    assign fanout_ready = m_axis_tready;
    assign m_axis_tvalid = fanout_valid;
    assign m_axis_tdata = fanout_data;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
