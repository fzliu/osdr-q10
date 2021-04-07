////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Parameterized output DDR register instantiation utility.
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  0 cycles, 1 cycle (DDR enabled)
// output  :  physical registered
//
////////////////////////////////////////////////////////////////////////////////

module data_out #(

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

  input   [ W0:0]   dout,
  input   [ W0:0]   dout_2,

  output  [ W0:0]   dout_p,
  output  [ W0:0]   dout_n

);

  // internal signals

  wire    [ W0:0]   dout_ddr;
  wire    [ W0:0]   dout_dly;

  // internal registers

  reg     [ W0:0]   dout_d = 'b0;

  /* Add DDR registers, if requested.
   */

  generate
  if (DATA_RATE == 2) begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      ODDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"),
        .INIT (1'b0),
        .SRTYPE ("ASYNC")
      ) oddr (
        .C (clk),
        .CE (1'b1),
        .R (rst),
        .S (1'b0),
        .D1 (dout[i]),
        .D2 (dout_2[i]),
        .Q (dout_ddr[i])
      );
    end

  end else if (DATA_RATE == 1) begin

    always @(posedge clk or posedge rst) begin
      if (rst) begin
        dout_d <= 1'b0;
      end else begin
        dout_d <= dout;
      end
    end

    assign dout_ddr = dout_d;

  end else begin

    assign dout_ddr = dout;

  end
  endgenerate

  /* Add output delays, if requested.
   */

  generate
  if (ENABLE_DELAY) begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      ODELAYE2 #(
        .CINVCTRL_SEL ("FALSE"),
        .DELAY_SRC ("ODATAIN"),
        .HIGH_PERFORMANCE_MODE ("TRUE"),
        .ODELAY_TYPE ("FIXED"),
        .ODELAY_VALUE (DELAY_VALUE),
        .PIPE_SEL ("FALSE"),
        .REFCLK_FREQUENCY (400.0),
        .SIGNAL_PATTERN ("DATA")
      ) odelaye2 (
        .C (),
        .CE (),
        .CINVCTRL (),
        .CNTVALUEIN (),
        .CLKIN (),
        .ODATAIN (dout_ddr[i]),
        .CNTVALUEOUT (),
        .DATAOUT (dout_dly[i]),
        .INC (),
        .LD (),
        .LDPIPEEN (), 
        .REGRST ()
      );    
    end

  end else begin

    assign dout_dly = dout_ddr;

  end
  endgenerate

  /* Generate output signal.
   */

  generate
  if (SIGNAL_TYPE == "LVDS") begin

    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin
      OBUFDS #(
        .IOSTANDARD (),
        .SLEW ()
      ) obufds (
        .O (dout_p[i]),
        .OB (dout_n[i]),
        .I (dout_dly[i])
      );
    end

  end else begin

    assign dout_p = dout_dly;

  end
  endgenerate


endmodule
