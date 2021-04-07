////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Turns an input signal into a single pulse.
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  0
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module pulse #(

  // parameters

  parameter   WIDTH = 1,

  // bit width parameters

  localparam  W0 = WIDTH - 1

) (

  input             clk,
  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  // internal registers

  reg     [ W0:0]   din_d = 'b0;

  /* Create delayed input.
   */

  always @(posedge clk) begin
    din_d <= din;
  end

  /* Assign output pulse.
   */

  assign dout = din & ~din_d;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
