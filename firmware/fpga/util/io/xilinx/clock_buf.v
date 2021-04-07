////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Clock buffer module, Xilinx devices.
//
////////////////////////////////////////////////////////////////////////////////


module clock_buf #(

  parameter   CLOCK_BUFFER = "GLOBAL"

) (

  input             ena,
  input             clk_in,
  output            clk_out

);

  /* Three output buffer options:
   * IO_ONLY: instantiates a BUFIO
   * REGIONAL: instantiates a BUFR
   * GLOBAL: instantiates a BUFG
   */

  generate
  if (CLOCK_BUFFER == "NONE") begin

    assign clk_out = clk_in;

  end else if (CLOCK_BUFFER == "IO_ONLY") begin

    BUFIO #()
    BUFIO (
      .I (clk_in),
      .O (clk_out)
    );

  end else if (CLOCK_BUFFER == "REGIONAL") begin

    BUFR #(
      .BUFR_DIVIDE ("1"),
      .SIM_DEVICE ("7SERIES")
    ) BUFR (
      .I (clk_in),
      .CE (ena),
      .CLR (1'b0),
      .O (clk_out)
    );

  end else begin

    BUFG #()
    BUFG (
      .I (clk_in),
      .O (clk_out)
    );

  end
  endgenerate

endmodule
