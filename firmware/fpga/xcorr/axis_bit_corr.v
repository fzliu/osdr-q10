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
  parameter   SLAVE_WIDTH = 128,
  parameter   MASTER_WIDTH = 256,
  parameter   ADDER_WIDTH = 20,
  parameter   CORR_NUM = 0,

  // derived parameters

  localparam  WAVE_WIDTH = SLAVE_WIDTH / NUM_PARALLEL,
  localparam  FILT_WIDTH = MASTER_WIDTH / NUM_PARALLEL,
  localparam  COUNT_WIDTH = log2(NUM_PARALLEL - 1),

  // bit width parameters

  localparam  NP = NUM_PARALLEL - 1,
  localparam  WS = SLAVE_WIDTH - 1,
  localparam  WM = MASTER_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  WW = WAVE_WIDTH - 1,
  localparam  WF = FILT_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1,

  `include "correlators.vh"

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WS:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WM:0]   m_axis_tdata

);

  `include "log2_func.vh"
  `include "sign_ext.vh"

  `define CORR(i,j) CORRELATORS[i*CORR_LENGTH+j]

  // internal memories

  reg     [ WA:0]   output_mem [0:NP];

  // internal registers

  reg               batch_done_d = 'b0;
  reg               valid_out = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WM:0]   m_axis_tdata_reg = 'b0;

  // internal signals

  wire              s_axis_frame;
  wire              m_axis_frame;

  wire    [ WW:0]   data_in [0:NP];
  wire    [ WM:0]   data_out;

  wire              enable_int;
  wire              batch_done;
  wire    [ WN:0]   count;
  wire    [ WN:0]   count_next;

  wire    [ WA:0]   adder_in0;
  wire    [ WA:0]   adder_in1 [0:LC];
  wire    [ WA:0]   adder_out [0:LC];


  // initialize final memory column

  genvar n;
  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    initial begin
      output_mem[n] <= 'b0;
    end
  end
  endgenerate

  // unpack input data

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * WAVE_WIDTH;
    localparam n1 = n0 + WW;
    assign data_in[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  // slave interface

  assign batch_done = (count == NP);
  assign enable_int = ~(valid_out & m_axis_tvalid);
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;
  assign s_axis_tready = enable_int & batch_done;

  // counter (for tracking current input set) logic

  counter #(
    .LOWER (0),
    .UPPER (NP),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .ena (enable_int & s_axis_tvalid),
    .rst (s_axis_frame),  // bus data is "transferred" upon completion
    .value (count)
  );

  assign count_next = count + 1'b1;

  // first adder input - s_axis_tdata module input

  assign adder_in0 = `SIGN_EXT(data_in[count],WAVE_WIDTH,ADDER_WIDTH);

  // second adder input - previous value in chain

  assign adder_in1[0] = {ADDER_WIDTH{1'b0}};

  generate
  for (n = 1; n < CORR_LENGTH; n = n + 1) begin
    xpm_memory_dpdistram # (
      .MEMORY_SIZE (NUM_PARALLEL * ADDER_WIDTH),
      .CLOCKING_MODE ("common_clock"),
      .MEMORY_INIT_FILE ("none"),
      .MEMORY_INIT_PARAM ("0"),
      .USE_MEM_INIT (1),
      .MESSAGE_CONTROL (0),
      .USE_EMBEDDED_CONSTRAINT (0),
      .MEMORY_OPTIMIZATION ("true"),
      .WRITE_DATA_WIDTH_A (ADDER_WIDTH),
      .READ_DATA_WIDTH_A (ADDER_WIDTH),
      .BYTE_WRITE_WIDTH_A (ADDER_WIDTH),
      .ADDR_WIDTH_A (COUNT_WIDTH),
      .READ_RESET_VALUE_A ("0"),
      .READ_LATENCY_A (1),
      .READ_DATA_WIDTH_B (ADDER_WIDTH),
      .ADDR_WIDTH_B (COUNT_WIDTH),
      .READ_RESET_VALUE_B ("0"),
      .READ_LATENCY_B (1)
    ) xpm_memory_dpdistram (
      .clka (clk),
      .rsta (1'b0),
      .ena (enable_int),
      .regcea (1'b0),
      .wea (1'b1),
      .addra (count),
      .dina (adder_out[n-1]),
      .douta (),
      .clkb (),
      .rstb (1'b0),
      .enb (enable_int),
      .regceb (1'b1),
      .addrb (count_next),
      .doutb (adder_in1[n])
    );
  end
  endgenerate

  // adder instantiation

  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    assign adder_out[n] = `CORR(CORR_NUM,n) ?
                          adder_in1[n] + adder_in0 :
                          adder_in1[n] - adder_in0;
  end
  endgenerate

  // output "memory"

  always @(posedge clk) begin
    if (enable_int) begin
      output_mem[count] <= adder_out[LC];
    end
  end

  // repack output data

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * FILT_WIDTH;
    localparam n1 = n0 + WF;
    assign data_out[n1:n0] = `SIGN_EXT(output_mem[n],ADDER_WIDTH,FILT_WIDTH);
  end
  endgenerate

  // valid_out logic

  always @(posedge clk) begin
    batch_done_d <= batch_done;
  end

  always @(posedge clk) begin
    if (batch_done & ~batch_done_d) begin
      valid_out <= 1'b1;
    end else if (m_axis_frame | ~m_axis_tvalid) begin
      valid_out <= 1'b0;
    end else begin
      valid_out <= valid_out;
    end
  end

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_frame | ~m_axis_tvalid) begin
      m_axis_tvalid_reg <= valid_out;
      m_axis_tdata_reg <= data_out;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

endmodule
