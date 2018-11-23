////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Serializes AXI-stream data and computes complex absolute value.
//
// enable  :  N/A
// reset   :  N/A
// latency :  CABS_DELAY + 1
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_cabs_serial #(

  // parameters

  parameter   NUM_TAGS = 20,
  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 64,

  // derived parameters

  localparam  CABS_DELAY = 6,
  localparam  COUNT_WIDTH = log2(NUM_CHANNELS - 1),
  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output  [ WD:0]   m_axis_tdata_abs

);

  // internal registers

  reg     [ WC:0]   m_axis_tdata_abs_unpack [0:NC];

  // internal signals

  wire    [ WC:0]   s_axis_tdata_unpack [0:NC];

  wire    [ WN:0]   count;
  wire    [ WN:0]   count_out;
  wire              batch_done;

  wire    [ WW:0]   cabs_dina;
  wire    [ WW:0]   cabs_dinb;
  wire    [ WD:0]   cabs_dout;

  // slave interface

  assign batch_done = (count == NC);
  assign s_axis_tready = m_axis_tready & batch_done;

  // unpack/pack data

  generate
  genvar i;
  for (i = 0; i < NC; i = i + 1) begin
    localparam i0 = i * CHANNEL_WIDTH;
    localparam i1 = i0 + WC;
    assign s_axis_tdata_unpack[i] = s_axis_tdata[i1:i0];
    assign m_axis_tdata_abs[i1:i0] = m_axis_tdata_abs_unpack[i];
  end
  endgenerate

  // channel counter

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .ena (s_axis_tvalid & m_axis_tready),
    .rst (s_axis_tvalid & s_axis_tready),
    .value (count)
  );

  // absolute value instantiation

  math_cabs #(
    .DIN_WIDTH (WORD_WIDTH),
    .DOUT_WIDTH (CHANNEL_WIDTH)
  ) math_cabs (
    .clk (clk),
    .dina (s_axis_tdata[count]),
    .dinb (s_axis_tdata[count]),
    .dout (cabs_dout)
  );

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (CABS_DELAY)
  ) shift_reg (
    .clk (clk),
    .ena (m_axis_tready),
    .din (count),
    .dout (count_out),
  );

  // master interface

  shift_reg #(
    .WIDTH (DATA_WIDTH + 1),
    .DEPTH (CABS_DELAY + 1)
  ) shift_reg (
    .clk (clk),
    .ena (m_axis_tready),
    .din ({s_axis_tdata, batch_done}),
    .dout ({m_axis_tdata, m_axis_tvalid})
  );

  always @(posedge clk) begin
    if (m_axis_tready) begin
      m_axis_tdata_abs_unpack[count_out] <= cabs_dout;
    end
  end

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
