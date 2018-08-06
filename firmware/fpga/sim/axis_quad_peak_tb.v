`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:  奥新智能
// Engineer: 洪颖
//
// Description: AXI-stream quad-channel peak detector testbench.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module axis_quad_peak_tb;

  reg               clk;
  reg               rst;

  reg               s_axis_tvalid;
  reg     [ 31:0]   data_a[0:1280];
  reg     [ 31:0]   data_b[0:1280];
  reg               s_axis_tlast;

  wire    [255:0]   s_axis_tdata;
  wire              s_axis_tready;
  wire              m_axis_tvalid;
  reg               m_axis_tready;
  wire    [255:0]   m_axis_tdata;
  wire              m_axis_tlast;
  reg     [  8:0]   count;

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
    end else begin
      count <= count+1;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      localparam I = i * 64;
      assign s_axis_tdata[I+31:I] = data_a[4*count+i];
      assign s_axis_tdata[I+63:I+32] = data_b[4*count+i];
    end
  endgenerate

  axis_quad_peak
  axis_quad_peak_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tlast(m_axis_tlast)
  );

  always #10 clk <= ~clk;

  initial begin
    clk = 0;
    rst = 0;
    #10 rst = 1;
    #100 rst = 0;
  end

  initial begin
    $readmemb("D:/verilog_ex/ex_17/mem_a_16.txt", data_a);
    $readmemb("D:/verilog_ex/ex_17/mem_b_16.txt", data_b);
  end

  initial begin
    s_axis_tvalid = 0;
    s_axis_tlast  = 0;
    m_axis_tready = 0;
    #50 s_axis_tvalid = 1;
    #50 m_axis_tready = 1;
    #50 m_axis_tready = 0;
    #50 m_axis_tready = 1;
  end

endmodule
