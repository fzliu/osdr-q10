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

  `include "func_log2.vh"

  reg     [ WO:0]   out = 'b0;

  integer i;
  always @* begin
    out = 'b0;
    for (i = 0; i < WIDTH_IN; i = i + 1) begin
      if (oh[i]) begin
        out = i;
      end
    end
  end

  assign bin = out;

endmodule
