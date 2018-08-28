onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib math_mult_32_opt

do {wave.do}

view wave
view structure
view signals

do {math_mult_32.udo}

run -all

quit -force
