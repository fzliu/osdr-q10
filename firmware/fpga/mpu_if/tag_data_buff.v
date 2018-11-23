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

  parameter   NUM_TAGS = 20,
  parameter   CHANNEL_WIDTH = 64,
  parameter   FIFO_DEPTH = 1024,
  parameter   READ_WIDTH = 16,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WR = READ_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input   [ NT:0]   s_axis_tvalid,
  output  [ NT:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,
  input   [ NT:0]   s_axis_tlast,

  // microcontroller interface

  input             rd_ena,
  output            ready,
  output  [ WR:0]   data_out

);

  `include "log2_func.v"

  // internal registers

  reg               rd_ena_d = 'b0;
  reg               in_valid_d = 'b0;

  // internal signals

  wire              in_valid;
  wire              in_ready;
  wire    [ WD:0]   in_data;
  wire    [ NT:0]   in_user;
  wire              in_last;

  wire    [ WP:0]   fifo_din;
  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_rd_rst_busy;
  wire              fifo_wr_rst_busy;

  // fan-in to a single AXI-stream

  assign in_ready = (~in_valid | in_valid) & ~fifo_full;

  axis_fan_in #(
    .NUM_FANIN (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH)
  ) axis_fan_in (
    .clk (clk),
    .rst (rst),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata (s_axis_tdata),
    .s_axis_tlast (s_axis_tlast),
    .m_axis_tvalid (in_valid),
    .m_axis_tready (in_ready),
    .m_axis_tdata (in_data),
    .m_axis_tuser (in_user),
    .m_axis_tlast (in_last)
  );

  // assign FIFO inputs

  always @(posedge clk) begin
    in_valid_d <= in_valid;
  end

  assign fifo_din = in_valid ? in_data : in_user;

  // delayed read enable

  always @(posedge clk) begin
    rd_ena_d <= rd_ena;
  end

  // fifo instantiation

  xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE ("block"),
    .ECC_MODE ("no_ecc"),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (DATA_WIDTH),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("std"),
    .FIFO_READ_LATENCY (1),
    .READ_DATA_WIDTH (READ_WIDTH),
    .DOUT_RESET_VALUE ("0"),
    .WAKEUP_TIME (0)
  ) xpm_fifo_sync (
    .sleep (1'b0),
    .rst (rst),
    .wr_clk (clk),
    .wr_en (in_valid | in_valid_d),
    .din (fifo_din),
    .full (fifo_full),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_en (rd_ena & ~rd_ena_d),
    .dout (data_out),
    .empty (fifo_empty),
    .rd_rst_busy (fifo_rd_rst_busy),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0)
  );

  // output control signals

  assign ready = ~fifo_empty;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
