////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 江凯都
//
// Description: Sample filter.
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_samp_filt #(

  // parameters

  parameter   ABS_WIDTH = 16,
  parameter   NUM_DELAY = 24,
  parameter   NUM_PAD_SAMPS = 7,
  parameter   DATA_PASS_VALUE = 16,
  parameter   LOG2_FILTER_LENGTH = 4,

  // bit width parameters

  localparam  WA = ABS_WIDTH - 1,
  localparam  WN = log2(NUM_PAD_SAMPS) - 1

) (

  // core interface

  input             clk,

  // input interface

  input             valid_0_in,
  input   [ 11:0]   data_i0_in,
  input   [ 11:0]   data_q0_in,
  input             valid_1_in,
  input   [ 11:0]   data_i1_in,
  input   [ 11:0]   data_q1_in,
  input             valid_2_in,
  input   [ 11:0]   data_i2_in,
  input   [ 11:0]   data_q2_in,
  input             valid_3_in,
  input   [ 11:0]   data_i3_in,
  input   [ 11:0]   data_q3_in,

  // output interface

  output            valid_0_out,
  output  [ 11:0]   data_i0_out,
  output  [ 11:0]   data_q0_out,
  output            valid_1_out,
  output  [ 11:0]   data_i1_out,
  output  [ 11:0]   data_q1_out,
  output            valid_2_out,
  output  [ 11:0]   data_i2_out,
  output  [ 11:0]   data_q2_out,
  output            valid_3_out,
  output  [ 11:0]   data_i3_out,
  output  [ 11:0]   data_q3_out

);

  `include "func_log2.vh"
  `include "sign_ext.vh"

  // internal signals

  wire    [  3:0]   valid_in;

  wire    [ 11:0]   data_iq [0:7];
  wire    [ 11:0]   data_out_iq [0:7];

  wire    [ 33:0]   abs_dout [0:3];
  wire    [ WA:0]   avg_dout [0:3];
  wire    [ WN:0]   pad_count [0:3];
  wire              data_pass [0:3];

  // internal registers

  reg     [  3:0]   valid_out = 'b0;

  // pack and unpack data

  assign data_iq[7] = data_i0_in;
  assign data_iq[6] = data_q0_in;
  assign data_iq[5] = data_i1_in;
  assign data_iq[4] = data_q1_in;
  assign data_iq[3] = data_i2_in;
  assign data_iq[2] = data_q2_in;
  assign data_iq[1] = data_i3_in;
  assign data_iq[0] = data_q3_in;

  assign valid_in[3] = valid_0_in;
  assign valid_in[2] = valid_1_in;
  assign valid_in[1] = valid_2_in;
  assign valid_in[0] = valid_3_in;

  assign valid_0_out = valid_out[3];
  assign valid_1_out = valid_out[2];
  assign valid_2_out = valid_out[1];
  assign valid_3_out = valid_out[0];

  assign data_i0_out = data_out_iq[7];
  assign data_q0_out = data_out_iq[6];
  assign data_i1_out = data_out_iq[5];
  assign data_q1_out = data_out_iq[4];
  assign data_i2_out = data_out_iq[3];
  assign data_q2_out = data_out_iq[2];
  assign data_i3_out = data_out_iq[1];
  assign data_q3_out = data_out_iq[0];

  // create one filter per channel

  genvar n;
  generate

  for (n = 0; n < 4; n = n + 1) begin : filt_gen
    localparam a = 2 * n;
    localparam b = 2 * n + 1;

    // filter passthrough

    assign data_pass[n] = (avg_dout[n] > DATA_PASS_VALUE);

    counter #(
      .LOWER (0),
      .UPPER (NUM_PAD_SAMPS),
      .WRAPAROUND (0),
      .INIT_VALUE (NUM_PAD_SAMPS)
    ) counter (
      .clk (clk),
      .rst (data_pass[n]),
      .ena (1'b1),
      .value (pad_count[n])
    );

    always @(posedge clk) begin
      if ((data_pass[n] | (pad_count[n] < NUM_PAD_SAMPS)) & valid_in[n]) begin
        valid_out[n] <= 1'b1;
      end else begin
        valid_out[n] <= 1'b0;
      end
    end

    // shift register (delay)

    shift_reg #(
      .WIDTH (12),
      .DEPTH (NUM_DELAY)
    ) shift_reg_iq0 (
      .clk (clk),
      .ena (1'b1),
      .din (data_iq[a]),
      .dout (data_out_iq[a])
    );

    shift_reg #(
      .WIDTH (12),
      .DEPTH (NUM_DELAY)
    ) shift_reg_iq1 (
      .clk (clk),
      .ena (1'b1),
      .din (data_iq[b]),
      .dout (data_out_iq[b])
    );

    // absolute value

    math_cabs_32 #(
    ) math_cabs (
      .clk (clk),
      .rst (1'b0),
      .ena (1'b1),
      .dina (`SIGN_EXT(data_iq[a],12,32)),
      .dinb (`SIGN_EXT(data_iq[b],12,32)),
      .dout (abs_dout[n])
    );

    // boxcar averager

    filt_boxcar #(
      .DATA_WIDTH (ABS_WIDTH),
      .FILTER_POWER (LOG2_FILTER_LENGTH)
    ) filt_boxcar (
      .clk (clk),
      .rst (1'b0),
      .ena (1'b1),
      .data_in (abs_dout[n][WA:0]),
      .avg_out (avg_dout[n])
    );

  end
  endgenerate

endmodule
