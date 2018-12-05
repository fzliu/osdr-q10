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

  wire     [ 69:0]  P1;
  wire     [ 69:0]  P2;
  wire     [ 63:0]  S;
  wire     [ 95:0]  add_a;
  wire     [ 95:0]  add_b;
  wire     [ 96:0]  add_out;
  wire     [  9:0]  log_out;
  wire     [ 11:0]  antilog_in;
  wire     [ 41:0]  mult_a_a;
  wire     [ 34:0]  mult_a_b;
  wire     [ 41:0]  mult_b_a;
  wire     [ 34:0]  mult_b_b;


  // multply_a_a

  assign mult_a_a = `SIGN_EXT(dina,32,42);
  assign mult_a_b = `SIGN_EXT(dina,32,35);

  math_mult_35 #()
  math_mult_35_0 (
    .clk (clk),
    .dina (mult_a_a),
    .dinb (mult_a_b),
    .dout (P1)
  );

  // multply_b_b

  assign mult_b_a = `SIGN_EXT(dinb,32,42);
  assign mult_b_b = `SIGN_EXT(dinb,32,35);

  math_mult_35 #()
  math_mult_35_1 (
     .clk(clk),
     .dina (mult_b_a),
     .dinb (mult_b_b),
     .dout (P2)
  );

  // add

  assign add_a = P1;
  assign add_b = P2;

  math_add_96 #()
  math_add_96 (
    .clk (clk),
    .dina (add_a),
    .dinb (add_b),
    .dout (add_out)
  );

  // input data domain

  //assign S_reg = (S[63:48] == 16'b0) ? S :(S >> 16);
  //assign shift_flag = (S[63:48] == 16'b0) ? 1 : 0;

  assign S = add_out;

  math_log2_64 #()
  math_log2_64 (
    .din(S),
    .clk(clk),
    .dout(log_out)
  );

 assign antilog_in = log_out << 1 ;

  math_pow2_12 #()
  math_pow2_12 (
    .din(antilog_in),
    .clk(clk),
    .dout(dout)
  );


endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
