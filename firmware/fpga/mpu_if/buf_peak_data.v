////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Serializes tag data into a single output buffer for consumption by external
// microprocessor.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module buf_peak_data #(

  // parameters

  parameter   NUM_TAGS = 10,
  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   FIFO_DEPTH = 128,
  parameter   READ_WIDTH = 16,
  parameter   MEMORY_TYPE = "block",

  // derived parameters

  localparam  DATA_WIDTH = NUM_CHANNELS * CHANNEL_WIDTH,
  localparam  PAD_WIDTH = DATA_WIDTH - NUM_TAGS,
  localparam  NUM_PARALLEL = NUM_CHANNELS * 2,
  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WR = READ_WIDTH - 1,
  localparam  NP = NUM_PARALLEL - 1,
  localparam  WW = WORD_WIDTH - 1

) (

  // core interface

  input             clk,
  input             clk_out,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input   [ NT:0]   s_axis_tuser,
  input             s_axis_tlast,

  // microcontroller interface

  input             rd_ena,
  output            rd_ready,
  output  [ 15:0]   rd_data

);

  `include "func_log2.vh"

  // internal registers

  reg               rd_ena_d = 'b0;
  reg               aux_valid = 'b0;
  
  reg     [ NT:0]   tag_num = 'b0;

  // internal signals

  wire              s_axis_frame;

  wire              aux_frame;
  wire    [ WD:0]   aux_data;

  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_rd_rst_busy;
  wire              fifo_wr_rst_busy;

  /* Slave interface.
   * Because auxiliary data needs to be fed into the FIFO immediately after the
   * last data batch, the ready signal incorporates aux_valid to ensure that
   * the slave AXI-stream does not conflict with this process.
   */

  assign s_axis_tready = ~aux_valid & ~fifo_full;
  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  /* Auxiliary data control.
   * Auxiliary data (primiarly the detected tag number) must be written into the
   * FIFO. This is done on the cycle after tlast is asserted. Since tlast may be
   * high while valid is low, we check to make sure s_axis_frame is high on the
   * same cycle s_axis_tlast is asserted. The fifo_full signal is used as an
   * enable for this control logic.
   */

  always @(posedge clk) begin
    casez ({fifo_full, aux_frame, s_axis_frame, s_axis_tlast})
      4'b1???: aux_valid <= aux_valid;
      4'b01??: aux_valid <= 1'b0;
      4'b0011: aux_valid <= 1'b1;
      default: aux_valid <= aux_valid;
    endcase
  end

  always @(posedge clk) begin
    if (s_axis_tlast) begin
      tag_num <= s_axis_tuser;
    end else begin
      tag_num <= tag_num;
    end
  end

  assign aux_data = {{PAD_WIDTH{1'b0}}, tag_num};
  assign aux_frame = aux_valid & ~fifo_full;

  /* FIFO instantiation.
   * Whenever slave AXI-stream or auxiliary data is available, we write it into
   * the FIFO. Since the output data will be read by the MCU through the EBI
   * bus, use of a memory latch is okay.
   */

  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE (MEMORY_TYPE),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH (0),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("std"),
    .FIFO_READ_LATENCY (1),
    .READ_DATA_WIDTH (READ_WIDTH),
    .RD_DATA_COUNT_WIDTH (0),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (3),
    .WAKEUP_TIME (0)
  ) xpm_fifo_sync (
    .rst (1'b0),
    .wr_clk (clk),
    .wr_en (aux_frame | s_axis_frame),
    .din (aux_valid ? aux_data : s_axis_tdata),
    .full (fifo_full),
    .overflow (),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (clk_out),
    .rd_en (rd_ena & ~rd_ena_d),
    .dout (rd_data[WR:0]),
    .empty (fifo_empty),
    .underflow (),
    .rd_rst_busy (fifo_rd_rst_busy),
    .prog_empty (),
    .rd_data_count (),
    .almost_empty (),
    .data_valid (),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  /* Delayed read enable.
   * This delayed read enable signal is used to slice out the rising edge of
   * rd_ena.
   */

  always @(posedge clk_out) begin
    rd_ena_d <= rd_ena;
  end

  /* Output data.
   * The EBI bus is a fixed 16 bits, but the FIFO supports only DATA_WIDTH * 2^N
   * values for its output width, where |N| <= 3. Therefore, the read width may
   * not be exactly 16. For such cases, we pad the upper bits of the output data
   * bus with 0s.
   */

  generate
  if (READ_WIDTH < 16) begin
    assign rd_data[15:(WR+1)] = 'b0;
  end
  endgenerate

  /* Read ready.
   * If the FIFO is not empty, data exists and can be read by the MCU.
   */

  assign rd_ready = ~fifo_empty;

  ////////////////
  // SIMULATION //
  ////////////////

  reg     [ WW:0]   _data_in [0:NP];

  genvar n;
  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * WORD_WIDTH, n1 = n0 + WW;
    always @(posedge clk) begin
      if (s_axis_tvalid) begin
        _data_in[n] = s_axis_tdata[n1:n0];
      end else begin
        _data_in[n] <= 'b0;
      end
    end
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
