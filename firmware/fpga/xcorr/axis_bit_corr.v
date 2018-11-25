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

  parameter   CORR_LENGTH = 7,
  parameter   NUM_CHANNELS = 8,
  parameter   INPUT_WIDTH = 128,
  parameter   ADDER_WIDTH = 20,

  // derived parameters

  localparam  SAMPS_WIDTH = INPUT_WIDTH / NUM_CHANNELS,
  localparam  TOTAL_WIDTH = INPUT_WIDTH * CORR_LENGTH,
  localparam  OUTPUT_WIDTH = ADDER_WIDTH * NUM_CHANNELS,
  localparam  COUNT_WIDTH = log2(NUM_CHANNELS - 1),

  // bit width parameters

  localparam  LC = CORR_LENGTH - 1,
  localparam  NC = NUM_CHANNELS - 1,
  localparam  WI = INPUT_WIDTH - 1,
  localparam  WA = ADDER_WIDTH - 1,
  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WT = TOTAL_WIDTH - 1,
  localparam  WO = OUTPUT_WIDTH - 1,
  localparam  WC = COUNT_WIDTH - 1,

  parameter [0:LC] CORRELATOR = {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0}

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WT:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WO:0]   m_axis_tdata

);

  `include "log2_func.v"

  // internal registers

  reg               m_axis_tvalid_reg;
  reg     [ WO:0]   m_axis_tdata_reg;

  reg     [ WA:0]   adder_in0 [0:LC];
  reg     [ WA:0]   adder_in0 [0:LC];

  // internal signals

  wire    [ WS:0]   adder_in0 [0:LC][0:NC];
  wire    [ WA:0]   adder_in1 [0:LC];

  wire    [ WC:0]   count;
  wire    [ WA:0]   adder_out [0:LC];
  wire    [ WO:0]   output_packed;

  // unpack and repack data

  generate
  genvar i, j;

  for (i = 0; i <  CORR_LENGTH; i = i + 1) begin : unroll_gen
    for (j = 0; j < NUM_CHANNELS; j = j + 1) begin: unpack_gen
      localparam i0 = i * CHANNEL_WIDTH;
      localparam j0 = i0 + j * SAMPS_WIDTH;
      localparam j1 = j0 + WS;
      assign adder_in0[i][j] = s_axis_tdata[j1:j0];
    end
  end

  endgenerate

  // counter (for tracking current input set) logic

  counter #(
    .LOWER (0),
    .UPPER (NC),
    .WRAPAROUND (0)
  ) counter (
    .clk (clk),
    .ena (s_axis_tvalid),
    .rst (s_axis_tvalid & s_axis_tready),
    .value (count)
  );

  assign s_axis_tready = m_axis_tready & (count == NC);

  // correlator instantiation

  generate
  genvar i;
  for (i = 0; i < CORR_LENGTH; i = i + 1) begin

    // create adder (one for each correlator bit)

    always @(posedge clk) begin
      if (s_axis_tvalid) begin
        if (CORRELATOR[j] == 1) begin
          adder_out[i] <= adder_in1[i] + adder_in0[i][count];
        end else begin
          adder_out[i] <= adder_in1[i] - adder_in0[i][count];
        end
      end else begin
        adder_out[i] <= adder_out[i];
      end
    end

    // create small distributed RAM instance

    xpm_memory_sdpram # (
      .MEMORY_SIZE (NUM_CHANNELS),
      .MEMORY_PRIMITIVE ("distributed"),
      .CLOCKING_MODE ("common_clock"),
      .MEMORY_INIT_FILE ("none"),
      .MEMORY_INIT_PARAM (""),
      .USE_MEM_INIT (1),
      .WAKEUP_TIME ("disable_sleep"),
      .MESSAGE_CONTROL (0),
      .ECC_MODE ("no_ecc"),
      .AUTO_SLEEP_TIME (0),
      .USE_EMBEDDED_CONSTRAINT (0),
      .MEMORY_OPTIMIZATION ("true"),
      .WRITE_DATA_WIDTH_A (ADDER_WIDTH),
      .BYTE_WRITE_WIDTH_A (),
      .ADDR_WIDTH_A (COUNT_WIDTH),
      .READ_DATA_WIDTH_B (ADDER_WIDTH),
      .ADDR_WIDTH_B (COUNT_WIDTH),
      .READ_RESET_VALUE_B ("0"),
      .READ_LATENCY_B (1),
      .WRITE_MODE_B ("read_first")
    ) xpm_memory_sdpram (
      .sleep (1'b0),
      .clka (clk),
      .ena (s_axis_tvalid),
      .wea (1'b1),
      .addra (count - 1'b1),
      .dina (adder_out[i]),
      .injectsbiterra (1'b0),
      .injectdbiterra (1'b0),
      .clkb (clk),
      .rstb (1'b0),
      .enb (s_axis_tvalid),
      .regceb (1'b1),
      .addrb (count + 1'b1),
      .doutb (adder_in1[i]),
      .sbiterrb (),
      .dbiterrb ()
    );

  end
  endgenerate

  // master interface

  always @(posedge clk) begin
    if (s_axis_tvalid & m_axis_tready) begin
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
