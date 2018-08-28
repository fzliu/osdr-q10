////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Serializes AXI-stream data and computes complex absolute value.
//
// enable  :  N/A
// reset   :  active-high
//
////////////////////////////////////////////////////////////////////////////////

module axis_cabs_all #(

  // parameters

  parameter   NUM_TAGS = 20,
  parameter   CHANNEL_WIDTH = 64,

  // derived parameters

  localparam  WORD_WIDTH = CHANNEL_WIDTH / 2,
  localparam  DATA_WIDTH = CHANNEL_WIDTH * 4,
  localparam  PACKED_WIDTH = NUM_TAGS * DATA_WIDTH,
  localparam  OUTPUT_WIDTH = 2 * PACKED_WIDTH,

  // bit width parameters

  localparam  NT = NUM_TAGS - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WO = OUTPUT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input   [ NT:0]   s_axis_tvalid,
  output  [ NT:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,

  // master interface

  output  [ NT:0]   m_axis_tvalid,
  input   [ NT:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata,
  output  [ WP:0]   m_axis_tdata_abs

);

  // internal signals

  wire              fanin_valid;
  wire    [ WD:0]   fanin_data;
  wire    [ NT:0]   fanin_chan;
  wire              fanin_valid_d;
  wire    [ WD:0]   fanin_data_d;
  wire    [ NT:0]   fanin_chan_d;
  wire    [ WD:0]   cabs_dout;

  wire              fanout_ready;
  wire    [ WO:0]   fanout_data;

  // axi-stream fan-in

  axis_fan_in #(
    .NUM_FANIN (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH)
  ) axis_fan_in (
    .clk (clk),
    .rst (rst),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata (s_axis_tdata),
    .s_axis_tlast ('b0),
    .m_axis_tvalid (fanin_valid),
    .m_axis_tready (fanout_ready),
    .m_axis_tdata (fanin_data),
    .m_axis_tuser (fanin_chan),
    .m_axis_tlast ()
  );

  // absval computation

  generate
  genvar i;
  for (i = 0; i < 4; i = i + 1) begin : math_cabs_gen
    localparam i_beg = i * CHANNEL_WIDTH;
    localparam i_end = i_beg + WW;
    localparam q_beg = i_end + 1;
    localparam q_end = q_beg + WW;

    math_cabs #(
      .DIN_WIDTH (WORD_WIDTH),
      .DOUT_WIDTH (CHANNEL_WIDTH)
    ) math_cabs (
      .clk (clk),
      .rst (rst),
      .dina (fanin_data[i_end:i_beg]),
      .dinb (fanin_data[q_end:q_beg]),
      .dout (cabs_dout [q_end:i_beg])
    );
  end
  endgenerate

  // delay via shift reg

  shift_reg #(
    .WIDTH (DATA_WIDTH + NUM_TAGS + 2),
    .DEPTH (8)  // cabs delay
  ) shift_reg (
    .clk (clk),
    .ena (m_axis_tready),
    .din ({fanin_valid, fanin_data, fanin_chan}),
    .dout ({fanin_valid_d, fanin_data_d, fanin_chan_d})
  );

  // axi-stream fan-out

  axis_fan_out #(
    .NUM_FANOUT (NUM_TAGS),
    .DATA_WIDTH (DATA_WIDTH * 2)
  ) axis_fan_out (
    .clk (clk),
    .rst (rst),
    .s_axis_tvalid (fanin_valid_d),
    .s_axis_tready (fanout_ready),
    .s_axis_tdata ({fanin_data_d, cabs_dout}),
    .s_axis_tuser (fanin_chan_d),
    .s_axis_tlast ('b0),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tdata (fanout_data),
    .m_axis_tlast ()
  );

  // split output data

  generate
  genvar j;
  for (j = 0; j < NUM_TAGS; j = j + 1) begin : dout_gen
    localparam j0 = j * DATA_WIDTH;
    localparam j1 = j0 + WD;
    localparam J0 = 2 * j0;
    localparam J1 = J0 + WD;
    localparam J2 = J1 + 1;
    localparam J3 = J2 + WD;

    assign m_axis_tdata_abs[j1:j0] = fanout_data[J1:J0];
    assign m_axis_tdata[j1:j0] = fanout_data[J3:J2];
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
