module top_3d_jscan (
    input  wire        scan_clk,
    input  wire        reset_n,
    input  wire        scan_in,
    input  wire        test_enable,
    output wire        fault_flag
);

    // Adding (* keep = "true" *) prevents Vivado from optimizing these out
    (* keep = "true" *) wire [1:0] tier_sel;
    (* keep = "true" *) wire [1:0] mode_sel;
    (* keep = "true" *) wire [3:0] col_addr;
    (* keep = "true" *) wire [1:0] cluster_sel;
    (* keep = "true" *) wire       shift_en;
    (* keep = "true" *) wire       capture_en;
    (* keep = "true" *) wire       test_en;
    (* keep = "true" *) wire       tsv_scan_in;

    wire misr_out_t1, misr_out_t2, misr_out_t3;

    global_test_controller GTC (
        .scan_clk(scan_clk), .reset_n(reset_n), .scan_in(scan_in),
        .test_enable(test_enable), .tier_sel(tier_sel), .mode_sel(mode_sel),
        .col_addr(col_addr), .cluster_sel(cluster_sel), .shift_en(shift_en),
        .capture_en(capture_en), .test_en(test_en), .tsv_scan_in(tsv_scan_in),
        .misr_t1(misr_out_t1), .misr_t2(misr_out_t2), .misr_t3(misr_out_t3),
        .fault_flag(fault_flag)
    );

    // Ensure instances are not optimized away 
    tier_block #(.TIER_ID(2'b01)) TIER1 (
        .scan_clk(scan_clk), .reset_n(reset_n), .tier_sel(tier_sel),
        .mode_sel(mode_sel), .col_addr(col_addr), .cluster_sel(cluster_sel),
        .shift_en(shift_en), .capture_en(capture_en), .test_en(test_en),
        .scan_in(tsv_scan_in), .misr_out(misr_out_t1)
    );

    tier_block #(.TIER_ID(2'b10)) TIER2 (
        .scan_clk(scan_clk), .reset_n(reset_n), .tier_sel(tier_sel),
        .mode_sel(mode_sel), .col_addr(col_addr), .cluster_sel(cluster_sel),
        .shift_en(shift_en), .capture_en(capture_en), .test_en(test_en),
        .scan_in(tsv_scan_in), .misr_out(misr_out_t2)
    );

    tier_block #(.TIER_ID(2'b11)) TIER3 (
        .scan_clk(scan_clk), .reset_n(reset_n), .tier_sel(tier_sel),
        .mode_sel(mode_sel), .col_addr(col_addr), .cluster_sel(cluster_sel),
        .shift_en(shift_en), .capture_en(capture_en), .test_en(test_en),
        .scan_in(tsv_scan_in), .misr_out(misr_out_t3)
    );

endmodule