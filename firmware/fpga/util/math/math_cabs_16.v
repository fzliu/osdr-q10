////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧��?
//
// Description: The absolute value of the complex number. 9-cycle delay.
//
////////////////////////////////////////////////////////////////////////////////

module math_cabs_16 (

  // core interface

  input             clk,
  input             ena,
  input             rst,

  // data interface

  input    [ 15:0]  dina,
  input    [ 15:0]  dinb,
  output   [ 16:0]  dout

);

  `include "sign_ext.vh"

  // internal signals

  wire     [ 42:0]  mult_a_out;
  wire     [ 42:0]  mult_b_out;
  wire     [ 48:0]  add_out;
  wire     [  8:0]  log_out;
  wire     [ 33:0]  pow_out;


  // mult_a

  math_mult_18 #()
  math_mult_18_a (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina (`SIGN_EXT(dina,16,25)),
    .dinb (`SIGN_EXT(dina,16,18)),
    .dout (mult_a_out)
  );

  // mult_b

  math_mult_18 #()
  math_mult_18_b (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina (`SIGN_EXT(dinb,16,25)),
    .dinb (`SIGN_EXT(dinb,16,18)),
    .dout (mult_b_out)
  );

  // add

  math_add_48 #()
  math_add_48 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .dina ({5'h00, mult_a_out}),  // mult_a_out is positive
    .dinb ({5'h00, mult_b_out}),  // mult_b_out is positive
    .dout (add_out)
  );

  // log2

  math_log2_32 #()
  math_log2_32 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .din (add_out[31:0]),
    .dout (log_out)
  );

  // pow2

  math_pow2_12 #()
  math_pow2_12 (
    .clk (clk),
    .ena (ena),
    .rst (rst),
    .din ({2'b0, log_out, 1'b0}),
    .dout (pow_out)
  );

  // assign output

  assign dout = pow_out[16:0];

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
