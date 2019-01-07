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
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_distrib #(

  // parameters

  parameter   NUM_DISTRIB = 6,
  parameter   DATA_WIDTH = 256,
  parameter   USE_FIFOS = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_LATENCY = 2,

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

  input             s_axis_clk,
  input             s_axis_rst,
  input             m_axis_clk,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output  [ ND:0]   m_axis_tvalid,
  input   [ ND:0]   m_axis_tready,
  output  [ WP:0]   m_axis_tdata

);

  `include "func_log2.vh"

  // internal registers

  reg     [ ND:0]   ready_all = 'b0;

  reg     [ ND:0]   distrib_valid = 'b0;
  reg     [ WP:0]   distrib_data = 'b0;

  // internal signals

  wire    [ ND:0]   ready_all_next;
  wire              s_axis_frame;

  wire    [ ND:0]   distrib_ready;
  wire    [ ND:0]   distrib_frame;

  // slave interface

  assign s_axis_frame = s_axis_tvalid & s_axis_tready;
  assign s_axis_tready = &(ready_all_next);

  // internal logic

  always @(posedge s_axis_clk) begin
    if (s_axis_rst | s_axis_frame) begin
      ready_all <= 'b0;
    end else begin
      ready_all <= ready_all_next;
    end
  end

  assign ready_all_next = ready_all | distrib_frame;

  // master interface

  assign distrib_frame = distrib_valid & distrib_ready;

  genvar n;
  generate
  for (n = 0; n < NUM_DISTRIB; n = n + 1) begin
    localparam n0 = n * DATA_WIDTH;
    localparam n1 = n0 + WD;
    always @(posedge s_axis_clk) begin
      if (s_axis_rst) begin
        distrib_valid[n] <= 'b0;
        distrib_data[n1:n0] <= 'b0;
      end else if (~ready_all_next[n]) begin
        distrib_valid[n] <= s_axis_tvalid;
        distrib_data[n1:n0] <= s_axis_tdata;
      end else begin
        distrib_valid[n] <= 'b0;
        distrib_data[n1:n0] <= 'b0;
      end
    end
  end
  endgenerate

  // assign outputs

  generate
  if (USE_FIFOS == 0) begin

    assign distrib_ready = m_axis_tready;
    assign m_axis_tvalid = distrib_valid;
    assign m_axis_tdata = distrib_data;

  end else begin

    for (n = 0; n < NUM_DISTRIB; n = n + 1) begin
      localparam n0 = n * DATA_WIDTH;
      localparam n1 = n0 + WD;
      axis_fifo_async #(
        .MEMORY_TYPE (FIFO_TYPE),
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (16),
        .READ_LATENCY (FIFO_LATENCY)
      ) axis_fifo_async (
        .s_axis_clk (s_axis_clk),
        .s_axis_rst (s_axis_rst),
        .m_axis_clk (m_axis_clk),
        .s_axis_tvalid (distrib_valid[n]),
        .s_axis_tready (distrib_ready[n]),
        .s_axis_tdata (distrib_data[n1:n0]),
        .m_axis_tvalid (m_axis_tvalid[n]),
        .m_axis_tready (m_axis_tready[n]),
        .m_axis_tdata (m_axis_tdata[n1:n0])
      );
    end

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
