`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/08 13:43:48
// Design Name: 
// Module Name: osdr_q10_tb
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

module osdr_q10_tb(
);

reg ref_clk;
reg usb_clk;
reg ebi_clk;
reg             data_clk_p;
wire             data_clk_n;
reg             frame_p;
wire             frame_n;
reg   [  5:0]   data_p;
wire   [  5:0]   data_n;

wire [1:0] usb_be;
reg nwe;
reg een;
wire [15:0] d_e;
reg  [15:0] din_e;
reg  [14:0] addr_e;
assign d_e = (!nwe)? din_e:'dz;

reg usb_rxf;
reg usb_txe;
wire usb_rd;
wire usb_wr;
wire usb_oe;
wire [15:0] d_usb;
reg  [15:0] din_usb;

wire a_fb_clk_p;
wire a_fb_clk_n;
wire a_tx_frame_p;
wire a_tx_frame_n;
wire [5:0] a_tx_data_p;
wire [5:0] a_tx_data_n;
wire b_fb_clk_p;
wire b_fb_clk_n;
wire b_tx_frame_p;
wire b_tx_frame_n;
wire [5:0] b_tx_data_p;
wire [5:0] b_tx_data_n;

initial
begin
ref_clk = 0;
usb_clk = 0;
ebi_clk = 0;
data_clk_p = 0;
data_p = 0;
frame_p = 1;
nwe = 1;
een = 1;
addr_e = 0;
din_e = 0;
din_usb = 'h8181;
usb_rxf = 1;
usb_txe = 1;
#50000
een = 1;
#50000
usb_txe = 0;
#50000
usb_txe = 1;
usb_rxf = 0;
#20000
usb_rxf = 1;
usb_txe = 0;
#10000
usb_rxf = 0;
usb_txe = 1;
din_usb = 'h4f00;
#10000
nwe = 0;
addr_e = 'h7f05;
din_e = 'h0000;
#20
nwe = 1;
addr_e = 'h0000;
din_e = 'h0000;
#300000
nwe = 0;
addr_e = 'h7fe2;
din_e = 'h5104;
#20
nwe = 1;
addr_e = 'h0000;
din_e = 'h0000;
#100000
nwe = 0;
addr_e = 'h7f05;
din_e = 'h0000;
#20
nwe = 1;
addr_e = 'h0000;
din_e = 'h0000;

#1000
een = 0;
addr_e = 'h7fe2;
end
always #(500/25) ref_clk = ~ref_clk;
always #(500/100) ebi_clk = ~ebi_clk;
always #(500/66) usb_clk = ~usb_clk;
always #(500/160) data_clk_p = ~data_clk_p;
always #(500/40) frame_p = ~frame_p;
assign data_clk_n = ~data_clk_p;
assign data_n = ~data_p;
assign frame_n = ~frame_p;
always #(500/160) data_p = data_p + 1;
//always #(500/40) din_usb = din_usb + 1;
always #(500/40*60) din_usb = ~din_usb;
assign adbus_oe = usb_rxf || usb_rd;
assign d_usb = (adbus_oe)?'dz:din_usb;
assign usb_be = (adbus_oe)?'dz:2'b11;
  
    osdr_q10_top #(
    )osdr_q10_top (
    
      // oscillator clock
    
      .ref_clk(ref_clk),
    
      // physical interface (chip A)
    
      .a_fb_clk_p(a_fb_clk_p),
      .a_fb_clk_n(a_fb_clk_n),
      .a_tx_frame_p(a_tx_frame_p),
      .a_tx_frame_n(a_tx_frame_n),
      .a_tx_data_p(a_tx_data_p),
      .a_tx_data_n(a_tx_data_n),
    
      .a_data_clk_p(data_clk_p),
      .a_data_clk_n(data_clk_n),
      .a_rx_frame_p(frame_p),
      .a_rx_frame_n(frame_n),
      .a_rx_data_p(data_p),
      .a_rx_data_n(data_n),
    
      // physical interface (chip B)
    
      .b_fb_clk_p(b_fb_clk_p),
      .b_fb_clk_n(b_fb_clk_n),
      .b_tx_frame_p(b_tx_frame_p),
      .b_tx_frame_n(b_tx_frame_n),
      .b_tx_data_p(b_tx_data_p),
      .b_tx_data_n(b_tx_data_n),
    
      .b_data_clk_p(data_clk_p),
      .b_data_clk_n(data_clk_n),
      .b_rx_frame_p(frame_p),
      .b_rx_frame_n(frame_n),
      .b_rx_data_p(data_p),
      .b_rx_data_n(data_n),

      // microprocessor interface (comms)
    
      .ebi_addr(addr_e),
      .ebi_clk(ebi_clk),
      .ebi_nrde(een),
      .ebi_nwre(nwe),
      .ebi_data(d_e),
     // .ebi_ready(),
    
      // USB 3.0 FIFO interface
    
      .usb_clk(usb_clk),
      .usb_adbus(d_usb),
      .usb_rxf_n(usb_rxf),
      .usb_txe_n(usb_txe),
      .usb_rd_n(usb_rd),
      .usb_wr_n(usb_wr),
      .usb_oe_n(usb_oe),
      .usb_be(usb_be),
      // LED interface
    
      .led_out()
    );
endmodule



/*module osdr_q10_tb(
);

reg ref_clk;
reg usb_clk;
reg ebi_clk;
reg             data_clk_p;
wire             data_clk_n;
reg             frame_p;
wire             frame_n;
reg   [  5:0]   data_p;
wire   [  5:0]   data_n;

wire [1:0] usb_be;
reg nwe;
reg een;
wire [15:0] d_e;
reg  [15:0] din_e;
reg  [14:0] addr_e;
assign d_e = (!nwe)? din_e:'dz;

reg usb_rxf;
reg usb_txe;
wire usb_rd;
wire usb_wr;
wire usb_oe;
wire [15:0] d_usb;
reg  [15:0] din_usb;

wire a_fb_clk_p;
wire a_fb_clk_n;
wire a_tx_frame_p;
wire a_tx_frame_n;
wire [5:0] a_tx_data_p;
wire [5:0] a_tx_data_n;
wire b_fb_clk_p;
wire b_fb_clk_n;
wire b_tx_frame_p;
wire b_tx_frame_n;
wire [5:0] b_tx_data_p;
wire [5:0] b_tx_data_n;

initial
begin
ref_clk = 0;
usb_clk = 0;
ebi_clk = 0;
data_clk_p = 0;
data_p = 0;
frame_p = 1;
nwe = 1;
een = 1;
addr_e = 0;
din_e = 0;
din_usb = 'h8181;
usb_rxf = 0;
usb_txe = 1;
end
always #(500/25) ref_clk = ~ref_clk;
always #(500/100) ebi_clk = ~ebi_clk;
always #(500/66) usb_clk = ~usb_clk;
always #(500/160) data_clk_p = ~data_clk_p;
always #(500/40) frame_p = ~frame_p;
assign data_clk_n = ~data_clk_p;
assign data_n = ~data_p;
assign frame_n = ~frame_p;
always #(500/160) data_p = data_p + 1;
always #(500/40*60) din_usb = ~din_usb;
assign adbus_oe = usb_rxf || usb_rd;
assign d_usb = (adbus_oe)?'dz:din_usb;
assign usb_be = (adbus_oe)?'dz:2'b11;
  
    osdr_q10_top #(
    )osdr_q10_top (
    
      // oscillator clock
    
      .ref_clk(ref_clk),
    
      // physical interface (chip A)
    
      .a_fb_clk_p(a_fb_clk_p),
      .a_fb_clk_n(a_fb_clk_n),
      .a_tx_frame_p(a_tx_frame_p),
      .a_tx_frame_n(a_tx_frame_n),
      .a_tx_data_p(a_tx_data_p),
      .a_tx_data_n(a_tx_data_n),
    
      .a_data_clk_p(data_clk_p),
      .a_data_clk_n(data_clk_n),
      .a_rx_frame_p(frame_p),
      .a_rx_frame_n(frame_n),
      .a_rx_data_p(data_p),
      .a_rx_data_n(data_n),
    
      // physical interface (chip B)
    
      .b_fb_clk_p(b_fb_clk_p),
      .b_fb_clk_n(b_fb_clk_n),
      .b_tx_frame_p(b_tx_frame_p),
      .b_tx_frame_n(b_tx_frame_n),
      .b_tx_data_p(b_tx_data_p),
      .b_tx_data_n(b_tx_data_n),
    
      .b_data_clk_p(data_clk_p),
      .b_data_clk_n(data_clk_n),
      .b_rx_frame_p(frame_p),
      .b_rx_frame_n(frame_n),
      .b_rx_data_p(data_p),
      .b_rx_data_n(data_n),

      // microprocessor interface (comms)
    
      .ebi_addr(addr_e),
      .ebi_clk(ebi_clk),
      .ebi_nrde(een),
      .ebi_nwre(nwe),
      .ebi_data(d_e),
     // .ebi_ready(),
    
      // USB 3.0 FIFO interface
    
      .usb_clk(usb_clk),
      .usb_adbus(d_usb),
      .usb_rxf_n(usb_rxf),
      .usb_txe_n(usb_txe),
      .usb_rd_n(usb_rd),
      .usb_wr_n(usb_wr),
      .usb_oe_n(usb_oe),
      .usb_be(usb_be),
      // LED interface
    
      .led_out()
    );
endmodule
*/