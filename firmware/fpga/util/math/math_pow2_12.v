////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慧
//
// Description: A fast base-2 anti-logarithm function
// The input and output have binary points: In: xxxxxx.yyyy_yy; Out: xxxx_xxxx_xxxx_xxxx.yyyy_yyyy.
//
// enable  :  N/A
// reset   :  active-high
// latency :  0 cycles
//
////////////////////////////////////////////////////////////////////////////////

module math_pow2_12 (

  // core interface

  input             clk,

  // data interface

  input   [11:0]   din,
  output  [33:0]   dout

);

  // Comprises 2 main blocks: barrel shifter & LUT

  reg     [ 5:0]   barrelshfcnt;
  reg     [22:0]   lut_out;
  reg     [71:0]   dout1;
  wire    [86:0]   tmp1 = ({1'b1, lut_out}  <<  barrelshfcnt);

  always @(posedge clk) begin
    barrelshfcnt <= din[11:6];
    dout1 <= tmp1[86:15];
  end

  assign dout = dout1[41:8];

  // LUT for one octave of antilog lookup
  // The equation is: output = (2^(input/64)-1) * 2^23
  // For larger tables, better to generate a separate data file using a program!

  always @(posedge clk)
    case (din[5:0])
      0 : lut_out <= 0;
      1 : lut_out <= 91346;
      2 : lut_out <= 183687;
      3 : lut_out <= 277033;
      4 : lut_out <= 371395;
      5 : lut_out <= 466786;
      6 : lut_out <= 563215;
      7 : lut_out <= 660693;
      8 : lut_out <= 759234;
      9 : lut_out <= 858847;
      10: lut_out <= 959546;
      11: lut_out <= 1061340;
      12: lut_out <= 1164243;
      13: lut_out <= 1268267;
      14: lut_out <= 1373424;
      15: lut_out <= 1479725;
      16: lut_out <= 1587184;
      17: lut_out <= 1695814;
      18: lut_out <= 1805626;
      19: lut_out <= 1916634;
      20: lut_out <= 2028850;
      21: lut_out <= 2142289;
      22: lut_out <= 2256963;
      23: lut_out <= 2372886;
      24: lut_out <= 2490071;
      25: lut_out <= 2608532;
      26: lut_out <= 2728283;
      27: lut_out <= 2849338;
      28: lut_out <= 2971711;
      29: lut_out <= 3095417;
      30: lut_out <= 3220470;
      31: lut_out <= 3346884;
      32: lut_out <= 3474675;
      33: lut_out <= 3603858;
      34: lut_out <= 3734447;
      35: lut_out <= 3866459;
      36: lut_out <= 3999908;
      37: lut_out <= 4134810;
      38: lut_out <= 4271181;
      39: lut_out <= 4409037;
      40: lut_out <= 4548394;
      41: lut_out <= 4689269;
      42: lut_out <= 4831678;
      43: lut_out <= 4975637;
      44: lut_out <= 5121164;
      45: lut_out <= 5268276;
      46: lut_out <= 5416990;
      47: lut_out <= 5567323;
      48: lut_out <= 5719293;
      49: lut_out <= 5872918;
      50: lut_out <= 6028216;
      51: lut_out <= 6185205;
      52: lut_out <= 6343903;
      53: lut_out <= 6504329;
      54: lut_out <= 6666503;
      55: lut_out <= 6830442;
      56: lut_out <= 6996167;
      57: lut_out <= 7163696;
      58: lut_out <= 7333050;
      59: lut_out <= 7504247;
      60: lut_out <= 7677309;
      61: lut_out <= 7852255;
      62: lut_out <= 8029107;
      63: lut_out <= 8207884;
    endcase

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
