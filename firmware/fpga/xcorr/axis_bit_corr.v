////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream bit (-1 and 1) correlator implementation using adders. The module
// clock frequency should be at least that of the input clock multiplied by the
// number of channels. The number of parallel channels must be a power of two.
// Computes y[n] = x[n] * h[n].
//
// Parameters
// NUM_PARALLEL: number of parallel input data streams (must be power of 2)
// SLAVE_WIDTH: width of the axi-stream slave (input) data bus
// MASTER_WIDTH: width of the axi-stream master (output) data bus
// USE_STALL_SIGNAL: set to 0 if the downstream module accepts data faster
// SHIFT_DEPTH: internal pipeline depth for timing closure
// CORR_NUM: index into correlators.vh which determines h[n]
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  variable (dependent on correlator length)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_bit_corr #(

  // parameters

  parameter   NUM_PARALLEL = 8,
  parameter   PRECISION = 6,
  parameter   SLAVE_WIDTH = 64,
  parameter   MASTER_WIDTH = 128,
  parameter   ADDER_WIDTH = 12,
  parameter   USE_STALL_SIGNAL = 1,
  parameter   SHIFT_DEPTH = 1,
  parameter   CORR_NUM = 0,

  // correlator parameters

  `include "correlators.vh"

  // derived parameters

  localparam  WAVE_WIDTH = SLAVE_WIDTH / NUM_PARALLEL,
  localparam  FILT_WIDTH = MASTER_WIDTH / NUM_PARALLEL,
  localparam  COUNT_WIDTH = log2(NUM_PARALLEL - 1),

  // bit width parameters

  localparam  NP = NUM_PARALLEL - 1,
  localparam  PR = PRECISION - 1,
  localparam  WS = SLAVE_WIDTH - 1,
  localparam  WM = MASTER_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  WW = WAVE_WIDTH - 1,
  localparam  WF = FILT_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1

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

  `include "func_log2.vh"
  `include "func_sqrt.vh"
  `include "sign_ext.vh"

  `define CORR(i,j) CORRELATORS[W0-(i*CORR_LENGTH+j)]

  // internal memories

  reg     [ WA:0]   output_mem [0:NP];

  // internal registers

  reg               batch_done_out_d = 'b0;
  reg               valid_out = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WM:0]   m_axis_tdata_reg = 'b0;

  // internal signals

  wire              s_axis_frame;
  wire    [ WW:0]   s_axis_tdata_unpack [0:NP];

  wire              stall;
  wire              batch_done;
  wire              enable_int;
  wire    [ WN:0]   count;

  wire    [ WN:0]   ram_addra;
  wire    [ WN:0]   ram_addrb;

  wire    [ PR:0]   data_in;
  wire    [ WA:0]   adder_in0;
  wire    [ WA:0]   adder_in1 [0:L0];
  wire    [ WA:0]   adder_out [0:L0];

  wire              batch_done_out;
  wire    [ WM:0]   output_pack;
  wire              m_axis_frame;

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
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  // slave interface

  generate
    assign stall = USE_STALL_SIGNAL ? valid_out & m_axis_tvalid : 1'b0;
  endgenerate

  assign batch_done = (count == NP);
  assign enable_int = ~stall & s_axis_tvalid;
  assign s_axis_tready = ~stall & batch_done;
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  // counter (for tracking current input set) logic

  counter #(
    .LOWER (0),
    .UPPER (NP),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .rst (s_axis_frame),  // bus data is "transferred" upon completion
    .ena (enable_int),
    .value (count)
  );

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_wr_addr (
    .clk (clk),
    .ena (1'b1),
    .din (count),
    .dout (ram_addra)
  );

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_rd_addr (
    .clk (clk),
    .ena (1'b1),
    .din (enable_int ? count + 1'b1 : count),
    .dout (ram_addrb)
  );

  // first adder input - s_axis_tdata module input

  shift_reg #(
    .WIDTH (PRECISION),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_din (
    .clk (clk),
    .ena (enable_int),  //1'b1
    .din (s_axis_tdata_unpack[count][PR:0]),
    .dout (data_in)
  );

  assign adder_in0 = `SIGN_EXT(data_in,PRECISION,ADDER_WIDTH);

  // second adder input - previous value in chain

  assign adder_in1[0] = {ADDER_WIDTH{1'b0}};

  generate
  for (n = 1; n < CORR_LENGTH; n = n + 1) begin
    xpm_memory_sdpram # (
      .MEMORY_SIZE (NUM_PARALLEL * ADDER_WIDTH),
      .MEMORY_PRIMITIVE ("distributed"),
      .CLOCKING_MODE ("common_clock"),
      .MEMORY_INIT_FILE ("none"),
      .MEMORY_INIT_PARAM ("0"),
      .USE_MEM_INIT (0),
      .WAKEUP_TIME ("disable_sleep"),
      .MESSAGE_CONTROL (0),
      .ECC_MODE ("no_ecc"),
      .AUTO_SLEEP_TIME (0),
      .USE_EMBEDDED_CONSTRAINT (0),
      .MEMORY_OPTIMIZATION ("false"),
      .WRITE_DATA_WIDTH_A (ADDER_WIDTH),
      .BYTE_WRITE_WIDTH_A (ADDER_WIDTH),
      .ADDR_WIDTH_A (COUNT_WIDTH),
      .READ_DATA_WIDTH_B (ADDER_WIDTH),
      .ADDR_WIDTH_B (COUNT_WIDTH),
      .READ_RESET_VALUE_B ("0"),
      .READ_LATENCY_B (1),
      .WRITE_MODE_B ("read_first")
    ) xpm_memory_sdpram_inst (
      .sleep (1'b0),
      .clka (clk),
      .ena (enable_int),  //1'b1
      .wea (1'b1),
      .addra (ram_addra),
      .dina (adder_out[n-1]),
      .injectsbiterra (1'b0),
      .injectdbiterra (1'b0),
      .clkb (1'b0),
      .rstb (1'b0),
      .enb (1'b1),  //enable_int
      .regceb (1'b1),
      .addrb (ram_addrb),
      .doutb (adder_in1[n]),
      .sbiterrb (),
      .dbiterrb ()
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
    if (enable_int) begin   //1'b1
      output_mem[ram_addra] <= adder_out[L0];
    end
  end

  // repack output data

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * FILT_WIDTH;
    localparam n1 = n0 + WF;
    assign output_pack[n1:n0] = `SIGN_EXT(output_mem[n],ADDER_WIDTH,FILT_WIDTH);
  end
  endgenerate

  // valid_out logic

  shift_reg #(
    .WIDTH (1),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_done (
    .clk (clk),
    .ena (1'b1),
    .din (batch_done),
    .dout (batch_done_out)
  );

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

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge clk) begin
    if (m_axis_frame | ~m_axis_tvalid) begin
      m_axis_tvalid_reg <= valid_out;
      m_axis_tdata_reg <= output_pack;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

  // SIMULATION

  wire      [ L0:0]   _correlator;
  wire      [ WF:0]   _m_axis_tdata_unpack [0:NP];

  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    assign _correlator[n] = `CORR(CORR_NUM,n);
  end
  endgenerate

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * FILT_WIDTH;
    localparam n1 = n0 + WF;
    assign _m_axis_tdata_unpack[n] = m_axis_tdata[n1:n0];
  end
  endgenerate

endmodule
