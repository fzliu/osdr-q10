onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+math_mult_32 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.math_mult_32 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {math_mult_32.udo}

run -all

endsim

quit -force
