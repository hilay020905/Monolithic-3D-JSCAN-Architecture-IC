###############################################################################
# Created by write_sdc
# Thu Feb 26 11:17:03 2026
###############################################################################
current_design top_3d_jscan
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name scan_clk -period 10.0000 [get_ports {scan_clk}]
set_clock_transition 0.1500 [get_clocks {scan_clk}]
set_clock_uncertainty 0.2500 scan_clk
set_propagated_clock [get_clocks {scan_clk}]
set_input_delay 2.0000 -clock [get_clocks {scan_clk}] -add_delay [get_ports {reset_n}]
set_input_delay 2.0000 -clock [get_clocks {scan_clk}] -add_delay [get_ports {scan_in}]
set_input_delay 2.0000 -clock [get_clocks {scan_clk}] -add_delay [get_ports {test_enable}]
set_output_delay 2.0000 -clock [get_clocks {scan_clk}] -add_delay [get_ports {fault_flag}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {fault_flag}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {reset_n}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {scan_clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {scan_in}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {test_enable}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 10.0000 [current_design]
