////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterizable shift register utility, Xilinx devices.
// DEPTH must be >= 1 (DEPTH = 1 implies a 1-cycle shift register).
//
// enable  :  active-high
// reset   :  N/A
// latency :  variable
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module shift_reg #(

  // parameters

  parameter   WIDTH = 1,
  parameter   DEPTH = 7,
  parameter   USE_FFS = 1,

  // derived parameters

  localparam  NUM_CASCADE = DEPTH / 32,
  localparam  DEPTH_LAST  = DEPTH - NUM_CASCADE * 32,

  // bit width parameters

  localparam  W0 = WIDTH - 1,
  localparam  D0 = DEPTH - 1,
  localparam  N0 = NUM_CASCADE,
  localparam  DL = DEPTH_LAST - 1

) (

  // master interface

  input             clk,
  input             ena,

  // data interface

  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  // internal registers

  reg     [ D0:0]   shift_ff [W0:0];

  // internal signals

  wire    [ N0:0]   shift [W0:0];

  genvar n, c;
  generate
  for (n = 0; n < WIDTH; n = n + 1) begin

    if (USE_FFS) begin

      // initialize flip-flops

      initial begin
        shift_ff[n] <= 'b0;
      end

      // shift register implementation

      always @(posedge clk) begin
        if (ena) begin
          shift_ff[n] <= {shift_ff[n][D0-1:0], din[n]};
        end
      end

      // assign outputs

      assign dout[n] = shift_ff[n][D0];

    end else begin

      // assign inputs

      assign shift[n][N0] = din[n];

      // LUTRAM-based shift register

      if (DEPTH < 16) begin // single SRL16 for short shift registers
        SRL16E #(
          .INIT(16'h0000)
        ) SRL16E_inst (
          .Q (dout[n]),
          .A0 (D0[0]),
          .A1 (D0[1]),
          .A2 (D0[2]),
          .A3 (D0[3]),
          .CE (ena),
          .CLK (clk),
          .D (shift[n][0])
        );
      end else begin // cascade SRL32 for long shift registers
        for (c = 0; c < NUM_CASCADE; c = c + 1) begin
          SRLC32E #(
            .INIT (32'h00000000)
          ) SRLC32E_inst (
            .Q (),
            .Q31 (shift[n][c]),
            .A (5'd31),
            .CE (ena),
            .CLK (clk),
            .D (shift[n][c+1])
          );
        end
        SRLC32E #(
          .INIT (32'h00000000)
        ) SRLC32E_inst (
          .Q (dout[n]),
          .Q31 (),
          .A (DL),
          .CE (ena),
          .CLK (clk),
          .D (shift[n][0])
        );
      end

    end

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
