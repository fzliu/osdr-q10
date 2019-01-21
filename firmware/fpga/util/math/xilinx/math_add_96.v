////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 江凯都
//
// Description: Cascades two 48-bit adders into a 96-bit one.
//
// enable  :  active-high
// reset   :  active-high
// latency :  3 cycles
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module math_add_96 (

  input             clk,
  input             rst,
  input             ena,

  // input operands

  input   [ 95:0]   dina,
  input   [ 95:0]   dinb,

  // output sum

  output  [ 96:0]   dout

);

  // internal registers

  wire    [ 47:0]   dinb_u_d;
  wire    [ 47:0]   dout_l;

  // internal signals

  wire              carry_out_0;
  wire    [  3:0]   carry_out_1;

  // delayed b input

  shift_reg #(
    .WIDTH (48),
    .DEPTH (1)
  ) shift_reg_dinb_u (
    .clk (clk),
    .rst (rst),
    .ena (ena),
    .din (dinb[95:48]),
    .dout (dinb_u_d)
  );

  // LSBs adder

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("DIRECT"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("NONE"),
    .USE_SIMD ("ONE48"),
    .AUTORESET_PATDET ("NO_RESET"),
    .MASK (48'h3fffffffffff),
    .PATTERN (48'h000000000000),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .ACASCREG (1),
    .ADREG (1),
    .ALUMODEREG (0),
    .AREG (1),
    .BCASCREG (1),
    .BREG (1),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (1),
    .DREG (1),
    .INMODEREG (0),
    .MREG (0),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1_l (
    .ACOUT (),
    .BCOUT (),
    .CARRYCASCOUT (carry_out_0),
    .MULTSIGNOUT (),
    .PCOUT (),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (),
    .P (dout_l),
    .ACIN (),
    .BCIN (),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b10001),
    .OPMODE (7'b0001111),
    .A (dina[47:18]),
    .B (dina[17:0]),
    .C (dinb[47:0]),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (1'b0),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (1'b0),
    .CEB2 (ena),
    .CEC (ena),
    .CECARRYIN (1'b0),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (1'b0),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (rst),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (1'b0),
    .RSTP (rst)
  );

  // MSBs adder

  DSP48E1 #(
    .A_INPUT ("DIRECT"),
    .B_INPUT ("DIRECT"),
    .USE_DPORT ("FALSE"),
    .USE_MULT ("NONE"),
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
    .CARRYINSELREG (1),
    .CREG (1),
    .DREG (0),
    .INMODEREG (0),
    .MREG (0),
    .OPMODEREG (1),   // if set to 0, warning occurs (CARRYINSEL == 3'b010)
    .PREG (1)
  ) DSP48E1_u (
    .ACOUT (),
    .BCOUT (),
    .CARRYCASCOUT (),
    .MULTSIGNOUT (),
    .PCOUT (),
    .OVERFLOW (),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .UNDERFLOW (),
    .CARRYOUT (carry_out_1),
    .P (dout[95:48]),
    .ACIN (),
    .BCIN (),
    .CARRYCASCIN (carry_out_0),
    .MULTSIGNIN (),
    .PCIN (),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b010),
    .CLK (clk),
    .INMODE (5'b00000),
    .OPMODE (7'b0001111),
    .A (dina[95:66]),
    .B (dina[65:48]),
    .C (dinb_u_d),
    .CARRYIN (1'b0),
    .D (),
    .CEA1 (1'b0),
    .CEA2 (ena),
    .CEAD (1'b0),
    .CEALUMODE (1'b1),
    .CEB1 (1'b0),
    .CEB2 (ena),
    .CEC (ena),
    .CECARRYIN (1'b1),
    .CECTRL (1'b1),
    .CED (1'b0),
    .CEINMODE (1'b1),
    .CEM (1'b0),
    .CEP (ena),
    .RSTA (rst),
    .RSTALLCARRYIN (1'b0),
    .RSTALUMODE (1'b0),
    .RSTB (rst),
    .RSTC (rst),
    .RSTCTRL (1'b0),
    .RSTD (1'b0),
    .RSTINMODE (1'b0),
    .RSTM (1'b0),
    .RSTP (rst)
  );

  // flop the outputs

  shift_reg #(
    .WIDTH (48),
    .DEPTH (1)
  ) shift_reg_dout_l (
    .clk (clk),
    .rst (rst),
    .ena (ena),
    .din (dout_l),
    .dout (dout[47:0])
  );

  assign dout[96] = carry_out_1[3];

endmodule
