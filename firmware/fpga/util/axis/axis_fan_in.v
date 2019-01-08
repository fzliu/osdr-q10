////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AXI-stream fan-in implementation. The relevant input channel
// is stored in the output tuser. Preference is given to earlier input channels.
// If USE_AXIS_TLAST is set to true, this module will lock onto a channel until
// s_axis_tlast is asserted.
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
  parameter   USE_FIFOS = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_LATENCY = 2,
  parameter   USE_AXIS_TLAST = 0,

  // derived parameters

  localparam  PACKED_WIDTH = NUM_FANIN * DATA_WIDTH,

  // bit width parameters

  localparam  NF = NUM_FANIN - 1,
  localparam  WD = DATA_WIDTH - 1,
  localparam  WP = PACKED_WIDTH - 1

) (

  // core interface

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,
  input             m_axis_rst,

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

  reg     [ NF:0]   chan_sel = {{NF{1'b0}}, 1'b1};
  reg               hold_cond = 'b0;

  reg               m_axis_tvalid_reg = 'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;
  reg               m_axis_tlast_reg = 'b0;
  reg     [ NF:0]   m_axis_tuser_reg = 'b0;

  // internal signals

  wire    [ NF:0]   fanin_valid;
  wire    [ NF:0]   fanin_ready;
  wire    [ WP:0]   fanin_data;
  wire    [ NF:0]   fanin_last;

  wire    [ WD:0]   fanin_data_unpack [0:NF];

  wire    [ NF:0]   chan_prio;
  wire    [ NF:0]   chan_num;

  wire              in_valid;
  wire    [ WD:0]   in_data;
  wire              in_last;

  // buffer inputs

  genvar n;
  generate
  if (USE_FIFOS) begin

    for (n = 0; n < NUM_FANIN; n = n + 1) begin
      localparam n0 = n * DATA_WIDTH;
      localparam n1 = n0 + WD;
      axis_fifo_async #(
        .MEMORY_TYPE (FIFO_TYPE),
        .DATA_WIDTH (DATA_WIDTH + 1),   // make room for tlast
        .FIFO_DEPTH (16),
        .READ_LATENCY (FIFO_LATENCY)
      ) axis_fifo_async (
        .s_axis_clk (s_axis_clk),
        .s_axis_rst (s_axis_rst),
        .m_axis_clk (m_axis_clk),
        .s_axis_tvalid (s_axis_tvalid[n]),
        .s_axis_tready (s_axis_tready[n]),
        .s_axis_tdata ({s_axis_tdata[n1:n0], s_axis_tlast[n]}),
        .m_axis_tvalid (fanin_valid[n]),
        .m_axis_tready (fanin_ready[n]),
        .m_axis_tdata ({fanin_data[n1:n0], fanin_last[n]})
      );
    end

  end else begin

    assign s_axis_tready = fanin_ready;
    assign fanin_valid = s_axis_tvalid;
    assign fanin_data = s_axis_tdata;
    assign fanin_last = s_axis_tlast;

  end
  endgenerate

  // slave interface

  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    assign fanin_data_unpack[n] = fanin_data[n1:n0];
  end
  endgenerate

  assign fanin_ready = m_axis_tready ? chan_sel : 1'b0;

  // fan-in priority logic

  assign chan_prio[0] = 1'b1;

  generate
  for (n = 1; n < NUM_FANIN; n = n + 1) begin
    assign chan_prio[n] = ~|fanin_valid[n-1:0];
  end
  endgenerate

  // select channel based on priority

  generate
  always @(posedge m_axis_clk) begin
    if (USE_AXIS_TLAST) begin
      if (m_axis_rst) begin
        hold_cond <= 'b0;
      end else if (in_valid) begin
        hold_cond <= ~in_last;
      end else begin
        hold_cond <= hold_cond;
      end
    end
  end
  endgenerate

  generate
  for (n = 0; n < NUM_FANIN; n = n + 1) begin
    always @(posedge m_axis_clk) begin
      casez ({m_axis_rst, hold_cond, chan_prio[n]})
        3'b1??: chan_sel[n] <= (n == 0);
        3'b01?: chan_sel[n] <= chan_sel[n];
        3'b001: chan_sel[n] <= fanin_valid[n];
        default: chan_sel[n] <= chan_sel[n];
      endcase
    end
  end
  endgenerate

  // channel selection

  oh_to_bin #(
    .WIDTH_IN (NUM_FANIN),
    .WIDTH_OUT (NUM_FANIN)
  ) oh_to_bin (
    .oh (chan_sel),
    .bin (chan_num)
  );

  // master interface

  assign in_valid = fanin_valid[chan_num];
  assign in_data = fanin_data_unpack[chan_num];

  always @(posedge m_axis_clk) begin
    if (m_axis_rst | ~in_valid) begin
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

  generate
  if (USE_AXIS_TLAST) begin

    assign in_last = fanin_last[chan_num];

    always @(posedge m_axis_clk) begin
      if (m_axis_rst | ~in_valid) begin
        m_axis_tlast_reg <= 'b0;
      end else if (m_axis_tready) begin
        m_axis_tlast_reg <= in_last;
      end else begin
        m_axis_tlast_reg <= m_axis_tlast;
      end
    end
 
  end
  endgenerate

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tlast = m_axis_tlast_reg;

  generate
  if (USE_AXIS_TLAST) begin
    assign m_axis_tuser = m_axis_tuser_reg;
  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
