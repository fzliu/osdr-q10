######################################################################
#
# File name : anchor_top_tb_simulate.do
# Created on: Sun Jan 06 19:28:54 CST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.anchor_top_tb xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {anchor_top_tb_wave.do}

view wave
view structure
view signals

do {anchor_top_tb.udo}

run 1000ns
