

set DESIGN unimd_top
set RTL_DIR ./rtl
set OUT_DIR ./genus_out
file mkdir $OUT_DIR



set LIB_FAST "/path/to/65nm/fast.lib"
set LIB_TYP  "/path/to/65nm/typical.lib"
set LIB_SLOW "/path/to/65nm/slow.lib"

set_db library [list $LIB_FAST $LIB_TYP $LIB_SLOW]



set_db syn_global_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

# CRITICAL: datapath optimization
set_db datapath_optimize true
set_db optimize_registers true


read_hdl -sv [glob ./rtl/*.v]
elaborate $DESIGN

check_design


create_clock -name clk -period 1.0 [get_ports clk]   ;# 1 GHz target
set_clock_uncertainty 0.1
set_clock_transition 0.05

# Pipeline aware optimization
set_db pipeline_design true
set_db retime true


set_input_delay 0.2 -clock clk [all_inputs]
set_output_delay 0.2 -clock clk [all_outputs]

set_driving_cell -lib_cell INVX4 [all_inputs]
set_load 0.02 [all_outputs]

# Force use of fast arithmetic structures
set_db hdlin_infer_multibit true
set_db syn_use_multibit_cells true

# Enable compressor / CSA optimization
set_db syn_enable_csa true

syn_generic
syn_map
syn_opt

report_timing > $OUT_DIR/timing.rpt
report_area   > $OUT_DIR/area.rpt
report_power  > $OUT_DIR/power.rpt

report_datapath > $OUT_DIR/datapath.rpt


write_hdl > $OUT_DIR/${DESIGN}_netlist.v
write_sdc > $OUT_DIR/${DESIGN}.sdc
write_sdf > $OUT_DIR/${DESIGN}.sdf

exit


