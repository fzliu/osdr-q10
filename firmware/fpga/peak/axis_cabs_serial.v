////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Complex absolute value and serializes it with input data.
//
// Parameters
// NUM_CHANNELS: total number of anchor channels (number of antennas)
// CHANNEL_WIDTH: total data width of each channel
// CABS_DELAY: number of clock cycles of delay for absolute value module
// USE_STALL_SIGNAL: set to 0 if the downstream module accepts data faster
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  CABS_DELAY + 1
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_cabs_serial #(

  // parameters

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   CABS_DELAY = 1,
  parameter   USE_STALL_SIGNAL = 1,

  // derived parameters

  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(NUM_CHANNELS - 1),
  localparam  ABS_WIDTH = (WORD_WIDTH <= 16) ? 16 : 32,
  localparam  PAD_WIDTH = CHANNEL_WIDTH - ABS_WIDTH,

  // bit width parameters

  localparam  NC = NUM_CHANNELS - 1,
  localparam  WC = CHANNEL_WIDTH - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,
  localparam  WB = ABS_WIDTH - 1

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

  `include "func_log2.vh"
  `include "sign_ext.vh"

  // internal memories

  reg     [ WB:0]   cabs_ram [0:NC];

  // internal registers

  reg               batch_done_out_d = 'b0;
  reg               valid_out = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_abs_reg = 'b0;

  // internal signals

  wire    [ WC:0]   s_axis_tdata_unpack [0:NC];
  wire              s_axis_frame;

  wire              stall;
  wire              batch_done;
  wire              enable_int;
  wire              batch_done_out;

  wire    [ WN:0]   count;
  wire    [ WN:0]   count_out;

  wire    [ WW:0]   data_in_a;
  wire    [ WW:0]   data_in_b;
  wire    [ WB:0]   cabs_dina;
  wire    [ WB:0]   cabs_dinb;
  wire    [ WB:0]   cabs_dout;

  wire    [ WD:0]   data_out;
  wire    [ WD:0]   data_abs_out;

  wire              m_axis_frame;

  // initialize final memory column

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    initial begin
      cabs_ram[n] <= 'b0;
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

  generate
    assign stall = USE_STALL_SIGNAL ? valid_out & m_axis_tvalid : 1'b0;
  endgenerate

  assign batch_done = (count == NC);
  assign enable_int = ~stall & s_axis_tvalid;
  assign s_axis_tready = ~stall & batch_done;
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  // channel counter

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .rst (s_axis_frame),  // bus data is "transferred" upon completion
    .ena (enable_int),
    .value (count)
  );

  // absolute value module

  assign data_in_a = s_axis_tdata_unpack[count][WW:0];
  assign data_in_b = s_axis_tdata_unpack[count][WC:(WW+1)];
  assign cabs_dina = `SIGN_EXT(data_in_a,WORD_WIDTH,ABS_WIDTH);
  assign cabs_dinb = `SIGN_EXT(data_in_b,WORD_WIDTH,ABS_WIDTH);

  generate
  if (CHANNEL_WIDTH <= 32) begin

    math_cabs_16 #()
    math_cabs_16 (
      .clk (clk),
      .rst (1'b0),
      .ena (enable_int),
      .dina (cabs_dina),
      .dinb (cabs_dinb),
      .dout (cabs_dout)
    );

  end else begin

    math_cabs_32 #()
    math_cabs_32 (
      .clk (clk),
      .rst (1'b0),
      .ena (enable_int),
      .dina (cabs_dina),
      .dinb (cabs_dinb),
      .dout (cabs_dout)
    );

  end
  endgenerate

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (CABS_DELAY)
  ) shift_reg_count (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (count),
    .dout (count_out)
  );

  shift_reg #(
    .WIDTH (1),
    .DEPTH (CABS_DELAY)
  ) shift_reg_done (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (batch_done),
    .dout (batch_done_out)
  );

  // cabs "memory"

  always @(posedge clk) begin
    if (enable_int) begin
      cabs_ram[count_out] <= cabs_dout; // overflow unlikely; discard MSB
    end
  end

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin : repack_gen
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign data_abs_out[n1:n0] = {{PAD_WIDTH{1'b0}}, cabs_ram[n]};
  end
  endgenerate

  // valid_out logic
  // when valid_out == 1'b1, both m_axis and output contain valid data

  always @(posedge clk) begin
    batch_done_out_d <= batch_done_out;
  end

  always @(posedge clk) begin
    if (batch_done_out & ~batch_done_out_d) begin
      valid_out <= 1'b1;
    end else if (m_axis_frame | ~m_axis_tvalid) begin
      valid_out <= 1'b0;
    end else begin
      valid_out <= valid_out;
    end
  end

  // align input data with abs data

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (CABS_DELAY+1)
  ) shift_reg_data (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (s_axis_tdata),
    .dout (data_out)
  );

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_frame | ~m_axis_tvalid) begin
      m_axis_tvalid_reg <= valid_out;
      m_axis_tdata_reg <= data_out;
      m_axis_tdata_abs_reg <= data_abs_out;
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
