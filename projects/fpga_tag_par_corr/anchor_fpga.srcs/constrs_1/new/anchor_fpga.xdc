
set_property USE_DSP48 YES [get_cells -hier -regexp .*axis_peak_detn/filt_boxcar]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property PACKAGE_PIN AA3 [get_ports clk]
set_property IOSTANDARD LVCMOS12 [get_ports clk]

set_property PACKAGE_PIN N26 [get_ports {ebi_data[0]}]
set_property PACKAGE_PIN M26 [get_ports {ebi_data[1]}]
set_property PACKAGE_PIN K26 [get_ports {ebi_data[2]}]
set_property PACKAGE_PIN L25 [get_ports {ebi_data[3]}]
set_property PACKAGE_PIN R25 [get_ports {ebi_data[4]}]
set_property PACKAGE_PIN M25 [get_ports {ebi_data[5]}]
set_property PACKAGE_PIN P26 [get_ports {ebi_data[6]}]
set_property PACKAGE_PIN K25 [get_ports {ebi_data[7]}]
set_property PACKAGE_PIN R26 [get_ports {ebi_data[8]}]
set_property PACKAGE_PIN P25 [get_ports {ebi_data[9]}]
set_property PACKAGE_PIN T24 [get_ports {ebi_data[10]}]
set_property PACKAGE_PIN L24 [get_ports {ebi_data[11]}]
set_property PACKAGE_PIN T25 [get_ports {ebi_data[12]}]
set_property PACKAGE_PIN M24 [get_ports {ebi_data[13]}]
set_property PACKAGE_PIN N24 [get_ports {ebi_data[14]}]
set_property PACKAGE_PIN P24 [get_ports {ebi_data[15]}]
set_property PACKAGE_PIN T17 [get_ports ebi_nrde]
set_property PACKAGE_PIN N18 [get_ports ebi_ready]
set_property DRIVE 8 [get_ports {ebi_data[15]}]
set_property DRIVE 8 [get_ports {ebi_data[14]}]
set_property DRIVE 8 [get_ports {ebi_data[13]}]
set_property DRIVE 8 [get_ports {ebi_data[12]}]
set_property DRIVE 8 [get_ports {ebi_data[11]}]
set_property DRIVE 8 [get_ports {ebi_data[10]}]
set_property DRIVE 8 [get_ports {ebi_data[9]}]
set_property DRIVE 8 [get_ports {ebi_data[8]}]
set_property DRIVE 8 [get_ports {ebi_data[7]}]
set_property DRIVE 8 [get_ports {ebi_data[6]}]
set_property DRIVE 8 [get_ports {ebi_data[5]}]
set_property DRIVE 8 [get_ports {ebi_data[4]}]
set_property DRIVE 8 [get_ports {ebi_data[3]}]
set_property DRIVE 8 [get_ports {ebi_data[2]}]
set_property DRIVE 8 [get_ports {ebi_data[1]}]
set_property DRIVE 8 [get_ports {ebi_data[0]}]
set_property DRIVE 8 [get_ports ebi_ready]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ebi_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports ebi_nrde]
set_property IOSTANDARD LVCMOS33 [get_ports ebi_ready]
set_property SLEW FAST [get_ports ebi_ready]
set_property SLEW FAST [get_ports {ebi_data[15]}]
set_property SLEW FAST [get_ports {ebi_data[14]}]
set_property SLEW FAST [get_ports {ebi_data[13]}]
set_property SLEW FAST [get_ports {ebi_data[12]}]
set_property SLEW FAST [get_ports {ebi_data[11]}]
set_property SLEW FAST [get_ports {ebi_data[10]}]
set_property SLEW FAST [get_ports {ebi_data[9]}]
set_property SLEW FAST [get_ports {ebi_data[8]}]
set_property SLEW FAST [get_ports {ebi_data[7]}]
set_property SLEW FAST [get_ports {ebi_data[6]}]
set_property SLEW FAST [get_ports {ebi_data[5]}]
set_property SLEW FAST [get_ports {ebi_data[4]}]
set_property SLEW FAST [get_ports {ebi_data[3]}]
set_property SLEW FAST [get_ports {ebi_data[2]}]
set_property SLEW FAST [get_ports {ebi_data[1]}]
set_property SLEW FAST [get_ports {ebi_data[0]}]

