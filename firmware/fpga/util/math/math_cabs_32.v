////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慧
//
// Description: The absolute value of the complex number. 14-cycle delay.
//
////////////////////////////////////////////////////////////////////////////////

module math_cabs_32 (

  // core interface

  input             clk,
  input             ena,
  input             rst,

  // data interface

  input    [ 31:0]  dina,
  input    [ 31:0]  dinb,
  output   [ 33:0]  dout

);

  `include "sign_ext.vh"

  // internal signals

  wire     [ 69:0]  mult_a_out;
  wire     [ 69:0]  mult_b_out;
  wire     [ 96:0]  add_out;
  wire     [  9:0]  log_out;


  // multiply_a

  math_mult_35 #()
  math_mult_35_b (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina (`SIGN_EXT(dina,32,42)),
    .dinb (`SIGN_EXT(dina,32,35)),
    .dout (mult_a_out)
  );

  // multiply_b

  math_mult_35 #()
  math_mult_35_a (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina (`SIGN_EXT(dinb,32,42)),
    .dinb (`SIGN_EXT(dinb,32,35)),
    .dout (mult_b_out)
  );

  // add

  math_add_96 #()
  math_add_96 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina ({26'h0000000, mult_a_out}),  // mult_a_out is positive
    .dinb ({26'h0000000, mult_b_out}),  // mult_b_out is positive
    .dout (add_out)
  );

  // log2 (6 decimal places)

  math_log2_64 #()
  math_log2_64 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .din (add_out[63:0]),
    .dout (log_out)
  );

  // pow2 (4 decimal places)

  math_pow2_12 #()
  math_pow2_12 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .din ({1'b0, log_out, 1'b0}),
    .dout (dout)
  );

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
