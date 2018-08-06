#!/usr/bin/env python

import sys

import numpy as np
from scipy.io import savemat

if __name__ == "__main__":

    in_path = sys.argv[1]
    out_path = sys.argv[2]

    data = np.fromfile(in_path, dtype=np.int16)
    data = np.left_shift(data, 4) / 2**4

    num_chan = 8
    data = data.reshape(num_chan, data.size / num_chan)
    chan0 = data[0] + 1j * data[1]
    chan1 = data[2] + 1j * data[3]
    chan2 = data[4] + 1j * data[5]
    chan3 = data[6] + 1j * data[7]

    savemat(out_path, {"chan0": chan0,
                       "chan1": chan1,
                       "chan2": chan2,
                       "chan3": chan3})
