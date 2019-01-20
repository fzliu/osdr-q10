////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterized module which computes the moving average of the
// inputs (aka boxcar filter). This module is synchronous, and is computed by
// adding the newest value while subtracting the oldest. This module must be
// reset before use. No overflow checking is performed.
//
// enable  :  active-high
// reset   :  active-high
// latency :  3 cycles
// output  :  registered
//
// TODO(fzliu): Implement this with distributed RAM and SRLs.
//
////////////////////////////////////////////////////////////////////////////////

module filt_boxcar #(

  // parameters

  parameter   DATA_WIDTH = 16,
  parameter   FILTER_POWER = 3,

  // derived parameters

  localparam  FILTER_LENGTH = 2**FILTER_POWER,

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  LF = FILTER_LENGTH - 1

) (

  // core interface

  input             clk,
  input             rst,
  input             ena,

  // data interface

  input   [ WD:0]   data_in,
  output  [ WD:0]   avg_out

);

  // internal registers

  reg     [ WD:0]   sum_diff = 'b0;
  reg     [ WD:0]   sum_reg = 'b0;
  reg     [ WD:0]   avg_out_reg = 'b0;

  // internal signals

  wire    [ WD:0]   shift_out;

  // shift register instantiation

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (FILTER_LENGTH)
  ) shift_reg (
    .clk (clk),
    .rst (rst),
    .ena (ena),
    .din (data_in),
    .dout (shift_out)
  );

  // boxcar filter implementation

  always @(posedge clk) begin
    if (rst) begin
      sum_diff <= 'b0;
      sum_reg <= 'b0;
    end else if (ena) begin
      sum_diff <= data_in - shift_out;
      sum_reg <= sum_reg + sum_diff;
    end
  end

  // assign output

  always @(posedge clk) begin
    if (rst) begin
      avg_out_reg <= 'b0;
    end else begin
      avg_out_reg <= (sum_reg >>> FILTER_POWER);
    end
  end

  assign avg_out = avg_out_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
