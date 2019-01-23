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
  parameter   USE_FIFOS = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_LATENCY = 2,

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

  reg     [ NF:0]   chan_num = 'b0;

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

  wire    [ NF:0]   prio_num;
  wire              chan_valid;


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
    assign fanin_ready[n] = m_axis_tready & (chan_num == n);
  end
  endgenerate

  // channel selection
  // use oh_to_bin as a priority encoder

  oh_to_bin #(
    .WIDTH_IN (NUM_FANIN),
    .WIDTH_OUT (NUM_FANIN)
  ) oh_to_bin (
    .oh (fanin_valid),
    .bin (prio_num)
  );

  always @(posedge m_axis_clk) begin
    if (m_axis_rst) begin
      chan_num <= 'b0;
    end else if (fanin_valid[chan_num]) begin
      chan_num <= chan_num;
    end else begin
      chan_num <= prio_num;
    end
  end

  // master interface

  always @(posedge m_axis_clk) begin
    if (m_axis_rst) begin
      m_axis_tvalid_reg <= 'b0;
      m_axis_tdata_reg <= 'b0;
      m_axis_tlast_reg <= 'b0;
      m_axis_tuser_reg <= 'b0;
    end else begin
      m_axis_tvalid_reg <= fanin_valid[chan_num];
      m_axis_tdata_reg <= fanin_data_unpack[chan_num];
      m_axis_tlast_reg <= fanin_last[chan_num];
      m_axis_tuser_reg <= chan_num;
    end
  end

  // assign outputs

  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tlast = m_axis_tlast_reg;
  assign m_axis_tuser = m_axis_tuser_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////