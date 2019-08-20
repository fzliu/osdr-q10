////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// RAM block for bit correlator.
//
// Parameters
// NUM_PARALLEL: number of parallel input data streams (must be power of 2)
// ADDER_WIDTH:
// NUM_CORRS:
//
// Signals
// enable  :  active-high
// reset   :  N/A
// latency :  0 cycles
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module corr_ram_blk #(

  // parameters

  parameter   NUM_PARALLEL = 8,       // TODO(fzliu): ensure this is 2^N
  parameter   DATA_WIDTH = 12,        // TODO(fzliu): ensure this is 2*N
  parameter   NUM_CORRS = 1,          // TODO(fzliu): ensure this is 2^N

  // derived parameters

  localparam  MEMORY_DEPTH = NUM_PARALLEL * NUM_CORRS,
  localparam  ADDR_WIDTH = log2(MEMORY_DEPTH - 1),

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  DM = MEMORY_DEPTH - 1,
  localparam  WA = ADDR_WIDTH - 1

) (

  // core interface

  input             clk,
  input             ena,

  // address busses

  input   [ WA:0]   rd_addr,
  input   [ WA:0]   wr_addr,

  // data interface

  input   [ WD:0]   din,
  output  [ WD:0]   dout

);

  `include "func_log2.vh"

  // internal memories

  reg     [ WD:0]   corr_ram [0:DM];

  /* Initialize memory.
   */

  genvar n;
  generate
  for (n = 0; n < MEMORY_DEPTH; n = n + 1) begin
    initial begin
      corr_ram[n] <= 'b0;
    end
  end
  endgenerate

  /* Write port.
   */

  always @(posedge clk) begin
    if (ena) begin
      corr_ram[wr_addr] <= din;
    end
  end

  /* Read port.
   */

  assign dout = corr_ram[rd_addr];

endmodule
