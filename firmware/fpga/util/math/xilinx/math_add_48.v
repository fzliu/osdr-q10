////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 江凯都
//
// Description: Single 48-bit adder, with fabric option.
//
// enable  :  active-high
// reset   :  active-high
// latency :  2 cycles (DSP), 1 cycle (fabric)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module math_add_48 #(

  parameter   USE_FABRIC = 0

)(

  input             clk,
  input             rst,
  input             ena,

  // input operands

  input   [ 47:0]   dina,
  input   [ 47:0]   dinb,

  // output sum

  output  [ 48:0]   dout

);

  // internal registers

  reg     [ 48:0]  dout_reg = 'b0;

  // internal signals

  wire    [  3:0]  carry_out;

  // adder implementation

  generate
  if (USE_FABRIC) begin

    // fabric adder

    always @(posedge clk) begin
      dout_reg <= dina + dinb;
    end

    assign dout = dout_reg;

  end else begin

    // DSP adder

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
      .AREG (1),
      .BCASCREG (1),
      .BREG (1),
      .CARRYINREG (0),
      .CARRYINSELREG (0),
      .CREG (1),
      .DREG (0),
      .INMODEREG (0),
      .MREG (0),
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
      .CARRYOUT (carry_out),
      .P (dout[47:0]),
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
      .C (dinb),
      .CARRYIN (1'b0),
      .D (),
      .CEA1 (ena),
      .CEA2 (ena),
      .CEAD (1'b0),
      .CEALUMODE (1'b1),
      .CEB1 (ena),
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

    assign dout[48] = carry_out[3];

  end
  endgenerate

endmodule
