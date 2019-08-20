////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Parameterized module which computes the moving average of the inputs (aka
// boxcar filter). This module is synchronous, and is computed by adding the
// newest value while subtracting the oldest. This module must be reset before
// use. No overflow checking is performed.
//
// Signals
// enable  :  active-high
// reset   :  active-high
// latency :  2 cycles
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module filt_boxcar #(

  // parameters

  parameter   DATA_WIDTH = 16,
  parameter   NUM_CHANNELS = 1,
  parameter   FILTER_LENGTH = 8,
  parameter   SHIFT_REG_USE_RAM = 0,

  // derived parameters

  localparam  COUNT_WIDTH = log2(NUM_CHANNELS - 1),

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  NC = NUM_CHANNELS - 1,
  localparam  WN = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  input   [ WD:0]   din,
  output  [ WD:0]   dout

);

  `include "func_log2.vh"

  // internal memories

  reg     [ WD:0]   sum_mem [0:NC];

  // internal registers

  reg     [ WD:0]   sum_diff = 'b0;
  reg     [ WN:0]   count_d = 'b0;

  // internal signals

  wire    [ WN:0]   count;
  wire    [ WD:0]   shift_out;

  /* Initialize output memory.
   * This prevents values from appearing on the output of this module before any
   * computation has occurred.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    initial begin
      sum_mem[n] = 'b0;
    end
  end
  endgenerate

  /* Shift register instantiation.
   * Because data is assumed to be shifted into filt_boxcar in serial fashion,
   * this shift register should accomodate the enough elements to store the
   * length multiplied by the number of channels.
   */

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (NUM_CHANNELS * FILTER_LENGTH),
    .USE_RAM (SHIFT_REG_USE_RAM)
  ) shift_reg (
    .clk (clk),
    .rst (rst),
    .ena (ena),
    .din (din),
    .dout (shift_out)
  );

  /* Index counter.
   * Since we have an extra cycle of output latency to accomodate high
   * performance applications, this count should always be at the "previous"
   * value. As a result, we start it with an initial value of NUM_CHANNELS - 1
   * rather than 0. Assuming filt_boxcar has been parameterized correctly, this
   * should have no effect on the output result, since all elements of the shift
   * register have been pre-initialized to 0.
   */

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (1),
    .INIT_VALUE (NC)  // active channel always preceding current
  ) counter (
    .clk (clk),
    .rst (1'b0),
    .ena (ena),
    .at_max (),
    .value (count)
  );

  /* Boxcar filter implementation.
   * For a filter length of n, note the following:
   * x[1] + x[2] + ... + x[n] =
   * x[0] + x[1] + ... + x[n-1] + (x[n] - x[0])
   * In other words, we can simply subtract continuously subtract the oldest
   * value from the newest one to implement this filter with minimal resources.
   */

  always @(posedge clk) begin
    if (rst) begin
      sum_diff <= 'b0;
    end else if (ena) begin
      sum_diff <= din - shift_out;
    end else begin
      sum_diff <= sum_diff;
    end
  end

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    always @(posedge clk) begin
      if (rst) begin
        sum_mem[n] <= 'b0;
      end else if (ena & (n == count)) begin
        sum_mem[n] <= sum_mem[count] + sum_diff;
      end else begin
        sum_mem[n] <= sum_mem[n];
      end
    end
  end
  endgenerate

  /* Assign output.
   * We do this by first indexing into the "sum" memory and extracting the
   * proper "previous" value to compute the output.
   */

  always @(posedge clk) begin
    if (rst) begin
      count_d <= 'b0;
    end else if (ena) begin
      count_d <= count;
    end else begin
      count_d <= count_d;
    end
  end

  assign dout = sum_mem[count_d] / FILTER_LENGTH;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
