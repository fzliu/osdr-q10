////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Serializes AD9361 raw data into AXI-stream data.
//
// Parameters
// PRECISION: the number of MSBs to keep in the input data before forwarding
// REVERSE_DATA: if 1, reverses the data bits; otherwise, keeps it as is
// USE_AXIS_TLAST: if 1, enables m_axis_tlast; disables it otherwise
// AXIS_BURST_LENGTH: the number of samples before tlast goes high
// USE_OUTPUT_FIFO: if 1, enables the output FIFO; disables it otherwise
// CONTINUOUS_DATA: if 1, ensures that the FIFO always has some data in it
// CORR_LENGTH: length of each correlator
// CORRELATORS: bits for all correlators
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  2 (single clock only)
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_dual_axis #(

  // parameters

  parameter   PRECISION = 12,
  parameter   REVERSE_DATA = 0,
  parameter   USE_AXIS_TLAST = 0,
  parameter   AXIS_BURST_LENGTH = 512,
  parameter   USE_OUTPUT_FIFO = 1,
  parameter   CONTINUOUS_DATA = 0,
  parameter   FIFO_TYPE = "auto",
  parameter   FIFO_DEPTH = 32,
  parameter   FIFO_LATENCY = 2,

  // derived parameters

  localparam  SAMPS_WIDTH = 8 * PRECISION,
  localparam  COUNT_WIDTH = log2(AXIS_BURST_LENGTH - 1),
  localparam  REDUCE_PRECISION = 12 - PRECISION,
  localparam  EXTRA_BIT = (USE_AXIS_TLAST != 0),

  // bit width parameters

  localparam  PR = PRECISION - 1,
  localparam  WS = SAMPS_WIDTH - 1,
  localparam  WC = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,

  // data interface

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

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WS:0]   m_axis_tdata,
  output            m_axis_tlast

);

  `include "func_log2.vh"

  // internal registers

  reg               samps_valid = 'b0;
  reg     [ WS:0]   samps_data = 'b0;
  reg     [ WC:0]   samps_count = 'b0;

  // internal signals

  wire              valid_int;

  wire    [ PR:0]   data_format [0:7];

  wire              samps_ready;
  wire              samps_last;

  wire              fifo_full;
  wire              fifo_empty;

  /* Format data.
   * The full 12-bit output data may not be required, so we (optionally) reduce
   * the precision of the incoming data by grabbing the MSBs.
   */

  assign data_format[0] = data_q3 >>> REDUCE_PRECISION;
  assign data_format[1] = data_i3 >>> REDUCE_PRECISION;
  assign data_format[2] = data_q2 >>> REDUCE_PRECISION;
  assign data_format[3] = data_i2 >>> REDUCE_PRECISION;
  assign data_format[4] = data_q1 >>> REDUCE_PRECISION;
  assign data_format[5] = data_i1 >>> REDUCE_PRECISION;
  assign data_format[6] = data_q0 >>> REDUCE_PRECISION;
  assign data_format[7] = data_i0 >>> REDUCE_PRECISION;

  /* Output valid.
   * If any of the four channels is valid, i.e. has "non-zero" data, then we
   * assert the output valid signal. This happens on the next cycle to ensure
   * alignment with samps_data.
   */

  generate
  assign valid_int = (USE_OUTPUT_FIFO && CONTINUOUS_DATA) ?
                     fifo_empty : 1'b0;
  endgenerate

  always @(posedge clk) begin
    samps_valid <= valid_0 | valid_1 | valid_2 | valid_3 | valid_int;
  end

  /* Output data.
   * An option to reverse the data is provided since some IP cores process data
   * this way.
   */

  genvar n;
  generate
  for (n = 0; n < 8; n = n + 1) begin
    localparam n0 = n * PRECISION;
    localparam n1 = n0 + PR;
    always @(posedge clk) begin
      if (REVERSE_DATA) begin
        samps_data[n1:n0] <= data_format[7-n];
      end else begin
        samps_data[n1:n0] <= data_format[n];
      end
    end
  end
  endgenerate

  /* Output tlast logic.
   * This signal should only be used when tlast is required, e.g. for the FFT
   * module where the length is pre-determined.
   */

  generate
  if (USE_AXIS_TLAST == 0) begin

    assign samps_last = 1'b0;

  end else begin

    always @(posedge clk) begin
      casez ({samps_valid, samps_ready, samps_last})
        3'b111: samps_count <= 'b0;
        3'b110: samps_count <= samps_count + 1'b1;
        default: samps_count <= samps_count;
      endcase
    end

    assign samps_last = (samps_count == AXIS_BURST_LENGTH - 1);

  end
  endgenerate

  /* Master interface FIFO.
   * Instantiate a FIFO only if requested.
   */

  generate
  if (USE_OUTPUT_FIFO) begin

    axis_fifo #(
      .DATA_WIDTH (SAMPS_WIDTH + EXTRA_BIT),
      .FIFO_DEPTH (FIFO_DEPTH),
      .FULL_THRESH (FIFO_DEPTH - 3),
      .EMPTY_THRESH (3)
    ) axis_fifo (
      .clk (clk),
      .rst (1'b0),
      .ena (1'b1),
      .full (fifo_full),
      .empty (fifo_empty),
      .s_axis_tvalid (samps_valid),
      .s_axis_tready (samps_ready),
      .s_axis_tdata ({samps_last,
                      samps_data}),
      .m_axis_tvalid (m_axis_tvalid),
      .m_axis_tready (m_axis_tready),
      .m_axis_tdata ({m_axis_tlast,
                      m_axis_tdata})
    );

  end else begin

    assign samps_ready = m_axis_tready;
    assign m_axis_tvalid = samps_valid;
    assign m_axis_tdata = samps_data;
    assign m_axis_tlast = samps_last;

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
