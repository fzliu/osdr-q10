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

  parameter   NUM_COMPUTE = 1;    //1
  parameter   NUM_TAGS = 2;       //2
  parameter   CORR_OFFSET = 18;   //19
  parameter   CABS_DELAY = 9;

  // signals

  reg               clk = 'b0;

  reg               rx_clk_in = 'b0;
  reg               rx_frame_in = 'b0;
  reg     [ 11:0]   a_rx_data_p0 = 'b0;
  reg     [ 11:0]   a_rx_data_p1 = 'b0;
  reg     [ 11:0]   b_rx_data_p0 = 'b0;
  reg     [ 11:0]   b_rx_data_p1 = 'b0;

  reg               ebi_nrde = 'b1;

  wire              ebi_ready;
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
    #1;     // align data with rx_frame signal
    #2500;  // clocks come up at about 2350

    for (i = 0; i < 1050; i = i + 1) begin
      #10;
      a_rx_data_p0 <= mema0[i];
      a_rx_data_p1 <= mema1[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p1 <= memb1[i];
    end
    a_rx_data_p0 <= 'b0;
    a_rx_data_p1 <= 'b0;
    b_rx_data_p0 <= 'b0;
    b_rx_data_p1 <= 'b0;
    #12500; //#2500;

    for (i = 0; i < 1050; i = i + 1) begin
      #10;
      a_rx_data_p0 <= mema0[i];
      a_rx_data_p1 <= mema1[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p1 <= memb1[i];
    end
    a_rx_data_p0 <= 'b0;
    a_rx_data_p1 <= 'b0;
    b_rx_data_p0 <= 'b0;
    b_rx_data_p1 <= 'b0;
  end

  /*
  integer j;
  initial begin
    #28000;
    for (j = 0; j < 264; j = j + 1) begin
      #20 ebi_nrde = 1'b0;
      #20 ebi_nrde = 1'b1;
    end
  end
  */

  // anchor_top

  anchor_top #(
    .NUM_COMPUTE (NUM_COMPUTE),
    .NUM_TAGS (NUM_TAGS),
    .CORR_OFFSET (CORR_OFFSET),
    .CABS_DELAY (CABS_DELAY)
  ) anchor_top (
    .clk (clk),
    .ena (1'b1),
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
    .ebi_ready (ebi_ready),
    .led_out ()
  ); 

  // add clocks by default

  wire              d_clk = anchor_top.d_clk;
  wire              m_clk = anchor_top.m_clk;
  wire              c_clk = anchor_top.c_clk;

endmodule
