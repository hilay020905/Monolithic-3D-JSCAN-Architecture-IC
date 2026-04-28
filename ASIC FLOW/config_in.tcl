#============================================================
# INNOVUS TCL - USING YOUR REAL LIB
#============================================================

set DESIGN unimd_top
set OUT_DIR ./innovus_out
file mkdir $OUT_DIR

set NETLIST ./genus_out/${DESIGN}_netlist.v
set SDC     ./genus_out/${DESIGN}.sdc

set LIB_CORE ./lib/fse0k_d_generic_core_ff1p32v125c.lib
set LIB_EXTRA ./lib/cads1_ffcell1_lib.lib

set TECH_LEF ./lef/tech.lef
set CELL_LEF ./lef/standard_cells.lef


create_library_set -name LIB_CORE \
    -timing [list $LIB_CORE $LIB_EXTRA]

create_rc_corner -name RC

create_delay_corner -name DC \
    -library_set LIB_CORE \
    -rc_corner RC

create_constraint_mode -name CON \
    -sdc_files [list $SDC]

create_analysis_view -name VIEW \
    -constraint_mode CON \
    -delay_corner DC

set_analysis_view -setup VIEW -hold VIEW


set init_top_cell $DESIGN
set init_verilog $NETLIST
set init_lef_file [list $TECH_LEF $CELL_LEF]

set init_pwr_net VDD
set init_gnd_net VSS

init_design



floorPlan -site CoreSite -r 1.0 0.65 10 10 10 10



globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

addRing -nets {VDD VSS} \
    -layer {top metal5 bottom metal5 left metal4 right metal4} \
    -width 2 -spacing 2

sroute


place_opt_design



create_ccopt_clock_tree_spec
ccopt_design

optDesign -postCTS
optDesign -postCTS -hold



routeDesign

optDesign -postRoute
optDesign -postRoute -hold


report_timing > $OUT_DIR/timing.rpt
report_power  > $OUT_DIR/power.rpt
report_area   > $OUT_DIR/area.rpt
report_qor    > $OUT_DIR/qor.rpt



write_def $OUT_DIR/${DESIGN}.def
write_verilog $OUT_DIR/${DESIGN}_pnr.v
saveDesign $OUT_DIR/${DESIGN}.enc

exit
