
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
  input   [ NF:0]   s_axis_tlast,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata,
  output  [ NF:0]   m_axis_tuser,
  output            m_axis_tlast

);

  `include "log2_func.v"

  // internal registers

  reg     [ NF:0]   chan_sel = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg     [ NF:0]   m_axis_tuser_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;

  // internal signals

  wire    [ WD:0]   s_axis_tdata_unpack [0:NF];

  wire    [ NF:0]   chan_prio;
  wire    [ NF:0]   chan_num;

  wire              in_valid;
  wire    [ WD:0]   in_data;
  wire              in_last;

  // slave interface

  generate
  genvar i;
  for (i = 0; i < NUM_FANIN; i = i + 1) begin : data_unpack_gen
    localparam i0 = i * DATA_WIDTH;
    localparam i1 = (i + 1) * DATA_WIDTH - 1;
    assign s_axis_tdata_unpack[i] = s_axis_tdata[i1:i0];
  end
  endgenerate

  assign s_axis_tready = m_axis_tready ? chan_sel : 'b0;

  // fan-in priority encoder

  generate
  genvar j;
  for (j = 0; j < NUM_FANIN; j = j + 1) begin : chan_prio_gen
    assign chan_prio[j] = (j == 0) ? 1'b1 : ~|s_axis_tvalid[j-1:0];
    always @(posedge clk) begin
      if (rst) begin
        chan_sel[j] <= 1'b0;
      end else if (in_valid) begin
        chan_sel[j] <= chan_sel[j];
      end else if (chan_prio[j]) begin
        chan_sel[j] <= s_axis_tvalid[j];
      end else begin
        chan_sel[j] <= 1'b0;
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
  assign in_last = s_axis_tlast[chan_num];

  // master interface

  always @(posedge clk) begin
    if (rst | ~in_valid) begin
      m_axis_tvalid_reg <= 'b0;
      m_axis_tdata_reg <= 'b0;
      m_axis_tuser_reg <= 'b0;
      m_axis_tlast_reg <= 'b0;
    end else if (m_axis_tready) begin
      m_axis_tvalid_reg <= in_valid;
      m_axis_tdata_reg <= in_data;
      m_axis_tuser_reg <= chan_num;
      m_axis_tlast_reg <= in_last;
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
      m_axis_tuser_reg <= m_axis_tuser;
      m_axis_tlast_reg <= m_axis_tlast;
    end
  end

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tuser = m_axis_tuser_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
