////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Stores AXI-stream data in distributed RAM. The memory is
// treated like a circular buffer, with the first element being overwritten
// once all elements of the RAM have been written to.
//
// enable  :  N/A
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_to_mem #(

  // parameters

  parameter   MEMORY_TYPE = "auto",
  parameter   MEMORY_DEPTH = 32,
  parameter   DATA_WIDTH = 32,
  parameter   READ_LATENCY = 1,

  // derived parameters

  localparam  MEMORY_SIZE = DATA_WIDTH * MEMORY_DEPTH,
  localparam  ADDR_WIDTH = log2(MEMORY_DEPTH - 1),

  // bit width parameters

  localparam  W0 = MEMORY_DEPTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WA = ADDR_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // axi-stream interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input             s_axis_tlast,

  // memory read interface

  input   [ WA:0]   addr,
  output            valid,
  output  [ WD:0]   data

);

  `include "func_log2.vh"

  // internal registers

  reg     [ W0:0]   has_data = 'b0;

  // internal signals

  wire    [ WA:0]   wr_addr;
  wire    [ WA:0]   rd_addr;
  wire    [ WD:0]   rd_data;

  // slave interface

  assign s_axis_tready = 1'b1;

  // read/write logic

  assign rd_addr = addr + wr_addr;

  generate
  genvar i;
  for (i = 0; i < MEMORY_DEPTH; i = i + 1) begin
    always @(posedge clk) begin
      if (rst | s_axis_tlast) begin
        has_data[i] <= 1'b0;
      end else if (s_axis_tvalid) begin
        has_data[i] <= (wr_addr == i) ? 1'b1 : has_data[i];
      end else begin
        has_data[i] <= has_data[i];
      end
    end
  end
  endgenerate

  // address counter

  counter #(
    .LOWER (0),
    .UPPER (MEMORY_DEPTH - 1),
    .WRAPAROUND (1)
  ) counter (
    .clk (clk),
    .ena (s_axis_tvalid),
    .rst (rst | s_axis_tlast),
    .value (wr_addr)
  );

  // memory instantiation

  xpm_memory_sdpram # (
    .MEMORY_SIZE (MEMORY_SIZE),
    .MEMORY_PRIMITIVE (MEMORY_TYPE),
    .CLOCKING_MODE ("common_clock"),
    .MEMORY_INIT_FILE ("none"),
    .MEMORY_INIT_PARAM ("0"),
    .USE_MEM_INIT (0),
    .WAKEUP_TIME ("disable_sleep"),
    .MESSAGE_CONTROL (0),
    .ECC_MODE ("no_ecc"),
    .AUTO_SLEEP_TIME (0),
    .USE_EMBEDDED_CONSTRAINT (0),
    .MEMORY_OPTIMIZATION ("true"),
    .WRITE_DATA_WIDTH_A (DATA_WIDTH),
    .BYTE_WRITE_WIDTH_A (DATA_WIDTH),
    .ADDR_WIDTH_A (ADDR_WIDTH),
    .READ_DATA_WIDTH_B (DATA_WIDTH),
    .ADDR_WIDTH_B (ADDR_WIDTH),
    .READ_RESET_VALUE_B ("0"),
    .READ_LATENCY_B (READ_LATENCY),
    .WRITE_MODE_B ("read_first")
  ) xpm_memory_sdpram (
    .sleep (1'b0),
    .clka (clk),
    .ena (1'b1),
    .wea (s_axis_tvalid),
    .addra (wr_addr),
    .dina (s_axis_tdata),
    .injectsbiterra (1'b0),
    .injectdbiterra (1'b0),
    .clkb (1'b0),
    .rstb (rst),
    .enb (1'b1),
    .regceb (1'b1),
    .addrb (rd_addr),
    .doutb (data),
    .sbiterrb (),
    .dbiterrb ()
  );

  // output valid

  shift_reg #(
    .WIDTH (1),
    .DEPTH (READ_LATENCY)
  ) shift_reg (
    .clk (clk),
    .ena (1'b1),
    .din (has_data[wr_addr]),
    .dout (valid)
  );

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
