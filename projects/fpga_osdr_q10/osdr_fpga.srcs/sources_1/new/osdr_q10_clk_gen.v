////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// OSDR Q10 clock generation module.
//
////////////////////////////////////////////////////////////////////////////////


module osdr_q10_clk_gen (

  input             ref_clk,
  input             ebi_clk,
  input             usb_clk,

  output            r_clk,
  output            c_clk,
  output            u_clk,
  output            rdy

);

  // internal signals

  wire              clk_400;

  wire              lock;

  // internal registers

  reg               lock_d = 1'b0;

  /* Reference clock generation.
   * Input: 25MHz
   * Output 0: 25MHz (delay-compensated)
   * Output 1: 400MHz (delay-compensated)
   */

  clock_gen #(
    .GENERATOR ("PLL"),
    .FEEDBACK ("GLOBAL"),
    .INPUT_BUFFER ("NONE"),
    .INPUT_PERIOD (40),
    .INPUT_MULT (32),
    .OUTPUT0_DIVIDE (32),
    .OUTPUT0_PHASE (0),
    .OUTPUT0_BUFFER ("GLOBAL"),
    .OUTPUT1_DIVIDE (2),
    .OUTPUT1_PHASE (0),
    .OUTPUT1_BUFFER ("GLOBAL")
  ) clock_gen_ref (
    .rst (1'b0),
    .clk_in (ref_clk),
    .clk_out_0 (r_clk),
    .clk_out_1 (clk_400),
    .clk_out_2 (),
    .cfg_clk (1'b0),
    .cfg_ena (1'b0),
    .cfg_wen (1'b0),
    .cfg_addr (7'h00),
    .cfg_wdata (32'h00000000),
    .cfg_rdata (),
    .cfg_rdy (),
    .lock (lock)
  );

  /* USB interface clock generation.
   * Input: 66MHz
   * Output 0: 66MHz (delay-compensated)
   */

  clock_gen #(
    .GENERATOR ("PLL"),
    .FEEDBACK ("GLOBAL"),
    .INPUT_BUFFER ("NONE"),
    .INPUT_PERIOD (15),
    .INPUT_MULT (15),
    .OUTPUT0_DIVIDE (15),
    .OUTPUT0_PHASE (0),
    .OUTPUT0_BUFFER ("GLOBAL")
  ) clock_gen_usb (
    .rst (1'b0),
    .clk_in (usb_clk),
    .clk_out_0 (u_clk),
    .clk_out_1 (),
    .clk_out_2 (),
    .cfg_clk (1'b0),
    .cfg_ena (1'b0),
    .cfg_wen (1'b0),
    .cfg_addr (7'h00),
    .cfg_wdata (32'h00000000),
    .cfg_rdata (),
    .cfg_rdy (),
    .lock ()
  );

  /* EBI interface clock generation.
   * Input: 99MHz
   * Output 0: 99MHz (delay-compensated)
   */

  clock_gen #(
    .GENERATOR ("PLL"),
    .FEEDBACK ("GLOBAL"),
    .INPUT_BUFFER ("NONE"),
    .INPUT_PERIOD (10),
    .INPUT_MULT (10),
    .OUTPUT0_DIVIDE (10),
    .OUTPUT0_PHASE (0),
    .OUTPUT0_BUFFER ("GLOBAL")
  ) clock_gen_ebi (
    .rst (1'b0),
    .clk_in (ebi_clk),
    .clk_out_0 (c_clk),
    .clk_out_1 (),
    .clk_out_2 (),
    .cfg_clk (1'b0),
    .cfg_ena (1'b0),
    .cfg_wen (1'b0),
    .cfg_addr (7'h00),
    .cfg_wdata (32'h00000000),
    .cfg_rdata (),
    .cfg_rdy (),
    .lock ()
  );

  /* IDELAY calibration.
   * Delay inputs so that the effect of clock skew is minimized.
   */

  always @(posedge clk_400) begin
    lock_d <= lock;
  end

  IDELAYCTRL #()
  IDELAYCTRL (
    .REFCLK (clk_400),
    .RST (~lock_d),
    .RDY (rdy)
  );

endmodule
