////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream distributor. Similar to axis_fan_out but sends the
// same data to all channels, i.e. waits for all channels to assert tready
// before updating the bus data (m_axis_tdata).
//
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
//
////////////////////////////////////////////////////////////////////////////////

module axis_distrib #(

  // parameters

  parameter   NUM_DISTRIB = 6,
  parameter   DATA_WIDTH = 256,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_DISTRIB * DATA_WIDTH,
  localparam  SELECT_WIDTH = log2(NUM_DISTRIB - 1),

  // bit width parameters

  localparam  ND = NUM_DISTRIB - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1,
  localparam  WS = SELECT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output  [ ND:0]   m_axis_tvalid,
  input   [ ND:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata

);

  `include "log2_func.vh"

  // internal registers

  reg     [ ND:0]   ready_all = 'b0;

  reg     [ ND:0]   m_axis_tvalid_reg = 'b0;
  reg     [ WP:0]   m_axis_tdata_reg = 'b0;

  // internal signals

  wire    [ ND:0]   ready_all_next;
  wire              s_axis_frame;
  wire    [ ND:0]   m_axis_frame;

  // slave interface

  assign s_axis_frame = s_axis_tvalid & s_axis_tready;
  assign s_axis_tready = &(ready_all_next);

  // internal logic

  always @(posedge clk) begin
    if (rst | s_axis_frame) begin
      ready_all <= 'b0;
    end else begin
      ready_all <= ready_all_next;
    end
  end

  assign ready_all_next = ready_all | m_axis_frame;

  // master interface

  assign m_axis_frame = m_axis_tvalid & m_axis_tready;

  genvar n;
  generate
  for (n = 0; n < NUM_DISTRIB; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    always @(posedge clk) begin
      if (rst) begin
        m_axis_tvalid_reg[n] <= 'b0;
        m_axis_tdata_reg[n1:n0] <= 'b0;
      // once all are ready, immediately proceed to avoid 1-cycle delay
      end else if (&ready_all_next) begin
        m_axis_tvalid_reg[n] <= s_axis_tvalid;
        m_axis_tdata_reg[n1:n0] <= s_axis_tdata;
      // single channel case - stay with current batch of data
      end else if (~ready_all_next[n]) begin
        m_axis_tvalid_reg[n] <= s_axis_tvalid;
        m_axis_tdata_reg[n1:n0] <= s_axis_tdata;
      end else begin
        m_axis_tvalid_reg[n] <= 'b0;
        m_axis_tdata_reg[n1:n0] <= 'b0;
      end
    end
  end
  endgenerate

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
