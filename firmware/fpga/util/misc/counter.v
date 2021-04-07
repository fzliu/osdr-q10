////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// Parameterizable upward counter. Single-cycle latency. If WRAPAROUND is set to
// false, the counter will hold its value once it reaches  the maximum.
//
////////////////////////////////////////////////////////////////////////////////

module counter #(

  // parameters

  parameter   LOWER = 0,
  parameter   UPPER = 255,
  parameter   WRAPAROUND = 0,
  parameter   INIT_VALUE = LOWER,

  // derived parameters

  localparam  WIDTH = log2(UPPER),

  // bit width parameters

  localparam  W0 = (WIDTH == 0) ? 0 : WIDTH - 1

) (

  // master interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  output            done,
  output  [ W0:0]   value

);

  `include "func_log2.vh"

  // internal registers

  reg     [ W0:0]   count = INIT_VALUE;

  /* Overflow logic.
   * When the counter has reached its highest value, this bit is asserted.
   */

  assign done = (count == UPPER);

  /* Counter implementation.
   * If WIDTH == 0, we assign the output to a constant zero value instead to
   * avoid creating unnecessary logic.
   */

  generate
  if (WIDTH == 0) begin

    always @* begin
      count = 'b0;
    end

  end else begin

    always @(posedge clk) begin
      casez ({rst, ena, done})
        3'b1??: count <= INIT_VALUE;
        3'b011: count <= WRAPAROUND ? LOWER : UPPER;
        3'b010: count <= count + 1'b1;
        default: count <= count;
      endcase
    end

  end
  endgenerate

  /* Assign output value.
   */

  assign value = count;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
