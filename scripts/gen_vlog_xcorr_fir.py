#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
from string import Template


# argparse
parser = argparse.ArgumentParser(description="Generate a mass-xcorr Verilog module.")
parser.add_argument("-n", "--num-tags", type=int, default=40, help="number of modules")
parser.add_argument("-f", "--out-file", type=str, default="axis_xcorr_all.v", help="output filename")


# module template
templ_top = Template("""
////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Packs all cross-correlations modules into a single file.
//
////////////////////////////////////////////////////////////////////////////////

module axis_xcorr_all #(

  // parameters

  parameter           NUM_TAGS = $num_tags,
  parameter           FIFO_DEPTH = 2048,
  parameter           S_TDATA_WIDTH = 128,
  parameter           M_TDATA_WIDTH = 256,

  // derived parameters

  localparam          M_TOTAL_WIDTH = NUM_TAGS * M_TDATA_WIDTH,

  // bit width parameters

  localparam          N0 = NUM_TAGS - 1,
  localparam          N1 = S_TDATA_WIDTH - 1,
  localparam          N2 = M_TOTAL_WIDTH - 1,

  parameter   [N0:0]  DISABLE_MASK = {NUM_TAGS{1'b0}}

) (

  // core interface

  input             in_clk,
  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ N1:0]   s_axis_tdata,

  // master interface

  output  [ N0:0]   m_axis_tvalid,
  input   [ N0:0]   m_axis_tready,
  output  [ N2:0]   m_axis_tdata

);

  // internal signals

  wire              fifo_wr_rst_busy;
  wire              fifo_rd_rst_busy;
  wire              fifo_oflow;
  wire              fifo_uflow;
  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_write;
  wire              fifo_read;
  wire    [ N1:0]   fifo_din;
  wire    [ N1:0]   fifo_dout;
  wire    [ N0:0]   fir_ready;

  // input FIFO queue

  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE ("block"),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (S_TDATA_WIDTH),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("fwft"),
    .FIFO_READ_LATENCY (0),
    .READ_DATA_WIDTH (128),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (3),
    .WAKEUP_TIME (0)
  ) axis_sample_fifo (
    .rst (rst),
    .wr_clk (in_clk),
    .wr_en (fifo_write),
    .din (fifo_din),
    .full (fifo_full),
    .overflow (fifo_oflow),
    .prog_full (),
    .wr_data_count (),
    .almost_full (),
    .wr_ack (),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (clk),
    .rd_en (fifo_read),
    .dout (fifo_dout),
    .empty (fifo_empty),
    .underflow (fifo_uflow),
    .rd_rst_busy (fifo_rd_rst_busy),
    .prog_empty (),
    .rd_data_count (),
    .almost_empty (),
    .data_valid (),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0),
    .sbiterr (),
    .dbiterr ()
  );

  assign fifo_write = s_axis_tvalid;
  assign fifo_din = s_axis_tdata;
  assign s_axis_tready = ~fifo_full;
  assign fifo_read = &fir_ready;
$all_chunks
endmodule
""")


# FIR filter instance template
templ_fir_inst = Template("""
  // tag $inst

  generate
  if (DISABLE_MASK[$inst] == 1'b0) begin

  axis_xcorr_tag_$inst #()
  axis_xcorr_tag_$inst (
    .aclk (clk),
    .s_axis_data_tvalid (~fifo_empty),
    .s_axis_data_tready (fir_ready[$inst]),
    .s_axis_data_tdata (fifo_dout),
    .m_axis_data_tvalid (m_axis_tvalid[$inst]),
    .m_axis_data_tready (m_axis_tready[$inst]),
    .m_axis_data_tdata (m_axis_tdata[$end:$start])
  );

  end else begin

  assign fir_ready[$inst] = 1'b1;
  assign m_axis_tvalid[$inst] = 1'b0;
  assign m_axis_tdata[$end:$start] = {M_TDATA_WIDTH{1'b0}};

  end
  endgenerate
""")


def main(args):
    """
        Entry point.
    """

    num_tags = args.num_tags
    out_fname = args.out_file

    # perform intra-module substitutions
    all_chunks = ""
    for n in range(num_tags):
        chunk = templ_fir_inst.substitute({"inst": n,
                                           "start": 256*n,
                                           "end": 256*n+255})
        all_chunks += chunk

    # compile whole module
    module_out = templ_top.substitute({"num_tags": num_tags,
                                       "all_chunks": all_chunks})

    # write to output file
    with open(out_fname, "w") as f:
        f.write(module_out)


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
