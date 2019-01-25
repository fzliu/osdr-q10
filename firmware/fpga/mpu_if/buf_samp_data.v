////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Stores sample data to a large block RAM FIFO in batches.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module buf_samp_data #(

  // parameters

  parameter   FIFO_DEPTH = 65536,
  parameter   WRITE_WIDTH = 128,
  parameter   READ_WIDTH = 16,

  // bit width parameters

  localparam  WI = WRITE_WIDTH - 1,
  localparam  WO = READ_WIDTH - 1

)(

  // master interface

  input             wr_clk,
  input             rd_clk,

  // sample (ad9361) interface

  input             s_axis_tvalid,
  input             s_axis_tready,
  input   [ WI:0]   s_axis_tdata,

  // microcontroller interface

  input             rd_ena,
  output            rd_ready,
  output  [ WO:0]   rd_data

);

  // internal registers

  reg               s_axis_tvalid_d = 'b0;
  reg               rd_ena_d = 'b0;

  // internal signals

  wire    [ WI:0]   fifo_din;
  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_rd_rst_busy;
  wire              fifo_wr_rst_busy;

  // assign FIFO inputs

  always @(posedge wr_clk) begin
    s_axis_tvalid_d <= s_axis_tvalid;
  end

  assign fifo_din = s_axis_tvalid ? s_axis_tdata : {128{1'b1}};

  // delayed read enable

  always @(posedge rd_clk) begin
    rd_ena_d <= rd_ena;
  end

  // fifo instantiation

  xpm_fifo_async # (
    .FIFO_MEMORY_TYPE ("block"),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (WRITE_WIDTH),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("std"),
    .FIFO_READ_LATENCY (1),   // memory latch is OK for EBI bus
    .READ_DATA_WIDTH (READ_WIDTH),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (2),
    .WAKEUP_TIME (0)
  ) xpm_fifo_async (
    .rst (1'b0),
    .wr_clk (wr_clk),
    .wr_en (s_axis_tvalid | s_axis_tvalid_d),
    .din (fifo_din),
    .full (fifo_full),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (rd_clk),
    .rd_en (rd_ena & ~rd_ena_d),
    .dout (rd_data),
    .empty (fifo_empty),
    .rd_rst_busy (fifo_rd_rst_busy),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0)
  );

  // output control signals

  assign rd_ready = ~fifo_empty;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
