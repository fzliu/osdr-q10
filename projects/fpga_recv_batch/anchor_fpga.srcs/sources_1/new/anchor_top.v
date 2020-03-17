////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor top-level module.
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  N/A
// output  :  N/A
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top (

  // master interface

  input             clk,

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

  // internal signals

  wire              rd_clk;
  wire              wr_clk;

  wire              rd_ena;

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

  wire              samp_valid;
  wire              samp_ready;
  wire    [127:0]   samp_data;

  // clock generation

  anchor_clk_gen #()
  anchor_clk_gen (
    .clk (a_data_clk),
    .rd_clk (rd_clk),
    .wr_clk (wr_clk)
  );

  /* Synchronize external signals.
   * EBI bus's read enable signal is active-low, so we invert it before
   * synchronizing.
   */

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_nrde (
    .src_in (~ebi_nrde),
    .dest_clk (rd_clk),
    .dest_out (rd_ena)
  );

  /* Receive interface (chip A).
   */

  ad9361_cmos_if #(
    .DEVICE ("7SERIES"),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_a (
    .clk (wr_clk),
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
    .DEVICE ("7SERIES"),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_b (
    .clk (wr_clk),
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
    .clk (wr_clk),
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
   * To ensure that the bit correlators are always active, CONTINUOUS_DATA may
   * be set to 1.
   */

  ad9361_dual_axis #(
    .PRECISION (16),
    .REVERSE_DATA (0),
    .USE_AXIS_TLAST (1),
    .USE_OUTPUT_FIFO (0),
    .CONTINUOUS_DATA (0)
  ) ad9361_dual_axis (
    .clk (wr_clk),
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
    .m_axis_tvalid (samp_valid),
    .m_axis_tready (samp_ready),
    .m_axis_tdata (samp_data),
    .m_axis_tlast ()
  );

  assign sync_out = sync_in;

  /* Sample buffer.
   */

  buf_samp_data #(
    .FIFO_DEPTH (65536),
    .WRITE_WIDTH (128),
    .READ_WIDTH (16)
  ) buf_samp_data (
    .wr_clk (wr_clk),
    .rd_clk (rd_clk),
    .s_axis_tvalid (samp_valid),
    .s_axis_tready (samp_ready),
    .s_axis_tdata (samp_data),
    .rd_ena (rd_ena),
    .rd_ready (ebi_ready),
    .rd_data (ebi_data)
  );

  /* Assign LED outputs.
   * For debugging only.
   */

  assign led_out[0] = samp_valid;
  assign led_out[1] = rd_ena;

endmodule
