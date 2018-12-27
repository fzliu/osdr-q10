////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧惿
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
  input             rst,
  input             ena, 
 
  // data interface

  input   [11:0]   din,
  output  [33:0]   dout

);

  // Comprises 2 main blocks: barrel shifter & LUT

  reg     [ 5:0]   barrelshfcnt = 'b0;
  reg     [22:0]   lut_out = 'b0;
  reg     [22:0]   lut_out_reg = 'b0;
  reg     [71:0]   dout1 = 'b0;
  wire    [86:0]   tmp1 = ({1'b1, lut_out}  <<  barrelshfcnt);

  always @(posedge clk) begin
    if (rst) begin
      barrelshfcnt <= 'b0;  
      dout1 <= 'b0;            
    end else if (ena) begin
      barrelshfcnt <= din[11:6];
      dout1 <= tmp1[86:15];     
    end       
  end

  assign dout = dout1[41:8];

  // LUT for one octave of antilog lookup
  // The equation is: output = (2^(input/64)-1) * 2^23
  // For larger tables, better to generate a separate data file using a program!

  always @(posedge clk) begin
    if (rst) begin
      lut_out_reg <= 'b0;
    end else if (ena) begin
      case (din[5:0])
        0 : lut_out_reg <= 0;
        1 : lut_out_reg <= 91346;
        2 : lut_out_reg <= 183687;
        3 : lut_out_reg <= 277033;
        4 : lut_out_reg <= 371395;
        5 : lut_out_reg <= 466786;
        6 : lut_out_reg <= 563215;
        7 : lut_out_reg <= 660693;
        8 : lut_out_reg <= 759234;
        9 : lut_out_reg <= 858847;
        10: lut_out_reg <= 959546;
        11: lut_out_reg <= 1061340;
        12: lut_out_reg <= 1164243;
        13: lut_out_reg <= 1268267;
        14: lut_out_reg <= 1373424;
        15: lut_out_reg <= 1479725;
        16: lut_out_reg <= 1587184;
        17: lut_out_reg <= 1695814;
        18: lut_out_reg <= 1805626;
        19: lut_out_reg <= 1916634;
        20: lut_out_reg <= 2028850;
        21: lut_out_reg <= 2142289;
        22: lut_out_reg <= 2256963;
        23: lut_out_reg <= 2372886;
        24: lut_out_reg <= 2490071;
        25: lut_out_reg <= 2608532;
        26: lut_out_reg <= 2728283;
        27: lut_out_reg <= 2849338;
        28: lut_out_reg <= 2971711;
        29: lut_out_reg <= 3095417;
        30: lut_out_reg <= 3220470;
        31: lut_out_reg <= 3346884;
        32: lut_out_reg <= 3474675;
        33: lut_out_reg <= 3603858;
        34: lut_out_reg <= 3734447;
        35: lut_out_reg <= 3866459;
        36: lut_out_reg <= 3999908;
        37: lut_out_reg <= 4134810;
        38: lut_out_reg <= 4271181;
        39: lut_out_reg <= 4409037;
        40: lut_out_reg <= 4548394;
        41: lut_out_reg <= 4689269;
        42: lut_out_reg <= 4831678;
        43: lut_out_reg <= 4975637;
        44: lut_out_reg <= 5121164;
        45: lut_out_reg <= 5268276;
        46: lut_out_reg <= 5416990;
        47: lut_out_reg <= 5567323;
        48: lut_out_reg <= 5719293;
        49: lut_out_reg <= 5872918;
        50: lut_out_reg <= 6028216;
        51: lut_out_reg <= 6185205;
        52: lut_out_reg <= 6343903;
        53: lut_out_reg <= 6504329;
        54: lut_out_reg <= 6666503;
        55: lut_out_reg <= 6830442;
        56: lut_out_reg <= 6996167;
        57: lut_out_reg <= 7163696;
        58: lut_out_reg <= 7333050;
        59: lut_out_reg <= 7504247;
        60: lut_out_reg <= 7677309;
        61: lut_out_reg <= 7852255;
        62: lut_out_reg <= 8029107;
        63: lut_out_reg <= 8207884;
        default : lut_out_reg <= 'b0;
      endcase
    end
  end

  always @(posedge clk) begin    
    if (rst) begin 
      lut_out <='b0;                    
    end else if (ena) begin     
      lut_out <= lut_out_reg;                       
    end
  end
endmodule

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////