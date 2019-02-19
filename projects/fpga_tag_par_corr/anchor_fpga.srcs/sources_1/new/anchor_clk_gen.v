////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor clock generation module. Input enable signals must be synchronized to
// the respective clock domains to avoid metastability when using BUFGCE. Google
// "xilinx tell timing to ignore this path" for more information.
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

  wire    [  5:0]   bufg_ce;

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

  /* 50MHz data clock (shifted).
   * This clock is used to latch in data from the AD9361s.
   */

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_0 (
    .src_clk (),
    .src_in (ena),
    .dest_clk (pll_out[0]),
    .dest_out (bufg_ce[0])
  );

  BUFGCE bufgce_0 (
    .I (pll_out[0]),
    .CE (bufg_ce[0]),
    .O (d_clk)
  );

  /* 100MHz main clock.
   * This clock is primarily used for buffering and control.
   */

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_1 (
    .src_clk (),
    .src_in (ena),
    .dest_clk (pll_out[1]),
    .dest_out (bufg_ce[1])
  );

  BUFGCE bufgce_1 (
    .I (pll_out[1]),
    .CE (bufg_ce[1]),
    .O (m_clk)
  );

  /* 400MHz compute clock.
   * This clock is used in high-performance modules.
   */

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_2 (
    .src_clk (),
    .src_in (ena),
    .dest_clk (pll_out[2]),
    .dest_out (bufg_ce[2])
  );

  BUFGCE bufgce_2 (
    .I (pll_out[2]),
    .CE (bufg_ce[2]),
    .O (c_clk)
  );

endmodule
