////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Anchor top-level module. Uses bit correlation and approximate
// absolute value to perform peak detection. Detected peaks are sliced out
// and placed inside a FIFO for consumption by the microprocessor through the
// EBI bus.
//
// enable  :  N/A
// reset   :  N/A
// latency :  N/A
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top #(

  // parameters

  parameter   NUM_TAGS = 1,
  parameter   CORR_OFFSET = 0,

  parameter   NUM_CHANNELS = 4,
  parameter   CHANNEL_WIDTH = 32,
  parameter   ADDER_WIDTH = 12,
  parameter   SAMPS_WIDTH = 64,
  parameter   EBI_WIDTH = 16,

  parameter   CABS_DELAY = 14,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESH_MULT = 8,

  // derived parameters

  localparam  DATA_WIDTH = NUM_CHANNELS * CHANNEL_WIDTH,
  localparam  INPUT_WIDTH = NUM_TAGS * SAMPS_WIDTH,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WE = EBI_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WI = INPUT_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // master interface

  input             clk,

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

  input             reset_a,
  input             reset_b,
  input             sync_in,

  // microprocessor interface (comms)

  input             ebi_nrde,
  output  [ WE:0]   ebi_data,
  output            ready

);

  // internal signals (clock)

  wire              d_clk;    // data clock (from ad9361)
  wire              m_clk;    // main clock (moderate frequency)
  wire              c_clk;    // compute clock (high frequency)

  // internal signals (sample data interface)

  wire              a_data_clk;
  wire              b_data_clk;

  // internal signals (ad9361 axi-stream)

  wire              ad9361_axis_tvalid;
  wire              ad9361_axis_tready;
  wire    [ WS:0]   ad9361_axis_tdata;

  // internal signals (clock conv axi-stream)

  wire              fifo_axis_tvalid;
  wire              fifo_axis_tready;
  wire    [ WS:0]   fifo_axis_tdata;

  // internal signals (distributor)

  wire    [ NT:0]   distrib_axis_tvalid;
  wire    [ NT:0]   distrib_axis_tready;
  wire    [ WI:0]   distrib_axis_tdata;

  // internal signals (bitcorr)

  wire    [ NT:0]   corr_axis_tvalid;
  wire    [ NT:0]   corr_axis_tready;
  wire    [ WP:0]   corr_axis_tdata;

  // internal signals (peak detect)

  wire    [ NT:0]   cabs_axis_tvalid;
  wire    [ NT:0]   cabs_axis_tready;
  wire    [ WP:0]   cabs_axis_tdata;
  wire    [ WP:0]   cabs_axis_tdata_abs;

  // internal signals (peak detect)

  wire    [ NT:0]   peak_axis_tvalid;
  wire    [ NT:0]   peak_axis_tready;
  wire    [ WP:0]   peak_axis_tdata;
  wire    [ NT:0]   peak_axis_tlast;

  // internal signals (fan-in)

  wire              fanin_axis_tvalid;
  wire              fanin_axis_tready;
  wire    [ WD:0]   fanin_axis_tdata;
  wire              fanin_axis_tlast;
  wire    [ NT:0]   fanin_axis_tuser;

  // buffer read enable

  wire              rd_ena;

  // multi-chip sync

  assign sync_out = sync_in;

  // clock generation

  anchor_clk_gen #()
  anchor_clk_gen (
    .clk_xtal (clk),
    .clk_ad9361 (a_data_clk),
    .m_clk (m_clk),
    .c_clk (c_clk),
    .d_clk (d_clk)
  );

  // synchronize external signals

  anchor_ext_sync #()
  anchor_ext_sync (
    .d_clk (d_clk),
    .m_clk (m_clk),
    .c_clk (c_clk),
    .ebi_nrde (ebi_nrde),
    .rd_ena (rd_ena)
  );

  // dual-9361 controller

  ad9361_dual #(
    .DEVICE_TYPE ("7SERIES"),
    .REALTIME_ENABLE (1),
    .USE_SAMPLE_FILTER (1),
    .NUM_PAD_SAMPS (15),
    .DATA_PASS_VALUE (64),
    .FILTER_LENGTH (16),
    .SAMPS_WIDTH (SAMPS_WIDTH),
    .REDUCE_PRECISION (6),
    .REVERSE_DATA (0),
    .INDEP_CLOCKS (0),
    .USE_AXIS_TLAST (0)
  ) ad9361_dual (
    .clk (d_clk),
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
    .reset_a (reset_a),
    .reset_b (reset_b),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b),
    .m_axis_clk (d_clk),
    .m_axis_tvalid (ad9361_axis_tvalid),
    .m_axis_tready (ad9361_axis_tready),
    .m_axis_tdata (ad9361_axis_tdata),
    .m_axis_tlast ()
  );

  // clock conversion (data -> master) and buffering

  axis_fifo_async #(
    .MEMORY_TYPE ("block"),
    .DATA_WIDTH (SAMPS_WIDTH),
    .FIFO_DEPTH (65536),
    .READ_LATENCY (3)
  ) axis_fifo_sync (
    .s_axis_clk (d_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (m_clk),
    .s_axis_tvalid (ad9361_axis_tvalid),
    .s_axis_tready (ad9361_axis_tready),
    .s_axis_tdata (ad9361_axis_tdata),
    .m_axis_tvalid (fifo_axis_tvalid),
    .m_axis_tready (fifo_axis_tready),
    .m_axis_tdata (fifo_axis_tdata)
  );

  // distribute to correlators (master -> compute)

  axis_distrib #(
    .NUM_DISTRIB (NUM_TAGS),
    .DATA_WIDTH (SAMPS_WIDTH),
    .USE_FIFOS (1),
    .FIFO_TYPE ("block"),
    .FIFO_LATENCY (3)
  ) axis_distrib (
    .s_axis_clk (m_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (c_clk),
    .s_axis_tvalid (fifo_axis_tvalid),
    .s_axis_tready (fifo_axis_tready),
    .s_axis_tdata (fifo_axis_tdata),
    .m_axis_tvalid (distrib_axis_tvalid),
    .m_axis_tready (distrib_axis_tready),
    .m_axis_tdata (distrib_axis_tdata)
  );

  genvar n;
  generate
  for (n = 0; n < NUM_TAGS; n = n + 1) begin
    localparam i0 = n * SAMPS_WIDTH;
    localparam i1 = i0 + WS;
    localparam j0 = n * DATA_WIDTH;
    localparam j1 = j0 + WD;

    // perform cross-correlation

    axis_bit_corr #(
      .NUM_PARALLEL (NUM_CHANNELS * 2),
      .SLAVE_WIDTH (SAMPS_WIDTH),
      .MASTER_WIDTH (DATA_WIDTH),
      .ADDER_WIDTH (ADDER_WIDTH),
      .SHIFT_DEPTH (2),
      .CORR_NUM (n + CORR_OFFSET)
    ) axis_bit_corr (
      .clk (c_clk),
      .s_axis_tvalid (distrib_axis_tvalid[n]),
      .s_axis_tready (distrib_axis_tready[n]),
      .s_axis_tdata (distrib_axis_tdata[i1:i0]),
      .m_axis_tvalid (corr_axis_tvalid[n]),
      .m_axis_tready (corr_axis_tready[n]),
      .m_axis_tdata (corr_axis_tdata[j1:j0])
    );

    // absolute value computation

    axis_cabs_serial #(
      .NUM_CHANNELS (NUM_CHANNELS),
      .CHANNEL_WIDTH (CHANNEL_WIDTH),
      .CABS_DELAY (CABS_DELAY)
    ) axis_cabs_serial (
      .clk (c_clk),
      .s_axis_tvalid (corr_axis_tvalid[n]),
      .s_axis_tready (corr_axis_tready[n]),
      .s_axis_tdata (corr_axis_tdata[j1:j0]),
      .m_axis_tvalid (cabs_axis_tvalid[n]),
      .m_axis_tready (cabs_axis_tready[n]),
      .m_axis_tdata (cabs_axis_tdata[j1:j0]),
      .m_axis_tdata_abs (cabs_axis_tdata_abs[j1:j0])
    );

    // peak detection

    axis_peak_detn #(
      .NUM_CHANNELS (NUM_CHANNELS),
      .CHANNEL_WIDTH (CHANNEL_WIDTH),
      .PEAK_THRESH_MULT (PEAK_THRESH_MULT),
      .BURST_LENGTH (BURST_LENGTH)
    ) axis_peak_detn (
      .clk (c_clk),
      .s_axis_tvalid (cabs_axis_tvalid[n]),
      .s_axis_tready (cabs_axis_tready[n]),
      .s_axis_tdata (cabs_axis_tdata[j1:j0]),
      .s_axis_tdata_abs (cabs_axis_tdata_abs[j1:j0]),
      .m_axis_tvalid (peak_axis_tvalid[n]),
      .m_axis_tready (peak_axis_tready[n]),
      .m_axis_tdata (peak_axis_tdata[j1:j0]),
      .m_axis_tlast (peak_axis_tlast[n])
    );

  end
  endgenerate

  // axi-stream fan-in (compute -> master)

  axis_fan_in #(
    .NUM_FANIN (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH),
    .USE_FIFOS (1),
    .FIFO_TYPE ("block"),
    .FIFO_LATENCY (3),
    .USE_AXIS_TLAST (1)
  ) axis_fan_in (
    .s_axis_clk (c_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (m_clk),
    .m_axis_rst (1'b0),
    .s_axis_tvalid (peak_axis_tvalid),
    .s_axis_tready (peak_axis_tready),
    .s_axis_tdata (peak_axis_tdata),
    .s_axis_tlast (peak_axis_tlast),
    .m_axis_tvalid (fanin_axis_tvalid),
    .m_axis_tready (fanin_axis_tready),
    .m_axis_tdata (fanin_axis_tdata),
    .m_axis_tlast (fanin_axis_tlast),
    .m_axis_tuser (fanin_axis_tuser)
  );

  // microprocessor interface

  tag_data_buff #(
    .NUM_TAGS (NUM_TAGS),
    .NUM_CHANNELS (NUM_CHANNELS),
    .CHANNEL_WIDTH (CHANNEL_WIDTH),
    .READ_WIDTH (EBI_WIDTH),
    .MEMORY_TYPE ("block")
  ) tag_data_buff (
    .clk (m_clk),
    .s_axis_tvalid (fanin_axis_tvalid),
    .s_axis_tready (fanin_axis_tready),
    .s_axis_tdata (fanin_axis_tdata),
    .s_axis_tlast (fanin_axis_tlast),
    .s_axis_tuser (fanin_axis_tuser),
    .rd_ena (rd_ena),
    .ready (ready),
    .data_out (ebi_data)
  );

endmodule
