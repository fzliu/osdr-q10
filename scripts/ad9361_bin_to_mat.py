#!/usr/bin/env python

import argparse
import sys

import numpy as np
from scipy.io import savemat

# argparse
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--in-file", type=str, required=True)
parser.add_argument("-o", "--out-path", type=str, required=True)
parser.add_argument("-n", "--num-batch", type=int, required=True)


N_CHAN = 8


def main(args):

    # load data as raw binary data from file
    data_all = np.fromfile(args.in_file, dtype=np.int16)
    data_all = np.left_shift(data_all, 4) / 2**4
    sublen = data_all.size / args.num_batch

    for n in range(args.num_batch):

        # split out data into individual channels
        data = data_all[n*sublen:(n+1)*sublen]

        #data = data.reshape(-1, N_CHAN).T
        #chans = data.astype(np.float64).view(np.complex128)

        data = data.reshape(N_CHAN, -1)
        chans = [data[i] + 1j*data[i+1] for i in range(0, N_CHAN, 2)]

        out_file = args.out_path + str(n) + ".mat"
        savemat(out_file, {"chan0": chans[0],
                           "chan1": chans[1],
                           "chan2": chans[2],
                           "chan3": chans[3]})


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
