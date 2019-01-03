######################################################################
#
# File name : anchor_top_tb_compile.do
# Created on: Thu Jan 03 10:30:40 CST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -64 -incr -work xil_defaultlib  "+incdir+../../../../../../firmware/fpga/util/incl" "+incdir+../../../../../../firmware/fpga/xcorr" \
"../../../../../../firmware/fpga/ad9361/ad9361_cmos_if.v" \
"../../../../../../firmware/fpga/ad9361/ad9361_dual.v" \
"../../../../../../firmware/fpga/ad9361/ad9361_dual_axis.v" \
"../../../../../../firmware/fpga/ad9361/ad9361_dual_spi.v" \
"../../../../../../firmware/fpga/ad9361/ad9361_samp_filt.v" \
"../../../../anchor_fpga.srcs/sources_1/new/anchor_clk_gen.v" \
"../../../../anchor_fpga.srcs/sources_1/new/anchor_ext_sync.v" \
"../../../../anchor_fpga.srcs/sources_1/new/anchor_top.v" \
"../../../../../../firmware/fpga/xcorr/axis_bit_corr.v" \
"../../../../../../firmware/fpga/peak/axis_cabs_serial.v" \
"../../../../../../firmware/fpga/util/axis/axis_distrib.v" \
"../../../../../../firmware/fpga/util/axis/axis_fan_in.v" \
"../../../../../../firmware/fpga/util/axis/xilinx/axis_fifo_async.v" \
"../../../../../../firmware/fpga/util/axis/xilinx/axis_fifo_sync.v" \
"../../../../../../firmware/fpga/peak/axis_peak_detn.v" \
"../../../../../../firmware/fpga/util/axis/xilinx/axis_to_mem.v" \
"../../../../../../firmware/fpga/util/math/counter.v" \
"../../../../../../firmware/fpga/util/filt/filt_boxcar.v" \
"../../../../../../firmware/fpga/util/math/xilinx/math_add_96.v" \
"../../../../../../firmware/fpga/util/math/math_cabs_32.v" \
"../../../../../../firmware/fpga/util/math/math_log2_64.v" \
"../../../../../../firmware/fpga/util/math/xilinx/math_mult_35.v" \
"../../../../../../firmware/fpga/util/math/math_pow2_12.v" \
"../../../../../../firmware/fpga/util/misc/oh_to_bin.v" \
"../../../../../../firmware/fpga/util/misc/xilinx/shift_reg.v" \
"../../../../../../firmware/fpga/mpu_if/tag_data_buff.v" \
"../../../../anchor_fpga.srcs/sim_1/new/anchor_top_tb.v" \


# compile glbl module
vlog -work xil_defaultlib "glbl.v"

