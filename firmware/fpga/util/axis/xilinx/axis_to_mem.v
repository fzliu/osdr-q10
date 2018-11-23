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
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_to_mem #(

  // parameters

  parameter   MEMORY_TYPE = "distributed",
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
  output  [ WD:0]   dout

);

  `include "log2_func.v"

  // internal registers

  reg     [ W0:0]   valid = 'b0;

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
  for (i = 0; i < MEMORY_DEPTH; i = i + 1) begin: valid_gen
    always @(posedge clk) begin
      if (rst | s_axis_tlast) begin
        valid[i] <= 1'b0;
      end else if (s_axis_tvalid) begin
        valid[i] <= (wr_addr == i) ? 1'b1 : valid[i];
      end else begin
        valid[i] <= valid[i];
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
    .MEMORY_INIT_PARAM (""),
    .USE_MEM_INIT (1),
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
    .clkb (clk),
    .rstb (rst),
    .enb (1'b1),
    .regceb (regceb),
    .addrb (rd_addr),
    .doutb (rd_data),
    .sbiterrb (),
    .dbiterrb ()
  );

  // output value

  assign dout = valid[wr_addr] ? rd_data : {DATA_WIDTH{1'b0}};

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
