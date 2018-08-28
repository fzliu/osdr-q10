////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AD9361 top-level module. Handles the default dual-AD9361
// configuration used by the Orion anchor.
//
// Revision:
//
// enable  :  N/A
// reset   :  active-high
// latency :  multiple
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top #(

  // parameters

  parameter           NUM_TAGS = 40,
  parameter           WORD_WIDTH = 32,
  parameter           BURST_LENGTH = 32,
  parameter           PEAK_THRESHOLD = 1024,

  // derived parameters

  localparam          DATA_WIDTH = WORD_WIDTH * 2 * 4,
  localparam          PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam          NT = NUM_TAGS - 1,
  localparam          WD = DATA_WIDTH - 1,
  localparam          WP = PACKED_WIDTH - 1,

  parameter   [NT:0]  TAG_ENABLE = {{NT{1'b0}}, 1'b1}

) (

  // master interface

  input             clk,
  input             rst,

  // physical interface (receive_a)

  input             a_rx_clk_in,
  input             a_rx_frame_in,
  input   [ 11:0]   a_rx_data_p0,
  input   [ 11:0]   a_rx_data_p1,

  // physical interface (receive_b)

  input             b_rx_clk_in,
  input             b_rx_frame_in,
  input   [ 11:0]   b_rx_data_p0,
  input   [ 11:0]   b_rx_data_p1,

  // physical interface (control)

  output            sync_out,
  output            a_resetb,
  output            a_enable,
  output            a_txnrx,
  output            b_resetb,
  output            b_enable,
  output            b_txnrx,

  // physical interface (spi_a)

  output            a_spi_sck,
  output            a_spi_di,
  input             a_spi_do,
  output            a_spi_cs,

  // physical interface (spi_b)

  output            b_spi_sck,
  output            b_spi_di,
  input             b_spi_do,
  output            b_spi_cs,

  // microprocessor interface (spi)

  input             spi_sck,
  input             spi_mosi,
  output            spi_miso,
  input             spi_cs_a,
  input             spi_cs_b,

  // microprocessor interface (control)

  input             sync_in,

  // microprocessor interface (comms)

  input             ebi_ren,
  input   [ 19:0]   ebi_addr,
  output  [ 15:0]   ebi_data

);

  // internal signals (clock)

  wire              d_clk;    // data clock (from ad9361)
  wire              m_clk;    // main clock (moderate frequency)
  wire              c_clk;    // compute clock (high frequency)

  // internal signals (clock gen)

  wire    [  5:0]   pll_out;
  wire              pll_fb;
  wire              pll_lock;

  // internal signals (sample data interface)

  wire              a_data_clk;
  wire              b_data_clk;

  // internal signals (xcorr axi-stream)

  wire              xcorr_axis_tvalid;
  wire              xcorr_axis_tready;
  wire              xcorr_axis_tlast;
  wire    [127:0]   xcorr_axis_tdata;

  // internal signals (peak detect axi-stream)

  wire    [ NT:0]   cabs_axis_tvalid;
  wire    [ NT:0]   cabs_axis_tready;
  wire    [ WP:0]   cabs_axis_tdata;
  wire    [ WP:0]   cabs_axis_tdata_abs;

  // internal signals (peak detect axi-stream)

  wire    [ NT:0]   peak_axis_tvalid;
  wire    [ NT:0]   peak_axis_tready;
  wire    [ WP:0]   peak_axis_tdata;
  wire    [ WP:0]   peak_axis_tdata_abs;

  // internal signals (block storage axi-stream)

  wire    [ NT:0]   dout_axis_tvalid;
  wire    [ NT:0]   dout_axis_tready;
  wire    [ WP:0]   dout_axis_tdata;

  // multi-chip sync

  assign sync_out = sync_in;

  // clock generation

  anchor_clk_gen #()
  anchor_clk_gen (
    .clk_25M (clk),
    .clk_ad9361 (a_data_clk),
    .m_clk (m_clk),
    .c_clk (c_clk),
    .d_clk (d_clk)
  );

  // dual-9361 controller

  ad9361_dual #(
    .DEVICE_TYPE ("7SERIES"),
    .REALTIME_ENABLE (1),
    .INDEP_CLOCKS (0),
    .USE_AXIS_TLAST (0)
  ) ad9361_dual (
    .clk (d_clk),
    .rst (rst),
    .a_rx_clk_in (a_rx_clk_in),
    .a_rx_frame_in (a_rx_frame_in),
    .a_rx_data_p0 (a_rx_data_p0),
    .a_rx_data_p1 (a_rx_data_p1),
    .b_rx_clk_in (b_rx_clk_in),
    .b_rx_frame_in (b_rx_frame_in),
    .b_rx_data_p0 (b_rx_data_p0),
    .b_rx_data_p1 (b_rx_data_p1),
    .a_data_clk (a_data_clk),
    .a_resetb (a_resetb),
    .a_enable (a_enable),
    .a_txnrx (a_txnrx),
    .b_data_clk (b_data_clk),
    .b_resetb (b_resetb),
    .b_enable (b_enable),
    .b_txnrx (b_txnrx),
    .a_spi_sck (a_spi_sck),
    .a_spi_di (a_spi_di),
    .a_spi_do (a_spi_do),
    .a_spi_cs (a_spi_cs),
    .b_spi_sck (b_spi_sck),
    .b_spi_di (b_spi_di),
    .b_spi_do (b_spi_do),
    .b_spi_cs (b_spi_cs),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b),
    .m_axis_clk (d_clk),
    .m_axis_tvalid (xcorr_axis_tvalid),
    .m_axis_tready (xcorr_axis_tready),
    .m_axis_tlast (xcorr_axis_tlast),
    .m_axis_tdata (xcorr_axis_tdata)
  );

  // mass cross-correlation

  axis_xcorr_all #(
    .NUM_TAGS (NUM_TAGS),
    .S_TDATA_WIDTH (128),
    .M_TDATA_WIDTH (DATA_WIDTH),
    .DISABLE_MASK (~TAG_ENABLE)
  ) axis_xcorr_all (
    .in_clk (d_clk),
    .clk (c_clk),
    .s_axis_tvalid (xcorr_axis_tvalid),
    .s_axis_tready (xcorr_axis_tready),
    .s_axis_tdata (xcorr_axis_tdata),
    .m_axis_tvalid (cabs_axis_tvalid),
    .m_axis_tready (cabs_axis_tready),
    .m_axis_tdata (cabs_axis_tdata)
  );

  // absval computation

  axis_cabs_all #(
    .NUM_TAGS (NUM_TAGS),
    .CHANNEL_WIDTH (WORD_WIDTH * 2)
  ) axis_cabs_all (
    .clk (c_clk),
    .rst (rst),
    .s_axis_tvalid (cabs_axis_tvalid),
    .s_axis_tready (cabs_axis_tready),
    .s_axis_tdata (cabs_axis_tdata),
    .m_axis_tvalid (peak_axis_tvalid),
    .m_axis_tready (peak_axis_tready),
    .m_axis_tdata (peak_axis_tdata),
    .m_axis_tdata_abs (peak_axis_tdata_abs)
  );

  // parallel tag processing

  axis_peak_all #(
    .NUM_TAGS (NUM_TAGS),
    .BURST_LENGTH (BURST_LENGTH),
    .PEAK_THRESHOLD (PEAK_THRESHOLD),
    .CHANNEL_WIDTH (WORD_WIDTH * 2)
  ) axis_peak_all (
    .in_clk (c_clk),
    .clk (m_clk),
    .rst (rst),
    .s_axis_tvalid (peak_axis_tvalid),
    .s_axis_tready (peak_axis_tready),
    .s_axis_tdata (peak_axis_tdata),
    .s_axis_tdata_abs (peak_axis_tdata_abs),
    .s_axis_tlast ({NUM_TAGS{1'b0}}),
    .m_axis_tvalid (dout_axis_tvalid),
    .m_axis_tready (dout_axis_tready),
    .m_axis_tdata (dout_axis_tdata)
  );

  // microprocessor interface

  axis_tag_data #(
    .NUM_TAGS (NUM_TAGS),
    .BURST_LENGTH (BURST_LENGTH),
    .CHANNEL_WIDTH (WORD_WIDTH * 2),
    .OUT_WIDTH (16)
  ) axis_tag_data (
    .clk (m_clk),
    .rst (rst),
    .s_axis_tvalid (dout_axis_tvalid),
    .s_axis_tready (dout_axis_tready),
    .s_axis_tdata (dout_axis_tdata),
    .s_axis_tlast ({NUM_TAGS{1'b0}}),
    .virt_tagn (ebi_addr[19:12]),
    .virt_addr (ebi_addr[11:0]),
    .data_out (ebi_data)
  );

endmodule
