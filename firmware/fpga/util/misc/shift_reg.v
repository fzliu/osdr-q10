////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Parameterizable shift register utility for any device. DEPTH == 0 will set
// dout = din.
//
// Signals
// enable  :  active-high
// reset   :  active-high
// latency :  DEPTH
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module shift_reg #(

  // parameters

  parameter   WIDTH = 1,
  parameter   DEPTH = 32,
  parameter   USE_RAM = 0,  // TODO(fzliu): DEPTH >= 2 if USE_RAM == 1
  parameter   DEVICE = "7SERIES",

  // derived parameters

  localparam  RAM_LATENCY = (DEPTH >= 3) ? 2 : 1,
  localparam  ADDR_WIDTH = log2(DEPTH - RAM_LATENCY),

  // bit width parameters

  localparam  W0 = WIDTH - 1,
  localparam  D0 = DEPTH - 1,
  localparam  WA = ADDR_WIDTH - 1

) (

  // master interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  `include "func_log2.vh"

  // internal memories

  reg     [ W0:0]   shift_ram [D0:0];
  reg     [ W0:0]   shift_ff [D0:0];

  // internal registers

  reg     [ WA:0]   wr_addr = 'b0;
  reg     [ W0:0]   ram_dout = 'b0;
  reg     [ W0:0]   dout_reg = 'b0;

  // internal signals

  wire    [ WA:0]   rd_addr;

  /* Shift register implementation.
   */

  genvar n;
  generate
  if (DEPTH == 0) begin

    assign dout = din;

  end else if (USE_RAM) begin

    /* Initialize RAM.
     * The initial memory contents to 0.
     */

    for (n = 0; n < DEPTH; n = n + 1) begin
      initial begin
        shift_ram[n] = 'b0;
      end
    end

    /* Address counter.
     * This counter tracks the read address. Since the RAM is pre-configured
     * to have a total size which matches the desired shift register depth,
     * the write address is simply addr - 1 if no output register is used, or
     * addr - 2 if an output register is used.
     */

    counter #(
      .LOWER (0),
      .UPPER (D0 - (RAM_LATENCY == 2)),
      .WRAPAROUND (1),
      .INIT_VALUE (1)
    ) counter_rd_addr (
      .clk (clk),
      .rst (rst),
      .ena (ena),
      .value (rd_addr)
    );

    always @(posedge clk) begin
      if (rst) begin
        wr_addr <= 'b0;
      end else if (ena) begin
        wr_addr <= rd_addr;
      end else begin
        wr_addr <= wr_addr;
      end
    end

    /* RAM definition.
     * The RAM module is paired with a counter which takes the output latency
     * into consideration.
     */

    always @(posedge clk) begin
      if (ena) begin
        shift_ram[wr_addr] <= din;
      end
    end

    always @(posedge clk) begin
      if (ena) begin
        ram_dout <= shift_ram[rd_addr];
      end
    end

    /* Assign output.
     * The output will need to go through either 0 or 1 cycles of extra latency,
     * depending on the RAM_LATENCY. This is done to improve block RAM timing.
     */

    if (RAM_LATENCY == 2) begin
      always @(posedge clk) begin
        if (rst) begin
          dout_reg <= 'b0;
        end else if (ena) begin
          dout_reg <= ram_dout;
        end else begin
          dout_reg <= dout_reg;
        end
      end
    end else begin
      always @* begin
        dout_reg = ram_dout;
      end
    end

  end else begin

    /* Initialize flops.
     * The initial memory for all flops is set to 0.
     */

    for (n = 0; n < DEPTH; n = n + 1) begin
      initial begin
        shift_ff[n] = 'b0;
      end
    end

    /* Shift flops LSB to MSB.
     * In this configuration, we shift data in the flops LSB to MSB. LSB is
     * the input, and MSB is the output, so the shift register is effectively
     * operating right-to-left.
     */

    for (n = 0; n < DEPTH; n = n + 1) begin
      always @(posedge clk) begin
        if (rst) begin
          shift_ff[n] <= 'b0;
        end else if (ena) begin
          shift_ff[n] <= (n == 0) ? din : shift_ff[n-1];
        end else begin
          shift_ff[n] <= shift_ff[n];
        end
      end
    end

    /* Assign output.
     * The output of the module is, by definition, the last element in the shift
     * register.
     */

    always @* begin
      dout_reg = shift_ff[D0];
    end

  end

  endgenerate

  /* Output data.
   */

  assign dout = dout_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
