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
// reset   :  N/A
// latency :  variable (dependent on correlator length)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_bit_corr #(

  // parameters

  parameter   NUM_PARALLEL = 8,     // TODO(fzliu): ensure this is 2^N
  parameter   WAVE_WIDTH = 6,
  parameter   ADDER_WIDTH = 12,     // TODO(fzliu): ensure this is 2*N
  parameter   USE_STALL_SIGNAL = 1,
  parameter   SHIFT_DEPTH = 1,

  // correlator parameters

  parameter   NUM_CORRS = 1,        // TODO(fzliu): ensure this is 2^N
  parameter   CORR_OFFSET = 0,
  parameter   CORR_LENGTH = 1,
  parameter   CORRELATORS = {1'b0},

  localparam  N0 = NUM_CORRS - 1,
  localparam  L0 = CORR_LENGTH - 1,

  // derived parameters

  parameter   SLAVE_WIDTH = WAVE_WIDTH * NUM_PARALLEL,
  parameter   MASTER_WIDTH = ADDER_WIDTH * NUM_PARALLEL,
  localparam  COUNT_WIDTH = log2(NUM_PARALLEL * NUM_CORRS - 1),

  // bit width parameters

  localparam  NP = NUM_PARALLEL - 1,
  localparam  WW = WAVE_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  WS = SLAVE_WIDTH - 1,
  localparam  WM = MASTER_WIDTH - 1,
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

  `define CORRS(n) CORRELATORS[(n)*CORR_LENGTH+:CORR_LENGTH]

  // internal memories

  reg     [ WA:0]   adder_out [0:L0];
  reg     [ WA:0]   output_ram [0:NP];

  // internal registers

  reg     [ L0:0]   correlator = `CORRS(CORR_OFFSET);

  reg               batch_done_d = 'b0;
  reg               valid_out = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WM:0]   m_axis_tdata_reg = 'b0;

  // internal signals

  wire              s_axis_frame;
  wire    [ WW:0]   s_axis_tdata_unpack [0:NP];

  wire              stall;
  wire              enable_int;

  wire    [ WN:0]   count;
  wire    [ WN:0]   wr_addr;
  wire    [ WN:0]   rd_addr;
  wire              batch_done;

  wire              corr_idx;
  wire    [ WW:0]   data_in;
  wire    [ WA:0]   adder_in0 [0:L0];
  wire    [ WA:0]   adder_in1 [0:L0];

  wire    [ WM:0]   output_pack;
  wire              m_axis_frame;

  /* Initialize adder output registers.
   * To improve timing, each adder output must go through a set of flops before
   * entering the distributed RAM.
   */

  genvar n;
  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    initial begin
      adder_out[n] = 'b0;
    end
  end
  endgenerate

  /* Initialize final memory column.
   * The final memory column is implemented in HDL to allow the synthesis tool
   * to infer flip-flops instead of a distributed RAM block. This is done to
   * improve timing.
   */

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    initial begin
      output_ram[n] = 'b0;
    end
  end
  endgenerate

  /* Unpack input data.
   * For ease of use later on in this module.
   */

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * WAVE_WIDTH;
    localparam n1 = n0 + WW;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  /* Slave interface.
   * If USE_STALL_SIGNAL is set, then the "next" module may not process the
   * incoming data as quickly as axis_bit_corr does. In this case, we check to
   * make sure that a) the output m_axis does not contain data that has not
   * yet been read by the downstream AXI block, or b) second-to-last set ot
   * output registers also does not contain data. If USE_STALL_SIGNAL is not set
   * (i.e. === 0). then we can safely remove the stall signal by zeroing it.
   */

  generate
    assign stall = USE_STALL_SIGNAL ? valid_out & m_axis_tvalid : 1'b0;
  endgenerate

  assign enable_int = ~stall & s_axis_tvalid;
  assign s_axis_tready = ~stall & (count == NP);
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  /* Counter logic.
   * This counter tracks the current input set that this module is processing.
   * For example, count == 0 means that it is processing the 0th data channel
   * and the 0th correlator. When a new batch of data is received from the
   * input AXI-stream interface, this counter gets reset so processing can
   * continue on the next clock cycle.
   */

  counter #(
    .LOWER (0),
    .UPPER (NP),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .rst (s_axis_frame),
    .ena (enable_int),
    .value (count)
  );

  /* Write and read addresses.
   * These are set based on the counter. Since the output of each adder goes
   * through a set of flops before reaching the memory, the write address is
   * effectively the previous input set. Similarly, since the distributed RAM
   * is set for 1 cycle of latency, the read address is effectively the next
   * input set in order for it to line up with the input data.
   */

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_wr_addr (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (count - 1'b1),
    .dout (wr_addr)
  );

  shift_reg #(
    .WIDTH (COUNT_WIDTH),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_rd_addr (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (count + 1'b1),  //enable_int ? count + 1'b1 : count
    .dout (rd_addr)
  );

  /* Set correlator for current batch.
   * Once we have finished processing NUM_PARALLEL input channels, we must move
   * on to the next correlator. However, to this must also go through
   * SHIFT_DEPTH cycles of delay so that we does not prematurely begin using the
   * next correlator. Another option would be to have the correlator itself pass
   * through SHIFT_DEPTH cycles of delay; however, this would be a waste of
   * resources as it does not seem to improve timing.
   */

  shift_reg #(
    .WIDTH (1),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_done (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din ((count % NUM_PARALLEL) == NP),
    .dout (batch_done)
  );

  assign corr_idx = (count + 1'b1) / NUM_PARALLEL;

  always @(posedge clk) begin
    if (enable_int & batch_done) begin
      correlator <= `CORRS(corr_idx+CORR_OFFSET);
    end else begin
      correlator <= correlator;
    end
  end

  /* First adder input.
   * The first input to each adder is simply the current input data.
   */

  shift_reg #(
    .WIDTH (WAVE_WIDTH),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_din (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (s_axis_tdata_unpack[count]),
    .dout (data_in)
  );

  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    assign adder_in0[n] = correlator[CORR_LENGTH-n-1] ?
                          `SIGN_EXT(data_in,WAVE_WIDTH,ADDER_WIDTH) :
                          -`SIGN_EXT(data_in,WAVE_WIDTH,ADDER_WIDTH);
  end
  endgenerate

  /* Second adder input.
   * The second input is the previous value in the long adder-memory chain. The
   * 0th element of the chain has no previous value, so its value is 0. For
   * performance reasons, we directly instantiate a simple dual-port RAM, since
   * this specialized configuration requires only ADDER_WIDTH / 3 LUTRAMs
   * instead of ADDER_WIDTH / 2.
   */

  assign adder_in1[0] = 'b0;

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
      .ena (enable_int),
      .wea (1'b1),
      .addra (wr_addr),
      .dina (adder_out[n-1]),
      .injectsbiterra (1'b0),
      .injectdbiterra (1'b0),
      .clkb (1'b0),
      .rstb (1'b0),
      .enb (enable_int),
      .regceb (1'b1),
      .addrb (rd_addr),
      .doutb (adder_in1[n]),
      .sbiterrb (),
      .dbiterrb ()
    );
  end
  endgenerate

  /* Adder instantiations.
   * The synthesis tool should be able to utilize the fast fabric carry logic.
   * As such, there is no need to pipeline this adder. AS previously mentioned,
   * the output of each adder is flopped to improve timing.
   */

  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    always @(posedge clk) begin
      if (enable_int) begin
        adder_out[n] <= adder_in1[n] + adder_in0[n];
      end else begin
        adder_out[n] <= adder_out[n];
      end
    end
  end
  endgenerate

  /* Output memory.
   * We do not have to use dual-port distributed RAM for the output memory
   * column. The synthesis tool should infer flops, which should improve
   * timing and routability.
   */

  always @(posedge clk) begin
    if (enable_int) begin
      output_ram[wr_addr] <= adder_out[L0];
    end
  end

  /* Repack output data.
   * Since Verilog does not allow unpacked input and output signals, we must
   * repack the final memory column.
   */

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * ADDER_WIDTH;
    localparam n1 = n0 + WA;
    assign output_pack[n1:n0] = output_ram[n];
  end
  endgenerate

  /* Second-to-last output stage.
   * This is required to prevent stalling. Since the batch_done signal may be
   * high for multiple clock cycles, we slice out its rising edge for a single
   * clock cycle using its delayed version. When the rising edge of batch_done
   * is detected, our output becomes valid. This output data is transfered to
   * m_axis_tdata if no valid data is currently present on m_axis, or if data
   * on m_axis was transferred on the current clock cycle.
   */

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

  /* Master interface.
   * The output AXI-stream interface simply exposes data from the penultimate
   * stage (see above for a more detailed explanation).
   */

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

endmodule
