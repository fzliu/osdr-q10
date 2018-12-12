`timescale 1ns / 100ps
////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer:
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top_tb;

  // parameters

  parameter   NUM_TAGS = 5;
  parameter   SAMPS_WIDTH = 128;
  parameter   DATA_WIDTH = 256;

  localparam  INPUT_WIDTH = NUM_TAGS * SAMPS_WIDTH;
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH;

  localparam  NT = NUM_TAGS - 1;
  localparam  WS = SAMPS_WIDTH - 1;
  localparam  WD = DATA_WIDTH - 1;
  localparam  WI = INPUT_WIDTH - 1;
  localparam  WP = PACKED_WIDTH - 1;

  // signals

  reg               clk = 'b0;

  reg               rx_clk_in = 'b0;
  reg               rx_frame_in = 'b0;
  reg     [ 11:0]   a_rx_data_p0 = 'b0;
  reg     [ 11:0]   a_rx_data_p1 = 'b0;
  reg     [ 11:0]   b_rx_data_p0 = 'b0;
  reg     [ 11:0]   b_rx_data_p1 = 'b0;

  reg               ebi_nrde = 'b0;

  wire              ready;
  wire    [ 15:0]   ebi_data;

  reg     [ 11:0]   mema0 [0:1051];
  reg     [ 11:0]   mema1 [0:1051];
  reg     [ 11:0]   memb1 [0:1051];
  reg     [ 11:0]   memb0 [0:1051];

  // input "real" signal

  localparam dir_mem = "../../../../anchor_fpga.srcs/sim_1/new/";
  initial $readmemb({dir_mem, "mem_a0.mem"}, mema0);
  initial $readmemb({dir_mem, "mem_a1.mem"}, mema1);
  initial $readmemb({dir_mem, "mem_b0.mem"}, memb0);
  initial $readmemb({dir_mem, "mem_b1.mem"}, memb1);

  // set clocks

  initial forever #20 clk = ~clk;
  initial forever #10 rx_clk_in <= ~rx_clk_in;

  initial #1 forever #10 rx_frame_in = ~rx_frame_in;

  // set input data

  integer i;
  initial begin
    #2500;  // clocks come up at about 2350
    for (i = 0; i < 1052; i = i + 1) begin
      a_rx_data_p0 <= mema0[i];
      a_rx_data_p1 <= mema1[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p1 <= memb1[i];
      #20;
    end

    a_rx_data_p0 <= 'b0;
    a_rx_data_p1 <= 'b0;
    b_rx_data_p0 <= 'b0;
    b_rx_data_p1 <= 'b0;

    #2500;
    for (i = 0; i < 1052; i = i + 1) begin
      a_rx_data_p0 <= mema0[i];
      a_rx_data_p1 <= mema1[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p1 <= memb1[i];
      #20;
    end
  end

  // anchor_top

  anchor_top anchor_top (
    .clk (clk),
    .a_rx_clk_in (rx_clk_in),
    .a_rx_frame_in (rx_frame_in),
    .a_rx_data_p0 (a_rx_data_p0),
    .a_rx_data_p1 (a_rx_data_p1),
    .b_rx_clk_in (rx_clk_in),
    .b_rx_frame_in (rx_frame_in),
    .b_rx_data_p0 (b_rx_data_p0),
    .b_rx_data_p1 (b_rx_data_p1),
    .sync_out (),
    .reset_a (1'b0),
    .a_resetb (),
    .a_enable (),
    .a_txnrx (),
    .reset_b (1'b0),
    .b_resetb (),
    .b_enable (),
    .b_txnrx (),
    .a_spi_sck (),
    .a_spi_di (),
    .a_spi_do (1'bz),
    .a_spi_cs (),
    .b_spi_sck (),
    .b_spi_di (),
    .b_spi_do (1'bz),
    .b_spi_cs (),
    .spi_sck (1'bz),
    .spi_mosi (1'bz),
    .spi_miso (),
    .spi_cs_a (1'bz),
    .spi_cs_b (1'bz),
    .sync_in (1'bz),
    .ebi_nrde (ebi_nrde),
    .ebi_data (ebi_data),
    .ready (ready)
  );

  // add signals to wave

  wire              d_clk = anchor_top.d_clk;
  wire              m_clk = anchor_top.m_clk;
  wire              c_clk = anchor_top.c_clk;

  wire              ad9361_axis_tvalid = anchor_top.ad9361_axis_tvalid;
  wire              ad9361_axis_tready = anchor_top.ad9361_axis_tready;
  wire    [ WS:0]   ad9361_axis_tdata = anchor_top.ad9361_axis_tdata;
  wire              fifo_axis_tvalid = anchor_top.fifo_axis_tvalid;
  wire              fifo_axis_tready = anchor_top.fifo_axis_tready;
  wire    [ WS:0]   fifo_axis_tdata = anchor_top.fifo_axis_tdata;
  wire    [ NT:0]   distrib_axis_tvalid = anchor_top.distrib_axis_tvalid;
  wire    [ NT:0]   distrib_axis_tready = anchor_top.distrib_axis_tready;
  wire    [ WI:0]   distrib_axis_tdata = anchor_top.distrib_axis_tdata;
  wire    [ NT:0]   corr_axis_tvalid = anchor_top.corr_axis_tvalid;
  wire    [ NT:0]   corr_axis_tready = anchor_top.corr_axis_tready;
  wire    [ WP:0]   corr_axis_tdata = anchor_top.corr_axis_tdata;
  wire    [ NT:0]   cabs_axis_tvalid = anchor_top.cabs_axis_tvalid;
  wire    [ NT:0]   cabs_axis_tready = anchor_top.cabs_axis_tready;
  wire    [ WP:0]   cabs_axis_tdata = anchor_top.cabs_axis_tdata;
  wire    [ WP:0]   cabs_axis_tdata_abs = anchor_top.cabs_axis_tdata_abs;
  wire    [ NT:0]   peak_axis_tvalid = anchor_top.peak_axis_tvalid;
  wire    [ NT:0]   peak_axis_tready = anchor_top.peak_axis_tready;
  wire    [ WP:0]   peak_axis_tdata = anchor_top.peak_axis_tdata;
  wire    [ NT:0]   peak_axis_tlast = anchor_top.peak_axis_tlast;
  wire              fanin_axis_tvalid = anchor_top.fanin_axis_tvalid;
  wire              fanin_axis_tready = anchor_top.fanin_axis_tready;
  wire    [ WD:0]   fanin_axis_tdata = anchor_top.fanin_axis_tdata;
  wire    [ NT:0]   fanin_axis_tuser = anchor_top.fanin_axis_tuser;

endmodule
