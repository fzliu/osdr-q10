#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
from string import Template

import numpy as np
from scipy.io import loadmat


# argparse
parser = argparse.ArgumentParser(description="Generate a correlators.vh Verilog header.")
parser.add_argument("-i", "--in-file", type=str, default="codes_gold_127.mat", help="path to bits")
parser.add_argument("-o", "--out-file", type=str, default="correlators.vh", help="output filename")


# module template
templ = Template("""
////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// List of correlators used by the system. Note: the zeroth correlator is at
// the bottom of the module.
//
////////////////////////////////////////////////////////////////////////////////

localparam            TOTAL_CORRS = $num_corrs,
localparam            CORR_LENGTH = $corr_length,
localparam            CORRS_WIDTH = TOTAL_CORRS * CORR_LENGTH,

localparam            L = CORR_LENGTH - 1,
localparam            W = CORRS_WIDTH - 1,

localparam  [  W:0]   CORRELATORS =
$correlators,
""")


def main(args):
    """
        Entry point.
    """

    templates = loadmat(args.in_file)["tag_ids"]
    (num_corrs, corr_length) = templates.shape

    corrs = "{"
    for bits in templates[::-1]:
        line = ""
        for bit in bits:
            line += "1'b{0}, ".format(bit)
        corrs += line + "\n "
    corrs = corrs[:-4]
    corrs += "}"

    # compile whole module
    module_out = templ.substitute({"num_corrs": num_corrs,
                                   "corr_length": corr_length,
                                   "correlators": corrs})

    # write to output file
    with open(args.out_file, "w") as f:
        f.write(module_out)


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
