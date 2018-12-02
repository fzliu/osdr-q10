////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterized module which computes the moving average of the
// inputs (aka boxcar filter).
//
// Revision: N/A
// Additional Comments: This module is synchronous, and is computed by adding
// the newest value while subtracting the oldest. This module must be reset
// before use. No overflow checking is performed.
//
// TODO(fzliu): Implement this with distributed RAM.
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

  // data interface

  input   [ WD:0]   data_in,
  output  [ WD:0]   avg_out

);

  // shift register

  reg     [ WD:0]   shift [LF:0];

  // internal registers

  reg     [ WD:0]   sum_reg;

  // internal signals

  wire    [ WD:0]   sum_step;
  wire    [ WD:0]   sum_out;

  // shift register implementation

  for (i = 0; i < FILTER_LENGTH; i = i + 1) begin
    always @(posedge clk) begin
      if (rst) begin
        shift[i] <= {DATA_WIDTH{1'b0}};
      end else begin
        shift[i] <= (i == 0) ? data_in : shift[i-1];
      end
    end
  end

  // boxcar filter implementation

  always @(posedge clk) begin
    if (rst) begin
      sum_reg <= {DATA_WIDTH{1'b0}};
    end else begin
      sum_reg <= sum_out;
    end
  end

  assign sum_step = sum_reg + data_in;
  assign sum_out = sum_step - shift[LF];

  // assign output

  assign avg_out = sum_reg[WD] ?
                   -(-sum_reg >> FILTER_POWER) :
                   sum_reg >> FILTER_POWER;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
