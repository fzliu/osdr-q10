////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream fan-in implementation. The relevant input channel is stored in
// m_axis_tdest. Preference is given to earlier (MSB) input channels.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_in #(

  // parameters

  parameter   NUM_FANIN = 6,
  parameter   DATA_WIDTH = 128,
  parameter   USE_AXIS_TLAST = 1,
  parameter   USE_OUTPUT_FIFO = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_DEPTH = 32,
  parameter   FIFO_LATENCY = 2,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_FANIN * DATA_WIDTH,
  localparam  EXTRA_BIT = (USE_AXIS_TLAST != 0),

  // bit width parameters

  localparam  NF = NUM_FANIN - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,   // unused if USE_FIFOs == 0

  // slave interface

  input   [ NF:0]   s_axis_tvalid,
  output  [ NF:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,
  input   [ NF:0]   s_axis_tlast,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output            m_axis_tlast,
  output  [ NF:0]   m_axis_tdest

);

  `include "func_log2.vh"

  // internal registers

  reg               is_active = 'b0;
  reg     [ NF:0]   chan_num = 'b0;

  // internal signals

  wire    [ WD:0]   s_axis_tdata_unpack [0:NF];

  wire    [ NF:0]   prio_num;
  wire              chan_valid;

  wire              fanin_valid;
  wire              fanin_ready;
  wire    [ WD:0]   fanin_data;
  wire              fanin_last;
  wire    [ NF:0]   fanin_dest;

  /* Slave interface.
   * We unpack input data for ease of use later on. The ready signal is asserted
   * only for the current active channel.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  assign s_axis_tready = {{NF{1'b0}}, fanin_ready} << chan_num;

  /* Channel prioritizer.
   * When one of the input valid signals goes high, it instantly acquires
   * priority. If it and other valid signals are asserted on the same clock
   * cycle, priority is given to the channel corresponding to the most
   * significant asserted valid.
   */

  oh_to_bin #(
    .WIDTH_IN (NUM_FANIN),
    .WIDTH_OUT (NUM_FANIN)
  ) oh_to_bin (
    .oh (s_axis_tvalid),
    .bin (prio_num)
  );

  /* AXI-stream tlast logic.
   * This module supports two modes of operation:
   * 1) wait for tlast to be asserted on current channel, and
   * 2) arbitrate on tvalid at all times.
   * These two cases are described below.
   */

  generate
  if (USE_AXIS_TLAST) begin

    /* Case 1: use tlast.
     * In this case, keep the current channel until tlast goes high.
     */

    always @(posedge s_axis_clk) begin
      casez ({s_axis_rst, fanin_last, fanin_valid})
        3'b1??: is_active <= 1'b0;
        3'b011: is_active <= ~fanin_ready;
        3'b001: is_active <= 1'b1;
        default: is_active <= is_active;
      endcase
    end

    /* Channel selector.
     * Active channels retain priority. If no channel is currently active, this
     * module will default to the one with the highest priority.
     */

    always @(posedge s_axis_clk) begin
      casez ({s_axis_rst, is_active})
        2'b1?: chan_num <= 'b0;
        2'b01: chan_num <= chan_num;
        default: chan_num <= prio_num;
      endcase
    end

  end else begin

    /* Case 2: do not use tlast.
     * The channel number defaults to the one with the highest priority. This
     * module may bounce back-and-forth between channels if tlast is not used.
     */

    always @* begin
      chan_num = prio_num;
    end

  end
  endgenerate

  // master interface

  assign fanin_valid = s_axis_tvalid[chan_num];
  assign fanin_data = s_axis_tdata_unpack[chan_num];
  assign fanin_dest = chan_num;

  generate
  if (USE_AXIS_TLAST) begin
    assign fanin_last = s_axis_tlast[chan_num];
  end
  endgenerate

  // assign outputs

  generate
  if (USE_OUTPUT_FIFO) begin

    axis_fifo_async #(
      .MEMORY_TYPE (FIFO_TYPE),
      .DATA_WIDTH (DATA_WIDTH + NUM_FANIN + EXTRA_BIT),
      .FIFO_DEPTH (FIFO_DEPTH),
      .READ_LATENCY (FIFO_LATENCY)
    ) axis_fifo_async (
      .s_axis_clk (s_axis_clk),
      .s_axis_rst (s_axis_rst),
      .m_axis_clk (m_axis_clk),
      .s_axis_tvalid (fanin_valid),
      .s_axis_tready (fanin_ready),
      .s_axis_tdata ({fanin_last,   // EXTRA_BIT == 0 ? truncated :
                      fanin_data,
                      fanin_dest}),
      .m_axis_tvalid (m_axis_tvalid),
      .m_axis_tready (m_axis_tready),
      .m_axis_tdata ({m_axis_tlast,
                      m_axis_tdata,
                      m_axis_tdest})
    );

  end else begin

    assign fanin_ready = m_axis_tready;
    assign m_axis_tvalid = fanin_valid;
    assign m_axis_tdata = fanin_data;
    assign m_axis_tlast = fanin_last;
    assign m_axis_tdest = fanin_dest;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
