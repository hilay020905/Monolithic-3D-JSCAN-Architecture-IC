set ::env(DESIGN_NAME) "top_3d_jscan"

set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/src/gtc.v \
    $::env(DESIGN_DIR)/src/lc.v \
    $::env(DESIGN_DIR)/src/jscan_top.v \
    $::env(DESIGN_DIR)/src/pras.v \
    $::env(DESIGN_DIR)/src/mss.v \
    $::env(DESIGN_DIR)/src/misr.v \
    $::env(DESIGN_DIR)/src/tier_block.v"

set ::env(CLOCK_PORT) "scan_clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(DIE_AREA) "0 0 300 300"
set ::env(FP_CORE_UTIL) "40"
set ::env(PL_TARGET_DENSITY_PCT) "50"

set ::env(RUN_POST_CTS_RESIZER_TIMING) 1
set ::env(RUN_IRDROP_REPORT) 1
set ::env(RUN_LINTER) 0
