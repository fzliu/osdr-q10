
# user constraints


# datasheet and programmable constraints

set AD9361_CLOCK_PERIOD 6.060
set AD9361_CLOCK_JITTER [expr 0.1 * $AD9361_CLOCK_PERIOD]

set AD9361_TX_DATA_DELAY 0.300
set AD9361_TX_MIN_DELAY [expr 0.000 + $AD9361_TX_DATA_DELAY]
set AD9361_TX_MAX_DELAY [expr 1.000 + $AD9361_TX_DATA_DELAY]
set AD9361_RX_MIN_DELAY 0.250
set AD9361_RX_MAX_DELAY 1.250

set FT600_CLOCK_PERIOD 15.000
set FT600_CLOCK_JITTER 0.800

set FT600_RX_MIN_DELAY 3.500
set FT600_RX_MAX_DELAY 7.000
set FT600_TX_MIN_DELAY -4.800
set FT600_TX_MAX_DELAY 1.000

# create clocks

create_clock -period $AD9361_CLOCK_PERIOD -name a_data_clk [get_ports a_data_clk_p]
create_clock -period $AD9361_CLOCK_PERIOD -name b_data_clk [get_ports b_data_clk_p]
create_clock -period $FT600_CLOCK_PERIOD -name usb_clk [get_ports usb_clk]
create_clock -period 40.000 -name ref_clk [get_ports ref_clk]
create_clock -period 10.000 -name ebi_clk [get_ports ebi_clk]

set_input_jitter [get_clocks a_data_clk] $AD9361_CLOCK_JITTER
set_input_jitter [get_clocks b_data_clk] $AD9361_CLOCK_JITTER
set_input_jitter [get_clocks usb_clk] $FT600_CLOCK_JITTER

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a_data_clk_p]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets b_data_clk_p]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ref_clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets usb_clk]

create_generated_clock -name a_fb_clk -source [get_ports a_data_clk_p] -divide_by 1 [get_ports a_fb_clk_p]
create_generated_clock -name b_fb_clk -source [get_ports b_data_clk_p] -divide_by 1 [get_ports b_fb_clk_p]

create_generated_clock -name fb_clk_ebi [get_pins {osdr_q10_clk_gen/clock_gen_ebi/plle2_adv/CLKFBOUT}]
create_generated_clock -name fb_clk_ref [get_pins {osdr_q10_clk_gen/clock_gen_ref/plle2_adv/CLKFBOUT}]
create_generated_clock -name fb_clk_usb [get_pins {osdr_q10_clk_gen/clock_gen_usb/plle2_adv/CLKFBOUT}]
create_generated_clock -name fb_clk_data_a [get_pins {ad9361_lvds_if_a/clock_gen/mmcme2_adv/CLKFBOUT}]
create_generated_clock -name fb_clk_data_b [get_pins {ad9361_lvds_if_b/clock_gen/mmcme2_adv/CLKFBOUT}]
create_generated_clock -name clk_sig_a [get_pins {ad9361_lvds_if_a/clock_gen/mmcme2_adv/CLKOUT0}]
create_generated_clock -name clk_sig_b [get_pins {ad9361_lvds_if_b/clock_gen/mmcme2_adv/CLKOUT0}]
create_generated_clock -name c_clk [get_pins {osdr_q10_clk_gen/clock_gen_ebi/plle2_adv/CLKOUT0}]
create_generated_clock -name r_clk [get_pins {osdr_q10_clk_gen/clock_gen_ref/plle2_adv/CLKOUT0}]
create_generated_clock -name u_clk [get_pins {osdr_q10_clk_gen/clock_gen_usb/plle2_adv/CLKOUT0}]
create_generated_clock -name delay_clk [get_pins {osdr_q10_clk_gen/clock_gen_ref/plle2_adv/CLKOUT1}]
create_generated_clock -name s_clk [get_pins {ad9361_lvds_if_a/clock_gen/mmcme2_adv/CLKOUT1}]
create_generated_clock -name d_clk_a [get_pins {ad9361_lvds_if_a/clock_gen/clock_buf_0/BUFR/O}]
create_generated_clock -name d_clk_b [get_pins {ad9361_lvds_if_b/clock_gen/clock_buf_0/BUFR/O}]

set_multicycle_path 2 -from [get_clocks d_clk_b] -to [get_clocks s_clk]

# FPGA configuration

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# oscillator and global enable

set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A20} [get_ports ref_clk]
#set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN E23} [get_ports rst]

# AD9361_A physical interface

