`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:  奥新智能
// Engineer: 江凯都
//
// Description: AD9361 AXI-stream serializer testbench.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////


module ad9361_dual_ser_tb;

  reg              data_clk;
  reg     [ 11:0]  data;
  reg              valid_0;
  reg              valid_1;
  reg              valid_2;
  reg              valid_3;
  reg              m_axis_clk;
  reg              m_axis_data_tready;

  wire    [ 11:0]  data_i0;
  wire    [ 11:0]  data_q0;
  wire    [ 11:0]  data_i1;
  wire    [ 11:0]  data_q1;
  wire    [ 11:0]  data_i2;
  wire    [ 11:0]  data_q2;
  wire    [ 11:0]  data_i3;
  wire    [ 11:0]  data_q3;
  wire    [127:0]  m_axis_data_tdata;
  wire             m_axis_data_tlast;
  wire             m_axis_data_tvalid;




  assign data_i0 = data;
  assign data_q0 = data + 12'd1000;
  assign data_i1 = data + 12'd2000;
  assign data_q1 = data + 12'd3000;
  assign data_i2 = data + 12'd4000;
  assign data_q2 = data + 12'd5000;
  assign data_i3 = data + 12'd6000;
  assign data_q3 = data + 12'd7000;

  initial begin
    m_axis_data_tready = 0;
    data_clk = 0;
    m_axis_clk = 1;
    data = 12'b010101010101;
    valid_0 = 0;
    valid_1 = 0;
    valid_2 = 0;
    valid_3 = 0;
    #10 valid_0 = 1;
    #10 valid_1 = 1;
    #10 valid_2 = 1;
    #10 valid_3 = 1;
    #60 m_axis_data_tready = 1;
    #5 m_axis_data_tready = 0;
    #40 m_axis_data_tready = 1;
  end



  always #10 data_clk <= ~data_clk;
  always begin
    #0.5 m_axis_clk <= ~m_axis_clk;
    #0.5 m_axis_clk <= m_axis_clk;
  end


  always @(posedge data_clk) begin
    data <= data + 12'd22;
  end


  ad9361_dual_ser #(
    .USE_AXIS_TLAST (1),
    .AXIS_BURST_LENGTH (10)
  ) ad9361_dual_ser_inst (
    .data_clk (data_clk),
    .valid_0 (valid_0),
    .data_i0 (data_i0),
    .data_q0 (data_q0),
    .valid_1 (valid_1),
    .data_i1 (data_i1),
    .data_q1 (data_q1),
    .valid_2 (valid_2),
    .data_i2 (data_i2),
    .data_q2 (data_q2),
    .valid_3 (valid_3),
    .data_i3 (data_i3),
    .data_q3 (data_q3),
    .m_axis_clk (m_axis_clk),
    .m_axis_data_tready (m_axis_data_tready),
    .m_axis_data_tvalid (m_axis_data_tvalid),
    .m_axis_data_tlast (m_axis_data_tlast),
    .m_axis_data_tdata (m_axis_data_tdata)
  );

endmodule
