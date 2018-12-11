////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Complex absolute value and serializes it with input data.
//
// enable  :  N/A
// reset   :  N/A
// latency :  CABS_DELAY + 1
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_cabs_serial #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 64,
  parameter   CABS_DELAY = 14,

  // derived parameters

  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(NUM_CHANNELS - 1),

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1

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

  `include "log2_func.vh"

  // internal memories

  reg     [ WC:0]   cabs_mem [0:NC];

  // internal registers

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_abs_reg = 'b0;

  // internal signals

  wire    [ WC:0]   s_axis_tdata_unpack [0:NC];
  wire              s_axis_frame;
  wire              m_axis_frame;

  wire              batch_done;
  wire              batch_done_d;

  wire    [ WN:0]   count;
  wire    [ WN:0]   count_out;
  wire              valid_out;

  wire    [ WW:0]   cabs_dina;
  wire    [ WW:0]   cabs_dinb;
  wire    [ WC:0]   cabs_dout;

  wire    [ WD:0]   data_out;
  wire    [ WD:0]   data_cabs_out;

  // initialize final memory column

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    initial begin
      cabs_mem[n] <= 'b0;
    end
  end
  endgenerate

  // unpack/pack data

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  // slave interface

  assign batch_done = (count == NC);
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;
  assign s_axis_tready = m_axis_tready & batch_done;

  // channel counter

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .ena (s_axis_tvalid),
    .rst (s_axis_frame),  // bus data is "transferred" upon completion
    .value (count)
  );

  // absolute value module

  assign cabs_dina = s_axis_tdata_unpack[count][WW:0];
  assign cabs_dinb = s_axis_tdata_unpack[count][WC:(WW+1)];
  assign cabs_dout[63:34] = 30'h00000000;

  math_cabs_32 #()
  math_cabs (
    .clk (clk),
    .dina (cabs_dina),
    .dinb (cabs_dinb),
    .dout (cabs_dout[33:0])
  );

  shift_reg #(
    .WIDTH (COUNT_WIDTH + 1),
    .DEPTH (CABS_DELAY)
  ) shift_reg_count (
    .clk (clk),
    .ena (1'b1),
    .din ({count, s_axis_tvalid}),
    .dout ({count_out, valid_out})
  );

  // cabs memory

  always @(posedge clk) begin
    if (valid_out) begin
      cabs_mem[count_out] <= cabs_dout;
    end
  end

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin : repack_gen
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign data_cabs_out[n1:n0] = cabs_mem[n];
  end
  endgenerate

  // align input data with abs data

  shift_reg #(
    .WIDTH (DATA_WIDTH + 1),
    .DEPTH (CABS_DELAY + 1)
  ) shift_reg_data (
    .clk (clk),
    .ena (1'b1),
    .din ({s_axis_tdata, batch_done}),
    .dout ({data_out, batch_done_d})
  );

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_frame | ~m_axis_tvalid) begin
      m_axis_tvalid_reg <= batch_done_d;
      m_axis_tdata_reg <= data_out;
      m_axis_tdata_abs_reg <= data_cabs_out;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
      m_axis_tdata_abs_reg <= m_axis_tdata_abs;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tdata_abs = m_axis_tdata_abs_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