set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN B10  DIFF_TERM FALSE  IOB TRUE} [get_ports a_fb_clk_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN E10  DIFF_TERM FALSE  IOB TRUE} [get_ports a_tx_frame_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN C12  DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[0]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN H12  DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[1]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN A9   DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[2]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN B12  DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[3]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN A13  DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[4]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G12  DIFF_TERM FALSE  IOB TRUE} [get_ports {a_tx_data_p[5]}]

set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports a_fb_clk_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports a_tx_frame_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports {a_tx_data_n[*]}]

set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN C9   DIFF_TERM TRUE           } [get_ports a_data_clk_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN E11  DIFF_TERM TRUE   IOB TRUE} [get_ports a_rx_frame_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN D9   DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[5]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G11  DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[4]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN F9   DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[3]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN J11  DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[2]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN H9   DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[1]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G10  DIFF_TERM TRUE   IOB TRUE} [get_ports {a_rx_data_p[0]}]

set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports a_data_clk_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports a_rx_frame_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports {a_rx_data_n[*]}]

# AD9361_B physical interface

set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN C17  DIFF_TERM FALSE  IOB TRUE} [get_ports b_fb_clk_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN B17  DIFF_TERM FALSE  IOB TRUE} [get_ports b_tx_frame_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN D19  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[5]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN F19  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[4]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G19  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[3]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN M17  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[2]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN H19  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[1]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN L19  DIFF_TERM FALSE  IOB TRUE} [get_ports {b_tx_data_p[0]}]

set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports b_fb_clk_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports b_tx_frame_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports {b_tx_data_n[*]}]

# DEBUG
#set_property -dict {IOSTANDARD LVDS_25 PACKAGE_PIN E18} [get_ports b_data_clk_p]
#set_property -dict {IOSTANDARD LVDS_25 PACKAGE_PIN A18} [get_ports {b_rx_data_p[0]}]
# END DEBUG
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN A18  DIFF_TERM TRUE           } [get_ports b_data_clk_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN C16  DIFF_TERM TRUE   IOB TRUE} [get_ports b_rx_frame_p]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G15  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[5]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN H16  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[4]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN L17  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[3]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN G17  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[2]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN C19  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[1]}]
set_property -dict {IOSTANDARD LVDS_25   PACKAGE_PIN E18  DIFF_TERM TRUE   IOB TRUE} [get_ports {b_rx_data_p[0]}]

set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports b_data_clk_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports b_rx_frame_n]
set_property -dict {IOSTANDARD LVDS_25                                             } [get_ports {b_rx_data_n[*]}]

# AD9361_A control signals

set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN C14} [get_ports a_resetb]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN F14} [get_ports a_enable]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN B14} [get_ports a_txnrx]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN D13} [get_ports a_spi_cs]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN A14} [get_ports a_spi_di]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN F13} [get_ports a_spi_do]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN C13} [get_ports a_spi_sck]

# AD9361_B control signals

set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN D15} [get_ports b_resetb]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN E17} [get_ports b_enable]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN J16} [get_ports b_txnrx]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN E16} [get_ports b_spi_cs]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN J15} [get_ports b_spi_di]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN E15} [get_ports b_spi_do]
set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN D16} [get_ports b_spi_sck]

# common control signals

set_property -dict {IOSTANDARD LVCMOS25  PACKAGE_PIN A15} [get_ports sync_out]

# voltage level shifting for SPI interfaces

set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN J23} [get_ports reset_a]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN H22} [get_ports reset_b]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN L22} [get_ports spi_cs_a]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN E22} [get_ports spi_cs_b]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN K22} [get_ports spi_miso]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN F22} [get_ports spi_mosi]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN L23} [get_ports spi_sck]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN G24} [get_ports sync_in]

# microcontroller data interface

