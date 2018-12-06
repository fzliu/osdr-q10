`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/10 15:04:25
// Design Name: 
// Module Name: mcu_to_fpga_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mcu_to_fpga_tb;
reg             clk;
reg             data_clk;
reg             reset;
reg             ren;
reg     [16:0]  read_addr;
//reg             read_start;
reg     [15:0]  din;

reg             rx_clk_in;
reg     [11:0]  a_rx_data_p_pos;
reg     [11:0]  a_rx_data_p_neg;

reg     [11:0]  _a_rx_data_p0;
reg     [11:0]  _a_rx_data_p1;
reg     [11:0]  _b_rx_data_p0;
reg     [11:0]  _b_rx_data_p1;

reg     [11:0]  mema0[0:1051];
reg     [11:0]  mema1[0:1051];
reg     [11:0]  memb0[0:1051];
reg     [11:0]  memb1[0:1051];

reg             rx_frame_in;

wire    [11:0]  a_rx_data_p0;
wire    [11:0]  a_rx_data_p1;
wire    [11:0]  b_rx_data_p0;
wire    [11:0]  b_rx_data_p1;

wire            done;
wire    [15:0]  data_tomcu;
wire    [ 2:0]  cs;

wire            a_spi_sck;
wire            a_spi_di;
wire            a_spi_do;
wire            a_spi_cs;

// physical interface (spi_b)

wire            b_spi_sck;
wire            b_spi_di;
wire            b_spi_do;
wire            b_spi_cs;

// microprocessor interface (spi)

wire           spi_sck;
wire           spi_mosi;
wire           spi_miso;
wire           spi_cs_a;
wire           spi_cs_b;

wire           a_reseta;
wire           b_resetb;
wire           sync_in;

assign a_spi_do = 1;
assign b_spi_do = 1;
assign spi_sck = 1;
assign spi_mosi = 1;
assign spi_cs_a = 1;
assign spi_cs_b = 1;
assign cs = 2;

//assign a_rx_data_p0 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg);
//assign a_rx_data_p1 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 100;
//assign b_rx_data_p0 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 200;
//assign b_rx_data_p1 = ((rx_frame_in) ? a_rx_data_p_pos : a_rx_data_p_neg) + 300;

assign a_rx_data_p0 = _a_rx_data_p0;
assign a_rx_data_p1 = _a_rx_data_p1;
assign b_rx_data_p0 = _b_rx_data_p0;
assign b_rx_data_p1 = _b_rx_data_p1;

//parameter _dina = 16'b0;
//parameter _addr = 708604;

integer i;

initial $readmemh("C:/mem_a0.txt",mema0);
initial $readmemh("C:/mem_a1.txt",mema1);
initial $readmemh("C:/mem_b0.txt",memb0);
initial $readmemh("C:/mem_b1.txt",memb1);

initial begin
  reset = 0;
  clk = 0;
  data_clk = 0;
  ren = 1;
  din = 0;
  //read_start = 1;
  #10000 reset = ~reset;
  #40 reset = ~reset;
  #400 reset = ~reset;
  #40 reset = ~reset;
  #243 reset = ~reset;
  #40 reset = ~reset;
  
  begin
    for(i=0;i<1052;i=i+1) begin
      #20
      _a_rx_data_p0 <= mema0[i];
      _a_rx_data_p1 <= mema1[i];
      _b_rx_data_p0 <= memb0[i];
      _b_rx_data_p1 <= memb1[i];
    end
  end
  
end
  
initial begin
  rx_clk_in = 0; 
  #1 rx_frame_in = 1;
  a_rx_data_p_pos = 12'b0;
  a_rx_data_p_neg = 12'b0;
end
always #10 rx_clk_in = ~rx_clk_in;
always #20 clk = ~clk;
always begin
  #1 rx_frame_in = ~rx_frame_in;
  #9 rx_frame_in = rx_frame_in;
end
always @ (posedge rx_frame_in) begin
  if (a_rx_data_p_pos <= 100) begin
    a_rx_data_p_pos <= 1;
  end else begin
    a_rx_data_p_pos <= 0;
  end
end

always @ (negedge rx_frame_in) begin
  if (a_rx_data_p_neg <= 100) begin
    a_rx_data_p_neg <= 0;
  end else begin
    a_rx_data_p_neg <= 0;
  end
end

/*
always @ (posedge clk) begin
  if (reset) begin
    read_start <= 1;
  end else if (done) begin
    read_start <= 0;
  end else if (read_start) begin
    read_start <= read_start;
  end else begin
    read_start <= read_start;
  end
end
always @ (posedge clk) begin
  if (reset) begin
    read_addr <= read_addr;
  end else if (done) begin
    read_addr <= 0;
  end else if (read_addr > 93182) begin
    #60 read_addr <= 17'b0;
  end else if (read_addr <= 93182 && ~read_start) begin
    #0 read_addr <= read_addr + 1;
    #60 read_addr <= read_addr;
  end else begin
    read_addr <= read_addr;
  end
end
*/

always @ (posedge clk) begin
  if (reset) begin
    ren <= 1;
  end else begin
    #0 ren <= 1;
    #10 ren <= 0;
    #40 ren <= 1;
    #10 ren <= ren;
  end
end

/*
mcu_to_fpga mcu_to_fpgaT(
  .read_addr(read_addr),
  .clk(clk),
  .reset(reset),
  .ren(ren),
  .data_tomcu(data_tomcu),
  .done(done),
  // core interface

  .ad9361_clk(rx_clk_in),

  // physical interface (receive_a)

  .a_rx_clk_in(1),
  .a_rx_frame_in(rx_frame_in),
  .a_rx_data_p0(a_rx_data_p0),
  .a_rx_data_p1(a_rx_data_p1),

  // physical interface (receive_b)

  .b_rx_clk_in(1),
  .b_rx_frame_in(rx_frame_in),
  .b_rx_data_p0(b_rx_data_p0),
  .b_rx_data_p1(b_rx_data_p1),
  .cs(cs),
  .a_spi_sck(a_spi_sck),
  .a_spi_di(a_spi_di),
  .a_spi_do(a_spi_do),
  .a_spi_cs(a_spi_cs),

  .b_spi_sck(b_spi_sck),
  .b_spi_di(b_spi_di),
  .b_spi_do(b_spi_do),
  .b_spi_cs(b_spi_cs),

  .spi_sck(spi_sck),
  .spi_mosi(spi_mosi),
  .spi_miso(spi_miso),
  .spi_cs_a(spi_cs_a),
  .spi_cs_b(spi_cs_b),
  
  .a_reset(reset),
  .b_reset(reset),
  .sync_in_m(reset),
  .a_reseta(a_reseta),
  .b_resetb(b_resetb),
  .sync_in(sync_in),
);
*/

anchor_top anchor_top(

  // master interface

  .clk(clk),

  // physical interface (receive_a)

  .a_rx_clk_in(rx_clk_in),
  .a_rx_frame_in(rx_frame_in),
  .a_rx_data_p0(a_rx_data_p0),
  .a_rx_data_p1(a_rx_data_p1),

  // physical interface (receive_b)

  .b_rx_clk_in(rx_clk_in),
  .b_rx_frame_in(rx_frame_in),
  .b_rx_data_p0(b_rx_data_p0),
  .b_rx_data_p1(b_rx_data_p1),

  // physical interface (control)

  .sync_out(sync_in),
  .reset_a(reset),
  .a_resetb(a_reseta),
  .a_enable(),
  .a_txnrx(),
  .reset_b(reset),
  .b_resetb(b_resetb),
  .b_enable(),
  .b_txnrx(),

  // physical interface (spi_a)

  .a_spi_sck(a_spi_sck),
  .a_spi_di(a_spi_di),
  .a_spi_do(a_spi_do),
  .a_spi_cs(a_spi_cs),

  // physical interface (spi_b)

  .b_spi_sck(b_spi_sck),
  .b_spi_di(b_spi_di),
  .b_spi_do(b_spi_do),
  .b_spi_cs(b_spi_cs),

  // microprocessor interface (spi)

  .spi_sck(spi_sck),
  .spi_mosi(spi_mosi),
  .spi_miso(spi_miso),
  .spi_cs_a(spi_cs_a),
  .spi_cs_b(spi_cs_b),

  // microprocessor interface (control)

  .sync_in(reset),

  // microprocessor interface (comms)

  .ebi_nrde(ren),
  .ebi_data(data_tomcu),
  .ready(done)

);
endmodule
