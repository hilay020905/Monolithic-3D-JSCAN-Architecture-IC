module global_test_controller(
    input  wire       scan_clk,
    input  wire       reset_n,
    input  wire       scan_in,
    input  wire       test_enable,

    output reg [1:0]  tier_sel,
    output reg [1:0]  mode_sel,
    output reg [3:0]  col_addr,
    output reg [1:0]  cluster_sel,
    output reg        shift_en,
    output reg        capture_en,
    output wire       test_en,
    output wire       tsv_scan_in,

    input  wire       misr_t1,
    input  wire       misr_t2,
    input  wire       misr_t3,
    output reg        fault_flag
);

    assign test_en = test_enable;
    assign tsv_scan_in = scan_in;

    always @(posedge scan_clk or negedge reset_n) begin
        if (!reset_n) begin
            tier_sel    <= 2'b01;
            mode_sel    <= 2'b00;  
            col_addr    <= 4'd0;
            cluster_sel <= 2'd0;
            shift_en    <= 1'b0;
            capture_en  <= 1'b0;
            fault_flag  <= 1'b0;
        end 
        else if (test_enable) begin
            shift_en   <= ~shift_en;
            capture_en <= shift_en;
            
            // Allow counters to increment naturally
            col_addr   <= col_addr + 1'b1;
            cluster_sel<= cluster_sel + 1'b1;

            // Cycle Tier Selection
            if (tier_sel == 2'b01)
                tier_sel <= 2'b10;
            else if (tier_sel == 2'b10)
                tier_sel <= 2'b11;
            else
                tier_sel <= 2'b01;

            if (col_addr == 4'hF) begin
                if (mode_sel == 2'b10)
                    mode_sel <= 2'b00;
                else
                    mode_sel <= mode_sel + 1'b1;
            end

            // MISR Aggregation
            fault_flag <= misr_t1 | misr_t2 | misr_t3;
        end
    end

endmodule