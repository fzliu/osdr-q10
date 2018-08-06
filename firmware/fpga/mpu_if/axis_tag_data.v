////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Quad-channel tag data collector.
//
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_tag_data #(

  // parameters

  parameter   NUM_TAGS = 20,
  parameter   BURST_LENGTH = 32,
  parameter   CHANNEL_WIDTH = 64,
  parameter   OUT_WIDTH = 16,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,
  localparam  WORDS_PER_DOUT = DATA_WIDTH / OUT_WIDTH,
  localparam  ADDR_WIDTH = log2(BURST_LENGTH - 1),
  localparam  SELECT_WIDTH = log2(WORDS_PER_DOUT - 1),

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WO = OUT_WIDTH - 1,
  localparam  WA = ADDR_WIDTH - 1,
  localparam  WS = SELECT_WIDTH - 1,
  localparam  N0 = WORDS_PER_DOUT - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input   [ NT:0]   s_axis_tvalid,
  output  [ NT:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,
  input   [ NT:0]   s_axis_tlast,

  // read interface

  input   [  7:0]   virt_tagn,
  input   [ 11:0]   virt_addr,
  output  [ WO:0]   data_out

);

  `include "log2_func.v"

  // internal registers;

  reg     [ WO:0]   mem_word = 'b0;
  reg     [ WO:0]   data_out_reg = 'b0;

  // internal signals

  wire    [ WA:0]   mem_addr;
  wire    [ WD:0]   mem_dout;
  wire    [ WD:0]   mem_dout_all[0:NT];

  // create memory interface

  assign mem_addr = virt_addr[WA+WS:WS];
  assign mem_dout = mem_dout_all[virt_tagn];

  generate
  genvar i;
  for (i = 0; i < NUM_TAGS; i = i + 1) begin : tag_mem_gen
    localparam i0 = i * DATA_WIDTH;
    localparam i1 = i * DATA_WIDTH + WD;

    axis_to_mem #(
      .MEMORY_TYPE ("distributed"),
      .MEMORY_DEPTH (BURST_LENGTH),
      .DATA_WIDTH (DATA_WIDTH)
    ) axis_to_mem (
      .clk (clk),
      .rst (rst),
      .s_axis_tvalid (s_axis_tvalid[i]),
      .s_axis_tready (s_axis_tready[i]),
      .s_axis_tdata (s_axis_tdata[i1:i0]),
      .s_axis_tlast (s_axis_tlast[i]),
      .addr (mem_addr),
      .dout (mem_dout_all[i])
    );

  end
  endgenerate

  // output value

  integer n;
  always @* begin
    for (n = 0; n < WORDS_PER_DOUT; n = n + 1) begin
      mem_word = 'b0;
      if (virt_addr[WS:0] == n)
        mem_word = mem_dout[n*N0+15:n*N0];
    end
  end

  always @(posedge clk) begin
    if (rst | (virt_tagn > NT)) begin
      data_out_reg <= 'b0;
    end else begin
      data_out_reg <= mem_word;
    end
  end

  assign data_out = data_out_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
