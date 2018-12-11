////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Serializes AD9361 raw data into AXI-stream data.
//
// enable  :  N/A
// reset   :  N/A
// latency :  2 (single clock only)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_dual_axis #(

  // parameters

  parameter   VALID_ALL = 0,
  parameter   INDEP_CLOCKS = 0,
  parameter   REVERSE_DATA = 0,
  parameter   USE_AXIS_TLAST = 0,
  parameter   AXIS_BURST_LENGTH = 512,

  // derived parameters

  localparam  COUNT_WIDTH = log2(AXIS_BURST_LENGTH),

  // bit width parameters

  localparam  N0 = COUNT_WIDTH - 1

) (

  // data interface

  input             data_clk,
  input             valid_0,
  input   [ 11:0]   data_i0,
  input   [ 11:0]   data_q0,
  input             valid_1,
  input   [ 11:0]   data_i1,
  input   [ 11:0]   data_q1,
  input             valid_2,
  input   [ 11:0]   data_i2,
  input   [ 11:0]   data_q2,
  input             valid_3,
  input   [ 11:0]   data_i3,
  input   [ 11:0]   data_q3,

  // axi-stream master interface

  input             m_axis_clk,
  output            m_axis_tvalid,
  input             m_axis_tready,
  output            m_axis_tlast,
  output  [127:0]   m_axis_tdata

);

  `include "log2_func.vh"
  `include "sign_ext.vh"

  // internal registers

  reg               data_frame = 'b0;
  reg     [127:0]   data_packed = 'b0;
  reg               m_axis_tvalid_reg = 'b0;
  reg     [ N0:0]   m_axis_count = 'b0;

  // clock domain boundary synchronization

  reg     [127:0]   m_axis_sync0_data = 'b0;
  reg     [127:0]   m_axis_sync1_data = 'b0;
  reg               m_axis_sync0_update = 'b0;
  reg               m_axis_sync1_update = 'b0;
  reg               m_axis_update_delay = 'b0;

  // internal signals

  wire              valid_int;

  wire              m_axis_update;
  wire              m_axis_frame;
  wire              m_axis_end_burst;

  // input data domain

  generate
  if (VALID_ALL != 0) begin
    assign valid_int = valid_0 & valid_1 & valid_2 & valid_3;
  end else begin
    assign valid_int = valid_0 | valid_1 | valid_2 | valid_3;
  end
  endgenerate

  always @(posedge data_clk) begin
    if (valid_int) begin
      data_frame <= ~data_frame;
    end else begin
      data_frame <= data_frame;
    end
  end

  generate
  if (REVERSE_DATA == 0) begin

    always @(posedge data_clk) begin
      data_packed[15:0] <= `SIGN_EXT(data_q3,12,16); // axi spec: byte align
      data_packed[31:16] <= `SIGN_EXT(data_i3,12,16);
      data_packed[47:32] <= `SIGN_EXT(data_q2,12,16);
      data_packed[63:48] <= `SIGN_EXT(data_i2,12,16);
      data_packed[79:64] <= `SIGN_EXT(data_q1,12,16);
      data_packed[95:80] <= `SIGN_EXT(data_i1,12,16);
      data_packed[111:96] <= `SIGN_EXT(data_q0,12,16);
      data_packed[127:112] <= `SIGN_EXT(data_i0,12,16);
    end

  end else begin

    always @(posedge data_clk) begin
      data_packed[15:0] <= `SIGN_EXT(data_i0,12,16);
      data_packed[31:16] <= `SIGN_EXT(data_q0,12,16);
      data_packed[47:32] <= `SIGN_EXT(data_i1,12,16);
      data_packed[63:48] <= `SIGN_EXT(data_q1,12,16);
      data_packed[79:64] <= `SIGN_EXT(data_i2,12,16);
      data_packed[95:80] <= `SIGN_EXT(data_q2,12,16);
      data_packed[111:96] <= `SIGN_EXT(data_i3,12,16);
      data_packed[127:112] <= `SIGN_EXT(data_q3,12,16);
    end

  end
  endgenerate

  generate
  if (INDEP_CLOCKS == 0) begin

  // single clock domain, no need to synchronize

  always @* begin
    m_axis_sync1_data = data_packed;
    m_axis_sync1_update = data_frame;
  end

  end else begin

  // synchronize across clock domains

  always @(posedge m_axis_clk) begin
    m_axis_sync0_data <= data_packed;
    m_axis_sync1_data <= m_axis_sync0_data;
    m_axis_sync0_update <= data_frame;
    m_axis_sync1_update <= m_axis_sync0_update;
  end

  end
  endgenerate

  // set data flow control signals

  always @(posedge m_axis_clk) begin
    m_axis_update_delay <= m_axis_sync1_update;
  end

  assign m_axis_update = m_axis_sync1_update ^ m_axis_update_delay;
  assign m_axis_frame = m_axis_tvalid & m_axis_tready;
  assign m_axis_tdata = m_axis_sync1_data;

  // master interface

  always @(posedge m_axis_clk) begin
    if (m_axis_update) begin
      m_axis_tvalid_reg <= 1'b1;
    end else if (m_axis_tvalid & ~m_axis_tready) begin
      m_axis_tvalid_reg <= 1'b1;
    end else begin
      m_axis_tvalid_reg <= 1'b0;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;

  // master interface tlast logic

  generate
  if (USE_AXIS_TLAST == 0) begin

    assign m_axis_tlast = 1'b0;

  end else begin

    assign m_axis_end_burst = (m_axis_count == AXIS_BURST_LENGTH - 1);

    always @(posedge m_axis_clk) begin
      casez ({m_axis_frame, m_axis_end_burst})
        2'b11: m_axis_count <= {COUNT_WIDTH{1'b0}};
        2'b10: m_axis_count <= m_axis_count + 1'b1;
        default: m_axis_count <= m_axis_count;
      endcase
    end

    assign m_axis_tlast = m_axis_tvalid & m_axis_end_burst;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
