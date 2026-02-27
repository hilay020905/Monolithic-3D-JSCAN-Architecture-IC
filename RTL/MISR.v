module misr(
    input  wire clk,
    input  wire reset_n,
    input  wire enable,
    input  wire data_in,
    output reg  signature
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            signature <= 1'b0;
        else if (enable)
            signature <= signature ^ data_in;
    end

endmodule