////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream (slave) quad-channel (8 I/Q) deserializer.
//
// Revision: N/A
// Additional Comments: The master clk "clk" must have a frequency greater than
// or equal to the input data clock to avoid dropping data. To avoid having to
// instantitate a FIFO, this module simply drops data if the output cannot
// handle the flow.
//
////////////////////////////////////////////////////////////////////////////////

module axis_quad_des #(

  // parameters

  parameter   USE_AXIS_TLAST = 0,
  parameter   CHAN_WIDTH = 64,

  // derived parameters

  localparam  DATA_WIDTH = CHAN_WIDTH * 4,

  // bit width parameters

  localparam  W0 = DATA_WIDTH - 1;

) (

  // core interface

  input             s_axis_clk,
  input             m_axis_clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input             s_axis_tlast,
  input   [ W0:0]   s_axis_tdata,

  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output            m_axis_tlast,
  output  [ W0:0]   m_axis_tdata

);

  // internal registers

  reg     [ W0:0]   s_axis_data_pack = {DATA_WIDTH{1'b0}};
  reg     [  3:0]   s_axis_count = 4'b0;
  reg               m_axis_tvalid_reg = 1'b0;
  reg               m_axis_end_burst = 1'b0;

  // clock domain boundary synchronization

  reg     [ W0:0]   m_axis_sync0_data = {DATA_WIDTH{1'b0}};
  reg     [ W0:0]   m_axis_sync1_data = {DATA_WIDTH{1'b0}};
  reg               m_axis_sync0_count = 1'b0;
  reg               m_axis_sync1_count = 1'b0;
  reg               m_axis_sync0_last = 1'b0;
  reg               m_axis_sync1_last = 1'b0;

  // internal signals

  wire              s_axis_frame;
  wire              m_axis_frame;

  // frame signals

  assign s_axis_frame = s_axis_tready & s_axis_tvalid;
  assign m_axis_frame = m_axis_tready & m_axis_tvalid;

  // slave interface

  always @(posedge s_axis_clk) begin
    if (rst) begin
      s_axis_data_pack <= {DATA_WIDTH{1'b0}};
    end else begin
      s_axis_data_pack <= s_axis_tdata;
    end
  end

  always @(posedge s_axis_clk) begin
    casez ({rst, s_axis_valid, s_axis_count[3]})
      3'b1??: s_axis_count <= 4'b0;
      3'b011: s_axis_count <= 4'b1;
      3'b010: s_axis_count <= s_axis_count + 1'b1;
      default: s_axis_count <= s_axis_count;
    endcase
  end

  assign s_axis_tready = 1'b1;

  // synchronize across clock domains

  always @(posedge m_axis_clk) begin
    if (rst) begin
      m_axis_sync0_data <= {DATA_WIDTH{1'b0}};
      m_axis_sync1_data <= {DATA_WIDTH{1'b0}};
      m_axis_sync0_count <= 4'b0;
      m_axis_sync1_count <= 4'b0;
    end else begin
      m_axis_sync0_data <= s_axis_data_pack;
      m_axis_sync1_data <= m_axis_sync0_data;
      m_axis_sync0_count <= s_axis_count[3];
      m_axis_sync1_count <= m_axis_sync0_count;
    end
  end

  // master interface

  always @(posedge m_axis_clk) begin
    casez ({rst, m_axis_sync1_count, m_axis_frame})
      3'b1??: m_axis_tvalid_reg <= 1'b0;
      3'b01?: m_axis_tvalid_reg <= 1'b1;
      3'b001: m_axis_tvalid_reg <= 1'b0;
      default: m_axis_tvalid_reg <= m_axis_tdata_valid;
    endcase
  end

  always @(posedge m_axis_clk) begin
    if (rst) begin
      m_axis_data_delay <= {DATA_WIDTH{1'b0}};
    end else begin
      m_axis_data_delay <= m_axis_sync1_data;
    end
  end

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_data_delay;

  // master interface tlast logic

  generate
  if (USE_AXIS_TLAST == 0) begin

  assign m_axis_tlast = 1'b0;

  end else begin

  always @(posedge m_axis_clk) begin
    if (rst) begin
      m_axis_sync0_last <= 1'b0;
      m_axis_sync1_last <= 1'b0;
    end else begin
      m_axis_sync0_last <= s_axis_tlast;
      m_axis_sync1_last <= m_axis_sync0_last;
    end
  end

  always @(posedge m_axis_clk) begin
    casez ({rst, m_axis_sync1_last, m_axis_frame})
      3'b1??: m_axis_end_burst <= 1'b0;
      3'b01?: m_axis_end_burst <= 1'b1;
      3'b001: m_axis_end_burst <= 1'b0;
      default: m_axis_end_burst <= m_axis_tdata_valid;
    endcase
  end

  assign m_axis_tlast = m_axis_tvalid & m_axis_end_burst;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
