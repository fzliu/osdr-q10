////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor top-level module. Uses bit correlation and approximate absolute value
// to perform peak detection. Detected peaks are sliced out and placed inside a
// FIFO for consumption by the microprocessor through the EBI bus.
//
// Parameters
// DEVICE: programmable logic family
// NUM_COMPUTE: number of compute modules to use
// NUM_TAGS: number of tags to support
// NUM_CHANNELS: number of RF inputs to the anchor board
// PRECISION: desired precision of the input data bus, must be <= 12
// ADDER_WIDTH: width of adders used by axis_bit_corr
// CORR_OFFSET: index of the first (zeroth) correlator to use
//
// enable  :  active-high
// reset   :  N/A
// latency :  N/A
// output  :  N/A
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top #(

  // parameters

  parameter   DEVICE = "7SERIES",
  parameter   NUM_COMPUTE = 12,
  parameter   NUM_TAGS = 48,
  parameter   NUM_CHANNELS = 4,

  parameter   PRECISION = 6,
  parameter   ADDER_WIDTH = 12,
  parameter   CORR_OFFSET = 0,

  parameter   PIPELINE_DEPTH = 3,
  parameter   USE_STALL_SIGNAL = 0,
  parameter   CABS_DELAY = 10,
  parameter   BOXCAR_DELAY = 2,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESH_MULT = 6,

  // correlator parameters

  `include "correlators.vh"

  // derived parameters

  localparam  NUM_FANOUT = NUM_TAGS / NUM_COMPUTE,

  localparam  CHANNEL_WIDTH = 2 * ADDER_WIDTH,
  localparam  SAMPS_WIDTH = 2 * PRECISION * NUM_CHANNELS,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  FANOUT_WIDTH = NUM_FANOUT * DATA_WIDTH,

  localparam  DISTRIB_WIDTH = NUM_COMPUTE * SAMPS_WIDTH,
  localparam  COMPUTE_WIDTH = NUM_COMPUTE * DATA_WIDTH,
  localparam  SWITCH_WIDTH = NUM_COMPUTE * NUM_FANOUT,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam  NM = NUM_COMPUTE - 1,
  localparam  NT = NUM_TAGS - 1,
  localparam  NF = NUM_FANOUT - 1,

  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WF = FANOUT_WIDTH - 1,

  localparam  W0 = DISTRIB_WIDTH - 1,
  localparam  W1 = COMPUTE_WIDTH - 1,
  localparam  W2 = SWITCH_WIDTH - 1,
  localparam  W3 = PACKED_WIDTH - 1

) (

  // master interface

  input             clk,
  input             ena,

  // physical interface (receive_a)

  input             a_rx_clk_in,
  input             a_rx_frame_in,
  input   [ 11:0]   a_rx_data_p0,
  input   [ 11:0]   a_rx_data_p1,

  // physical interface (receive_b)

  input             b_rx_clk_in,
  input             b_rx_frame_in,
  input   [ 11:0]   b_rx_data_p0,
  input   [ 11:0]   b_rx_data_p1,

  // physical interface (control)

  output            sync_out,
  output            a_resetb,
  output            a_enable,
  output            a_txnrx,
  output            b_resetb,
  output            b_enable,
  output            b_txnrx,

  // physical interface (spi_a)

  output            a_spi_sck,
  output            a_spi_di,
  input             a_spi_do,
  output            a_spi_cs,

  // physical interface (spi_b)

  output            b_spi_sck,
  output            b_spi_di,
  input             b_spi_do,
  output            b_spi_cs,

  // microprocessor interface (spi)

  input             spi_sck,
  input             spi_mosi,
  output            spi_miso,
  input             spi_cs_a,
  input             spi_cs_b,

  // microprocessor interface (control)

  input             reset_a,
  input             reset_b,
  input             sync_in,

  // microprocessor interface (comms)

  input             ebi_nrde,
  output  [ 15:0]   ebi_data,
  output            ebi_ready,

  // LED interface

  output  [  7:0]   led_out

);

  `define CORRS(n) CORRELATORS[(n)*CORR_LENGTH+:NUM_FANOUT*CORR_LENGTH]

  // internal signals (clock)

  wire              d_clk;    // data clock (from ad9361)
  wire              m_clk;    // main clock (moderate frequency)
  wire              c_clk;    // compute clock (high frequency)

  // internal signals (sample interface)

  wire              a_data_clk;
  wire              b_data_clk;

  wire              valid_0;
  wire    [ 11:0]   data_i0;
  wire    [ 11:0]   data_q0;
  wire              valid_1;
  wire    [ 11:0]   data_i1;
  wire    [ 11:0]   data_q1;
  wire              valid_2;
  wire    [ 11:0]   data_i2;
  wire    [ 11:0]   data_q2;
  wire              valid_3;
  wire    [ 11:0]   data_i3;
  wire    [ 11:0]   data_q3;

  wire              valid_0_sf;
  wire    [ 11:0]   data_i0_sf;
  wire    [ 11:0]   data_q0_sf;
  wire              valid_1_sf;
  wire    [ 11:0]   data_i1_sf;
  wire    [ 11:0]   data_q1_sf;
  wire              valid_2_sf;
  wire    [ 11:0]   data_i2_sf;
  wire    [ 11:0]   data_q2_sf;
  wire              valid_3_sf;
  wire    [ 11:0]   data_i3_sf;
  wire    [ 11:0]   data_q3_sf;

  // internal signals (microprocessor)

  wire              rd_ena;

  // internal signals (axi-stream)

  wire              ad9361_axis_tvalid;
  wire              ad9361_axis_tready;
  wire    [ WS:0]   ad9361_axis_tdata;

  wire    [ NM:0]   distrib_axis_tvalid;
  wire    [ NM:0]   distrib_axis_tready;
  wire    [ W0:0]   distrib_axis_tdata;

  wire    [ NM:0]   corr_axis_tvalid;
  wire    [ NM:0]   corr_axis_tready;
  wire    [ W1:0]   corr_axis_tdata;
  wire    [ W2:0]   corr_axis_tdest;

  wire    [ NT:0]   switch_axis_tvalid;
  wire    [ NT:0]   switch_axis_tready;
  wire    [ W3:0]   switch_axis_tdata;

  wire    [ NT:0]   peak_axis_tvalid;
  wire    [ NT:0]   peak_axis_tready;
  wire    [ W3:0]   peak_axis_tdata;
  wire    [ NT:0]   peak_axis_tlast;

  wire              fanin_axis_tvalid;
  wire              fanin_axis_tready;
  wire    [ WD:0]   fanin_axis_tdata;
  wire              fanin_axis_tlast;
  wire    [ NT:0]   fanin_axis_tuser;

  /* Clock generation.
   * Both AD9361's will be synchronized via the SPI bus from the MCU and the
   * sync_in signal common to both chips. We pick a_data_clk since doing so
   * seems to improve timing.
   */

  anchor_clk_gen #()
  anchor_clk_gen (
    .clk_xtal (clk),
    .clk_ad9361 (a_data_clk),
    .ena (ena),
    .m_clk (m_clk),
    .c_clk (c_clk),
    .d_clk (d_clk)
  );

  /* Synchronize external signals.
   * EBI bus's read enable signal is active-low, so we invert it before
   * synchronizing.
   */

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_rd_ena (
    .src_clk (),
    .src_in (~ebi_nrde),
    .dest_clk (c_clk),
    .dest_out (rd_ena)
  );

  /* LED control.
   * The fifth output is currently set low due to a bug in the hardware.
   */

  assign led_out[0] = valid_1;
  assign led_out[1] = valid_0;
  assign led_out[2] = valid_2;
  assign led_out[3] = valid_3;
  assign led_out[4] = 1'b0;
  assign led_out[5] = ena;
  assign led_out[6] = 1'b0;
  assign led_out[7] = ebi_ready;

  /* Receive interface (chip A).
   */

  ad9361_cmos_if #(
    .DEVICE (DEVICE),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_a (
    .clk (d_clk),
    .rx_clk_in (a_rx_clk_in),
    .rx_frame_in (a_rx_frame_in),
    .rx_data_p0 (a_rx_data_p0),
    .rx_data_p1 (a_rx_data_p1),
    .enable (a_enable),
    .txnrx (a_txnrx),
    .data_clk (a_data_clk),
    .valid_0 (valid_0),
    .data_i0 (data_i0),
    .data_q0 (data_q0),
    .valid_1 (valid_1),
    .data_i1 (data_i1),
    .data_q1 (data_q1)
  );

  /* Receive interface (chip B).
   */

  ad9361_cmos_if #(
    .DEVICE (DEVICE),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_b (
    .clk (d_clk),
    .rx_clk_in (b_rx_clk_in),
    .rx_frame_in (b_rx_frame_in),
    .rx_data_p0 (b_rx_data_p0),
    .rx_data_p1 (b_rx_data_p1),
    .enable (b_enable),
    .txnrx (b_txnrx),
    .data_clk (b_data_clk),
    .valid_0 (valid_2),
    .data_i0 (data_i2),
    .data_q0 (data_q2),
    .valid_1 (valid_3),
    .data_i1 (data_i3),
    .data_q1 (data_q3)
  );

  /* Dual SPI bus controller.
   */

  ad9361_dual_spi #()
  ad9361_dual_spi (
    .a_resetb (a_resetb),
    .a_spi_sck (a_spi_sck),
    .a_spi_di (a_spi_di),
    .a_spi_do (a_spi_do),
    .a_spi_cs (a_spi_cs),
    .b_resetb (b_resetb),
    .b_spi_sck (b_spi_sck),
    .b_spi_di (b_spi_di),
    .b_spi_do (b_spi_do),
    .b_spi_cs (b_spi_cs),
    .sync_out (sync_out),
    .reset_a (reset_a),
    .reset_b (reset_b),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b),
    .sync_in (sync_in)
  );

  /* Sample filter.
   */

  ad9361_dual_filt #(
    .ABS_WIDTH (16),
    .NUM_DELAY (22),
    .NUM_PAD_SAMPS (16),
    .DATA_PASS_VALUE (16),
    .FILTER_LENGTH (16)
  ) ad9361_dual_filt (
    .clk (d_clk),
    .valid_0_in (valid_0),
    .data_i0_in (data_i0),
    .data_q0_in (data_q0),
    .valid_1_in (valid_1),
    .data_i1_in (data_i1),
    .data_q1_in (data_q1),
    .valid_2_in (valid_2),
    .data_i2_in (data_i2),
    .data_q2_in (data_q2),
    .valid_3_in (valid_3),
    .data_i3_in (data_i3),
    .data_q3_in (data_q3),
    .valid_0_out (valid_0_sf),
    .data_i0_out (data_i0_sf),
    .data_q0_out (data_q0_sf),
    .valid_1_out (valid_1_sf),
    .data_i1_out (data_i1_sf),
    .data_q1_out (data_q1_sf),
    .valid_2_out (valid_2_sf),
    .data_i2_out (data_i2_sf),
    .data_q2_out (data_q2_sf),
    .valid_3_out (valid_3_sf),
    .data_i3_out (data_i3_sf),
    .data_q3_out (data_q3_sf)
  );

  /* Serialize data.
   * The input and master AXI-stream clocks are the same, so we set
   * INDEP_CLOCKS to zero.
   */

  ad9361_dual_axis #(
    .PRECISION (PRECISION),
    .REVERSE_DATA (0),
    .INDEP_CLOCKS (0),
    .USE_AXIS_TLAST (0),
    .USE_OUTPUT_FIFO (1),
    .FIFO_TYPE ("block"),
    .FIFO_DEPTH (32768),  //65536
    .FIFO_LATENCY (2)
  ) ad9361_dual_axis (
    .clk (d_clk),
    .valid_0 (valid_0_sf),
    .data_i0 (data_i0_sf),
    .data_q0 (data_q0_sf),
    .valid_1 (valid_1_sf),
    .data_i1 (data_i1_sf),
    .data_q1 (data_q1_sf),
    .valid_2 (valid_2_sf),
    .data_i2 (data_i2_sf),
    .data_q2 (data_q2_sf),
    .valid_3 (valid_3_sf),
    .data_i3 (data_i3_sf),
    .data_q3 (data_q3_sf),
    .m_axis_tvalid (ad9361_axis_tvalid),
    .m_axis_tready (ad9361_axis_tready),
    .m_axis_tdata (ad9361_axis_tdata),
    .m_axis_tlast ()
  );

  /* Distribute to correlators.
   * Converts master clock to data clock and distributes the data to the
   * compute modules.
   */

  axis_distrib #(
    .NUM_DISTRIB (NUM_COMPUTE),
    .DATA_WIDTH (SAMPS_WIDTH),
    .USE_OUTPUT_FIFO (1),
    .FIFO_TYPE ("block"),
    .FIFO_LATENCY (2)
  ) axis_distrib (
    .s_axis_clk (d_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (c_clk),
    .s_axis_tvalid (ad9361_axis_tvalid),
    .s_axis_tready (ad9361_axis_tready),
    .s_axis_tdata (ad9361_axis_tdata),
    .m_axis_tvalid (distrib_axis_tvalid),
    .m_axis_tready (distrib_axis_tready),
    .m_axis_tdata (distrib_axis_tdata)
  );

  /* Cross-correlation (primariy compute).
   * There are fewer compute modules than tags, so outputs are fed into a fanout
   * module which arbitrates the downstream module based on tdest.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_COMPUTE; n = n + 1) begin
    localparam n0 = n * NUM_FANOUT, n1 = n0 + NF;
    localparam i0 = n * SAMPS_WIDTH, i1 = i0 + WS;
    localparam j0 = n * DATA_WIDTH, j1 = j0 + WD;
    localparam k0 = n * NUM_FANOUT, k1 = k0 + NF;
    localparam l0 = n * FANOUT_WIDTH, l1 = l0 + WF;

    axis_bit_corr #(
      .NUM_PARALLEL (2 * NUM_CHANNELS),
      .WAVE_WIDTH (PRECISION),
      .ADDER_WIDTH (ADDER_WIDTH),
      .USE_STALL_SIGNAL (USE_STALL_SIGNAL),
      .SHIFT_DEPTH (PIPELINE_DEPTH),
      .NUM_CORRS (NUM_FANOUT),
      .CORR_LENGTH (CORR_LENGTH),
      .CORRELATORS (`CORRS(NUM_FANOUT*n+CORR_OFFSET))
    ) axis_bit_corr (
      .clk (c_clk),
      .s_axis_tvalid (distrib_axis_tvalid[n]),
      .s_axis_tready (distrib_axis_tready[n]),
      .s_axis_tdata (distrib_axis_tdata[i1:i0]),
      .m_axis_tvalid (corr_axis_tvalid[n]),
      .m_axis_tready (corr_axis_tready[n]),
      .m_axis_tdata (corr_axis_tdata[j1:j0]),
      .m_axis_tdest (corr_axis_tdest[k1:k0])
    );

    axis_fan_out #(
      .NUM_FANOUT (NUM_FANOUT),
      .DATA_WIDTH (DATA_WIDTH),
      .USE_OUTPUT_FIFO (1),
      .FIFO_TYPE ("block"),
      .FIFO_LATENCY (2)
    ) axis_fan_out (
      .s_axis_clk (c_clk),
      .s_axis_rst (1'b0),
      .m_axis_clk (m_clk),
      .s_axis_tvalid (corr_axis_tvalid[n]),
      .s_axis_tready (corr_axis_tready[n]),
      .s_axis_tdata (corr_axis_tdata[j1:j0]),
      .s_axis_tdest (corr_axis_tdest[k1:k0]),
      .m_axis_tvalid (switch_axis_tvalid[n1:n0]),
      .m_axis_tready (switch_axis_tready[n1:n0]),
      .m_axis_tdata (switch_axis_tdata[l1:l0])
    );

  end
  endgenerate

  /* Absolute value computation and peak detection.
   * To save power and improve both routability and timing, this module uses
   * the slow m_clk instead of the faster c_clk.
   */

  generate
  for (n = 0; n < NUM_TAGS; n = n + 1) begin
    localparam i0 = n * DATA_WIDTH, i1 = i0 + WD;

    axis_peak_detn #(
      .NUM_CHANNELS (NUM_CHANNELS),
      .CHANNEL_WIDTH (CHANNEL_WIDTH),
      .CABS_DELAY (CABS_DELAY),
      .BOXCAR_DELAY (BOXCAR_DELAY),
      .BURST_LENGTH (BURST_LENGTH),
      .PEAK_THRESH_MULT (PEAK_THRESH_MULT)
    ) axis_peak_detn (
      .clk (m_clk),
      .s_axis_tvalid (switch_axis_tvalid[n]),
      .s_axis_tready (switch_axis_tready[n]),
      .s_axis_tdata (switch_axis_tdata[i1:i0]),
      .m_axis_tvalid (peak_axis_tvalid[n]),
      .m_axis_tready (peak_axis_tready[n]),
      .m_axis_tdata (peak_axis_tdata[i1:i0]),
      .m_axis_tlast (peak_axis_tlast[n])
    );

  end
  endgenerate

  /* AXI-stream fan in.
   * There is no need for clock conversion, so a FIFO at the output is
   * unnecessary.
   */

  axis_fan_in #(
    .NUM_FANIN (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH),
    .USE_AXIS_TLAST (1),
    .USE_OUTPUT_FIFO (0)
  ) axis_fan_in (
    .s_axis_clk (m_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (),
    .s_axis_tvalid (peak_axis_tvalid),
    .s_axis_tready (peak_axis_tready),
    .s_axis_tdata (peak_axis_tdata),
    .s_axis_tlast (peak_axis_tlast),
    .m_axis_tvalid (fanin_axis_tvalid),
    .m_axis_tready (fanin_axis_tready),
    .m_axis_tdata (fanin_axis_tdata),
    .m_axis_tlast (fanin_axis_tlast),
    .m_axis_tuser (fanin_axis_tuser)
  );

  /* Microprocessor interface.
   * To save compute resources, use block RAM instead of distributed RAM.
   */

  buf_peak_data #(
    .NUM_TAGS (NUM_TAGS),
    .NUM_CHANNELS (NUM_CHANNELS),
    .CHANNEL_WIDTH (CHANNEL_WIDTH),
    .FIFO_DEPTH (32),
    .READ_WIDTH (12),  //12
    .MEMORY_TYPE ("block")
  ) buf_peak_data (
    .wr_clk (m_clk),
    .rd_clk (c_clk),
    .s_axis_tvalid (fanin_axis_tvalid),
    .s_axis_tready (fanin_axis_tready),
    .s_axis_tdata (fanin_axis_tdata),
    .s_axis_tlast (fanin_axis_tlast),
    .s_axis_tuser (fanin_axis_tuser),
    .rd_ena (rd_ena),
    .rd_ready (ebi_ready),
    .rd_data (ebi_data)
  );

endmodule
