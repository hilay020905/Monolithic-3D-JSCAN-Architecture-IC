module pras_block(
    input  wire clk,
    input  wire reset_n,
    input  wire enable,
    input  wire [3:0] col_addr,
    output reg  scan_out
);
    reg [15:0] grid;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            grid <= 16'hA5A5; 
        else if (enable)
            scan_out <= grid[col_addr];
    end
endmodule