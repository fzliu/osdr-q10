////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Simple buffer (with optional inversion).
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  0
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module buffer #(

  // parameters

  parameter   WIDTH = 1,
  parameter   INVERT = 0,

  // bit width parameters

  localparam  W0 = WIDTH - 1

) (

  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  generate
  genvar i;
  for (i = 0; i < WIDTH; i = i + 1) begin

    LUT1 #(
      .INIT (INVERT ? 2'b01 : 2'b10)
    ) LUT1 (
      .I0 (din[i]),
      .O (dout[i])
    );

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
