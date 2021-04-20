////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description: AXI-stream clock converter using FIFO.
//
// enable  :  N/A
// reset   :  active-high
// latency :  multiple
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fifo_async #(

  // parameters

  parameter   MEMORY_TYPE = "auto",
  parameter   DATA_WIDTH = 72,
  parameter   READ_WIDTH = DATA_WIDTH,
  parameter   FIFO_DEPTH = 16,

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  WR = READ_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WR:0]   m_axis_tdata

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
  wire    [ WR:0]   fifo_dout;

  /* Slave interface.
   */

  assign s_axis_tready = ~s_axis_rst & ~fifo_wr_rst_busy & ~fifo_full;

  /* FIFO glue logic.
   */

  assign fifo_write = s_axis_tvalid & s_axis_tready;
  assign fifo_din = s_axis_tdata;

  assign fifo_read = m_axis_tvalid & m_axis_tready;

  /* FIFO instantiation.
   */

  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE (MEMORY_TYPE),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (DATA_WIDTH),
    .WR_DATA_COUNT_WIDTH (1),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("1000"),
    .READ_MODE ("fwft"),
    .FIFO_READ_LATENCY (0),
    .READ_DATA_WIDTH (READ_WIDTH),
    .RD_DATA_COUNT_WIDTH (1),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (2),
    .WAKEUP_TIME (0)
  ) xpm_fifo_async (
    .rst (s_axis_rst),
    .wr_clk (s_axis_clk),
    .wr_en (fifo_write),
    .din (fifo_din),
    .full (fifo_full),
    .overflow (fifo_oflow),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (m_axis_clk),
    .rd_en (fifo_read),
    .dout (fifo_dout),
    .empty (fifo_empty),
    .underflow (fifo_uflow),
    .rd_rst_busy (fifo_rd_rst_busy),
    .prog_empty (),
    .rd_data_count (),
    .almost_empty (),
    .data_valid (fifo_valid),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  /* Master interface.
   */

  assign m_axis_tdata = fifo_valid ? fifo_dout : {READ_WIDTH{1'b0}};
  assign m_axis_tvalid = ~fifo_rd_rst_busy & fifo_valid;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
