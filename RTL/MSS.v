module mss_block(
    input  wire clk,
    input  wire reset_n,
    input  wire enable,
    input  wire scan_in,
    input  wire [1:0] cluster_sel,
    output wire scan_out
);

    reg [7:0] scan_chain;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            scan_chain <= 8'b0;
        else if (enable)
            scan_chain <= {scan_chain[6:0], scan_in};
    end

    assign scan_out = scan_chain[7];

endmodule