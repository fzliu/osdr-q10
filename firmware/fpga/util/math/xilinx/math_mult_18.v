////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Single 25x18 multiplier.
//
// enable  :  active-high
// reset   :  active-high
// latency :  3 cycles
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module math_mult_18 (

  input             clk,
  input             rst,
  input             ena,

  // input operands

  input   [ 24:0]   dina,
  input   [ 17:0]   dinb,

  // output sum

  output  [ 42:0]   dout

);

  // internal signals

  wire    [ 47:0]   mult_p;

  // DSP multiplier

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
    .ADREG (1),
    .ALUMODEREG (0),
    .AREG (1),
    .BCASCREG (1),
    .BREG (1),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (0),
    .DREG (1),
    .INMODEREG (0),
    .MREG (1),
    .OPMODEREG (0),
    .PREG (1)
  ) DSP48E1 (
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
    .P (mult_p),
    .ACIN (),
    .BCIN (),
    .CARRYCASCIN (),
    .MULTSIGNIN (),
    .PCIN (),
    .ALUMODE (4'b0000),
    .CARRYINSEL (3'b000),
    .CLK (clk),
    .INMODE (5'b00000),
    .OPMODE (7'b0000101),
    .A ({5'h00, dina}),
    .B (dinb),
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

  assign dout = mult_p[42:0];

endmodule
