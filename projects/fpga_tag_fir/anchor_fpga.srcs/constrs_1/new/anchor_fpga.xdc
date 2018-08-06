create_clock -period 20.000 -name a_rx_clk_in -waveform {0.000 10.000} [get_ports a_rx_clk_in]
create_clock -period 3.117 -name VIRTUAL_c_clk_anchor_top_clock -waveform {0.000 1.558}
create_clock -period 10.000 -name VIRTUAL_m_clk_anchor_top_clock -waveform {0.000 5.000}
set_clock_groups -name sys_ss_async0 -asynchronous -group [get_clocks -include_generated_clocks a_rx_clk_in] -group [get_clocks -include_generated_clocks VIRTUAL_c_clk_anchor_top_clock]
set_clock_groups -name sys_ss_async1 -asynchronous -group [get_clocks -include_generated_clocks a_rx_clk_in] -group [get_clocks -include_generated_clocks c_clk_anchor_top_clock]
set_clock_groups -name sys_ss_async2 -asynchronous -group [get_clocks -include_generated_clocks VIRTUAL_m_clk_anchor_top_clock] -group [get_clocks -include_generated_clocks c_clk_anchor_top_clock]
set_clock_groups -name sys_ss_async3 -asynchronous -group [get_clocks -include_generated_clocks VIRTUAL_c_clk_anchor_top_clock] -group [get_clocks -include_generated_clocks c_clk_anchor_top_clock]
set_clock_groups -name sys_ss_async4 -asynchronous -group [get_clocks -include_generated_clocks VIRTUAL_c_clk_anchor_top_clock] -group [get_clocks -include_generated_clocks m_clk_anchor_top_clock]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports {a_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports {a_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports {b_rx_data_p0[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports {b_rx_data_p1[*]}]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports a_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -min -add_delay 4.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -clock_fall -max -add_delay 4.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports b_rx_frame_in]
set_input_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 4.000 [get_ports rst]
set_input_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 4.000 [get_ports rst]
set_input_delay -clock [get_clocks VIRTUAL_c_clk_anchor_top_clock] -min -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks VIRTUAL_c_clk_anchor_top_clock] -max -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks VIRTUAL_m_clk_anchor_top_clock] -min -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks VIRTUAL_m_clk_anchor_top_clock] -max -add_delay 0.000 [get_ports rst]
set_output_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports a_enable]
set_output_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 0.000 [get_ports a_enable]
set_output_delay -clock [get_clocks a_rx_clk_in] -min -add_delay 0.000 [get_ports b_enable]
set_output_delay -clock [get_clocks a_rx_clk_in] -max -add_delay 0.000 [get_ports b_enable]
