////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: One-hot to binary converter.
//
// enable  :  N/A
// reset   :  active-high
// latency :  0 cycles
//
////////////////////////////////////////////////////////////////////////////////

module oh_to_bin #(

  parameter   WIDTH_IN = 8,
  parameter   WIDTH_OUT = log2(WIDTH_IN - 1),

  localparam  WI = WIDTH_IN - 1,
  localparam  WO = WIDTH_OUT - 1

) (

  input   [ WI:0]   oh,
  output  [ WO:0]   bin

);

  `include "log2_func.v"

  reg     [ WO:0]   out;

  integer i;
  always @* begin
    out = 'b0;
    for (i = 0; i < WIDTH_IN; i = i + 1) begin
      if (oh[i])
        out = i;
    end
  end

  assign bin = out;

endmodule
