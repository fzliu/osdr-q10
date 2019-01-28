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

  reg               valid_out = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_abs_reg = 'b0;

  // internal signals

  wire    [ WC:0]   s_axis_tdata_unpack [0:NC];
  wire              s_axis_frame;

  wire              stall;
  wire              enable_int;

  wire    [ WN:0]   count;
  wire    [ WN:0]   count_out;
  wire              batch_done;

  wire    [ WW:0]   data_in_a;
  wire    [ WW:0]   data_in_b;
  wire    [ WB:0]   cabs_dina;
  wire    [ WB:0]   cabs_dinb;
  wire    [ WB:0]   cabs_dout;

  wire    [ WD:0]   data_out;
  wire    [ WD:0]   data_abs_out;

  wire              m_axis_frame;

  /* Initialize final memory column.
   * This memory stores the computed absolute values.
   */

  genvar n;
  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    initial begin
      cabs_ram[n] <= 'b0;
    end
  end
  endgenerate

  /* Unpack input data.
   * As with axis_bit_corr, this is done for ease of use later on in this
   * module.
   */

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  /* Slave interface.
   * The slave interface for axis_cabs_serial mimics that of axis_bit_corr. For
   * more details, refer to that module.
   */

  generate
    assign stall = USE_STALL_SIGNAL ? valid_out & m_axis_tvalid : 1'b0;
  endgenerate

  assign enable_int = ~stall & s_axis_tvalid;
  assign s_axis_tready = ~stall & (count == NC);
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  /* Counter logic.
   * The counter logic for axis_cabs_serial mimics that of axis_bit_corr. For
   * more details, refer to that module.
   */

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .rst (s_axis_frame),
    .ena (enable_int),
    .value (count)
  );

  /* Absolute value instantiation.
   * The width of the absolute value module is set based on the input data
   * width. While the absolute value of the inputs are being computed, the
   * control logic must go through a shift register to match the latency of the
   * absolute value module.
   */

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
    .din (count == NC),
    .dout (batch_done)
  );

  /* Output memory.
   * The output memory for axis_cabs_serial mimics that of axis_bit_corr. For
   * more details, refer to that module.
   */

  always @(posedge clk) begin
    if (enable_int) begin
      cabs_ram[count_out] <= cabs_dout;
    end
  end

  generate
  for (n = 0; n < NUM_CHANNELS; n = n + 1) begin : repack_gen
    localparam n0 = n * CHANNEL_WIDTH;
    localparam n1 = n0 + WC;
    assign data_abs_out[n1:n0] = {{PAD_WIDTH{1'b0}}, cabs_ram[n]};
  end
  endgenerate

  /* Second-to-last output stage.
   * The penultimate stage for axis_cabs_serial mimics that of axis_bit_corr.
   * For more details, refer to that module.
   */

  always @(posedge clk) begin
    if (enable_int & batch_done) begin
      valid_out <= 1'b1;
    end else if (m_axis_frame | ~m_axis_tvalid) begin
      valid_out <= 1'b0;
    end else begin
      valid_out <= valid_out;
    end
  end

  /* Align input data with absolute value data.
   * We need to add an extra clock cycle to this shift register to compensate
   * for the penultimate stage (see previous section).
   */

  shift_reg #(
    .WIDTH (DATA_WIDTH),
    .DEPTH (CABS_DELAY + 1)
  ) shift_reg_data (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (s_axis_tdata),
    .dout (data_out)
  );

  /* Master interface.
   * In addition to the input data, this module must also expose a second data
   * port to transfer absolute value information. This port is aptly named
   * m_axis_tdata_abs.
   */

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
