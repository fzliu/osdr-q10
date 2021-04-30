////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description0
// Dual-port full-duplex (receive and transmit) handler for a single AD9361.
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  1 cycle
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_lvds_if #(

  // parameters

  parameter   CLOCK_PERIOD = 4,
  parameter   CLOCK_MULT = 6,
  parameter   CLOCK_DIVIDE = 6,
  parameter   CLOCK_PHASE = 0,

  parameter   ENABLE_ODELAY = 0,
  parameter   ENABLE_IDELAY = 0,
  parameter   ODELAY_CLOCK = 0,
  parameter   ODELAY_FRAME = 0,
  parameter   ODELAY_DATA = 0,
  parameter   IDELAY_CLOCK = 0,
  parameter   IDELAY_FRAME = 0,
  parameter   IDELAY_DATA = 0,

  parameter   DEBUG_TX = 0

  // derived parameters

  // bit width parameters

) (

  // core interface

  input             rst,

  // physical interface (transmit)

  output            fb_clk_p,
  output            fb_clk_n,
  output            tx_frame_p,
  output            tx_frame_n,
  output  [  5:0]   tx_data_p,
  output  [  5:0]   tx_data_n,

  // physical interface (receive)

  input             data_clk_p,
  input             data_clk_n,
  input             rx_frame_p,
  input             rx_frame_n,
  input   [  5:0]   rx_data_p,
  input   [  5:0]   rx_data_n,

  // physical interface (control)

  output            enable,
  output            txnrx,

  // clock config interface

  input             cfg_clk,
  input             cfg_ena,
  input             cfg_wen,
  input   [  6:0]   cfg_addr,
  input   [ 31:0]   cfg_wdata,
  output  [ 31:0]   cfg_rdata,
  output            cfg_rdy,

  // output interface

  output            clk_out,
  output            lock,

  output            tx_done,
  input   [ 11:0]   tx_data_i0,
  input   [ 11:0]   tx_data_q0,
  input   [ 11:0]   tx_data_i1,
  input   [ 11:0]   tx_data_q1,

  output            rx_done,
  output  [ 11:0]   rx_data_i0,
  output  [ 11:0]   rx_data_q0,
  output  [ 11:0]   rx_data_i1,
  output  [ 11:0]   rx_data_q1

);

  `include "func_log2.vh"

  // internal signals

  wire              d_clk;
  wire              d_rst;

  wire              data_clk;

  wire              tx_rst;
  wire    [  1:0]   tx_step;
  wire              tx_frame;
  wire    [ 11:0]   tx_data;

  wire              rx_rst;
  wire    [  1:0]   rx_step;
  wire              rx_frame;
  wire    [ 11:0]   rx_data;

  // internal registers

  reg     [  2:0]   n_lock_sh = 3'b111;

  reg     [ 11:0]   tx_data_reg = 'b0;

  reg     [ 11:0]   rx_data_i0_reg = 'b0;
  reg     [ 11:0]   rx_data_q0_reg = 'b0;
  reg     [ 11:0]   rx_data_i1_reg = 'b0;
  reg     [ 11:0]   rx_data_q1_reg = 'b0;

  // internal test signals

  reg     [ 11:0]   tx_data_i0_test = 'h0;
  reg     [ 11:0]   tx_data_q0_test = 'h0;
  reg     [ 11:0]   tx_data_i1_test = 'h0;
  reg     [ 11:0]   tx_data_q1_test = 'h0;

  // generate test signal waveforms

  generate
  if (DEBUG_TX) begin

    always @(posedge d_clk) begin
      if (tx_done) begin
        tx_data_i0_test <= tx_data_i0_test + 1'b1;
        tx_data_q0_test <= tx_data_q0_test + 1'b1;
        tx_data_i1_test <= tx_data_i1_test + 1'b1;
        tx_data_q1_test <= tx_data_q1_test + 1'b1;
      end else begin
        tx_data_i0_test <= tx_data_i0_test;
        tx_data_q0_test <= tx_data_q0_test;
        tx_data_i1_test <= tx_data_i1_test;
        tx_data_q1_test <= tx_data_q1_test;
      end
    end

  end
  endgenerate

  /* Create IO clock and data clock.
   */

  clock_gen #(
    .GENERATOR ("DEFAULT"),
    .FEEDBACK ("REGIONAL"),
    .INPUT_BUFFER ("LOGIC"),
    .INPUT_PERIOD (CLOCK_PERIOD),
    .INPUT_MULT (CLOCK_MULT),
    .OUTPUT0_DIVIDE (CLOCK_DIVIDE),
    .OUTPUT0_PHASE (CLOCK_PHASE),
    .OUTPUT0_BUFFER ("REGIONAL"),
    .OUTPUT1_DIVIDE (CLOCK_DIVIDE),
    .OUTPUT1_PHASE (CLOCK_PHASE),
    .OUTPUT1_BUFFER ("GLOBAL")
  ) clock_gen (
    .rst (rst),
    .clk_in (data_clk),
    .clk_out_0 (d_clk),
    .clk_out_1 (clk_out),
    .clk_out_2 (),
    .cfg_clk (cfg_clk),
    .cfg_ena (cfg_ena),
    .cfg_wen (cfg_wen),
    .cfg_addr (cfg_addr),
    .cfg_wdata (cfg_wdata),
    .cfg_rdata (cfg_rdata),
    .cfg_rdy (cfg_rdy),
    .lock (lock)
  );

  /* Internal reset.
   * The inverted version of lock asynchronously resets the flops in this
   * circuit such that all flip-flops have their Q output set high and the
   * internal reset signal goes active. Once lock goes active high, the shift
   * register starts to clock the logic 0 at the D input of the first stage 
   * until the internal reset goes low..
   */

  always @(posedge d_clk or negedge lock) begin
    if (~lock) begin
      n_lock_sh <= 3'b111;
    end else begin
      n_lock_sh <= n_lock_sh >> 1;
    end
  end

  assign d_rst = n_lock_sh[0];

  /* Input buffers - transmit ports.
   */

  data_out #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (1),
    .DATA_RATE (2),
    .ENABLE_DELAY (ENABLE_ODELAY),
    .DELAY_VALUE (ODELAY_CLOCK)
  ) data_out_fb_clk (
    .clk (d_clk),
    .rst (d_rst),
    .dout (1'b1),
    .dout_2 (1'b0),
    .dout_p (fb_clk_p),
    .dout_n (fb_clk_n)
  );

  data_out #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (1),
    .DATA_RATE (1),
    .ENABLE_DELAY (ENABLE_ODELAY),
    .DELAY_VALUE (ODELAY_FRAME)
  ) data_out_tx_frame (
    .clk (d_clk),
    .rst (d_rst),
    .dout (tx_frame),
    .dout_2 (),
    .dout_p (tx_frame_p),
    .dout_n (tx_frame_n)
  );

  data_out #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (6),
    .DATA_RATE (2),
    .ENABLE_DELAY (ENABLE_ODELAY),
    .DELAY_VALUE (ODELAY_DATA)
  ) data_out_tx_data (
    .clk (d_clk),
    .rst (d_rst),
    .dout (tx_data[11:6]),
    .dout_2 (tx_data[5:0]),
    .dout_p (tx_data_p),
    .dout_n (tx_data_n)
  );

  /* Input buffers - receive ports.
   */

  data_in #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (1),
    .DATA_RATE (0),
    .ENABLE_DELAY (ENABLE_IDELAY),
    .DELAY_VALUE (IDELAY_CLOCK)
  ) data_in_data_clk (
    .clk (),
    .rst (),
    .din_p (data_clk_p),
    .din_n (data_clk_n),
    .din (data_clk),
    .din_2 ()
  );

  data_in #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (1),
    .DATA_RATE (1),
    .ENABLE_DELAY (ENABLE_IDELAY),
    .DELAY_VALUE (IDELAY_FRAME)
  ) data_in_rx_frame (
    .clk (d_clk),
    .rst (d_rst),
    .din_p (rx_frame_p),
    .din_n (rx_frame_n),
    .din (rx_frame),
    .din_2 ()
  );

  data_in #(
    .SIGNAL_TYPE ("LVDS"),
    .DATA_WIDTH (6),
    .DATA_RATE (2),
    .ENABLE_DELAY (ENABLE_IDELAY),
    .DELAY_VALUE (IDELAY_DATA)
  ) data_in_rx_data (
    .clk (d_clk),
    .rst (d_rst),
    .din_p (rx_data_p),
    .din_n (rx_data_n),
    .din (rx_data[11:6]),
    .din_2 (rx_data[5:0])
  );

  /* RX and TX counters.
   * These counters enables this module to serialize input and output data.
   */

  pulse #(
    .WIDTH (1)
  ) pulse_rx_rst (
    .clk (d_clk),
    .din (rx_frame),
    .dout (rx_rst)
  );

  counter #(
    .LOWER (0),
    .UPPER (3),
    .WRAPAROUND (1),
    .INIT_VALUE (0)
  ) counter_tx (
    .clk (d_clk),
    .rst (1'b0),
    .ena (1'b1),
    .done (),
    .value (tx_step)
  );

  counter #(
    .LOWER (0),
    .UPPER (3),
    .WRAPAROUND (1),
    .INIT_VALUE (0)
  ) counter_rx (
    .clk (d_clk),
    .rst (rx_rst),
    .ena (1'b1),
    .done (),
    .value (rx_step)
  );

  /* Set TX output registers.
   * High levels for tx_frame indicate channel 1, while low values indicate
   * channel 2. Each tx_frame cycle is sub-divided as follows:
   * i[11:6], q[11:6], i[5:0], q[5:0], repeat
   */

  generate
  if (DEBUG_TX) begin

    always @* begin
      casez (tx_step)
        2'b00: tx_data_reg = {tx_data_i0_test[11:6], tx_data_q0_test[11:6]};
        2'b01: tx_data_reg = {tx_data_i0_test[5:0], tx_data_q0_test[5:0]};
        2'b10: tx_data_reg = {tx_data_i1_test[11:6], tx_data_q1_test[11:6]};
        2'b11: tx_data_reg = {tx_data_i1_test[5:0], tx_data_q1_test[5:0]};
        default: tx_data_reg = 12'h000;
      endcase
    end
  
  end else begin

    always @* begin
      casez (tx_step)
        2'b00: tx_data_reg = {tx_data_i0[11:6], tx_data_q0[11:6]};
        2'b01: tx_data_reg = {tx_data_i0[5:0], tx_data_q0[5:0]};
        2'b10: tx_data_reg = {tx_data_i1[11:6], tx_data_q1[11:6]};
        2'b11: tx_data_reg = {tx_data_i1[5:0], tx_data_q1[5:0]};
        default: tx_data_reg = 12'h000;
      endcase
    end

  end
  endgenerate

  assign tx_frame = ~tx_step[1];
  assign tx_data = tx_data_reg;

  /* Set RX output registers.
   * Unlike TX (where this module is the driver), this module must anticipate
   * by 1 clock cycle when a new batch of data will come in.
   */

  always @(posedge d_clk) begin
    casez (rx_step)
      3'b11: {rx_data_q0_reg[11:6], rx_data_i0_reg[11:6]} <= rx_data;
      3'b00: {rx_data_q0_reg[5:0], rx_data_i0_reg[5:0]} <= rx_data;
      3'b01: {rx_data_q1_reg[11:6], rx_data_i1_reg[11:6]} <= rx_data;
      3'b10: {rx_data_q1_reg[5:0], rx_data_i1_reg[5:0]} <= rx_data;
    endcase
  end

  /* Set output data.
   * For TX: done goes high the same cycle we send the last word.
   * For RX: done goes high right before we latch in the first word.
   */

  assign tx_done = &tx_step;
   
  assign rx_done = &rx_step;  //~|rx_step
  assign rx_data_i0 = rx_data_i0_reg;
  assign rx_data_q0 = rx_data_q0_reg;
  assign rx_data_i1 = rx_data_i1_reg;
  assign rx_data_q1 = rx_data_q1_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
