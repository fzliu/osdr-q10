////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream synchronous FIFO.
//
// enable  :  N/A
// reset   :  active-high
// latency :  multiple
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fifo_sync #(

  // parameters

  parameter   MEMORY_TYPE = "distributed",
  parameter   DATA_WIDTH = 256,
  parameter   FIFO_DEPTH = 16,

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata

);

  // internal signals

  wire              fifo_wr_rst_busy;
  wire              fifo_rd_rst_busy;
  wire              fifo_oflow;
  wire              fifo_uflow;
  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_write;
  wire              fifo_read;
  wire              fifo_valid;
  wire    [ WD:0]   fifo_din;
  wire    [ WD:0]   fifo_dout;

  // slave interface

  assign s_axis_tready = ~fifo_full;

  // fifo instantitation

  assign fifo_write = s_axis_tvalid & s_axis_tready;
  assign fifo_din = s_axis_tdata;

  xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE (MEMORY_TYPE),
    .ECC_MODE ("no_ecc"),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH (0),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("1000"),
    .READ_MODE ("fwft"),
    .FIFO_READ_LATENCY (1),
    .READ_DATA_WIDTH (DATA_WIDTH),
    .RD_DATA_COUNT_WIDTH (0),
    .DOUT_RESET_VALUE ("0"),
    .WAKEUP_TIME (0)
  ) axis_sample_fifo (
    .sleep (1'b0),
    .rst (rst),
    .wr_clk (clk),
    .wr_en (fifo_write),
    .din (fifo_din),
    .full (fifo_full),
    .overflow (fifo_oflow),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_en (fifo_read),
    .dout (fifo_dout),
    .empty (fifo_empty),
    .rd_rst_busy (fifo_rd_rst_busy),
    .prog_empty (),
    .rd_data_count (),
    .almost_empty (),
    .data_valid (fifo_valid),
    .underflow (fifo_uflow),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  assign fifo_read = m_axis_tready & m_axis_tvalid;

  // master interface

  assign m_axis_tdata = fifo_dout;
  assign m_axis_tvalid = fifo_valid;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
