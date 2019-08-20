////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧�?
//
// Description: A fast base-2 anti-logarithm function
// The input and output have binary points:
// In: xxxxxx.yyyy; Out: xxxx_xxxx_xxxx_xxxx.yyyy_yyyy.
//
// enable  :  active-high
// reset   :  active-high
// latency :  ? cycles
//
////////////////////////////////////////////////////////////////////////////////

module math_pow2_9 (

  // core interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  input   [ 8:0]   din,
  output  [31:0]   dout

);

  // Comprises 2 main blocks: barrel shifter & LUT

  reg     [ 3:0]   barrelshfcnt = 'b0;
  reg     [22:0]   lut_out = 'b0;
  reg     [39:0]   dout1 = 'b0;
  wire    [54:0]   tmp1 = ({1'b1, lut_out}  <<  barrelshfcnt);

  always @(posedge clk) begin
    if (rst) begin
      barrelshfcnt <= 'b0;
      dout1 <= 'b0;
    end else if (ena) begin
      barrelshfcnt <= din[8:4];
      dout1 <= tmp1[54:15];
    end
  end

  assign dout = dout1[39:8];

  // LUT for one octave of antilog lookup
  // The equation is: output = (2^(input/16)-1) * 2^23
  // For larger tables, better to generate a separate data file using a program!

  always @(posedge clk) begin
    if (rst) begin
      lut_out <= 'b0;
    end else if (ena) begin
      case (din[3:0])
        0 : lut_out <= 0;
        1 : lut_out <= 371395;
        2 : lut_out <= 759234;
        3 : lut_out <= 1164243;
        4 : lut_out <= 1587184;
        5 : lut_out <= 2028850;
        6 : lut_out <= 2490071;
        7 : lut_out <= 2971711;
        8 : lut_out <= 3474675;
        9 : lut_out <= 3999908;
        10: lut_out <= 4548394;
        11: lut_out <= 5121164;
        12: lut_out <= 5719293;
        13: lut_out <= 6343903;
        14: lut_out <= 6996167;
        15: lut_out <= 7677309;
        default : lut_out <= 'b0;
      endcase
    end
  end

endmodule

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////