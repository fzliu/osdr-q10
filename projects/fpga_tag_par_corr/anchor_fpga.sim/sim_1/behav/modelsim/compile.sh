#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Mentor Graphics ModelSim Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Tue Dec 11 10:46:47 CST 2018
# SW Build 2086221 on Fri Dec 15 20:54:30 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
# usage: compile.sh
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
ExecStep source anchor_top_tb_compile.do 2>&1 | tee -a compile.log
