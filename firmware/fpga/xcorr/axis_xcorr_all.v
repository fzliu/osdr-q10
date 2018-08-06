////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Packs all cross-correlations modules into a single file.
//
////////////////////////////////////////////////////////////////////////////////

module axis_xcorr_all #(

  // parameters

  parameter           NUM_TAGS = 40,
  parameter           FIFO_DEPTH = 2048,
  parameter           S_TDATA_WIDTH = 128,
  parameter           M_TDATA_WIDTH = 256,

  // derived parameters

  localparam          M_TOTAL_WIDTH = NUM_TAGS * M_TDATA_WIDTH,

  // bit width parameters

  localparam          N0 = NUM_TAGS - 1,
  localparam          N1 = S_TDATA_WIDTH - 1,
  localparam          N2 = M_TOTAL_WIDTH - 1,

  parameter   [N0:0]  DISABLE_MASK = {NUM_TAGS{1'b0}}

) (

  // core interface

  input             in_clk,
  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ N1:0]   s_axis_tdata,

  // master interface

  output  [ N0:0]   m_axis_tvalid,
  input   [ N0:0]   m_axis_tready,
  output  [ N2:0]   m_axis_tdata

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
  wire    [ N1:0]   fifo_din;
  wire    [ N1:0]   fifo_dout;
  wire    [ N0:0]   fir_ready;

  // input FIFO queue

  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE ("block"),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (S_TDATA_WIDTH),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("fwft"),
    .FIFO_READ_LATENCY (0),
    .READ_DATA_WIDTH (128),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (3),
    .WAKEUP_TIME (0)
  ) axis_sample_fifo (
    .rst (rst),
    .wr_clk (in_clk),
    .wr_en (fifo_write),
    .din (fifo_din),
    .full (fifo_full),
    .overflow (fifo_oflow),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (clk),
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

  assign fifo_write = s_axis_tvalid;
  assign fifo_din = s_axis_tdata;
  assign s_axis_tready = ~fifo_full;
  assign fifo_read = &fir_ready;

  // tag 0

  generate
  if (DISABLE_MASK[0] == 1'b0) begin

  axis_xcorr_tag_0 #()
  axis_xcorr_tag_0 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[0]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[0]),
    .m_axis_data_tready (m_axis_tready[0]),
    .m_axis_data_tdata (m_axis_tdata[255:0])
  );

  end else begin

  assign fir_ready[0] = 1'b1;
  assign m_axis_tvalid[0] = 1'b0;
  assign m_axis_tdata[255:0] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 1

  generate
  if (DISABLE_MASK[1] == 1'b0) begin

  axis_xcorr_tag_1 #()
  axis_xcorr_tag_1 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[1]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[1]),
    .m_axis_data_tready (m_axis_tready[1]),
    .m_axis_data_tdata (m_axis_tdata[511:256])
  );

  end else begin

  assign fir_ready[1] = 1'b1;
  assign m_axis_tvalid[1] = 1'b0;
  assign m_axis_tdata[511:256] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 2

  generate
  if (DISABLE_MASK[2] == 1'b0) begin

  axis_xcorr_tag_2 #()
  axis_xcorr_tag_2 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[2]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[2]),
    .m_axis_data_tready (m_axis_tready[2]),
    .m_axis_data_tdata (m_axis_tdata[767:512])
  );

  end else begin

  assign fir_ready[2] = 1'b1;
  assign m_axis_tvalid[2] = 1'b0;
  assign m_axis_tdata[767:512] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 3

  generate
  if (DISABLE_MASK[3] == 1'b0) begin

  axis_xcorr_tag_3 #()
  axis_xcorr_tag_3 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[3]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[3]),
    .m_axis_data_tready (m_axis_tready[3]),
    .m_axis_data_tdata (m_axis_tdata[1023:768])
  );

  end else begin

  assign fir_ready[3] = 1'b1;
  assign m_axis_tvalid[3] = 1'b0;
  assign m_axis_tdata[1023:768] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 4

  generate
  if (DISABLE_MASK[4] == 1'b0) begin

  axis_xcorr_tag_4 #()
  axis_xcorr_tag_4 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[4]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[4]),
    .m_axis_data_tready (m_axis_tready[4]),
    .m_axis_data_tdata (m_axis_tdata[1279:1024])
  );

  end else begin

  assign fir_ready[4] = 1'b1;
  assign m_axis_tvalid[4] = 1'b0;
  assign m_axis_tdata[1279:1024] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 5

  generate
  if (DISABLE_MASK[5] == 1'b0) begin

  axis_xcorr_tag_5 #()
  axis_xcorr_tag_5 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[5]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[5]),
    .m_axis_data_tready (m_axis_tready[5]),
    .m_axis_data_tdata (m_axis_tdata[1535:1280])
  );

  end else begin

  assign fir_ready[5] = 1'b1;
  assign m_axis_tvalid[5] = 1'b0;
  assign m_axis_tdata[1535:1280] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 6

  generate
  if (DISABLE_MASK[6] == 1'b0) begin

  axis_xcorr_tag_6 #()
  axis_xcorr_tag_6 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[6]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[6]),
    .m_axis_data_tready (m_axis_tready[6]),
    .m_axis_data_tdata (m_axis_tdata[1791:1536])
  );

  end else begin

  assign fir_ready[6] = 1'b1;
  assign m_axis_tvalid[6] = 1'b0;
  assign m_axis_tdata[1791:1536] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 7

  generate
  if (DISABLE_MASK[7] == 1'b0) begin

  axis_xcorr_tag_7 #()
  axis_xcorr_tag_7 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[7]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[7]),
    .m_axis_data_tready (m_axis_tready[7]),
    .m_axis_data_tdata (m_axis_tdata[2047:1792])
  );

  end else begin

  assign fir_ready[7] = 1'b1;
  assign m_axis_tvalid[7] = 1'b0;
  assign m_axis_tdata[2047:1792] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 8

  generate
  if (DISABLE_MASK[8] == 1'b0) begin

  axis_xcorr_tag_8 #()
  axis_xcorr_tag_8 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[8]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[8]),
    .m_axis_data_tready (m_axis_tready[8]),
    .m_axis_data_tdata (m_axis_tdata[2303:2048])
  );

  end else begin

  assign fir_ready[8] = 1'b1;
  assign m_axis_tvalid[8] = 1'b0;
  assign m_axis_tdata[2303:2048] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 9

  generate
  if (DISABLE_MASK[9] == 1'b0) begin

  axis_xcorr_tag_9 #()
  axis_xcorr_tag_9 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[9]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[9]),
    .m_axis_data_tready (m_axis_tready[9]),
    .m_axis_data_tdata (m_axis_tdata[2559:2304])
  );

  end else begin

  assign fir_ready[9] = 1'b1;
  assign m_axis_tvalid[9] = 1'b0;
  assign m_axis_tdata[2559:2304] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 10

  generate
  if (DISABLE_MASK[10] == 1'b0) begin

  axis_xcorr_tag_10 #()
  axis_xcorr_tag_10 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[10]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[10]),
    .m_axis_data_tready (m_axis_tready[10]),
    .m_axis_data_tdata (m_axis_tdata[2815:2560])
  );

  end else begin

  assign fir_ready[10] = 1'b1;
  assign m_axis_tvalid[10] = 1'b0;
  assign m_axis_tdata[2815:2560] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 11

  generate
  if (DISABLE_MASK[11] == 1'b0) begin

  axis_xcorr_tag_11 #()
  axis_xcorr_tag_11 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[11]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[11]),
    .m_axis_data_tready (m_axis_tready[11]),
    .m_axis_data_tdata (m_axis_tdata[3071:2816])
  );

  end else begin

  assign fir_ready[11] = 1'b1;
  assign m_axis_tvalid[11] = 1'b0;
  assign m_axis_tdata[3071:2816] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 12

  generate
  if (DISABLE_MASK[12] == 1'b0) begin

  axis_xcorr_tag_12 #()
  axis_xcorr_tag_12 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[12]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[12]),
    .m_axis_data_tready (m_axis_tready[12]),
    .m_axis_data_tdata (m_axis_tdata[3327:3072])
  );

  end else begin

  assign fir_ready[12] = 1'b1;
  assign m_axis_tvalid[12] = 1'b0;
  assign m_axis_tdata[3327:3072] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 13

  generate
  if (DISABLE_MASK[13] == 1'b0) begin

  axis_xcorr_tag_13 #()
  axis_xcorr_tag_13 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[13]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[13]),
    .m_axis_data_tready (m_axis_tready[13]),
    .m_axis_data_tdata (m_axis_tdata[3583:3328])
  );

  end else begin

  assign fir_ready[13] = 1'b1;
  assign m_axis_tvalid[13] = 1'b0;
  assign m_axis_tdata[3583:3328] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 14

  generate
  if (DISABLE_MASK[14] == 1'b0) begin

  axis_xcorr_tag_14 #()
  axis_xcorr_tag_14 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[14]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[14]),
    .m_axis_data_tready (m_axis_tready[14]),
    .m_axis_data_tdata (m_axis_tdata[3839:3584])
  );

  end else begin

  assign fir_ready[14] = 1'b1;
  assign m_axis_tvalid[14] = 1'b0;
  assign m_axis_tdata[3839:3584] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 15

  generate
  if (DISABLE_MASK[15] == 1'b0) begin

  axis_xcorr_tag_15 #()
  axis_xcorr_tag_15 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[15]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[15]),
    .m_axis_data_tready (m_axis_tready[15]),
    .m_axis_data_tdata (m_axis_tdata[4095:3840])
  );

  end else begin

  assign fir_ready[15] = 1'b1;
  assign m_axis_tvalid[15] = 1'b0;
  assign m_axis_tdata[4095:3840] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 16

  generate
  if (DISABLE_MASK[16] == 1'b0) begin

  axis_xcorr_tag_16 #()
  axis_xcorr_tag_16 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[16]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[16]),
    .m_axis_data_tready (m_axis_tready[16]),
    .m_axis_data_tdata (m_axis_tdata[4351:4096])
  );

  end else begin

  assign fir_ready[16] = 1'b1;
  assign m_axis_tvalid[16] = 1'b0;
  assign m_axis_tdata[4351:4096] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 17

  generate
  if (DISABLE_MASK[17] == 1'b0) begin

  axis_xcorr_tag_17 #()
  axis_xcorr_tag_17 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[17]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[17]),
    .m_axis_data_tready (m_axis_tready[17]),
    .m_axis_data_tdata (m_axis_tdata[4607:4352])
  );

  end else begin

  assign fir_ready[17] = 1'b1;
  assign m_axis_tvalid[17] = 1'b0;
  assign m_axis_tdata[4607:4352] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 18

  generate
  if (DISABLE_MASK[18] == 1'b0) begin

  axis_xcorr_tag_18 #()
  axis_xcorr_tag_18 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[18]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[18]),
    .m_axis_data_tready (m_axis_tready[18]),
    .m_axis_data_tdata (m_axis_tdata[4863:4608])
  );

  end else begin

  assign fir_ready[18] = 1'b1;
  assign m_axis_tvalid[18] = 1'b0;
  assign m_axis_tdata[4863:4608] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 19

  generate
  if (DISABLE_MASK[19] == 1'b0) begin

  axis_xcorr_tag_19 #()
  axis_xcorr_tag_19 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[19]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[19]),
    .m_axis_data_tready (m_axis_tready[19]),
    .m_axis_data_tdata (m_axis_tdata[5119:4864])
  );

  end else begin

  assign fir_ready[19] = 1'b1;
  assign m_axis_tvalid[19] = 1'b0;
  assign m_axis_tdata[5119:4864] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 20

  generate
  if (DISABLE_MASK[20] == 1'b0) begin

  axis_xcorr_tag_20 #()
  axis_xcorr_tag_20 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[20]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[20]),
    .m_axis_data_tready (m_axis_tready[20]),
    .m_axis_data_tdata (m_axis_tdata[5375:5120])
  );

  end else begin

  assign fir_ready[20] = 1'b1;
  assign m_axis_tvalid[20] = 1'b0;
  assign m_axis_tdata[5375:5120] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 21

  generate
  if (DISABLE_MASK[21] == 1'b0) begin

  axis_xcorr_tag_21 #()
  axis_xcorr_tag_21 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[21]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[21]),
    .m_axis_data_tready (m_axis_tready[21]),
    .m_axis_data_tdata (m_axis_tdata[5631:5376])
  );

  end else begin

  assign fir_ready[21] = 1'b1;
  assign m_axis_tvalid[21] = 1'b0;
  assign m_axis_tdata[5631:5376] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 22

  generate
  if (DISABLE_MASK[22] == 1'b0) begin

  axis_xcorr_tag_22 #()
  axis_xcorr_tag_22 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[22]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[22]),
    .m_axis_data_tready (m_axis_tready[22]),
    .m_axis_data_tdata (m_axis_tdata[5887:5632])
  );

  end else begin

  assign fir_ready[22] = 1'b1;
  assign m_axis_tvalid[22] = 1'b0;
  assign m_axis_tdata[5887:5632] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 23

  generate
  if (DISABLE_MASK[23] == 1'b0) begin

  axis_xcorr_tag_23 #()
  axis_xcorr_tag_23 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[23]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[23]),
    .m_axis_data_tready (m_axis_tready[23]),
    .m_axis_data_tdata (m_axis_tdata[6143:5888])
  );

  end else begin

  assign fir_ready[23] = 1'b1;
  assign m_axis_tvalid[23] = 1'b0;
  assign m_axis_tdata[6143:5888] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 24

  generate
  if (DISABLE_MASK[24] == 1'b0) begin

  axis_xcorr_tag_24 #()
  axis_xcorr_tag_24 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[24]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[24]),
    .m_axis_data_tready (m_axis_tready[24]),
    .m_axis_data_tdata (m_axis_tdata[6399:6144])
  );

  end else begin

  assign fir_ready[24] = 1'b1;
  assign m_axis_tvalid[24] = 1'b0;
  assign m_axis_tdata[6399:6144] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 25

  generate
  if (DISABLE_MASK[25] == 1'b0) begin

  axis_xcorr_tag_25 #()
  axis_xcorr_tag_25 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[25]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[25]),
    .m_axis_data_tready (m_axis_tready[25]),
    .m_axis_data_tdata (m_axis_tdata[6655:6400])
  );

  end else begin

  assign fir_ready[25] = 1'b1;
  assign m_axis_tvalid[25] = 1'b0;
  assign m_axis_tdata[6655:6400] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 26

  generate
  if (DISABLE_MASK[26] == 1'b0) begin

  axis_xcorr_tag_26 #()
  axis_xcorr_tag_26 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[26]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[26]),
    .m_axis_data_tready (m_axis_tready[26]),
    .m_axis_data_tdata (m_axis_tdata[6911:6656])
  );

  end else begin

  assign fir_ready[26] = 1'b1;
  assign m_axis_tvalid[26] = 1'b0;
  assign m_axis_tdata[6911:6656] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 27

  generate
  if (DISABLE_MASK[27] == 1'b0) begin

  axis_xcorr_tag_27 #()
  axis_xcorr_tag_27 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[27]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[27]),
    .m_axis_data_tready (m_axis_tready[27]),
    .m_axis_data_tdata (m_axis_tdata[7167:6912])
  );

  end else begin

  assign fir_ready[27] = 1'b1;
  assign m_axis_tvalid[27] = 1'b0;
  assign m_axis_tdata[7167:6912] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 28

  generate
  if (DISABLE_MASK[28] == 1'b0) begin

  axis_xcorr_tag_28 #()
  axis_xcorr_tag_28 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[28]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[28]),
    .m_axis_data_tready (m_axis_tready[28]),
    .m_axis_data_tdata (m_axis_tdata[7423:7168])
  );

  end else begin

  assign fir_ready[28] = 1'b1;
  assign m_axis_tvalid[28] = 1'b0;
  assign m_axis_tdata[7423:7168] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 29

  generate
  if (DISABLE_MASK[29] == 1'b0) begin

  axis_xcorr_tag_29 #()
  axis_xcorr_tag_29 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[29]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[29]),
    .m_axis_data_tready (m_axis_tready[29]),
    .m_axis_data_tdata (m_axis_tdata[7679:7424])
  );

  end else begin

  assign fir_ready[29] = 1'b1;
  assign m_axis_tvalid[29] = 1'b0;
  assign m_axis_tdata[7679:7424] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 30

  generate
  if (DISABLE_MASK[30] == 1'b0) begin

  axis_xcorr_tag_30 #()
  axis_xcorr_tag_30 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[30]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[30]),
    .m_axis_data_tready (m_axis_tready[30]),
    .m_axis_data_tdata (m_axis_tdata[7935:7680])
  );

  end else begin

  assign fir_ready[30] = 1'b1;
  assign m_axis_tvalid[30] = 1'b0;
  assign m_axis_tdata[7935:7680] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 31

  generate
  if (DISABLE_MASK[31] == 1'b0) begin

  axis_xcorr_tag_31 #()
  axis_xcorr_tag_31 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[31]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[31]),
    .m_axis_data_tready (m_axis_tready[31]),
    .m_axis_data_tdata (m_axis_tdata[8191:7936])
  );

  end else begin

  assign fir_ready[31] = 1'b1;
  assign m_axis_tvalid[31] = 1'b0;
  assign m_axis_tdata[8191:7936] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 32

  generate
  if (DISABLE_MASK[32] == 1'b0) begin

  axis_xcorr_tag_32 #()
  axis_xcorr_tag_32 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[32]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[32]),
    .m_axis_data_tready (m_axis_tready[32]),
    .m_axis_data_tdata (m_axis_tdata[8447:8192])
  );

  end else begin

  assign fir_ready[32] = 1'b1;
  assign m_axis_tvalid[32] = 1'b0;
  assign m_axis_tdata[8447:8192] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 33

  generate
  if (DISABLE_MASK[33] == 1'b0) begin

  axis_xcorr_tag_33 #()
  axis_xcorr_tag_33 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[33]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[33]),
    .m_axis_data_tready (m_axis_tready[33]),
    .m_axis_data_tdata (m_axis_tdata[8703:8448])
  );

  end else begin

  assign fir_ready[33] = 1'b1;
  assign m_axis_tvalid[33] = 1'b0;
  assign m_axis_tdata[8703:8448] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 34

  generate
  if (DISABLE_MASK[34] == 1'b0) begin

  axis_xcorr_tag_34 #()
  axis_xcorr_tag_34 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[34]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[34]),
    .m_axis_data_tready (m_axis_tready[34]),
    .m_axis_data_tdata (m_axis_tdata[8959:8704])
  );

  end else begin

  assign fir_ready[34] = 1'b1;
  assign m_axis_tvalid[34] = 1'b0;
  assign m_axis_tdata[8959:8704] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 35

  generate
  if (DISABLE_MASK[35] == 1'b0) begin

  axis_xcorr_tag_35 #()
  axis_xcorr_tag_35 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[35]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[35]),
    .m_axis_data_tready (m_axis_tready[35]),
    .m_axis_data_tdata (m_axis_tdata[9215:8960])
  );

  end else begin

  assign fir_ready[35] = 1'b1;
  assign m_axis_tvalid[35] = 1'b0;
  assign m_axis_tdata[9215:8960] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 36

  generate
  if (DISABLE_MASK[36] == 1'b0) begin

  axis_xcorr_tag_36 #()
  axis_xcorr_tag_36 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[36]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[36]),
    .m_axis_data_tready (m_axis_tready[36]),
    .m_axis_data_tdata (m_axis_tdata[9471:9216])
  );

  end else begin

  assign fir_ready[36] = 1'b1;
  assign m_axis_tvalid[36] = 1'b0;
  assign m_axis_tdata[9471:9216] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 37

  generate
  if (DISABLE_MASK[37] == 1'b0) begin

  axis_xcorr_tag_37 #()
  axis_xcorr_tag_37 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[37]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[37]),
    .m_axis_data_tready (m_axis_tready[37]),
    .m_axis_data_tdata (m_axis_tdata[9727:9472])
  );

  end else begin

  assign fir_ready[37] = 1'b1;
  assign m_axis_tvalid[37] = 1'b0;
  assign m_axis_tdata[9727:9472] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 38

  generate
  if (DISABLE_MASK[38] == 1'b0) begin

  axis_xcorr_tag_38 #()
  axis_xcorr_tag_38 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[38]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[38]),
    .m_axis_data_tready (m_axis_tready[38]),
    .m_axis_data_tdata (m_axis_tdata[9983:9728])
  );

  end else begin

  assign fir_ready[38] = 1'b1;
  assign m_axis_tvalid[38] = 1'b0;
  assign m_axis_tdata[9983:9728] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

  // tag 39

  generate
  if (DISABLE_MASK[39] == 1'b0) begin

  axis_xcorr_tag_39 #()
  axis_xcorr_tag_39 (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[39]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[39]),
    .m_axis_data_tready (m_axis_tready[39]),
    .m_axis_data_tdata (m_axis_tdata[10239:9984])
  );

  end else begin

  assign fir_ready[39] = 1'b1;
  assign m_axis_tvalid[39] = 1'b0;
  assign m_axis_tdata[10239:9984] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate

endmodule
