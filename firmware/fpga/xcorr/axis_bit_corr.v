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
// ADDER_WIDTH:
// USE_STALL_SIGNAL: set to 0 if the downstream module accepts data faster
// SHIFT_DEPTH: internal pipeline depth for timing closure
// NUM_CORRS:
// CORR_OFFSET: index into correlators.vh which determines h[n]
// CORR_LENGTH:
// CORRELATORS:
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

  parameter   NUM_PARALLEL = 8,       // TODO(fzliu): ensure this is 2^N
  parameter   WAVE_WIDTH = 6,
  parameter   ADDER_WIDTH = 12,       // TODO(fzliu): ensure this is 2*N
  parameter   USE_STALL_SIGNAL = 1,
  parameter   SHIFT_DEPTH = 1,        // TODO(fzliu): ensure >= 2

  // correlator parameters

  parameter   NUM_CORRS = 1,          // TODO(fzliu): ensure this is 2^N
  parameter   CORR_OFFSET = 0,
  parameter   CORR_LENGTH = 1,
  parameter   CORRELATORS = {1'b0},

  localparam  N0 = NUM_CORRS - 1,
  localparam  L0 = CORR_LENGTH - 1,

  // derived parameters

  localparam  MEMORY_DEPTH = NUM_PARALLEL * NUM_CORRS,
  localparam  MEMORY_WIDTH = ADDER_WIDTH * (CORR_LENGTH - 1),
  localparam  INPUT_WIDTH = WAVE_WIDTH * NUM_PARALLEL,
  localparam  OUTPUT_WIDTH = ADDER_WIDTH * NUM_PARALLEL,
  localparam  COUNT_WIDTH = log2(MEMORY_DEPTH - 1),

  // bit width parameters

  localparam  NP = NUM_PARALLEL - 1,
  localparam  WW = WAVE_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  DM = MEMORY_DEPTH - 1,
  localparam  WM = MEMORY_WIDTH - 1,
  localparam  WI = INPUT_WIDTH - 1,
  localparam  WO = OUTPUT_WIDTH - 1,
  localparam  WN = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WI:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WO:0]   m_axis_tdata,
  output  [ N0:0]   m_axis_tdest

);

  `include "func_log2.vh"
  `include "func_sqrt.vh"
  `include "sign_ext.vh"

  `define CORRS(n) CORRELATORS[(n+CORR_OFFSET)*CORR_LENGTH+:CORR_LENGTH]

  // internal memories

  reg     [ WA:0]   output_ram [0:DM];

  // internal registers

  reg               valid_out = 'b0;
  reg     [ N0:0]   dest_out = 'b0;

  reg     [ WN:0]   p_count = 'b0;    // parallel count == count % NUM_PARALLEL
  reg     [ WN:0]   b_count = 'b0;    // batch count    == count / NUM_PARALLEL

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WO:0]   m_axis_tdata_reg = 'b0;
  reg     [ N0:0]   m_axis_tdest_reg = 'b0;

  // internal signals

  wire              s_axis_frame;
  wire    [ WW:0]   s_axis_tdata_unpack [0:NP];

  wire              stall;
  wire              enable_int;

  wire    [ WN:0]   count;
  wire    [ WN:0]   ram_addr;
  wire    [ L0:0]   correlator;

  wire    [ WW:0]   data_in;
  wire    [ WA:0]   adder_in0 [0:L0];
  wire    [ WA:0]   adder_in1 [0:L0];
  wire    [ WA:0]   adder_out [0:L0];

  wire    [ N0:0]   corr_num;
  wire              batch_done;
  wire    [ WO:0]   output_pack;
  wire              m_axis_frame;

  /* Initialize memory columns.
   * The final memory column is implemented in HDL to allow the synthesis tool
   * to infer flip-flops instead of a distributed RAM block if it improves
   * timing.
   */

  genvar n;
  generate
  for (n = 0; n < MEMORY_DEPTH; n = n + 1) begin
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
    localparam n0 = n * WAVE_WIDTH, n1 = n0 + WW;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  /* Slave interface.
   * If USE_STALL_SIGNAL is set, then the downstream module may not process the
   * outgoing data as quickly as axis_bit_corr does. In this case, we check to
   * make sure that a) the output m_axis does not contain data that has not
   * yet been read by the downstream AXI block, or b) second-to-last set ot
   * output registers also does not contain data. If USE_STALL_SIGNAL is not set
   * (i.e. === 0). then we can safely remove the stall signal by zeroing it.
   */

  generate
    assign stall = USE_STALL_SIGNAL ? valid_out & m_axis_tvalid : 1'b0;
  endgenerate

  assign enable_int = ~stall & s_axis_tvalid;
  assign s_axis_tready = ~stall & (count == DM);
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
    .UPPER (DM),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .rst (s_axis_frame),
    .ena (enable_int),
    .value (count)
  );

  always @(posedge clk) begin
    if (enable_int) begin
      p_count <= count % NUM_PARALLEL;
      b_count <= count / NUM_PARALLEL;
    end else begin
      p_count <= p_count;
      b_count <= b_count;
    end
  end

  /* Set correlator for current batch.
   * Once we have finished processing NUM_PARALLEL input channels, we must move
   * on to the next correlator. However, these bits must also go through
   * SHIFT_DEPTH cycles of delay so that we do not prematurely begin using the
   * next correlator.
   */

  shift_reg #(
    .WIDTH (CORR_LENGTH),
    .DEPTH (SHIFT_DEPTH - 1)
  ) shift_reg_correlator (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (`CORRS(b_count)),
    .dout (correlator)
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
    .din (count),
    .dout (ram_addr)
  );

  /* First adder input.
   * The first input to each adder is simply the current input data. Note that
   * the correlator bits need to be reversed for proper functionality.
   */

  shift_reg #(
    .WIDTH (WAVE_WIDTH),
    .DEPTH (SHIFT_DEPTH - 1)
  ) shift_reg_din (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (s_axis_tdata_unpack[p_count]),
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
   * 0th element of the chain has no previous value, so its value set to 0. Data
   * is ready asynchronously to allow for distributed RAM inference (see next
   * section).
   */

  assign adder_in1[0] = 'b0;

  /* Memory chain.
   * Because this module implements the entire correlation as one large chain,
   * intermediate results must be stored in memory. Previously, we directly
   * instantiated a series of simple dual-port distributed RAMs to do this. Now,
   * we write the entire memory chain as one large memory block. Vivado (or
   * Quartus) should still be able to infer the most efficient RAM type for this
   * particular application,
   */

  genvar a;
  generate
  for (n = 0; n < CORR_LENGTH - 1; n = n + 1) begin
    corr_ram_blk #(
      .NUM_PARALLEL (NUM_PARALLEL),
      .DATA_WIDTH (ADDER_WIDTH),
      .NUM_CORRS (NUM_CORRS)
    ) corr_ram_blk (
      .clk (clk),
      .ena (enable_int),
      .addr (ram_addr),
      .din (adder_out[n]),
      .dout (adder_in1[n+1])
    );
  end
  endgenerate

  /* Adder instantiations.
   * The synthesis tool should be able to utilize the fast fabric carry logic.
   * As such, there is no need to pipeline this adder.
   */

  generate
  for (n = 0; n < CORR_LENGTH; n = n + 1) begin
    assign adder_out[n] = adder_in1[n] + adder_in0[n];
  end
  endgenerate

  /* Output memory.
   * We do not have to use dual-port distributed RAM for the output memory
   * column. The synthesis tool should infer flops, which should improve
   * timing and routability. Since Verilog does not allow unpacked input and
   * output signals, we must also repack the final memory column later on.
   */

  always @(posedge clk) begin
    if (enable_int) begin
      output_ram[ram_addr] <= adder_out[L0];
    end
  end

  /* Second-to-last output stage.
   * This is required to prevent stalling. When batch_done is asserted, our
   * output becomes valid. This output data is transfered to m_axis_tdata if no
   * valid data is currently present on m_axis, or if data on m_axis was
   * transferred on the current clock cycle.
   */

  shift_reg #(
    .WIDTH (1),
    .DEPTH (SHIFT_DEPTH)
  ) shift_reg_batch_done (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (p_count == NP),
    .dout (batch_done)
  );

  shift_reg #(
    .WIDTH (NUM_CORRS),
    .DEPTH (SHIFT_DEPTH + 1)
  ) shift_reg_corr_num (
    .clk (clk),
    .rst (1'b0),
    .ena (enable_int),
    .din (b_count),
    .dout (corr_num)
  );

  always @(posedge clk) begin
    if (enable_int & batch_done) begin
      valid_out <= 1'b1;
    end else if (m_axis_frame | ~m_axis_tvalid) begin
      valid_out <= 1'b0;
    end else begin
      valid_out <= valid_out;
    end
  end

  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * ADDER_WIDTH, n1 = n0 + WA;
    assign output_pack[n1:n0] = output_ram[dest_out*NUM_PARALLEL+n];
  end
  endgenerate

  always @(posedge clk) begin
    if (enable_int & batch_done) begin
      dest_out <= corr_num;
    end else begin
      dest_out <= dest_out;
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
      m_axis_tdest_reg <= dest_out;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
      m_axis_tdest_reg <= m_axis_tdest;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tdest = m_axis_tdest_reg;

endmodule
