////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AXI-stream fan-in implementation. The relevant input channel is stored in
// m_axis_tuser. Preference is given to earlier (MSB) input channels.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fan_in #(

  // parameters

  parameter   NUM_FANIN = 6,
  parameter   DATA_WIDTH = 256,
  parameter   USE_AXIS_TLAST = 1,

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
  output            m_axis_tlast,
  output  [ NF:0]   m_axis_tuser

);

  `include "func_log2.vh"

  // internal registers

  reg               is_active = 'b0;
  reg     [ NF:0]   chan_num = 'b0;

  // internal signals

  wire    [ WD:0]   s_axis_tdata_unpack [0:NF];

  wire    [ NF:0]   prio_num;
  wire              chan_valid;

  // slave interface

  genvar n;
  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    assign s_axis_tdata_unpack[n] = s_axis_tdata[n1:n0];
    assign s_axis_tready[n] = m_axis_tready & (chan_num == n);
  end
  endgenerate

  // channel selection
  // oh_to_bin acts as priority encoder

  oh_to_bin #(
    .WIDTH_IN (NUM_FANIN),
    .WIDTH_OUT (NUM_FANIN)
  ) oh_to_bin (
    .oh (s_axis_tvalid),
    .bin (prio_num)
  );

  generate
  if (USE_AXIS_TLAST) begin

    // case 0: use tlast
    // keep the current channel until tlast goes high

    always @(posedge clk) begin
      casez ({rst, m_axis_tlast, m_axis_tvalid})
        3'b1??: is_active <= 1'b0;
        3'b011: is_active <= m_axis_tready;
        3'b001: is_active <= 1'b1;
        default: is_active <= is_active;
      endcase
    end

    // the active channel retains priority

    always @(posedge clk) begin
      casez ({rst, is_active})
        2'b1?: chan_num <= 'b0;
        2'b01: chan_num <= chan_num;
        default: chan_num <= prio_num;
      endcase
    end

  end else begin

    // case 1: do not use tlast
    // channel number = one with highest priority

    always @* begin
      chan_num = prio_num;
    end

  end
  endgenerate

  // master interface

  assign m_axis_tvalid = s_axis_tvalid[chan_num];
  assign m_axis_tdata = s_axis_tdata_unpack[chan_num];
  assign m_axis_tuser = chan_num;

  generate
  if (USE_AXIS_TLAST) begin
    assign m_axis_tlast = s_axis_tlast[chan_num];
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
