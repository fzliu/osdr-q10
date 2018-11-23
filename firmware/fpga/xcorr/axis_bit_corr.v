////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream bit (-1 and 1) correlator implementation using
// adders. The module clock frequency should be at least that of the input
// clock multiplied by the number of channels. The number of parallel channels
// must be a power of two.
//
// enable  :  N/A
// reset   :  active-high
// latency :  variable (dependent on correlator length)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_bit_corr #(

  // parameters

  parameter   NUM_PARALLEL = 8,
  parameter   SAMPS_WIDTH = 16,
  parameter   ADDER_WIDTH = 20,
  parameter   CORR_LENGTH = 7,

  // derived parameters

  localparam  INPUT_WIDTH = SAMPS_WIDTH * NUM_PARALLEL,
  localparam  OUTPUT_WIDTH = ADDER_WIDTH * NUM_PARALLEL,
  localparam  COUNT_WIDTH = log2(NUM_PARALLEL - 1),

  // bit width parameters

  localparam  NP = NUM_PARALLEL - 1,
  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  WI = INPUT_WIDTH - 1,
  localparam  WO = OUTPUT_WIDTH - 1,
  localparam  WC = COUNT_WIDTH - 1,
  localparam  LC = CORR_LENGTH - 1,
  parameter [0:LC] CORRELATOR = {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0}
) (

  // core interface

  input             in_clk,
  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WI:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WO:0]   m_axis_tdata

);

  `include "log2_func.v"

  // internal registers

  reg     [ WA:0]   memory [0:NP][0:LC];
  reg               m_axis_tvalid_reg;
  reg     [ WO:0]   m_axis_tdata_reg;

  // internal signals

  wire    [ WC:0]   count;
  wire              batch_valid;
  wire              batch_ready;
  wire    [ WI:0]   batch_data;
  wire    [ WS:0]   batch_data_unpack [0:NP];

  wire    [ WA:0]   adder_in1 [0:LC];
  wire    [ WA:0]   adder_in2;
  wire    [ WA:0]   adder_out [0:LC];

  wire    [ WO:0]   output_packed;

  // convert from input (slowish) to module (fastish) clock

  axis_clk_conv_fifo #(
    .DATA_WIDTH (INPUT_WIDTH),
    .FIFO_DEPTH (16)
  ) axis_clk_conv_fifo (
    .s_axis_clk (in_clk),
    .rst (1'b0),
    .m_axis_clk (clk),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata (s_axis_tdata),
    .s_axis_tlast (1'b0),
    .m_axis_tvalid (batch_valid),
    .m_axis_tready (batch_ready),
    .m_axis_tdata (batch_data),
    .m_axis_tlast ()
  );

 // assign batch_ready = m_axis_tready;

  // unpack and repack data

  generate
  genvar i;

  for (i = 0; i <  NUM_PARALLEL; i = i + 1) begin : unpack_gen
    localparam i0 = i * SAMPS_WIDTH;
    localparam i1 = i0 + WS;
    assign batch_data_unpack[i] = batch_data[i1:i0];
  end

  for (i = 0; i < NUM_PARALLEL; i = i + 1) begin: repack_gen
    localparam i0 = i * ADDER_WIDTH;
    localparam i1 = i0 + WA;
    assign output_packed[i1:i0] = memory[i][LC];
  end

  endgenerate

  // counter (for tracking current input set) logic

  counter #(
    .LOWER (0),
    .UPPER (NP),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .ena (batch_valid),
    .rst (batch_valid & batch_ready),
    .value (count)
  );

  assign batch_ready = m_axis_tready & (count == NP);

  // correlator instantiation

  generate
  genvar j;
  for (j = 0; j < CORR_LENGTH; j = j + 1) begin

    for (i = 0; i < NUM_PARALLEL; i = i + 1) begin
      always @(posedge clk) begin
        if (batch_valid & (count == i)) begin
          memory[i][j] <= adder_out[j];
        end else begin
          memory[i][j] <= memory[i][j];
        end
      end
    end

    // create adder (1 per channel)

    assign adder_in1[j] = (j == 0) ?
                          {ADDER_WIDTH{1'b0}} :
                          memory[count][j-1];
    assign adder_in2 = {{(WA-WS){batch_data_unpack[count][WS]}},
                       batch_data_unpack[count]};
    assign adder_out[j] = CORRELATOR[j] ?
                          adder_in1[j] + adder_in2 :
                          adder_in1[j] - adder_in2;
  end
  endgenerate


  // master interface

  always @(posedge clk) begin
    if (batch_valid) begin
      m_axis_tvalid_reg <= 1'b1;
      m_axis_tdata_reg <= output_packed;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

endmodule
