module layer_connections(
    input  wire clk,
    input  wire reset_n,
    input  wire enable,
    input  wire scan_in,
    output reg  scan_out
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            scan_out <= 1'b0;
        else if (enable)
            scan_out <= scan_in;
    end

endmodule