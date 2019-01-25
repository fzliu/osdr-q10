////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor top-level module. Uses bit correlation and approximate absolute value
// to perform peak detection. Detected peaks are sliced out and placed inside a
// FIFO for consumption by the microprocessor through the EBI bus.
//
// Parameters
// DEVICE_TYPE: programmable logic family
// NUM_TAGS: number of tags to support
// PRECISION: desired precision of the input data bus, must be <= 12
// CORR_OFFSET: index of the first (zeroth) correlator to use
//
// enable  :  N/A
// reset   :  N/A
// latency :  N/A
// output  :  N/A
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top #(

  // parameters

  parameter   DEVICE_TYPE = "7SERIES",

  parameter   NUM_TAGS = 2,
  parameter   NUM_CHANNELS = 4,
  parameter   PRECISION = 6,
  parameter   ADDER_WIDTH = 12,
  parameter   CORR_OFFSET = 0,

  parameter   CABS_DELAY = 10,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESH_MULT = 8,

  // correlator parameters

  `include "correlators.vh"

  // derived parameters

  localparam  CHANNEL_WIDTH = 2 * ADDER_WIDTH,
  localparam  SAMPS_WIDTH = 2 * PRECISION * NUM_CHANNELS,
  localparam  DATA_WIDTH = NUM_CHANNELS * CHANNEL_WIDTH,
  localparam  INPUT_WIDTH = NUM_TAGS * SAMPS_WIDTH,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WS = SAMPS_WIDTH - 1,
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
  output  [ 15:0]   ebi_data,
  output            ebi_ready,

  // LED interface

  output  [  7:0]   led_out

);

  // internal signals (clock)

  wire              d_clk;    // data clock (from ad9361)
  wire              m_clk;    // main clock (moderate frequency)
  wire              c_clk;    // compute clock (high frequency)

  // internal signals (sample interface)

  wire              a_data_clk;
  wire              b_data_clk;

  wire              valid_0;
  wire    [ 11:0]   data_i0;
  wire    [ 11:0]   data_q0;
  wire              valid_1;
  wire    [ 11:0]   data_i1;
  wire    [ 11:0]   data_q1;
  wire              valid_2;
  wire    [ 11:0]   data_i2;
  wire    [ 11:0]   data_q2;
  wire              valid_3;
  wire    [ 11:0]   data_i3;
  wire    [ 11:0]   data_q3;

  wire              valid_0_sf;
  wire    [ 11:0]   data_i0_sf;
  wire    [ 11:0]   data_q0_sf;
  wire              valid_1_sf;
  wire    [ 11:0]   data_i1_sf;
  wire    [ 11:0]   data_q1_sf;
  wire              valid_2_sf;
  wire    [ 11:0]   data_i2_sf;
  wire    [ 11:0]   data_q2_sf;
  wire              valid_3_sf;
  wire    [ 11:0]   data_i3_sf;
  wire    [ 11:0]   data_q3_sf;

  // internal signals (microprocessor)

  wire              rd_ena;

  // internal signals (axi-stream)

  wire              ad9361_axis_tvalid;
  wire              ad9361_axis_tready;
  wire    [ WS:0]   ad9361_axis_tdata;

  wire              fifo_axis_tvalid;
  wire              fifo_axis_tready;
  wire    [ WS:0]   fifo_axis_tdata;

  wire    [ NT:0]   distrib_axis_tvalid;
  wire    [ NT:0]   distrib_axis_tready;
  wire    [ WI:0]   distrib_axis_tdata;

  wire    [ NT:0]   corr_axis_tvalid;
  wire    [ NT:0]   corr_axis_tready;
  wire    [ WP:0]   corr_axis_tdata;

  wire    [ NT:0]   cabs_axis_tvalid;
  wire    [ NT:0]   cabs_axis_tready;
  wire    [ WP:0]   cabs_axis_tdata;
  wire    [ WP:0]   cabs_axis_tdata_abs;

  wire    [ NT:0]   peak_axis_tvalid;
  wire    [ NT:0]   peak_axis_tready;
  wire    [ WP:0]   peak_axis_tdata;
  wire    [ NT:0]   peak_axis_tlast;

  wire              fanin_axis_tvalid;
  wire              fanin_axis_tready;
  wire    [ WD:0]   fanin_axis_tdata;
  wire              fanin_axis_tlast;
  wire    [ NT:0]   fanin_axis_tuser;

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

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_rd_ena (
    .src_clk (),
    .src_in (~ebi_nrde),
    .dest_clk (m_clk),
    .dest_out (rd_ena)
  );

  // led control

  assign led_out[0] = valid_1;
  assign led_out[1] = valid_0;
  assign led_out[2] = valid_2;
  assign led_out[3] = valid_3;
  assign led_out[4] = 1'b0;
  assign led_out[5] = ad9361_axis_tvalid;
  assign led_out[6] = 1'b0;
  assign led_out[7] = ebi_ready;

  // receive_a

  ad9361_cmos_if #(
    .DEVICE_TYPE (DEVICE_TYPE),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_a (
    .clk (d_clk),
    .rx_clk_in (a_rx_clk_in),
    .rx_frame_in (a_rx_frame_in),
    .rx_data_p0 (a_rx_data_p0),
    .rx_data_p1 (a_rx_data_p1),
    .enable (a_enable),
    .txnrx (a_txnrx),
    .data_clk (a_data_clk),
    .valid_0 (valid_0),
    .data_i0 (data_i0),
    .data_q0 (data_q0),
    .valid_1 (valid_1),
    .data_i1 (data_i1),
    .data_q1 (data_q1)
  );

  // receive_b

  ad9361_cmos_if #(
    .DEVICE_TYPE (DEVICE_TYPE),
    .USE_EXT_CLOCK (1),
    .REALTIME_ENABLE (1)
  ) ad9361_cmos_if_b (
    .clk (d_clk),
    .rx_clk_in (b_rx_clk_in),
    .rx_frame_in (b_rx_frame_in),
    .rx_data_p0 (b_rx_data_p0),
    .rx_data_p1 (b_rx_data_p1),
    .enable (b_enable),
    .txnrx (b_txnrx),
    .data_clk (b_data_clk),
    .valid_0 (valid_2),
    .data_i0 (data_i2),
    .data_q0 (data_q2),
    .valid_1 (valid_3),
    .data_i1 (data_i3),
    .data_q1 (data_q3)
  );

  // dual spi

  ad9361_dual_spi #()
  ad9361_dual_spi (
    .a_resetb (a_resetb),
    .a_spi_sck (a_spi_sck),
    .a_spi_di (a_spi_di),
    .a_spi_do (a_spi_do),
    .a_spi_cs (a_spi_cs),
    .b_resetb (b_resetb),
    .b_spi_sck (b_spi_sck),
    .b_spi_di (b_spi_di),
    .b_spi_do (b_spi_do),
    .b_spi_cs (b_spi_cs),
    .sync_out (sync_out),
    .reset_a (reset_a),
    .reset_b (reset_b),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b),
    .sync_in (sync_in)
  );

  // sample filter

  ad9361_dual_filt #(
    .ABS_WIDTH (16),
    .NUM_DELAY (22),
    .NUM_PAD_SAMPS (15),
    .DATA_PASS_VALUE (16),
    .FILTER_LENGTH (16)
  ) ad9361_dual_filt (
    .clk (d_clk),
    .valid_0_in (valid_0),
    .data_i0_in (data_i0),
    .data_q0_in (data_q0),
    .valid_1_in (valid_1),
    .data_i1_in (data_i1),
    .data_q1_in (data_q1),
    .valid_2_in (valid_2),
    .data_i2_in (data_i2),
    .data_q2_in (data_q2),
    .valid_3_in (valid_3),
    .data_i3_in (data_i3),
    .data_q3_in (data_q3),
    .valid_0_out (valid_0_sf),
    .data_i0_out (data_i0_sf),
    .data_q0_out (data_q0_sf),
    .valid_1_out (valid_1_sf),
    .data_i1_out (data_i1_sf),
    .data_q1_out (data_q1_sf),
    .valid_2_out (valid_2_sf),
    .data_i2_out (data_i2_sf),
    .data_q2_out (data_q2_sf),
    .valid_3_out (valid_3_sf),
    .data_i3_out (data_i3_sf),
    .data_q3_out (data_q3_sf)
  );

  // serialize data

  ad9361_dual_axis #(
    .PRECISION (PRECISION),
    .REVERSE_DATA (0),
    .INDEP_CLOCKS (0),
    .USE_AXIS_TLAST (0)
  ) ad9361_dual_axis (
    .clk (d_clk),
    .valid_0 (valid_0_sf),
    .data_i0 (data_i0_sf),
    .data_q0 (data_q0_sf),
    .valid_1 (valid_1_sf),
    .data_i1 (data_i1_sf),
    .data_q1 (data_q1_sf),
    .valid_2 (valid_2_sf),
    .data_i2 (data_i2_sf),
    .data_q2 (data_q2_sf),
    .valid_3 (valid_3_sf),
    .data_i3 (data_i3_sf),
    .data_q3 (data_q3_sf),
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
    .FIFO_DEPTH (131072),
    .READ_LATENCY (2)
  ) axis_fifo_async (
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
      .WAVE_WIDTH (PRECISION),
      .ADDER_WIDTH (ADDER_WIDTH),
      .USE_STALL_SIGNAL (0),
      .SHIFT_DEPTH (2),
      .NUM_CORRS (1),
      .CORR_OFFSET (CORR_OFFSET + n),
      .CORR_LENGTH (CORR_LENGTH),
      .CORRELATORS (CORRELATORS)
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
      .CABS_DELAY (CABS_DELAY),
      .USE_STALL_SIGNAL (0)
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

  // axi-stream fan-in

  axis_fan_in #(
    .NUM_FANIN (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH),
    .USE_AXIS_TLAST (1),
    .USE_FIFOS (1),
    .FIFO_TYPE ("block"),
    .FIFO_LATENCY (2)
  ) axis_fan_in (
    .s_axis_clk (c_clk),
    .s_axis_rst (1'b0),
    .m_axis_clk (m_clk),
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

  buf_peak_data #(
    .NUM_TAGS (NUM_TAGS),
    .NUM_CHANNELS (NUM_CHANNELS),
    .CHANNEL_WIDTH (CHANNEL_WIDTH),
    .FIFO_DEPTH (256),
    .READ_WIDTH (ADDER_WIDTH),
    .MEMORY_TYPE ("block")
  ) buf_peak_data (
    .clk (m_clk),
    .s_axis_tvalid (fanin_axis_tvalid),
    .s_axis_tready (fanin_axis_tready),
    .s_axis_tdata (fanin_axis_tdata),
    .s_axis_tlast (fanin_axis_tlast),
    .s_axis_tuser (fanin_axis_tuser),
    .rd_ena (rd_ena),
    .rd_ready (ebi_ready),
    .rd_data (ebi_data)
  );

endmodule
