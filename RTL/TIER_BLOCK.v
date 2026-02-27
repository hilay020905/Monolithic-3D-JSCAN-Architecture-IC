module tier_block #(
    parameter TIER_ID = 2'b01
)(
    input  wire       scan_clk,
    input  wire       reset_n,
    input  wire [1:0] tier_sel,
    input  wire [1:0] mode_sel,
    input  wire [3:0] col_addr,
    input  wire [1:0] cluster_sel,
    input  wire       shift_en,
    input  wire       capture_en,
    input  wire       test_en,
    input  wire       scan_in,
    output wire       misr_out
);

    wire active = (tier_sel == TIER_ID) && test_en;

    wire sas_out;
    wire ras_out;
    wire tsv_out;

    // SAS (Serial)
    mss_block MSS (
        .clk(scan_clk),
        .reset_n(reset_n),
        .enable(active && (mode_sel==2'b00)),
        .scan_in(scan_in),
        .cluster_sel(cluster_sel),
        .scan_out(sas_out)
    );

    // RAS
    pras_block PRAS (
        .clk(scan_clk),
        .reset_n(reset_n),
        .enable(active && (mode_sel==2'b01)),
        .col_addr(col_addr),
        .scan_out(ras_out)
    );

    // TSV Wrapper
    layer_connections LC (
        .clk(scan_clk),
        .reset_n(reset_n),
        .enable(active && (mode_sel==2'b10)),
        .scan_in(scan_in),
        .scan_out(tsv_out)
    );

    // Mode MUX
    wire scan_data =
        (mode_sel==2'b00) ? sas_out :
        (mode_sel==2'b01) ? ras_out :
                            tsv_out;
    // MISR
    misr MISR (
        .clk(scan_clk),
        .reset_n(reset_n),
        .enable(capture_en && active),
        .data_in(scan_data),
        .signature(misr_out)
    );

endmodule