`timescale 1ns / 1ns
////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer:
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

module anchor_top_tb;

  reg                 clk = 'b0;

  reg                 rx_clk_in = 'b0;
  reg                 rx_frame_in = 'b0;
  reg       [ 11:0]   a_rx_data_p0 = 'b0;
  reg       [ 11:0]   a_rx_data_p1 = 'b0;
  reg       [ 11:0]   b_rx_data_p0 = 'b0;
  reg       [ 11:0]   b_rx_data_p1 = 'b0;

  reg                 ebi_nrde = 'b0;

  wire                ready;
  wire      [ 15:0]   ebi_data;

  reg       [ 11:0]   mema0 [0:1051];
  reg       [ 11:0]   mema1 [0:1051];
  reg       [ 11:0]   memb1 [0:1051];
  reg       [ 11:0]   memb0 [0:1051];

  localparam dir_mem = "../../../../anchor_fpga.srcs/sim_1/new/";
  initial $readmemb({dir_mem, "mem_a0.mem"}, mema0);
  initial $readmemb({dir_mem, "mem_a1.mem"}, mema1);
  initial $readmemb({dir_mem, "mem_b0.mem"}, memb0);
  initial $readmemb({dir_mem, "mem_b1.mem"}, memb1);

  initial forever #20 clk = ~clk;
  initial forever #40 rx_clk_in <= ~rx_clk_in;

  initial #2 forever #40 rx_frame_in = ~rx_frame_in;

  integer i;
  initial begin
    #12000
    for (i = 0; i < 1052; i = i + 1) begin
      #20
      a_rx_data_p0 <= mema0[i];
      a_rx_data_p1 <= mema1[i];
      b_rx_data_p0 <= memb0[i];
      b_rx_data_p1 <= memb1[i];
    end
    #20
    a_rx_data_p0 <= 'b0;
    a_rx_data_p1 <= 'b0;
    b_rx_data_p0 <= 'b0;
    b_rx_data_p1 <= 'b0;
  end

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

  // add signals to waveform by default

  wire d_clk = anchor_top.d_clk;
  wire m_clk = anchor_top.m_clk;
  wire c_clk = anchor_top.c_clk;

endmodule
