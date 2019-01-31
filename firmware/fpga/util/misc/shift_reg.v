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
  parameter   USE_BRAM = 0,   // TODO(fzliu): DEPTH >= 2 if USE_BRAM == 1
  parameter   DEVICE = "7SERIES",

  // derived parameters

  localparam  BRAM_LATENCY = (DEPTH >= 3) ? 2 : 1,
  localparam  BRAM_DEPTH = DEPTH - BRAM_LATENCY + 1,
  localparam  ADDR_WIDTH = log2(BRAM_DEPTH - 1),

  // bit width parameters

  localparam  W0 = WIDTH - 1,
  localparam  D0 = DEPTH - 1,
  localparam  DB = BRAM_DEPTH - 1,
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

  reg     [ D0:0]   shift [W0:0];

  // internal registers

  reg     [ WA:0]   addr_d = 'b0;

  // internal signals

  wire    [ WA:0]   addr;

  /* Shift register implementation.
   */

  genvar n;
  generate
  if (DEPTH == 0) begin

    assign dout = din;

  end else begin

    if (USE_BRAM && DEVICE == "7SERIES") begin

      /* Block RAM instantiation.
       * The RAM module is paired with a counter which takes the output latency
       * into consideration.
       */

      xpm_memory_sdpram #(
        .MEMORY_SIZE (WIDTH * BRAM_DEPTH),
        .MEMORY_PRIMITIVE ("block"),
        .CLOCKING_MODE ("common_clock"),
        .MEMORY_INIT_FILE ("none"),
        .MEMORY_INIT_PARAM (""),
        .USE_MEM_INIT (1),
        .WAKEUP_TIME ("disable_sleep"),
        .MESSAGE_CONTROL (0),
        .ECC_MODE ("no_ecc"),
        .AUTO_SLEEP_TIME (0),
        .USE_EMBEDDED_CONSTRAINT (0),
        .MEMORY_OPTIMIZATION ("true"),
        .WRITE_DATA_WIDTH_A (WIDTH),
        .BYTE_WRITE_WIDTH_A (WIDTH),
        .ADDR_WIDTH_A (ADDR_WIDTH),
        .READ_DATA_WIDTH_B (WIDTH),
        .ADDR_WIDTH_B (ADDR_WIDTH),
        .READ_RESET_VALUE_B ("0"),
        .READ_LATENCY_B (BRAM_LATENCY),
        .WRITE_MODE_B ("read_first")
      ) xpm_memory_sdpram (
        .sleep (1'b0),
        .clka (clk),
        .ena (ena),
        .wea (1'b1),
        .addra (addr_d),
        .dina (din),
        .injectsbiterra (1'b0),
        .injectdbiterra (1'b0),
        .clkb (1'b0),
        .rstb (rst),
        .enb (ena),
        .regceb (1'b1),
        .addrb (addr),
        .doutb (dout),
        .sbiterrb (),
        .dbiterrb ()
      );

      /* Address counter.
       * This counter tracks the read address. Since the RAM is pre-configured
       * to have a total size which matches the desired shift register depth,
       * the write address is simply addr - 1.
       */

       counter #(
         .LOWER (0),
         .UPPER (DB),
         .WRAPAROUND (1),
         .INIT_VALUE (1)
       ) counter_addr (
         .clk (clk),
         .rst (1'b0),
         .ena (ena),
         .value (addr)
       );

       always @(posedge clk) begin
         if (ena) begin
           addr_d <= addr;
         end
       end

    end else begin

      for (n = 0; n < WIDTH; n = n + 1) begin

        /* Initialize flops.
         * The initial memory for all flops is set to 0.
         */

        initial begin
          shift[n] <= 'b0;
        end

        /* Shift flops LSB to MSB.
         * In this configuration, LSB is the input, and MSB is the output, so the
         * shift register is effectively operating right-to-left.
         */

        always @(posedge clk) begin
          if (rst) begin
            shift[n] <= 'b0;
          end else if (ena) begin
            shift[n] <= (D0 == 0) ? din[n] : {shift[n][D0-1:0], din[n]};
          end
        end

        /* Assign outputs.
         */

        assign dout[n] = shift[n][D0];

      end

    end

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
