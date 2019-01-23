////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Serializes tag data into a single output buffer for consumption
// by external microprocessor.
//
// enable  :  N/A
// reset   :  active-high
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module tag_data_buff #(

  // parameters

  parameter   NUM_TAGS = 10,
  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 64,
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

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input   [ NT:0]   s_axis_tuser,
  input             s_axis_tlast,

  // microcontroller interface

  input             rd_ena,
  output            rd_ready,
  output  [ WR:0]   rd_data

);

  `include "func_log2.vh"

  // internal registers

  reg               rd_ena_d = 'b0;
  reg               s_axis_tlast_d = 'b0;

  // internal signals

  wire    [ WD:0]   tag_num;

  wire    [ WD:0]   fifo_din;
  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_rd_rst_busy;
  wire              fifo_wr_rst_busy;

  // slave interface

  always @(posedge clk) begin
    s_axis_tlast_d <= s_axis_tlast;
  end

  assign s_axis_tready = ~s_axis_tlast_d & ~fifo_full;

  // assign FIFO inputs

  assign tag_num = {{PAD_WIDTH{1'b0}}, s_axis_tuser};
  assign fifo_din = s_axis_tlast_d ? tag_num : s_axis_tdata;

  // delayed read enable

  always @(posedge clk) begin
    rd_ena_d <= rd_ena;
  end

  // fifo instantiation

  xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE (MEMORY_TYPE),
    .ECC_MODE ("no_ecc"),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH (0),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("std"),
    .FIFO_READ_LATENCY (1),   // memory latch is OK for EBI bus
    .READ_DATA_WIDTH (READ_WIDTH),
    .RD_DATA_COUNT_WIDTH (0),
    .DOUT_RESET_VALUE ("0"),
    .WAKEUP_TIME (0)
  ) xpm_fifo_sync (
    .sleep (1'b0),
    .rst (1'b0),
    .wr_clk (clk),
    .wr_en (s_axis_tvalid | s_axis_tlast_d),
    .din (fifo_din),
    .full (fifo_full),
    .overflow (),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_en (rd_ena & ~rd_ena_d),
    .dout (rd_data),
    .empty (fifo_empty),
    .rd_rst_busy (fifo_rd_rst_busy),
    .prog_empty (),
    .rd_data_count (),
    .almost_empty (),
    .data_valid (),
    .underflow (),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  // output control signals

  assign rd_ready = ~fifo_empty;

  // SIMULATION
  
  wire      [ WW:0]   _s_axis_tdata_unpack [0:NP];

  genvar n;
  generate
  for (n = 0; n < NUM_PARALLEL; n = n + 1) begin
    localparam n0 = n * WORD_WIDTH;
    localparam n1 = n0 + WW;
    assign _s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
