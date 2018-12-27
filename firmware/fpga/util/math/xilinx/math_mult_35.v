////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Cascades four DSP48 multipliers into a larger 42x35 multiply.
//
// enable  :  active-high
// reset   :  active-high
// latency :  6 cycles
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module math_mult_35 (

  input             clk,
  input             ena,
  input             rst,

  // input operands

  input   [ 41:0]   dina,
  input   [ 34:0]   dinb,

  // output sum

  output  [ 69:0]   dout

);

  // internal registers

  // internal signals

  wire    [ 16:0]   mult_2_a;   // dina, lower bits, delay 1
  wire    [ 17:0]   mult_2_b;   // dinb, upper bits, delay 1
  wire    [ 24:0]   mult_3_a;   // dina, upper bits, delay 2

  wire    [ 17:0]   mult_1_bc;  // cascade: port B, mult 0 -> mult 1
  wire    [ 17:0]   mult_3_bc;  // cascade: port B, mult 2 -> mult 3
  wire    [ 47:0]   mult_pc [0:2];

  wire    [ 47:0]   mult_p [0:3];

  // register the inputs

  shift_reg #(
    .WIDTH (17),
    .DEPTH (0)
  ) shift_reg_mult_2_a (
    .clk (clk),
    .ena (ena),
    .din (dina[16:0]),
    .dout (mult_2_a)
  );

  shift_reg #(
    .WIDTH (25),
    .DEPTH (1)
  ) shift_reg_mult_3_a (
    .clk (clk),
    .ena (ena),
    .din (dina[41:17]),
    .dout (mult_3_a)
  );

  shift_reg #(
    .WIDTH (18),
    .DEPTH (0)
  ) shift_reg_mult_2_b (
    .clk (clk),
    .ena (ena),
    .din (dinb[34:17]),
    .dout (mult_2_b)
  );

  // multiplier 0
  // inputs: single flop both
  // output: quad flop, [16:0]

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("DIRECT"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("MULTIPLY"),
    .USE_SIMD ("ONE48"),
    .AUTORESET_PATDET ("NO_RESET"),
    .MASK (48'h3fffffffffff),
    .PATTERN (48'h000000000000),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .ACASCREG (1),
    .ADREG (0),
    .ALUMODEREG (0),
    .AREG (1),
    .BCASCREG (1),
    .BREG (1),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (0),
    .DREG (0),
    .INMODEREG (0),
    .MREG (1),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1_0 (
    .ACOUT (),
    .BCOUT (mult_1_bc),
    .CARRYCASCOUT (),
    .MULTSIGNOUT (),
    .PCOUT (mult_pc[0]),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (),
    .P (mult_p[0]),
    .ACIN (),
    .BCIN (),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b10001),
    .OPMODE (7'b0000101),
    .A ({13'b0, dina[16:0]}),
    .B ({1'b0, dinb[16:0]}),
    .C (),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (ena),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (ena),
    .CEB2 (ena),
    .CEC (1'b0),
    .CECARRYIN (1'b1),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (ena),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (1'b0),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (rst),
    .RSTP (rst)
  );

  // multiplier 1
  // inputs: double flop a, cascade b
  // output: cascade

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("CASCADE"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("MULTIPLY"),
    .USE_SIMD ("ONE48"),
    .AUTORESET_PATDET ("NO_RESET"),
    .MASK (48'h3fffffffffff),
    .PATTERN (48'h000000000000),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .ACASCREG (1),
    .ADREG (0),
    .ALUMODEREG (0),
    .AREG (2),
    .BCASCREG (1),
    .BREG (1),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (0),
    .DREG (0),
    .INMODEREG (0),
    .MREG (1),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1_1 (
    .ACOUT (),
    .BCOUT (),
    .CARRYCASCOUT (),
    .MULTSIGNOUT (),
    .PCOUT (mult_pc[1]),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (),
    .P (mult_p[1]),
    .ACIN (),
    .BCIN (mult_1_bc),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (mult_pc[0]),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b10000),
    .OPMODE (7'b1010101),
    .A ({5'h00, dina[41:17]}),
    .B (),
    .C (),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (ena),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (ena),
    .CEB2 (ena),
    .CEC (1'b0),
    .CECARRYIN (1'b1),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (ena),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (1'b0),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (rst),
    .RSTP (rst)
  );

  // multiplier 2
  // inputs: triple flop both
  // output: double flop, [33:17]

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("DIRECT"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("MULTIPLY"),
    .USE_SIMD ("ONE48"),
    .AUTORESET_PATDET ("NO_RESET"),
    .MASK (48'h3fffffffffff),
    .PATTERN (48'h000000000000),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .ACASCREG (1),
    .ADREG (0),
    .ALUMODEREG (0),
    .AREG (2),
    .BCASCREG (1),
    .BREG (2),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (0),
    .DREG (0),
    .INMODEREG (0),
    .MREG (1),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1_2 (
    .ACOUT (),
    .BCOUT (mult_3_bc),
    .CARRYCASCOUT (),
    .MULTSIGNOUT (),
    .PCOUT (mult_pc[2]),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (),
    .P (mult_p[2]),
    .ACIN (),
    .BCIN (),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (mult_pc[1]),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b00000),
    .OPMODE (7'b0010101),
    .A ({13'h0000, mult_2_a}),
    .B (mult_2_b),
    .C (),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (ena),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (ena),
    .CEB2 (ena),
    .CEC (1'b0),
    .CECARRYIN (1'b1),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (ena),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (1'b0),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (rst),
    .RSTP (rst)
  );

  // multiplier 3
  // inputs: quad flop a, cascade b
  // output: single flop, [69:34]

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("CASCADE"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("MULTIPLY"),
    .USE_SIMD ("ONE48"),
    .AUTORESET_PATDET ("NO_RESET"),
    .MASK (48'h3fffffffffff),
    .PATTERN (48'h000000000000),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .ACASCREG (1),
    .ADREG (0),
    .ALUMODEREG (0),
    .AREG (2),
    .BCASCREG (1),
    .BREG (2),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (0),
    .DREG (0),
    .INMODEREG (0),
    .MREG (1),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1_3 (
    .ACOUT (),
    .BCOUT (),
    .CARRYCASCOUT (),
    .MULTSIGNOUT (),
    .PCOUT (),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (),
    .P (mult_p[3]),
    .ACIN (),
    .BCIN (mult_3_bc),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (mult_pc[2]),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b00000),
    .OPMODE (7'b1010101),
    .A ({5'h00, mult_3_a}),
    .B (),
    .C (),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (ena),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (ena),
    .CEB2 (ena),
    .CEC (1'b0),
    .CECARRYIN (1'b1),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (ena),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (1'b0),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (rst),
    .RSTP (rst)
  );

  // connect outputs

  shift_reg #(
    .WIDTH (17),
    .DEPTH (2)
  ) shift_reg_dout_l (
    .clk (clk),
    .ena (ena),
    .din (mult_p[0][16:0]),
    .dout (dout[16:0])
  );

  shift_reg #(
    .WIDTH (17),
    .DEPTH (0)
  ) shift_reg_dout_m (
    .clk (clk),
    .ena (ena),
    .din (mult_p[2][16:0]),
    .dout (dout[33:17])
  );

  assign dout[69:34] = mult_p[3][35:0];

endmodule
