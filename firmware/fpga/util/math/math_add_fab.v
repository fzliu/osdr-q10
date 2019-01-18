////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Signed variable bit width fabric-based adder.
//
// Parameters
// WIDTH: adder bit width
// LATENCY: total latency of module
//
// Signals
// enable  :  active-high
// reset   :  active-high
// latency :  dependent on LATENCY
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module math_add_fab #(

  parameter   WIDTH = 16,   //TODO(fzliu): multiple of (latency + 1)
  parameter   LATENCY = 1,

  localparam  NUM_STAGES = LATENCY + 1,
  localparam  ADD_WIDTH = WIDTH / NUM_STAGES,

  localparam  W0 = WIDTH - 1,
  localparam  NS = NUM_STAGES - 1,
  localparam  WA = ADD_WIDTH - 1

) (

  input             clk,
  input             rst,
  input             ena,

  // input operands

  input   [ W0:0]   dina,
  input   [ W0:0]   dinb,

  // output sum

  output  [ W0:0]   dout

);

  // internal registers

  reg     [ NS:0]   carry_d = 'b0;

  // internal signals

  wire    [ WA:0]   a [0:NS];       // A inputs to all sub-adders
  wire    [ WA:0]   b [0:NS];       // B inputs to all sub-adders
  wire    [ WA:0]   sum [0:NS];     // A+B outputs of all sub-adders
  wire    [ NS:0]   carry;          // carry outputs to next adder

  // adder implementation

  always @(posedge clk) begin
    if (rst) begin
      carry_d <= 'b0;
    end else if (ena) begin
      carry_d <= carry;
    end
  end

  genvar n;
  generate
  for (n = 0; n < NUM_STAGES; n = n + 1) begin
    localparam n0 = n * ADD_WIDTH;
    localparam n1 = n0 + WA;

    // input shift register

    if (n != 0) begin
      shift_reg #(
        .WIDTH (2 * ADD_WIDTH),
        .DEPTH (n)
      ) shift_reg_a_i (
        .clk (clk),
        .ena (ena),
        .din ({dina[n1:n0], dinb[n1:n0]}),
        .dout ({a[n], b[n]})
      );
    end else begin
      assign a[n] = dina[n1:n0];
      assign b[n] = dinb[n1:n0];
    end

    // adder

    if (n == 0) begin
      assign {carry[n], sum[n]} = a[n] + b[n];
    end else begin
      assign {carry[n], sum[n]} = a[n] + b[n] + carry[n-1];
    end

    // output shift register

    if (n != NS) begin
      shift_reg #(
        .WIDTH (ADD_WIDTH),
        .DEPTH (NS)
      ) shift_reg_a_i (
        .clk (clk),
        .ena (ena),
        .din (sum[n]),
        .dout (dout[n1:n0])
      );
    end else begin
      assign dout[n1:n0] = sum[n];
    end

  end
  endgenerate

endmodule
