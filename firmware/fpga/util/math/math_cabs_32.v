////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慿
//
// Description: The absolute value of the complex number. 14-cycle delay.
//
////////////////////////////////////////////////////////////////////////////////

module math_cabs_32 (

  // core interface

  input             clk,

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
  math_mult_35_0 (
    .clk (clk),
    .dina (`SIGN_EXT(dina,32,42)),
    .dinb (`SIGN_EXT(dina,32,35)),
    .dout (mult_a_out)
  );

  // multiply_b

  math_mult_35 #()
  math_mult_35_1 (
     .clk(clk),
     .dina (`SIGN_EXT(dinb,32,42)),
     .dinb (`SIGN_EXT(dinb,32,35)),
     .dout (mult_b_out)
  );

  // add

  math_add_96 #()
  math_add_96 (
    .clk (clk),
    .dina ({26'h0000000, mult_a_out}),
    .dinb ({26'h0000000, mult_b_out}),
    .dout (add_out)
  );

  // input data domain

  math_log2_64 #()
  math_log2_64 (
    .clk (clk),
    .din (add_out[63:0]),
    .dout (log_out)
  );

  math_pow2_12 #()
  math_pow2_12 (
    .clk (clk),
    .din (log_out << 1),  // left shift log = sqrt of exp
    .dout (dout)
  );

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
