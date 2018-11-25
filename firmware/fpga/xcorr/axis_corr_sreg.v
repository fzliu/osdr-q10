////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream correlation shift register implementation.
//
// enable  :  N/A
// reset   :  active-high
// latency :  variable (dependent on correlator length)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_corr_sreg #(

  // parameters

  parameter   CORR_LENGTH = 7,
  parameter   INPUT_WIDTH = 128,

  // derived parameters

  parameter   TOTAL_WIDTH = INPUT_WIDTH * CORR_LENGTH,
  parameter   SHIFT_WIDTH = TOTAL_WIDTH - INPUT_WIDTH,

  // bit width parameters

  localparam  LC = CORR_LENGTH - 1,
  localparam  WI = INPUT_WIDTH - 1,
  localparam  WT = TOTAL_WIDTH - 1,
  localparam  WS = SHIFT_WIDTH - 1

) (

  // core interface

  input             clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WI:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WT:0]   m_axis_tdata

);

  // internal registers

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WT:0]   m_axis_tdata_reg = 'b0;

  // shift implementation

  always @(posedge clk) begin
    if (s_axis_tvalid & m_axis_tready) begin
      m_axis_tvalid_reg <= 1'b1;
      m_axis_tdata_reg <= {m_axis_tdata[WS:0], s_axis_tdata};
    end else begin
      m_axis_tvalid_reg <= m_axis_tvalid;
      m_axis_tdata_reg <= m_axis_tdata;
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;

endmodule
