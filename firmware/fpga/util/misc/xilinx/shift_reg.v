////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterizable shift register utility, Xilinx devices.
// DEPTH = 0 implies a 1-cycle shift register.
//
// enable  :  active-high
// reset   :  N/A
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module shift_reg #(

  // parameters

  parameter   WIDTH = 1,
  parameter   DEPTH = 7,

  // derived parameters

  localparam  NUM_CASCADE = DEPTH / 32,
  localparam  DEPTH_LAST  = DEPTH - NUM_CASCADE * 32,

  // bit width parameters

  localparam  W0 = WIDTH - 1,
  localparam  W1 = NUM_CASCADE

) (

  // master interface

  input             clk,
  input             ena,

  // data interface

  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  // internal signals

  wire    [ W1:0]   shift [W0:0];

  // shift register implementation

  genvar i, j;
  generate
  for (i = 0; i < WIDTH; i = i + 1) begin : shift_gen

    // assign input

    assign shift[i][W1] = din[i];

    // use SRL16 for short shift registers

    if (DEPTH < 16) begin

      // single SRL16 for short shift registers

      SRL16E #(
        .INIT(16'h0000)
      ) SRL16E_inst (
        .Q (dout[i]),
        .A0 (DEPTH[0]),
        .A1 (DEPTH[1]),
        .A2 (DEPTH[2]),
        .A3 (DEPTH[3]),
        .CE (ena),
        .CLK (clk),
        .D (shift[i][0])
      );

    end else begin

      // cascade SRL32 for long shift registers

      for (j = 0; j < NUM_CASCADE; j = j + 1) begin : casc_gen
        SRLC32E #(
          .INIT (32'h00000000)
        ) SRLC32E_inst (
          .Q (),
          .Q31 (shift[i][j]),
          .A (5'd31),
          .CE (ena),
          .CLK (clk),
          .D (shift[i][j+1])
        );
      end
      SRLC32E #(
        .INIT (32'h00000000)
      ) SRLC32E_inst (
        .Q (dout[i]),
        .Q31 (),
        .A (DEPTH_LAST[4:0]),
        .CE (ena),
        .CLK (clk),
        .D (shift[i][0])
      );

    end

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
