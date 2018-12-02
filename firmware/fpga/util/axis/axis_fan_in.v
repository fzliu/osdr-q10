
////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description: AXI-stream fan-in implementation. The relevant input channel
// is stored in the output tuser. Preference is given to earlier input channels.
//
// enable  :  N/A
// reset   :  active-high
// latency :  2 cycles
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_in #(

  // parameters

  parameter   NUM_FANIN = 6,
  parameter   DATA_WIDTH = 256,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_FANIN * DATA_WIDTH,

  // bit width parameters

  localparam  NF = NUM_FANIN - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input   [ NF:0]   s_axis_tvalid,
  output  [ NF:0]   s_axis_tready,
  input   [ WP:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output  [ NF:0]   m_axis_tuser

);

  `include "log2_func.vh"

  // internal registers

  reg     [ NF:0]   chan_sel = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg     [ NF:0]   m_axis_tuser_reg = 'b0;

  // internal signals

  wire    [ WD:0]   s_axis_tdata_unpack [0:NF];

  wire    [ NF:0]   chan_prio;
  wire    [ NF:0]   chan_num;

  wire              in_valid;
  wire    [ WD:0]   in_data;
  wire              in_last;

  // slave interface

  genvar n;
  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
  end
  endgenerate

  assign s_axis_tready = m_axis_tready ? chan_sel : 'b0;

  // fan-in priority encoder

  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    assign chan_prio[n] = (n == 0) ? 1'b1 : ~|s_axis_tvalid[n-1:0];
    always @(posedge clk) begin
      if (rst) begin
        chan_sel[n] <= 1'b0;
      end else if (in_valid) begin
        chan_sel[n] <= chan_sel[n];
      end else if (chan_prio[n]) begin
        chan_sel[n] <= s_axis_tvalid[n];
      end else begin
        chan_sel[n] <= 1'b0;
      end
    end
  end
  endgenerate

  // channel selection

  oh_to_bin #(
    .WIDTH_IN (NUM_FANIN)
  ) oh_to_bin (
    .oh (chan_sel),
    .bin (chan_num)
  );

  assign in_valid = s_axis_tvalid[chan_num];
  assign in_data = s_axis_tdata_unpack[chan_num];

  // master interface

  always @(posedge clk) begin
    if (rst | ~in_valid) begin
      m_axis_tvalid_reg <= 'b0;
      m_axis_tdata_reg <= 'b0;
      m_axis_tuser_reg <= 'b0;
    end else if (m_axis_tready) begin
      m_axis_tvalid_reg <= in_valid;
      m_axis_tdata_reg <= in_data;
      m_axis_tuser_reg <= chan_num;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
      m_axis_tuser_reg <= m_axis_tuser;
    end
  end

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tuser = m_axis_tuser_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