set_property PACKAGE_PIN D23 [get_ports spi_sck]
set_property PACKAGE_PIN D25 [get_ports spi_mosi]
set_property PACKAGE_PIN D26 [get_ports spi_miso]
set_property PACKAGE_PIN C26 [get_ports spi_cs_a]
set_property PACKAGE_PIN E25 [get_ports spi_cs_b]
set_property PACKAGE_PIN B10 [get_ports a_spi_di]
set_property PACKAGE_PIN F10 [get_ports a_spi_do]
set_property PACKAGE_PIN F19 [get_ports b_spi_do]
set_property PACKAGE_PIN E20 [get_ports b_spi_di]
set_property PACKAGE_PIN E10 [get_ports a_spi_cs]
set_property PACKAGE_PIN E12 [get_ports a_spi_sck]
set_property PACKAGE_PIN F20 [get_ports b_spi_sck]
set_property PACKAGE_PIN G19 [get_ports b_spi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs_a]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs_b]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sck]
set_property IOSTANDARD LVCMOS25 [get_ports a_spi_di]
set_property IOSTANDARD LVCMOS25 [get_ports a_spi_do]
set_property IOSTANDARD LVCMOS25 [get_ports a_spi_sck]
set_property IOSTANDARD LVCMOS25 [get_ports b_spi_cs]
set_property IOSTANDARD LVCMOS25 [get_ports b_spi_di]
set_property IOSTANDARD LVCMOS25 [get_ports b_spi_do]
set_property IOSTANDARD LVCMOS25 [get_ports b_spi_sck]
set_property IOSTANDARD LVCMOS25 [get_ports a_spi_cs]

set_property PACKAGE_PIN F25 [get_ports reset_a]
set_property PACKAGE_PIN A13 [get_ports a_resetb]
set_property PACKAGE_PIN E26 [get_ports reset_b]
set_property PACKAGE_PIN J19 [get_ports b_resetb]
set_property PACKAGE_PIN J26 [get_ports sync_in]
set_property PACKAGE_PIN A15 [get_ports sync_out]
set_property PACKAGE_PIN H19 [get_ports b_enable]
set_property PACKAGE_PIN A10 [get_ports a_enable]
set_property PACKAGE_PIN D13 [get_ports a_txnrx]
set_property PACKAGE_PIN D20 [get_ports b_txnrx]
set_property IOSTANDARD LVCMOS25 [get_ports a_enable]
set_property IOSTANDARD LVCMOS25 [get_ports b_enable]
set_property IOSTANDARD LVCMOS25 [get_ports a_txnrx]
set_property IOSTANDARD LVCMOS25 [get_ports b_txnrx]
set_property IOSTANDARD LVCMOS25 [get_ports sync_out]
set_property IOSTANDARD LVCMOS33 [get_ports sync_in]
set_property IOSTANDARD LVCMOS33 [get_ports reset_a]
set_property IOSTANDARD LVCMOS25 [get_ports a_resetb]
set_property IOSTANDARD LVCMOS33 [get_ports reset_b]
set_property IOSTANDARD LVCMOS25 [get_ports b_resetb]
set_property SLEW FAST [get_ports a_spi_cs]
set_property SLEW FAST [get_ports a_spi_di]
set_property SLEW FAST [get_ports a_spi_sck]
set_property SLEW FAST [get_ports a_txnrx]
set_property SLEW FAST [get_ports b_enable]
set_property SLEW FAST [get_ports b_resetb]
set_property SLEW FAST [get_ports b_spi_cs]
set_property SLEW FAST [get_ports b_spi_di]
set_property SLEW FAST [get_ports b_spi_sck]
set_property SLEW FAST [get_ports b_txnrx]
set_property SLEW FAST [get_ports spi_miso]
set_property SLEW FAST [get_ports sync_out]
set_property SLEW FAST [get_ports a_resetb]
set_property SLEW FAST [get_ports a_enable]