set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN N24} [get_ports {ebi_addr[14]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN N23} [get_ports {ebi_addr[13]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T25} [get_ports {ebi_addr[12]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R25} [get_ports {ebi_addr[11]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R22} [get_ports {ebi_addr[10]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R26} [get_ports {ebi_addr[9]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P26} [get_ports {ebi_addr[8]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M25} [get_ports {ebi_addr[7]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN N26} [get_ports {ebi_addr[6]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN K25} [get_ports {ebi_addr[5]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P25} [get_ports {ebi_addr[4]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P23} [get_ports {ebi_addr[3]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M26} [get_ports {ebi_addr[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN L25} [get_ports {ebi_addr[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN K26} [get_ports {ebi_addr[0]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R21} [get_ports ebi_clk]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN N19} [get_ports ebi_nrde]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P19} [get_ports ebi_nwre]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R20} [get_ports {ebi_data[15]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P24} [get_ports {ebi_data[14]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN R23} [get_ports {ebi_data[13]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T23} [get_ports {ebi_data[12]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T24} [get_ports {ebi_data[11]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T20} [get_ports {ebi_data[10]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T19} [get_ports {ebi_data[9]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M20} [get_ports {ebi_data[8]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN N22} [get_ports {ebi_data[7]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M22} [get_ports {ebi_data[6]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P21} [get_ports {ebi_data[5]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN T22} [get_ports {ebi_data[4]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN P20} [get_ports {ebi_data[3]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M24} [get_ports {ebi_data[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN L24} [get_ports {ebi_data[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN M21} [get_ports {ebi_data[0]}]

# USB3 interface

set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AB4} [get_ports usb_clk]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN V1 } [get_ports {usb_adbus[15]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN V2 } [get_ports {usb_adbus[14]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN W1 } [get_ports {usb_adbus[13]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN Y1 } [get_ports {usb_adbus[12]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN Y2 } [get_ports {usb_adbus[11]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AA2} [get_ports {usb_adbus[10]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AB1} [get_ports {usb_adbus[9]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AB2} [get_ports {usb_adbus[8]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AE3} [get_ports {usb_adbus[7]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AC1} [get_ports {usb_adbus[6]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AE2} [get_ports {usb_adbus[5]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AD1} [get_ports {usb_adbus[4]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AF2} [get_ports {usb_adbus[3]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AC2} [get_ports {usb_adbus[2]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AF3} [get_ports {usb_adbus[1]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN AE1} [get_ports {usb_adbus[0]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN U6 } [get_ports {usb_be[1]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN U1 } [get_ports {usb_be[0]}]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN V6 } [get_ports usb_rxf_n]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN U2 } [get_ports usb_txe_n]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN V4 } [get_ports usb_rd_n]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN U5 } [get_ports usb_wr_n]
set_property -dict {IOSTANDARD LVCMOS18  PACKAGE_PIN U4 } [get_ports usb_oe_n]

# LEDs

set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN D24} [get_ports {led_out[7]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN C24} [get_ports {led_out[6]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN B24} [get_ports {led_out[5]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A24} [get_ports {led_out[4]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A23} [get_ports {led_out[3]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A22} [get_ports {led_out[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN H21} [get_ports {led_out[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN J21} [get_ports {led_out[0]}]

# AD9361_A interface timing

set_output_delay -clock [get_clocks a_fb_clk] -max -add_delay $AD9361_TX_MAX_DELAY [get_ports {a_tx_frame* {a_tx_data_*[*]}}]
set_output_delay -clock [get_clocks a_fb_clk] -min -add_delay $AD9361_TX_MIN_DELAY  [get_ports {a_tx_frame* {a_tx_data_*[*]}}]
set_output_delay -clock [get_clocks a_fb_clk] -clock_fall -max -add_delay $AD9361_TX_MAX_DELAY [get_ports {a_tx_frame* {a_tx_data_*[*]}}]
set_output_delay -clock [get_clocks a_fb_clk] -clock_fall -min -add_delay $AD9361_TX_MIN_DELAY [get_ports {a_tx_frame* {a_tx_data_*[*]}}]

set_input_delay -clock [get_clocks a_data_clk] -max -add_delay $AD9361_RX_MAX_DELAY [get_ports {a_rx_frame_* {a_rx_data_*[*]}}]
set_input_delay -clock [get_clocks a_data_clk] -min -add_delay $AD9361_RX_MIN_DELAY [get_ports {a_rx_frame_* {a_rx_data_*[*]}}]
set_input_delay -clock [get_clocks a_data_clk] -clock_fall -max -add_delay $AD9361_RX_MAX_DELAY [get_ports {a_rx_frame_* {a_rx_data_*[*]}}]
set_input_delay -clock [get_clocks a_data_clk] -clock_fall -min -add_delay $AD9361_RX_MIN_DELAY [get_ports {a_rx_frame_* {a_rx_data_*[*]}}]

set_output_delay -clock [get_clocks a_data_clk] -max $AD9361_TX_MAX_DELAY [get_ports a_enable]
set_output_delay -clock [get_clocks a_data_clk] -min $AD9361_TX_MIN_DELAY [get_ports a_enable]

# AD9361_B interface timing

set_output_delay -clock [get_clocks b_fb_clk] -max -add_delay $AD9361_TX_MAX_DELAY [get_ports {b_tx_frame* {b_tx_data_*[*]}}]
set_output_delay -clock [get_clocks b_fb_clk] -min -add_delay $AD9361_TX_MIN_DELAY  [get_ports {b_tx_frame* {b_tx_data_*[*]}}]
set_output_delay -clock [get_clocks b_fb_clk] -clock_fall -max -add_delay $AD9361_TX_MAX_DELAY [get_ports {b_tx_frame* {b_tx_data_*[*]}}]
set_output_delay -clock [get_clocks b_fb_clk] -clock_fall -min -add_delay $AD9361_TX_MIN_DELAY [get_ports {b_tx_frame* {b_tx_data_*[*]}}]

set_input_delay -clock [get_clocks b_data_clk] -max -add_delay $AD9361_RX_MAX_DELAY [get_ports {b_rx_frame_* {b_rx_data_*[*]}}]
set_input_delay -clock [get_clocks b_data_clk] -min -add_delay $AD9361_RX_MIN_DELAY [get_ports {b_rx_frame_* {b_rx_data_*[*]}}]
set_input_delay -clock [get_clocks b_data_clk] -clock_fall -max -add_delay $AD9361_RX_MAX_DELAY [get_ports {b_rx_frame_* {b_rx_data_*[*]}}]
set_input_delay -clock [get_clocks b_data_clk] -clock_fall -min -add_delay $AD9361_RX_MIN_DELAY [get_ports {b_rx_frame_* {b_rx_data_*[*]}}]

set_output_delay -clock [get_clocks b_data_clk] -max $AD9361_TX_MAX_DELAY [get_ports b_enable]
set_output_delay -clock [get_clocks b_data_clk] -min $AD9361_TX_MIN_DELAY [get_ports b_enable]

# FT600 interface timing

set_output_delay -clock [get_clocks usb_clk] -max $FT600_TX_MAX_DELAY [get_ports {usb_rd_n usb_wr_n usb_oe_n}]
set_output_delay -clock [get_clocks usb_clk] -min $FT600_TX_MIN_DELAY [get_ports {usb_rd_n usb_wr_n usb_oe_n}]
set_output_delay -clock [get_clocks usb_clk] -max $FT600_TX_MAX_DELAY [get_ports {{usb_adbus[*]} {usb_be[*]}}]
set_output_delay -clock [get_clocks usb_clk] -min $FT600_TX_MIN_DELAY [get_ports {{usb_adbus[*]} {usb_be[*]}}]

set_input_delay -clock [get_clocks usb_clk] -max $FT600_RX_MAX_DELAY [get_ports {usb_rxf_n usb_txe_n}]
set_input_delay -clock [get_clocks usb_clk] -min $FT600_RX_MIN_DELAY [get_ports {usb_rxf_n usb_txe_n}]
set_input_delay -clock [get_clocks usb_clk] -max $FT600_RX_MAX_DELAY [get_ports {{usb_adbus[*]} {usb_be[*]}}]
set_input_delay -clock [get_clocks usb_clk] -min $FT600_RX_MIN_DELAY [get_ports {{usb_adbus[*]} {usb_be[*]}}]

# EBI interface timing

set_input_delay -clock [get_clocks ebi_clk] -min 0.000 [get_ports {{ebi_data[*]} {ebi_addr[*]} ebi_nrde ebi_nwre}]
set_input_delay -clock [get_clocks ebi_clk] -max 4.000 [get_ports {{ebi_data[*]} {ebi_addr[*]} ebi_nrde ebi_nwre}]
set_output_delay -clock [get_clocks ebi_clk] -min -2.000 [get_ports {ebi_data[*]}]
set_output_delay -clock [get_clocks ebi_clk] -max 3.000 [get_ports {ebi_data[*]}]

# untimed signals

set_output_delay -clock [get_clocks ref_clk] -min -add_delay -5.000 [get_ports sync_out]
set_output_delay -clock [get_clocks ref_clk] -max -add_delay 5.000 [get_ports sync_out]

set_false_path -from [get_clocks *] -to [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks ebi_clk] -min 0.000 [get_ports {led_out[*]}]
set_output_delay -clock [get_clocks ebi_clk] -max 1.000 [get_ports {led_out[*]}]

set_false_path -from [get_ports sync_in] -to [get_clocks *]
set_input_delay -clock [get_clocks ebi_clk] -min 0.000 [get_ports sync_in]
set_input_delay -clock [get_clocks ebi_clk] -max 1.000 [get_ports sync_in]
