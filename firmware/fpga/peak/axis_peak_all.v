////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Packs all peak detectors into a single module.
//
// enable  :  N/A
// reset   :  active-high
//
////////////////////////////////////////////////////////////////////////////////

module axis_peak_all #(

  // parameters

  parameter   NUM_TAGS = 20,
  parameter   BURST_LENGTH = 32,
  parameter   PEAK_THRESHOLD = 1024,
  parameter   CHANNEL_WIDTH = 64,

  // derived parameters

  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // core interface

  input             in_clk,
  input             clk,
  input             rst,

  // slave interface

  input   [ NT:0]   s_axis_tvalid,
  output  [ NT:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,
  input   [ WP:0]   s_axis_tdata_abs,
  input   [ NT:0]   s_axis_tlast,

  // master interface

  output  [ NT:0]   m_axis_tvalid,
  input   [ NT:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata,
  output  [ NT:0]   m_axis_tlast

);

  // internal signals

  wire    [ NT:0]   c_axis_tvalid;
  wire    [ NT:0]   c_axis_tready;
  wire    [ WP:0]   c_axis_tdata;
  wire    [ WP:0]   c_axis_tdata_abs;
  wire    [ NT:0]   c_axis_tlast;

  // all peak detectors

  generate
  genvar i;
  for (i = 0; i < NUM_TAGS; i = i + 1) begin : peak_gen
    localparam i0 = i * DATA_WIDTH;
    localparam i1 = i * DATA_WIDTH + WD;

    // clock domain conversion

    axis_clk_conv_bus #(
      .DATA_WIDTH (2 * DATA_WIDTH)
    ) axis_clk_conv_bus (
      .s_axis_clk (in_clk),
      .m_axis_clk (clk),
      .rst (rst),
      .s_axis_tvalid (s_axis_tvalid[i]),
      .s_axis_tready (s_axis_tready[i]),
      .s_axis_tdata ({s_axis_tdata[i1:i0], s_axis_tdata_abs[i1:i0]}),
      .s_axis_tlast (s_axis_tlast[i]),
      .m_axis_tvalid (c_axis_tvalid[i]),
      .m_axis_tready (c_axis_tready[i]),
      .m_axis_tdata ({c_axis_tdata[i1:i0], c_axis_tdata_abs[i1:i0]}),
      .m_axis_tlast (c_axis_tlast[i])
    );

    // peak detect & storage

    axis_peak_detn #(
      .BURST_LENGTH (BURST_LENGTH),
      .PEAK_THRESHOLD (PEAK_THRESHOLD),
      .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) axis_peak_detn (
      .clk (clk),
      .rst (rst),
      .s_axis_tvalid (c_axis_tvalid[i]),
      .s_axis_tready (c_axis_tready[i]),
      .s_axis_tdata (c_axis_tdata[i1:i0]),
      .s_axis_tdata_abs (c_axis_tdata_abs[i1:i0]),
      .s_axis_tlast (c_axis_tlast[i]),
      .m_axis_tvalid (m_axis_tvalid[i]),
      .m_axis_tready (m_axis_tready[i]),
      .m_axis_tdata (m_axis_tdata[i1:i0]),
      .m_axis_tlast (m_axis_tlast[i])
    );

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
