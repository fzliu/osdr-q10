`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:  奥新智能
// Engineer: 江凯都
//
// Description: AD9361 top-level module testbench.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////


module ad9361_top_tb;

reg             rx_clk_in;
reg     [11:0]  a_rx_data_p_pos;
reg     [11:0]  a_rx_data_p_neg;

reg             rx_frame_in;
wire    [11:0]  a_rx_data_p0;
wire    [11:0]  a_rx_data_p1;
wire    [11:0]  b_rx_data_p0;
wire    [11:0]  b_rx_data_p1;

wire            a_data_clk;
wire            valid_0;
wire    [11:0]  data_i0;
wire    [11:0]  data_q0;
wire            valid_1;
wire    [11:0]  data_i1;
wire    [11:0]  data_q1;
wire            b_data_clk;
wire            valid_2;
wire    [11:0]  data_i2;
wire    [11:0]  data_q2;
wire            valid_3;
wire    [11:0]  data_i3;
wire    [11:0]  data_q3;


//No used

wire clk;
wire rst;
wire a_spi_do;
wire b_spi_do;
wire spi_sck;
wire spi_mosi;
wire spi_cs_a;
wire spi_cs_b;
wire sync_in;

wire sync_out;
wire a_resetb;
wire a_enable;
wire a_txnrx;
wire b_resetb;
wire b_enable;
wire b_txnrx;
wire a_spi_sck;
wire a_spi_di;
wire a_spi_cs;
wire b_spi_sck;
wire b_spi_di;
wire b_spi_cs;
wire spi_miso;

// used

//assign rx_frame_in = (rx_clk_in) ? 1 : 0;
assign a_rx_data_p0 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg);
assign a_rx_data_p1 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 1000;
assign b_rx_data_p0 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 2000;
assign b_rx_data_p1 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 3000;

// not used

assign clk = 0;
assign rst = 0;
assign a_spi_do = 0;
assign b_spi_do = 0;
assign spi_sck = 0;
assign spi_mosi = 0;
assign spi_cs_a = 0;
assign spi_cs_b = 0;
assign sync_in = 0;

assign sync_out = 0;
assign a_resetb = 0;
assign a_enable = 0;
assign a_txnrx = 0;
assign b_resetb = 0;
assign b_enable = 0;
assign b_txnrx = 0;
assign a_spi_sck = 0;
assign a_spi_di = 0;
assign a_spi_cs = 0;
assign b_spi_sck = 0;
assign b_spi_di = 0;
assign b_spi_cs = 0;
assign spi_miso = 0;

initial begin
  rx_clk_in = 0;
  #1 rx_frame_in = 1;
  a_rx_data_p_pos = 12'b010101010101;
  a_rx_data_p_neg = 12'b010101010101;
end
always #5 rx_clk_in = ~rx_clk_in;
always begin
  #1 rx_frame_in = ~rx_frame_in;
  #4 rx_frame_in = rx_frame_in;
end
always @ (posedge rx_frame_in) begin
  a_rx_data_p_pos <= a_rx_data_p_neg + 22;
end

always @ (negedge rx_frame_in) begin
  a_rx_data_p_neg <= a_rx_data_p_pos + 22;
end


ad9361_top #(
  .DC_FILTER_ENABLE (1),
  .DC_FILTER_LENGTH (1000),
  .IQ_CORRECTION_ENABLE (1)
) ad9361_top_test (

  // inputs

  .clk (clk),
  .rst (rst),

  .a_rx_clk_in (rx_clk_in),
  .a_rx_frame_in (rx_frame_in),
  .a_rx_data_p0 (a_rx_data_p0),
  .a_rx_data_p1 (a_rx_data_p1),
  .b_rx_clk_in (rx_clk_in),
  .b_rx_frame_in (rx_frame_in),
  .b_rx_data_p0 (b_rx_data_p0),
  .b_rx_data_p1 (b_rx_data_p1),

  .a_spi_do (a_spi_do),
  .b_spi_do (b_spi_do),
  .spi_sck (spi_sck),
  .spi_mosi (spi_mosi),
  .spi_cs_a (spi_cs_a),
  .spi_cs_b (spi_cs_b),
  .sync_in (sync_in),

   // outputs

  .sync_out (sync_out),
  .a_resetb (a_resetb),
  .a_enable (a_enable),
  .a_txnrx (a_txnrx),
  .b_resetb (b_resetb),
  .b_enable (b_enable),
  .b_txnrx (b_txnrx),
  .a_spi_sck (a_spi_sck),
  .a_spi_di (a_spi_di),
  .a_spi_cs (a_spi_cs),
  .b_spi_sck (b_spi_sck),
  .b_spi_di (b_spi_di),
  .b_spi_cs (b_spi_cs),
  .spi_miso (spi_miso),

  .a_data_clk (a_data_clk),
  .valid_0 (valid_0),
  .data_i0 (data_i0),
  .data_q0 (data_q0),
  .valid_1 (valid_1),
  .data_i1 (data_i1),
  .data_q1 (data_q1),
  .b_data_clk (b_data_clk),
  .valid_2 (valid_2),
  .data_i2 (data_i2),
  .data_q2 (data_q2),
  .valid_3 (valid_3),
  .data_i3 (data_i3),
  .data_q3 (data_q3)
);

endmodule
