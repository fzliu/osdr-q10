////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Clock generation module, Xilinx devices.
//
////////////////////////////////////////////////////////////////////////////////


module clock_gen #(

  parameter   GENERATOR = "DEFAULT",
  parameter   FEEDBACK = "NONE",
  parameter   INPUT_BUFFER = "NONE",
  parameter   INPUT_PERIOD = 10,
  parameter   INPUT_MULT = 10,
  parameter   OUTPUT0_DIVIDE = 10,
  parameter   OUTPUT0_PHASE = 0,
  parameter   OUTPUT0_BUFFER = "NONE",
  parameter   OUTPUT1_DIVIDE = 10,
  parameter   OUTPUT1_PHASE = 0,
  parameter   OUTPUT1_BUFFER = "NONE",
  parameter   OUTPUT2_DIVIDE = 10,
  parameter   OUTPUT2_PHASE = 0,
  parameter   OUTPUT2_BUFFER = "NONE"

) (

  input             rst,

  input             clk_in,
  output            clk_out_0,
  output            clk_out_1,
  output            clk_out_2,

  input             cfg_clk,
  input             cfg_ena,
  input             cfg_wen,
  input   [  6:0]   cfg_addr,
  input   [ 31:0]   cfg_wdata,
  output  [ 31:0]   cfg_rdata,
  output            cfg_rdy,

  output            lock

);

  // internal signals

  wire              clk_in_b;

  wire              clk_fb_in;
  wire              clk_fb_out;

  wire              clk_out_0_s;
  wire              clk_out_1_s;
  wire              clk_out_2_s;

  /* Instantiate input buffer.
   */

  generate
  if (INPUT_BUFFER == "LOGIC") begin

    LUT1 #(
      .INIT (2'b10)
    ) LUT1 (
      .I0 (clk_in),
      .O (clk_in_b)
    );

  end else begin
  
    assign clk_in_b = clk_in;
  
  end
  endgenerate

  /* Instantiate PLL/MMCM.
   */

  generate
  if (GENERATOR == "PLL") begin

    PLLE2_ADV #(
      .BANDWIDTH ("HIGH"),
      .CLKIN1_PERIOD (INPUT_PERIOD),
      .DIVCLK_DIVIDE (1),
      .CLKFBOUT_MULT (INPUT_MULT),
      .CLKFBOUT_PHASE (0.0),
      .CLKOUT0_DIVIDE (OUTPUT0_DIVIDE),
      .CLKOUT0_DUTY_CYCLE (0.5),
      .CLKOUT0_PHASE (OUTPUT0_PHASE),
      .CLKOUT1_DIVIDE (OUTPUT1_DIVIDE),
      .CLKOUT1_DUTY_CYCLE (0.5),
      .CLKOUT1_PHASE (OUTPUT1_PHASE),
      .CLKOUT2_DIVIDE (OUTPUT2_DIVIDE),
      .CLKOUT2_DUTY_CYCLE (0.5),
      .CLKOUT2_PHASE (OUTPUT2_PHASE),
      .STARTUP_WAIT ("FALSE")
    ) plle2_adv (
      .RST (rst),
      .PWRDWN (1'b0),
      .CLKIN1 (clk_in_b),
      .CLKIN2 (1'b0),
      .CLKINSEL (1'b1),
      .CLKFBIN (clk_fb_in),
      .CLKFBOUT (clk_fb_out),
      .CLKOUT0 (clk_out_0_s),
      .CLKOUT1 (clk_out_1_s),
      .CLKOUT2 (clk_out_2_s),
      .CLKOUT3 (),
      .CLKOUT4 (),
      .CLKOUT5 (),
      .LOCKED (lock),
      .DCLK (cfg_clk),
      .DEN (cfg_ena),
      .DWE (cfg_wen),
      .DADDR (cfg_addr),
      .DI (cfg_wdata[15:0]),
      .DO (cfg_rdata[15:0]),
      .DRDY (cfg_rdy)
    );

  end else begin  // "DEFAULT"

    MMCME2_ADV #(
      .BANDWIDTH ("HIGH"),
      .CLKIN1_PERIOD (INPUT_PERIOD),
      .CLKIN2_PERIOD (0.0),
      .DIVCLK_DIVIDE (1),
      .CLKFBOUT_MULT_F (INPUT_MULT),
      .CLKFBOUT_PHASE (0.0),
      .CLKOUT0_DIVIDE_F (OUTPUT0_DIVIDE),
      .CLKOUT0_DUTY_CYCLE (0.5),
      .CLKOUT0_PHASE (OUTPUT0_PHASE),
      .CLKOUT1_DIVIDE (OUTPUT1_DIVIDE),
      .CLKOUT1_DUTY_CYCLE (0.5),
      .CLKOUT1_PHASE (OUTPUT1_PHASE),
      .CLKOUT2_DIVIDE (OUTPUT2_DIVIDE),
      .CLKOUT2_DUTY_CYCLE (0.5),
      .CLKOUT2_PHASE (OUTPUT2_PHASE),
      .STARTUP_WAIT ("FALSE")
    ) mmcme2_adv (
      .RST (rst),
      .PWRDWN (1'b0),
      .CLKIN1 (clk_in_b),
      .CLKIN2 (1'b0),
      .CLKINSEL (1'b1),
      .CLKFBIN (clk_fb_in),
      .CLKFBOUT (clk_fb_out),
      .CLKFBOUTB (),
      .CLKOUT0 (clk_out_0_s),
      .CLKOUT0B (),
      .CLKOUT1 (clk_out_1_s),
      .CLKOUT1B (),
      .CLKOUT2 (clk_out_2_s),
      .CLKOUT2B (),
      .CLKOUT3 (),
      .CLKOUT3B (),
      .CLKOUT4 (),
      .CLKOUT5 (),
      .CLKOUT6 (),
      .LOCKED (lock),
      .CLKFBSTOPPED (),
      .CLKINSTOPPED (),
      .DCLK (cfg_clk),
      .DEN (cfg_ena),
      .DWE (cfg_wen),
      .DADDR (cfg_addr),
      .DI (cfg_wdata[15:0]),
      .DO (cfg_rdata[15:0]),
      .DRDY (cfg_rdy),
      .PSCLK (1'b0),
      .PSEN (1'b0),
      .PSINCDEC (1'b1),
      .PSDONE ()
    );

  end
  endgenerate

  assign cfg_rdata[31:16] = 16'h0000;

  /* Create feedback loop.
   */

  generate
  if (FEEDBACK == "NONE") begin

    assign clk_fb_in = clk_fb_out;

  end else if (FEEDBACK == "REGIONAL") begin

    BUFR #(
      .BUFR_DIVIDE ("BYPASS"),
      .SIM_DEVICE ("7SERIES")
    ) BUFR_fb (
      .I (clk_fb_out),
      .CE (1'b0),
      .CLR (1'b0),
      .O (clk_fb_in)
    );

  end else begin

    BUFG #()
    BUFG_fb (
      .I (clk_fb_out),
      .O (clk_fb_in)
    );

  end
  endgenerate

  /* Output clock buffers.
   */

  clock_buf #(
    .CLOCK_BUFFER (OUTPUT0_BUFFER)
  ) clock_buf_0 (
    .ena (lock),
    .clk_in (clk_out_0_s),
    .clk_out (clk_out_0)
  );

  clock_buf #(
    .CLOCK_BUFFER (OUTPUT1_BUFFER)
  ) clock_buf_1 (
    .ena (lock),
    .clk_in (clk_out_1_s),
    .clk_out (clk_out_1)
  );

  clock_buf #(
    .CLOCK_BUFFER (OUTPUT2_BUFFER)
  ) clock_buf_2 (
    .ena (lock),
    .clk_in (clk_out_2_s),
    .clk_out (clk_out_2)
  );

endmodule
