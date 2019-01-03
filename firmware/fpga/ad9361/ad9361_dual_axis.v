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

  parameter   SAMPS_WIDTH = 128,
  parameter   REDUCE_PRECISION = 0,
  parameter   REVERSE_DATA = 0,
  parameter   INDEP_CLOCKS = 0,
  parameter   USE_AXIS_TLAST = 0,
  parameter   AXIS_BURST_LENGTH = 512,

  // derived parameters

  localparam  COUNT_WIDTH = log2(AXIS_BURST_LENGTH),
  localparam  WORD_WIDTH = SAMPS_WIDTH / 8,
  localparam  PRECISION = 12 - REDUCE_PRECISION,

  // bit width parameters

  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WC = COUNT_WIDTH - 1,
  localparam  WW = WORD_WIDTH - 1,
  localparam  W0 = PRECISION - 1

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
  output  [ WS:0]   m_axis_tdata

);

  `include "log2_func.vh"
  `include "sign_ext.vh"

  // internal registers

  reg               data_frame = 'b0;
  reg     [ WS:0]   data_packed = 'b0;
  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WC:0]   m_axis_count = 'b0;

  reg     [ WS:0]   m_axis_sync0_data = 'b0;
  reg     [ WS:0]   m_axis_sync1_data = 'b0;
  reg               m_axis_sync0_update = 'b0;
  reg               m_axis_sync1_update = 'b0;
  reg               m_axis_update_delay = 'b0;

  // internal signals

  wire    [ W0:0]   data_format [0:7];

  wire              valid_int;

  wire              m_axis_update;
  wire              m_axis_frame;
  wire              m_axis_end_burst;

  // input data domain

  assign valid_int = valid_0 | valid_1 | valid_2 | valid_3;

  always @(posedge data_clk) begin
    if (valid_int) begin
      data_frame <= ~data_frame;
    end else begin
      data_frame <= data_frame;
    end
  end

  // format data to desired precision

  assign data_format[0] = data_q3 >>> REDUCE_PRECISION;
  assign data_format[1] = data_i3 >>> REDUCE_PRECISION;
  assign data_format[2] = data_q2 >>> REDUCE_PRECISION;
  assign data_format[3] = data_i2 >>> REDUCE_PRECISION;
  assign data_format[4] = data_q1 >>> REDUCE_PRECISION;
  assign data_format[5] = data_i1 >>> REDUCE_PRECISION;
  assign data_format[6] = data_q0 >>> REDUCE_PRECISION;
  assign data_format[7] = data_i0 >>> REDUCE_PRECISION;

  // pack sample data

  genvar n;
  generate
  for (n = 0; n < 8; n = n + 1) begin
    localparam n0 = n * WORD_WIDTH;
    localparam n1 = n0 + WW;
    always @(posedge data_clk) begin
      if (REVERSE_DATA) begin
        data_packed[n1:n0] <= `SIGN_EXT(data_format[7-n],PRECISION,WORD_WIDTH);
      end else begin
        data_packed[n1:n0] <= `SIGN_EXT(data_format[n],PRECISION,WORD_WIDTH);
      end
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
