////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Zero-pads input data into an output stream. Both AXI-stream
// channels share a common clock (clk).
//
// Revision: N/A
// Additional Comments: Input AXI clock is idential to output AXI clock,
// therefore input rate multiplied by upsample factor must be less or equal to
// the output rate. Upsample factor = PAD_SIZE + 1.
////////////////////////////////////////////////////////////////////////////////

module axis_zero_pad #(

  // parameters

  parameter   PAD_SIZE = 19,

  // derived parameters

  localparam  COUNT_WIDTH = log2(PAD_SIZE+1),

  // bit width parameters

  localparam  N0 = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // axi-stream slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ 31:0]   s_axis_tdata,
  input             s_axis_tlast,

  // axi-stream master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ 31:0]   m_axis_tdata,
  output            m_axis_tlast

);

  `include "log2_func.vh"

  // internal registers

  reg               burst_done = 1'b0;
  reg     [ 31:0]   m_axis_tdata_reg = 32'b0;
  reg     [ N0:0]   m_axis_count = PAD_SIZE + 1;

  // internal signals

  wire              s_axis_frame;
  wire              m_axis_frame;
  wire              m_axis_pad_done;

  // frame signals

  assign s_axis_frame = s_axis_tready & s_axis_tvalid;
  assign m_axis_frame = m_axis_tready & m_axis_tvalid;

  // slave interface

  assign s_axis_tready = m_axis_pad_done;

  // internal counter

  assign m_axis_pad_done = (m_axis_count >= PAD_SIZE);

  always @(posedge clk) begin
    casez ({rst, s_axis_frame, m_axis_frame})
      3'b1??: m_axis_count <= PAD_SIZE;
      3'b01?: m_axis_count <= {COUNT_WIDTH{1'b0}};
      3'b001: m_axis_count <= m_axis_count + 1'b1;
      default: m_axis_count <= m_axis_count;
    endcase
  end

  // master interface

  always @(posedge clk) begin
    casez ({rst, s_axis_frame, m_axis_frame})
      3'b1??: m_axis_tdata_reg <= 32'b0;
      3'b01?: m_axis_tdata_reg <= s_axis_tdata;
      3'b001: m_axis_tdata_reg <= 32'b0;
      default: m_axis_tdata_reg <= m_axis_tdata;
    endcase
  end

  always @(posedge clk) begin
    casez ({rst, s_axis_tlast, m_axis_tlast})
      3'b1??: burst_done <= 1'b0;
      3'b01?: burst_done <= 1'b1;
      3'b001: burst_done <= 1'b0;
      default: burst_done <= burst_done;
    endcase
  end

  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tvalid = (m_axis_count <= PAD_SIZE);
  assign m_axis_tlast = burst_done & m_axis_pad_done;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
