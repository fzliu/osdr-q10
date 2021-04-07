////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// OSDR Q10 top-level module.
//
// Parameters
//
// Signals
// enable  :  active-high
// reset   :  N/A
// latency :  N/A
// output  :  N/A
//
////////////////////////////////////////////////////////////////////////////////

module osdr_q10_top #(

  parameter   DATA_CLOCK_PERIOD = 6.060,
  parameter   DATA_CLOCK_MULT = 8,
  parameter   DATA_CLOCK_DIVIDE = 8,
  parameter   DATA_CLOCK_PHASE_A = -112.500,
  parameter   DATA_CLOCK_PHASE_B = -118.125

) (

  // oscillator clock

  input             ref_clk,

  // physical interface (chip A)

  output            a_fb_clk_p,
  output            a_fb_clk_n,
  output            a_tx_frame_p,
  output            a_tx_frame_n,
  output  [  5:0]   a_tx_data_p,
  output  [  5:0]   a_tx_data_n,

  input             a_data_clk_p,
  input             a_data_clk_n,
  input             a_rx_frame_p,
  input             a_rx_frame_n,
  input   [  5:0]   a_rx_data_p,
  input   [  5:0]   a_rx_data_n,

  // physical interface (chip B)

  output            b_fb_clk_p,
  output            b_fb_clk_n,
  output            b_tx_frame_p,
  output            b_tx_frame_n,
  output  [  5:0]   b_tx_data_p,
  output  [  5:0]   b_tx_data_n,

  input             b_data_clk_p,
  input             b_data_clk_n,
  input             b_rx_frame_p,
  input             b_rx_frame_n,
  input   [  5:0]   b_rx_data_p,
  input   [  5:0]   b_rx_data_n,

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

  input   [ 14:0]   ebi_addr,
  input             ebi_clk,
  input             ebi_nrde,
  input             ebi_nwre,
  inout   [ 15:0]   ebi_data,
 // output            ebi_ready,

  // USB 3.0 FIFO interface

  input             usb_clk,
  inout   [ 15:0]   usb_adbus,
  inout   [  1:0]   usb_be,
  input             usb_rxf_n,
  input             usb_txe_n,
  output            usb_rd_n,
  output            usb_wr_n,
  output            usb_oe_n,
  
  // LED interface

  output  [  7:0]   led_out

);

  // internal signals (core)

  wire              d_clk_a;  // data clock (AD9361_A)
  wire              d_clk_b;  // data clock (AD9361_B)
  wire              c_clk;    // compute clock
  wire              u_clk;    // USB clock

  wire              c_rst;
  wire              u_rst;

  wire              lock_a;
  wire              lock_b;

  wire    [  3:0]   act_chan;

  // internal signals (clock config)

  wire              cfg_rst;

  wire              cfg_ena_a;
  wire              cfg_wen_a;
  wire    [  6:0]   cfg_addr_a;
  wire    [ 31:0]   cfg_wdata_a;
  wire    [ 31:0]   cfg_rdata_a;
  wire              cfg_rdy_a;

  wire              cfg_ena_b;
  wire              cfg_wen_b;
  wire    [  6:0]   cfg_addr_b;
  wire    [ 31:0]   cfg_wdata_b;
  wire    [ 31:0]   cfg_rdata_b;
  wire              cfg_rdy_b;

  // internal signals (data interface)

  wire    [ 11:0]   tx_data_i0;
  wire    [ 11:0]   tx_data_q0;
  wire    [ 11:0]   tx_data_i1;
  wire    [ 11:0]   tx_data_q1;
  wire    [ 11:0]   tx_data_i2;
  wire    [ 11:0]   tx_data_q2;
  wire    [ 11:0]   tx_data_i3;
  wire    [ 11:0]   tx_data_q3;

  wire    [ 11:0]   rx_data_i0;
  wire    [ 11:0]   rx_data_q0;
  wire    [ 11:0]   rx_data_i1;
  wire    [ 11:0]   rx_data_q1;
  wire    [ 11:0]   rx_data_i2;
  wire    [ 11:0]   rx_data_q2;
  wire    [ 11:0]   rx_data_i3;
  wire    [ 11:0]   rx_data_q3;

  // internal signals (sample data)

  wire    [ 11:0]   rx_samp_i0;
  wire    [ 11:0]   rx_samp_q0;
  wire    [ 11:0]   rx_samp_i1;
  wire    [ 11:0]   rx_samp_q1;
  wire    [ 11:0]   rx_samp_i2;
  wire    [ 11:0]   rx_samp_q2;
  wire    [ 11:0]   rx_samp_i3;
  wire    [ 11:0]   rx_samp_q3;

  wire    [ 11:0]   tx_samp_i0;
  wire    [ 11:0]   tx_samp_q0;
  wire    [ 11:0]   tx_samp_i1;
  wire    [ 11:0]   tx_samp_q1;
  wire    [ 11:0]   tx_samp_i2;
  wire    [ 11:0]   tx_samp_q2;
  wire    [ 11:0]   tx_samp_i3;
  wire    [ 11:0]   tx_samp_q3;

  // internal signals (data bus)

  wire              tx_done_a;
  wire              tx_done_b;
  wire              rx_done_a;
  wire              rx_done_b;

  wire              tx_done;
  wire              rx_done;

  // internal signals (FIFO interface)

  wire              usb_val_out;
  wire              usb_rdy_out;
  wire    [ 15:0]   usb_data_out;

  wire              usb_val_in;
  wire              usb_rdy_in;
  wire    [ 15:0]   usb_data_in;

  // internal signals (host interface)

  wire              usb_rx_val;
  wire              usb_rx_rdy;
  wire    [ 15:0]   usb_rx_data;

  wire              usb_tx_val;
  wire              usb_tx_rdy;
  wire    [ 15:0]   usb_tx_data;

  /* Clock and reset generation.
   * Both AD9361's will be synchronized via the SPI bus from the MCU and the
   * sync_in signal common to both chips.
   */

  osdr_q10_clk_gen #()
  osdr_q10_clk_gen (
    .ref_clk (ref_clk),
    .ebi_clk (ebi_clk),
    .usb_clk (usb_clk),
    .r_clk (r_clk),
    .c_clk (c_clk),
    .u_clk (u_clk),
    .rdy ()
  );

  xpm_cdc_pulse #(
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .REG_OUTPUT (0),
    .RST_USED (0),
    .SIM_ASSERT_CHK (1)
  ) xpm_cdc_pulse_u_rst (
    .src_clk (c_clk),
    .src_rst (),
    .src_pulse (c_rst),
    .dest_clk (u_clk),
    .dest_rst (),
    .dest_pulse (u_rst)
  );

  /* Chip A interface.
   */

  ad9361_lvds_if #(
    .CLOCK_PERIOD (DATA_CLOCK_PERIOD),
    .CLOCK_MULT (DATA_CLOCK_MULT),
    .CLOCK_DIVIDE (DATA_CLOCK_DIVIDE),
    .CLOCK_PHASE (DATA_CLOCK_PHASE_A),
    .ENABLE_ODELAY (0),
    .ENABLE_IDELAY (0),
    .ODELAY_CLOCK (0),
    .ODELAY_FRAME (0),
    .ODELAY_DATA (0),
    .IDELAY_CLOCK (0),  //5
    .IDELAY_FRAME (0),
    .IDELAY_DATA (0)
  ) ad9361_lvds_if_a (
    .rst (cfg_rst),
    .fb_clk_p (a_fb_clk_p),
    .fb_clk_n (a_fb_clk_n),
    .tx_frame_p (a_tx_frame_p),
    .tx_frame_n (a_tx_frame_n),
    .tx_data_p (a_tx_data_p),
    .tx_data_n (a_tx_data_n),
    .data_clk_p (a_data_clk_p),
    .data_clk_n (a_data_clk_n),
    .rx_frame_p (a_rx_frame_p),
    .rx_frame_n (a_rx_frame_n),
    .rx_data_p (a_rx_data_p),
    .rx_data_n (a_rx_data_n),
    .enable (a_enable),
    .txnrx (a_txnrx),
    .cfg_clk (c_clk),
    .cfg_ena (cfg_ena_a),
    .cfg_wen (cfg_wen_a),
    .cfg_addr (cfg_addr_a),
    .cfg_wdata (cfg_wdata_a),
    .cfg_rdata (cfg_rdata_a),
    .cfg_rdy (cfg_rdy_a),
    .d_clk (d_clk_a),
    .lock (lock_a),
    .tx_done (tx_done_a),
    .tx_data_i0 (tx_data_i0),
    .tx_data_q0 (tx_data_q0),
    .tx_data_i1 (tx_data_i1),
    .tx_data_q1 (tx_data_q1),
    .rx_done (rx_done_a),
    .rx_data_i0 (rx_data_i0),
    .rx_data_q0 (rx_data_q0),
    .rx_data_i1 (rx_data_i1),
    .rx_data_q1 (rx_data_q1)
  );

  /* Chip B interface.
   */

  ad9361_lvds_if #(
    .CLOCK_PERIOD (DATA_CLOCK_PERIOD),
    .CLOCK_MULT (DATA_CLOCK_MULT),
    .CLOCK_DIVIDE (DATA_CLOCK_DIVIDE),
    .CLOCK_PHASE (DATA_CLOCK_PHASE_B),
    .ENABLE_ODELAY (0),
    .ENABLE_IDELAY (0),
    .ODELAY_CLOCK (0),
    .ODELAY_FRAME (0),
    .ODELAY_DATA (0),
    .IDELAY_CLOCK (0),  //2
    .IDELAY_FRAME (0),
    .IDELAY_DATA (0)
  ) ad9361_lvds_if_b (
    .rst (cfg_rst),
    .fb_clk_p (b_fb_clk_p),
    .fb_clk_n (b_fb_clk_n),
    .tx_frame_p (b_tx_frame_p),
    .tx_frame_n (b_tx_frame_n),
    .tx_data_p (b_tx_data_p),
    .tx_data_n (b_tx_data_n),
    .data_clk_p (b_data_clk_p),
    .data_clk_n (b_data_clk_n),
    .rx_frame_p (b_rx_frame_p),
    .rx_frame_n (b_rx_frame_n),
    .rx_data_p (b_rx_data_p),
    .rx_data_n (b_rx_data_n),
    .enable (b_enable),
    .txnrx (b_txnrx),
    .cfg_clk (c_clk),
    .cfg_ena (cfg_ena_b),
    .cfg_wen (cfg_wen_b),
    .cfg_addr (cfg_addr_b),
    .cfg_wdata (cfg_wdata_b),
    .cfg_rdata (cfg_rdata_b),
    .cfg_rdy (cfg_rdy_b),
    .d_clk (d_clk_b),
    .lock (lock_b),
    .tx_done (tx_done_b),
    .tx_data_i0 (tx_data_i2),
    .tx_data_q0 (tx_data_q2),
    .tx_data_i1 (tx_data_i3),
    .tx_data_q1 (tx_data_q3),
    .rx_done (rx_done_b),
    .rx_data_i0 (rx_data_i2),
    .rx_data_q0 (rx_data_q2),
    .rx_data_i1 (rx_data_i3),
    .rx_data_q1 (rx_data_q3)
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
    .reset_a (reset_a),
    .reset_b (reset_b),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b)
  );

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .SIM_ASSERT_CHK (1),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_sync_out (
    .src_clk (),
    .src_in (sync_in),
    .dest_clk (r_clk),
    .dest_out (sync_out)
  );

  /* Chip A FIFOs.
   */

  axis_fifo_async #(
    .MEMORY_TYPE ("distributed"),
    .DATA_WIDTH (48),
    .READ_WIDTH (),
    .FIFO_DEPTH (16)
  ) axis_fifo_async_a_tx (
    .s_axis_clk (c_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (d_clk_a),
    .s_axis_tvalid (1'b1),
    .s_axis_tready (tx_done),
    .s_axis_tdata ({tx_samp_i0, tx_samp_q0, tx_samp_i1, tx_samp_q1}),
    .m_axis_tvalid (),
    .m_axis_tready (tx_done_a),
    .m_axis_tdata ({tx_data_i0, tx_data_q0, tx_data_i1, tx_data_q1})
  );

  axis_fifo_async #(
    .MEMORY_TYPE ("distributed"),
    .DATA_WIDTH (48),
    .READ_WIDTH (),
    .FIFO_DEPTH (16)
  ) axis_fifo_async_a_rx (
    .s_axis_clk (d_clk_a),
    .s_axis_rst (1'b0),
    .m_axis_clk (c_clk),
    .s_axis_tvalid (rx_done_a),
    .s_axis_tready (),
    .s_axis_tdata ({rx_data_i0, rx_data_q0, rx_data_i1, rx_data_q1}),
    .m_axis_tvalid (rx_done),
    .m_axis_tready (1'b1),
    .m_axis_tdata ({rx_samp_i0, rx_samp_q0, rx_samp_i1, rx_samp_q1})
  );

  /* Chip B FIFOs.
   */

  axis_fifo_async #(
    .MEMORY_TYPE ("distributed"),
    .DATA_WIDTH (48),
    .READ_WIDTH (),
    .FIFO_DEPTH (16)
  ) axis_fifo_async_b_tx (
    .s_axis_clk (c_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (d_clk_b),
    .s_axis_tvalid (1'b1),
    .s_axis_tready (),
    .s_axis_tdata ({tx_samp_i2, tx_samp_q2, tx_samp_i3, tx_samp_q3}),
    .m_axis_tvalid (),
    .m_axis_tready (tx_done_b),
    .m_axis_tdata ({tx_data_i2, tx_data_q2, tx_data_i3, tx_data_q3})
  );

  axis_fifo_async #(
    .MEMORY_TYPE ("distributed"),
    .DATA_WIDTH (48),
    .READ_WIDTH (),
    .FIFO_DEPTH (16)
  ) axis_fifo_async_b_rx (
    .s_axis_clk (d_clk_b),
    .s_axis_rst (1'b0),
    .m_axis_clk (c_clk),
    .s_axis_tvalid (rx_done_b),
    .s_axis_tready (),
    .s_axis_tdata ({rx_data_i2, rx_data_q2, rx_data_i3, rx_data_q3}),
    .m_axis_tvalid (),  //rx_done_slave
    .m_axis_tready (1'b1),
    .m_axis_tdata ({rx_samp_i2, rx_samp_q2, rx_samp_i3, rx_samp_q3})
  );

  /* Core control module.
   */

  osdr_q10_ctrl #()
  osdr_q10_ctrl (
    .clk (c_clk),
    .cfg_rst (cfg_rst),
    .cfg_ena_a (cfg_ena_a),
    .cfg_wen_a (cfg_wen_a),
    .cfg_addr_a (cfg_addr_a),
    .cfg_wdata_a (cfg_wdata_a),
    .cfg_rdata_a (cfg_rdata_a),
    .cfg_rdy_a (cfg_rdy_a),
    .cfg_ena_b (cfg_ena_b),
    .cfg_wen_b (cfg_wen_b),
    .cfg_addr_b (cfg_addr_b),
    .cfg_wdata_b (cfg_wdata_b),
    .cfg_rdata_b (cfg_rdata_b),
    .cfg_rdy_b (cfg_rdy_b),
    .tx_done (tx_done),
    .tx_data_i0 (tx_samp_i0),
    .tx_data_q0 (tx_samp_q0),
    .tx_data_i1 (tx_samp_i1),
    .tx_data_q1 (tx_samp_q1),
    .tx_data_i2 (tx_samp_i2),
    .tx_data_q2 (tx_samp_q2),
    .tx_data_i3 (tx_samp_i3),
    .tx_data_q3 (tx_samp_q3),
    .rx_done (rx_done),
    .rx_data_i0 (rx_samp_i0),
    .rx_data_q0 (rx_samp_q0),
    .rx_data_i1 (rx_samp_i1),
    .rx_data_q1 (rx_samp_q1),
    .rx_data_i2 (rx_samp_i2),
    .rx_data_q2 (rx_samp_q2),
    .rx_data_i3 (rx_samp_i3),
    .rx_data_q3 (rx_samp_q3),
    .usb_val_out (usb_val_out),
    .usb_rdy_out (usb_rdy_out),
    .usb_data_out (usb_data_out),
    .usb_val_in (usb_val_in),
    .usb_rdy_in (usb_rdy_in),
    .usb_data_in (usb_data_in),
    .ebi_addr (ebi_addr),
    .ebi_nrde (ebi_nrde),
    .ebi_nwre (ebi_nwre),
    .ebi_irq (),
    .ebi_data (ebi_data),
    .fifo_rst (c_rst)
  );

  /* USB data FIFOs.
   */

  axis_fifo_async #(
    .MEMORY_TYPE ("block"),
    .DATA_WIDTH (16),
    .READ_WIDTH (),
    .FIFO_DEPTH (65536)  //262144
  ) axis_fifo_async_usb_out (
    .s_axis_clk (c_clk),
    .s_axis_rst (c_rst),
    .m_axis_clk (u_clk),
    .s_axis_tvalid (usb_val_out),
    .s_axis_tready (usb_rdy_out),
    .s_axis_tdata (usb_data_out),
    .m_axis_tvalid (usb_tx_val),
    .m_axis_tready (usb_tx_rdy),
    .m_axis_tdata (usb_tx_data)
  );

  axis_fifo_async #(
    .MEMORY_TYPE ("block"),
    .DATA_WIDTH (16),
    .READ_WIDTH (),
    .FIFO_DEPTH (65536)  //262144
  ) axis_fifo_async_usb_in (
    .s_axis_clk (u_clk),
    .s_axis_rst (u_rst),
    .m_axis_clk (c_clk),
    .s_axis_tvalid (usb_rx_val),
    .s_axis_tready (usb_rx_rdy),
    .s_axis_tdata (usb_rx_data),
    .m_axis_tvalid (usb_val_in),
    .m_axis_tready (usb_rdy_in),
    .m_axis_tdata (usb_data_in)
  );

  /* USB3 chip interface.
   */

  axis_ft245_sync #()
  axis_ft245_sync (
    .clk (u_clk),
    .tx_rdy (usb_tx_rdy),  //tx == out
    .tx_val (usb_tx_val),
    .tx_data (usb_tx_data),
    .rx_rdy (usb_rx_rdy),  //rx == in
    .rx_val (usb_rx_val),
    .rx_data (usb_rx_data),
    .adbus (usb_adbus),
    .be (usb_be),
    .rxf_n (usb_rxf_n),
    .txe_n (usb_txe_n),
    .rd_n (usb_rd_n),
    .wr_n (usb_wr_n),
    .oe_n (usb_oe_n),
    .siwu_n ()
  );

  /* LED output.
   */

  assign led_out[0] = ~d_clk_a;
  assign led_out[1] = 1'b0;
  assign led_out[2] = 1'b0;
  assign led_out[3] = ~d_clk_b;

  assign led_out[4] = cfg_rst;
  assign led_out[5] = 1'b0;
  assign led_out[6] = usb_rdy_out;  // TX fifo full
  assign led_out[7] = usb_rx_rdy;  // RX fifo full

endmodule
