////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Parameterized input DDR register instantiation utility.
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  0 or 1 cycles
// output  :  unregistered or registered
//
////////////////////////////////////////////////////////////////////////////////


module data_in #(

  // parameters

  parameter   SIGNAL_TYPE = "CMOS",
  parameter   DATA_WIDTH = 1,
  parameter   DATA_RATE = 0,
  parameter   ENABLE_DELAY = 0,
  parameter   DELAY_VALUE = 0,

  // bit with parameters

  localparam  W0 = DATA_WIDTH - 1

) (

  input             clk,
  input             rst,

  input   [ W0:0]   din_p,
  input   [ W0:0]   din_n,

  output  [ W0:0]   din,
  output  [ W0:0]   din_2

);

  // internal signals

  wire    [ W0:0]   din_buf;
  wire    [ W0:0]   din_dly;

  // internal registers

  reg     [ W0:0]   din_dly_d = 'b0;

  /* Create input buffers.
   * Current available options: "CMOS", "LVDS".
   */

  generate
  if (SIGNAL_TYPE == "LVDS") begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      IBUFDS #(
        .DIFF_TERM ("TRUE"),
        .IBUF_LOW_PWR ("FALSE"),
        .IOSTANDARD ("DEFAULT")
      ) ibufds (
        .I (din_p[i]),
        .IB (din_n[i]),
        .O (din_buf[i])
      );
    end

  end else begin

    assign din_buf = din_p;

  end
  endgenerate

  /* Add input delays, if requested.
   */

  generate
  if (ENABLE_DELAY) begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      IDELAYE2 #(
        .CINVCTRL_SEL ("FALSE"),
        .DELAY_SRC ("IDATAIN"),
        .HIGH_PERFORMANCE_MODE ("TRUE"),
        .IDELAY_TYPE ("FIXED"),
        .IDELAY_VALUE (DELAY_VALUE),
        .PIPE_SEL ("FALSE"),
        .REFCLK_FREQUENCY (400.0),
        .SIGNAL_PATTERN ("DATA")
      ) idelaye2 (
        .C (),
        .CE (),
        .CINVCTRL (),
        .CNTVALUEIN (),
        .DATAIN (),
        .IDATAIN (din_buf[i]),
        .CNTVALUEOUT (),
        .DATAOUT (din_dly[i]),
        .INC (),
        .LD (),
        .LDPIPEEN (),
        .REGRST ()
      );
    end

  end else begin

    assign din_dly = din_buf;

  end
  endgenerate

  /* Add DDR registers, if requested.
   */

  generate
  if (DATA_RATE == 2) begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"),
        .INIT_Q1 (1'b0),
        .INIT_Q2 (1'b0),
        .SRTYPE ("ASYNC")
      ) iddr (
        .C (clk),
        .CE (1'b1),
        .R (rst),
        .S (1'b0),
        .D (din_dly[i]),
        .Q1 (din[i]),
        .Q2 (din_2[i])
      );
    end

  end else if (DATA_RATE == 1) begin

    always @(posedge clk or posedge rst) begin
      if (rst) begin
        din_dly_d <= 'b0;
      end else begin
        din_dly_d <= din_dly;
      end
    end

    assign din = din_dly_d;
    assign din2 = 'bz;

  end else begin

    assign din = din_dly;
    assign din_2 = 'bz;

  end
  endgenerate

endmodule
