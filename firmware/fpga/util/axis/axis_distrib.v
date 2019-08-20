////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream distributor. Similar to axis_fan_out but sends the same data to
// all channels, i.e. waits for all channels to assert tready before updating
// the bus data (m_axis_tdata). Optional "ramp start" functionality is
// implemented in this module, staggers the data sent to each output channel.
//
// Parameters
// NUM_DISTRIB: number of output AXI streams, e.g. 7 if 1-7 distributor
// DATA_WIDTH: width of input data (and per-channel output data)
// USE_OUTPUT_FIFO: if 0, the output FIFO is disabled
// FIFO_TYPE: "auto", "block", or "distributed"; see Vivado templates
// FIFO_DEPTH: depth of output FIFO, if enabled
// FIFO_LATENCY: latency of output FIFO, if enabled
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  variable
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_distrib #(

  // parameters

  parameter   NUM_DISTRIB = 6,
  parameter   DATA_WIDTH = 128,
  parameter   RAMP_DELAY = 1024,
  parameter   USE_OUTPUT_FIFO = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_DEPTH = 32,
  parameter   FIFO_LATENCY = 2,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_DISTRIB * DATA_WIDTH,
  localparam  SELECT_WIDTH = log2(NUM_DISTRIB - 1),

  // bit width parameters

  localparam  ND = NUM_DISTRIB - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WS = SELECT_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output  [ ND:0]   m_axis_tvalid,
  input   [ ND:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata

);

  `include "func_log2.vh"

  // internal registers

  reg     [ ND:0]   chan_ena = 'b0;
  reg     [ ND:0]   ready_all = 'b0;

  // internal signals

  wire              s_axis_frame;

  wire              ramp_next;

  wire    [ ND:0]   distrib_frame;
  wire    [ ND:0]   distrib_valid;
  wire    [ ND:0]   distrib_ready;
  wire    [ WP:0]   distrib_data;

  /* Slave interface.
   * The output ready signal goes high only when ALL channels are ready to
   * accept new data. Although this causes one extra cycle of throughput delay,
   * there is no other way to accomplish AXI-stream distribution since at least
   * one set of flops is required to store state.
   */

  assign s_axis_frame = s_axis_tvalid & s_axis_tready;
  assign s_axis_tready = &(ready_all);

  /* Ramped, i.e. staggered start.
   * The staggered start is achieved via the use of a continuously running
   * counter.
   */

  generate
  if (RAMP_DELAY > 0) begin

    counter #(
      .LOWER (0),
      .UPPER (RAMP_DELAY - 1),
      .WRAPAROUND (1)
    ) counter (
      .clk (s_axis_clk),
      .rst (1'b0),
      .ena (1'b1),
      .at_max (ramp_next),
      .value ()
    );

    always @(posedge s_axis_clk) begin
      if (ramp_next) begin
        chan_ena <= (chan_ena << 1) + 1'b1;
      end else begin
        chan_ena <= chan_ena;
      end
    end

  end else begin

    always @* begin
      chan_ena = {NUM_DISTRIB{1'b1}};
    end

  end
  endgenerate

  /* Ready logic.
   * Whenever new data is framed from the slave AXI-stream interface, the
   * internal ready logic for all output channels goes low. These signals go
   * high again only after the master AXI-stream has accepted the data. Since
   * the downstream modules can be running at different speeds, state is stored
   * between clock cycles to denote when each downstream module has framed the
   * "current" data.
   */

  always @(posedge s_axis_clk) begin
    if (s_axis_rst | s_axis_frame) begin
      ready_all <= ~chan_ena;
    end else begin
      ready_all <= ready_all | distrib_frame;
    end
  end

  /* Master interface.
   * Mostly straightfoward. Data is provided to the downstream modules only if
   * the current data has not already been input.
   */

  assign distrib_frame = distrib_valid & distrib_ready;
  assign distrib_valid = s_axis_tvalid ? ~ready_all : 'b0;
  assign distrib_data = {NUM_DISTRIB{s_axis_tdata}};

  // assign outputs

  genvar n;
  generate
  if (USE_OUTPUT_FIFO) begin

    for (n = 0; n < NUM_DISTRIB; n = n + 1) begin
      localparam n0 = n * DATA_WIDTH;
      localparam n1 = n0 + WD;
      axis_fifo_async #(
        .MEMORY_TYPE (FIFO_TYPE),
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH),
        .READ_LATENCY (FIFO_LATENCY)
      ) axis_fifo_async (
        .s_axis_clk (s_axis_clk),
        .s_axis_rst (s_axis_rst),
        .m_axis_clk (m_axis_clk),
        .s_axis_tvalid (distrib_valid[n]),
        .s_axis_tready (distrib_ready[n]),
        .s_axis_tdata (distrib_data[n1:n0]),
        .m_axis_tvalid (m_axis_tvalid[n]),
        .m_axis_tready (m_axis_tready[n]),
        .m_axis_tdata (m_axis_tdata[n1:n0])
      );
    end

  end else begin

    assign distrib_ready = m_axis_tready;
    assign m_axis_tvalid = distrib_valid;
    assign m_axis_tdata = distrib_data;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
