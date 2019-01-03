#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Mentor Graphics ModelSim Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Thu Jan 03 10:30:41 CST 2019
# SW Build 2086221 on Fri Dec 15 20:54:30 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
bin_path="/opt/intelFPGA/18.1/modelsim_ase/bin"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $bin_path/vsim -64  -do "do {anchor_top_tb_simulate.do}" -l simulate.log
