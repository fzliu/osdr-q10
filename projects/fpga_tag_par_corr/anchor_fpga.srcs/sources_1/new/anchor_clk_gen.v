////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor clock generation module.
//
////////////////////////////////////////////////////////////////////////////////


module anchor_clk_gen (

  input             clk_xtal,
  input             clk_ad9361,
  input             ena,

  output            d_clk,   /* data clock */
  output            m_clk,   /* main clock */
  output            c_clk    /* compute clock */

);

  // internal signals

  wire              pll_clk;
  wire    [  5:0]   pll_out;
  wire              pll_fb;
  wire              pll_lock;

  /* Clock generation
   * Input: 50MHz (nominal)
   * Output 0: 50MHz, -pi/2 phase shift
   * Output 1: 100MHz
   * Output 2: 400MHz
   */

  PLLE2_BASE #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKIN1_PERIOD (20),
    .DIVCLK_DIVIDE (1),
    .CLKFBOUT_MULT (32),
    .CLKFBOUT_PHASE (0.000),
    .CLKOUT0_DIVIDE (32),
    .CLKOUT0_PHASE (-90.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DIVIDE (16),
    .CLKOUT1_PHASE (0),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT2_DIVIDE (4),
    .CLKOUT2_PHASE (0),
    .CLKOUT2_DUTY_CYCLE (0.500),
    .REF_JITTER1 (0.0),
    .STARTUP_WAIT ("TRUE")
  ) plle2_base (
    .CLKOUT0 (pll_out[0]),
    .CLKOUT1 (pll_out[1]),
    .CLKOUT2 (pll_out[2]),
    .CLKOUT3 (pll_out[3]),
    .CLKOUT4 (pll_out[4]),
    .CLKOUT5 (pll_out[5]),
    .CLKFBOUT (pll_fb),
    .CLKIN1 (clk_ad9361),
    .LOCKED (pll_lock),
    .PWRDWN (1'b0),
    .RST (1'b0),
    .CLKFBIN (pll_fb)
  );

  /* 50MHz data clock (shifted)
   * This clock is used to latch in data from the AD9361s.
   */

  BUFGCE bufgce_0 (
    .I (pll_out[0]),
    .CE (ena),
    .O (d_clk)
  );

  /* 100MHz main clock
   * This clock is primarily used for buffering and control.
   */

  BUFGCE bufgce_1 (
    .I (pll_out[1]),
    .CE (ena),
    .O (m_clk)
  );

  /* 400MHz compute clock
   * This clock is used in high-performance modules.
   */

  BUFGCE bufgce_2 (
    .I (pll_out[2]),
    .CE (ena),
    .O (c_clk)
  );

endmodule
