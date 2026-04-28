#============================================================
# GENUS TCL - USING ACTUAL LIB FROM YOUR DESIGN
#============================================================

set DESIGN unimd_top
set RTL_DIR ./rtl
set OUT_DIR ./genus_out
file mkdir $OUT_DIR


set LIB_CORE ./lib/fse0k_d_generic_core_ff1p32v125c.lib
set LIB_EXTRA ./lib/cads1_ffcell1_lib.lib

set_db library [list $LIB_CORE $LIB_EXTRA]

set_db hdl_search_path $RTL_DIR
read_hdl -sv [glob ./rtl/*.v]

elaborate $DESIGN
check_design


create_clock -name clk -period 2.0 [get_ports clk]

set_clock_uncertainty 0.1
set_clock_transition 0.05

set_input_delay 0.2 -clock clk [all_inputs]
set_output_delay 0.2 -clock clk [all_outputs]

# Reset false path
if {[llength [get_ports reset_n]] > 0} {
    set_false_path -from [get_ports reset_n]
}

set_db syn_global_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

set_db datapath_optimize true
set_db use_multibit_cells true



syn_generic
syn_map
syn_opt



report_timing > $OUT_DIR/timing.rpt
report_area   > $OUT_DIR/area.rpt
report_power  > $OUT_DIR/power.rpt
report_qor    > $OUT_DIR/qor.rpt



write_hdl > $OUT_DIR/${DESIGN}_netlist.v
write_sdc > $OUT_DIR/${DESIGN}.sdc
write_sdf > $OUT_DIR/${DESIGN}.sdf

exit
