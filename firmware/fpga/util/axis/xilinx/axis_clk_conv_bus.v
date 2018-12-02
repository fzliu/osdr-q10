////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream clock conversion using bus handshake synchronizer.
//
// enable  :  N/A
// reset   :  active-high
// latency :  multiple
// output  :  unregistered
//
////////////////////////////////////////////////////////////////////////////////

module axis_clk_conv_bus #(

  // parameters

  parameter   DATA_WIDTH = 32,

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             m_axis_clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // memory interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata

);

  // internal registers

  reg               m_axis_tvalid_reg = 'b0;

  reg     [ WD:0]   cdc_src_in = 'b0;
  reg               cdc_src_send = 'b0;
  reg               cdc_dest_ack = 'b0;

  // internal signals

  wire              s_axis_frame;
  wire              m_axis_frame;

  wire              cdc_src_rcv;
  wire              cdc_dest_req;
  wire    [ WD:0]   cdc_dest_out;

  // slave interface

  assign s_axis_frame = s_axis_tvalid & s_axis_tready;

  always @(posedge s_axis_clk) begin
    if (rst) begin
      cdc_src_send <= 1'b0;
    end else if (s_axis_frame) begin
      cdc_src_send <= 1'b1;
    end else if (cdc_src_rcv) begin
      cdc_src_send <= 1'b0;
    end else begin
      cdc_src_send <= cdc_src_send;
    end
  end

  always @(posedge s_axis_clk) begin
    if (s_axis_frame) begin
      cdc_src_in <= s_axis_tdata;
    end else begin
      cdc_src_in <= cdc_src_in;
    end
  end

  assign s_axis_tready = ~(cdc_src_send | cdc_src_rcv);

  // bus handshake

  xpm_cdc_handshake #(
    .DEST_EXT_HSK (1),
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .SIM_ASSERT_CHK (1),
    .SRC_SYNC_FF (2),
    .WIDTH (DATA_WIDTH + 1)
  ) xpm_cdc_handshake (
    .src_clk (s_axis_clk),
    .src_in (cdc_src_in),
    .src_send (cdc_src_send),
    .src_rcv (cdc_src_rcv),
    .dest_clk (m_axis_clk),
    .dest_req (cdc_dest_req),
    .dest_ack (cdc_dest_ack),
    .dest_out (cdc_dest_out)
  );

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  always @(posedge m_axis_clk) begin
    if (rst | m_axis_frame) begin
      m_axis_tvalid_reg <= 1'b0;
    end else if (cdc_dest_req & ~cdc_dest_ack) begin
      m_axis_tvalid_reg <= 1'b1;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
    end
  end

  always @(posedge m_axis_clk) begin
    if (m_axis_frame) begin
      cdc_dest_ack <= 1'b1;
    end else if (~cdc_dest_req) begin
      cdc_dest_ack <= 1'b0;
    end else begin
      cdc_dest_ack <= cdc_dest_ack;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = cdc_dest_out;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