set_property PACKAGE_PIN C12 [get_ports a_rx_clk_in]
set_property PACKAGE_PIN D10 [get_ports a_rx_frame_in]
set_property PACKAGE_PIN D18 [get_ports b_rx_frame_in]
set_property PACKAGE_PIN E18 [get_ports b_rx_clk_in]
set_property PACKAGE_PIN A9 [get_ports {a_rx_data_p0[0]}]
set_property PACKAGE_PIN B12 [get_ports {a_rx_data_p0[1]}]
set_property PACKAGE_PIN D11 [get_ports {a_rx_data_p0[2]}]
set_property PACKAGE_PIN C13 [get_ports {a_rx_data_p0[3]}]
set_property PACKAGE_PIN C11 [get_ports {a_rx_data_p0[4]}]
set_property PACKAGE_PIN F14 [get_ports {a_rx_data_p0[5]}]
set_property PACKAGE_PIN A12 [get_ports {a_rx_data_p0[6]}]
set_property PACKAGE_PIN G14 [get_ports {a_rx_data_p0[7]}]
set_property PACKAGE_PIN B14 [get_ports {a_rx_data_p0[8]}]
set_property PACKAGE_PIN C14 [get_ports {a_rx_data_p0[9]}]
set_property PACKAGE_PIN A14 [get_ports {a_rx_data_p0[10]}]
set_property PACKAGE_PIN D14 [get_ports {a_rx_data_p0[11]}]
set_property PACKAGE_PIN G10 [get_ports {a_rx_data_p1[0]}]
set_property PACKAGE_PIN F9 [get_ports {a_rx_data_p1[1]}]
set_property PACKAGE_PIN G11 [get_ports {a_rx_data_p1[2]}]
set_property PACKAGE_PIN G9 [get_ports {a_rx_data_p1[3]}]
set_property PACKAGE_PIN H9 [get_ports {a_rx_data_p1[4]}]
set_property PACKAGE_PIN H12 [get_ports {a_rx_data_p1[5]}]
set_property PACKAGE_PIN H11 [get_ports {a_rx_data_p1[6]}]
set_property PACKAGE_PIN J10 [get_ports {a_rx_data_p1[7]}]
set_property PACKAGE_PIN J8 [get_ports {a_rx_data_p1[8]}]
set_property PACKAGE_PIN J11 [get_ports {a_rx_data_p1[9]}]
set_property PACKAGE_PIN J13 [get_ports {a_rx_data_p1[10]}]
set_property PACKAGE_PIN H13 [get_ports {a_rx_data_p1[11]}]
set_property PACKAGE_PIN H18 [get_ports {b_rx_data_p0[0]}]
set_property PACKAGE_PIN G16 [get_ports {b_rx_data_p0[1]}]
set_property PACKAGE_PIN G17 [get_ports {b_rx_data_p0[2]}]
set_property PACKAGE_PIN J16 [get_ports {b_rx_data_p0[3]}]
set_property PACKAGE_PIN H17 [get_ports {b_rx_data_p0[4]}]
set_property PACKAGE_PIN J15 [get_ports {b_rx_data_p0[5]}]
set_property PACKAGE_PIN F18 [get_ports {b_rx_data_p0[6]}]
set_property PACKAGE_PIN H16 [get_ports {b_rx_data_p0[7]}]
set_property PACKAGE_PIN E17 [get_ports {b_rx_data_p0[8]}]
set_property PACKAGE_PIN E16 [get_ports {b_rx_data_p0[9]}]
set_property PACKAGE_PIN D19 [get_ports {b_rx_data_p0[10]}]
set_property PACKAGE_PIN C19 [get_ports {b_rx_data_p0[11]}]
set_property PACKAGE_PIN B19 [get_ports {b_rx_data_p1[0]}]
set_property PACKAGE_PIN C18 [get_ports {b_rx_data_p1[1]}]
set_property PACKAGE_PIN A18 [get_ports {b_rx_data_p1[2]}]
set_property PACKAGE_PIN A19 [get_ports {b_rx_data_p1[3]}]
set_property PACKAGE_PIN A17 [get_ports {b_rx_data_p1[4]}]
set_property PACKAGE_PIN C17 [get_ports {b_rx_data_p1[5]}]
set_property PACKAGE_PIN C16 [get_ports {b_rx_data_p1[6]}]
set_property PACKAGE_PIN D16 [get_ports {b_rx_data_p1[7]}]
set_property PACKAGE_PIN B16 [get_ports {b_rx_data_p1[8]}]
set_property PACKAGE_PIN E15 [get_ports {b_rx_data_p1[9]}]
set_property PACKAGE_PIN D15 [get_ports {b_rx_data_p1[10]}]
set_property PACKAGE_PIN F15 [get_ports {b_rx_data_p1[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports a_rx_clk_in]
set_property IOSTANDARD LVCMOS25 [get_ports a_rx_frame_in]
set_property IOSTANDARD LVCMOS25 [get_ports b_rx_clk_in]
set_property IOSTANDARD LVCMOS25 [get_ports b_rx_frame_in]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p0[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {a_rx_data_p1[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p0[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {b_rx_data_p1[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[7]}]
set_property PACKAGE_PIN J21 [get_ports {led_out[0]}]
set_property PACKAGE_PIN H21 [get_ports {led_out[1]}]
set_property PACKAGE_PIN K22 [get_ports {led_out[2]}]
set_property PACKAGE_PIN L22 [get_ports {led_out[3]}]
set_property PACKAGE_PIN A24 [get_ports {led_out[4]}]
set_property PACKAGE_PIN B24 [get_ports {led_out[5]}]
set_property PACKAGE_PIN C24 [get_ports {led_out[6]}]
set_property PACKAGE_PIN D24 [get_ports {led_out[7]}]
set_property SLEW FAST [get_ports {led_out[0]}]
set_property SLEW FAST [get_ports {led_out[1]}]
set_property SLEW FAST [get_ports {led_out[2]}]
set_property SLEW FAST [get_ports {led_out[3]}]
set_property SLEW FAST [get_ports {led_out[4]}]
set_property SLEW FAST [get_ports {led_out[5]}]
set_property SLEW FAST [get_ports {led_out[6]}]
set_property SLEW FAST [get_ports {led_out[7]}]

create_clock -period 20.000 -name a_rx_clk_in -waveform {0.000 10.000} [get_ports a_rx_clk_in]
create_clock -period 20.000 -name {VIRTUAL_pll_out[0]} -waveform {0.000 10.000}
create_clock -period 10.000 -name {VIRTUAL_pll_out[1]} -waveform {0.000 5.000}
create_clock -period 2.500 -name {VIRTUAL_pll_out[2]} -waveform {0.000 1.250}
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 0.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 1.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 1.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -min -add_delay 0.000 [get_ports ebi_nrde]
set_input_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -max -add_delay 1.000 [get_ports ebi_nrde]

set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -min -add_delay 0.000 [get_ports {ebi_data[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -max -add_delay 1.000 [get_ports {ebi_data[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -min -add_delay 0.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -max -add_delay 1.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -min -add_delay 0.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -max -add_delay 1.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[2]}] -min -add_delay 0.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[2]}] -max -add_delay 1.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -min -add_delay 0.000 [get_ports a_enable]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -max -add_delay 1.000 [get_ports a_enable]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -min -add_delay 0.000 [get_ports b_enable]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[0]}] -max -add_delay 1.000 [get_ports b_enable]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -min -add_delay 0.000 [get_ports ebi_ready]
set_output_delay -clock [get_clocks {VIRTUAL_pll_out[1]}] -max -add_delay 1.000 [get_ports ebi_ready]

set_clock_groups -name sys_ss_async0 -asynchronous -group [get_clocks -include_generated_clocks a_rx_clk_in] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[0]}]
set_clock_groups -name sys_ss_async1 -asynchronous -group [get_clocks -include_generated_clocks a_rx_clk_in] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[1]}]
set_clock_groups -name sys_ss_async2 -asynchronous -group [get_clocks -include_generated_clocks a_rx_clk_in] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[2]}]
set_clock_groups -name sys_ss_async3 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[0]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[0]}]
set_clock_groups -name sys_ss_async4 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[0]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[1]}]
set_clock_groups -name sys_ss_async5 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[0]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[2]}]
set_clock_groups -name sys_ss_async6 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[1]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[0]}]
set_clock_groups -name sys_ss_async7 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[1]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[1]}]
set_clock_groups -name sys_ss_async8 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[1]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[2]}]
set_clock_groups -name sys_ss_async9 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[2]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[0]}]
set_clock_groups -name sys_ss_async10 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[2]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[1]}]
set_clock_groups -name sys_ss_async11 -asynchronous -group [get_clocks -include_generated_clocks {pll_out[2]}] -group [get_clocks -include_generated_clocks {VIRTUAL_pll_out[2]}]
