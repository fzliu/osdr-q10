////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterizable upward counter. Single-cycle latency. If
// WRAPAROUND is set to false, the counter will hold its value once it reaches
// the maximum.
//
////////////////////////////////////////////////////////////////////////////////

module counter #(

  // parameters

  parameter   LOWER = 0,
  parameter   UPPER = 255,
  parameter   WRAPAROUND = 0,
  parameter   INIT_VALUE = 0,

  // derived parameters

  localparam  WIDTH = log2(UPPER),

  // bit width parameters

  localparam  W0 = WIDTH - 1

) (

  // master interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  output  [ W0:0]   value

);

  `include "func_log2.vh"

  // internal registers

  reg     [ W0:0]   count = INIT_VALUE;

  // internal signals

  wire              at_upper;

  // counter implementation

  assign at_upper = (count == UPPER);

  generate
  always @(posedge clk) begin
    casez ({rst, ena, at_upper})
      3'b1??: count <= LOWER;
      3'b011: count <= WRAPAROUND ? LOWER : UPPER;
      3'b010: count <= count + 1'b1;
      default: count <= count;
    endcase
  end
  endgenerate

  // assign output

  assign value = count;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
