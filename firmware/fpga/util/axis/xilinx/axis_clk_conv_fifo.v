////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
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

module axis_clk_conv_fifo #(

  // parameters

  parameter   DATA_WIDTH = 256,
  parameter   FIFO_DEPTH = 6,

  // derived parameters

  localparam  FIFO_WIDTH = DATA_WIDTH + 1,

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  WF = FIFO_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             m_axis_clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,
  input             s_axis_tlast,

  // master interace

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output            m_axis_tlast

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
  wire    [ WD:0]   fifo_din;
  wire    [ WD:0]   fifo_dout;

  // slave interface

  assign fifo_write = s_axis_valid & s_axis_ready;
  assign fifo_din = {s_axis_tdata & s_axis_tlast};

  assign s_axis_ready = ~fifo_full;

  // fifo instantitation

  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE ("distributed"),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (FIFO_WIDTH),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("fwft"),
    .FIFO_READ_LATENCY (0),
    .READ_DATA_WIDTH (FIFO_WIDTH),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (3),
    .WAKEUP_TIME (0)
  ) axis_sample_fifo (
    .rst (rst),
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
    .data_valid (),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  // master interface

  assign fifo_read = m_axis_tready & m_axis_tvalid;

  assign {m_axis_tdata, m_axis_tlast} = fifo_dout;
  assign m_axis_tvalid = ~fifo_empty;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
