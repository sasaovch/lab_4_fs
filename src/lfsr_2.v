`timescale 1ns / 1ps

module lfsr_2 (
    input wire clk_i,
    input wire rst_i,
    input wire [ 7 : 0 ] val,
    input wire start_i,
    output wire [ 7 : 0 ] result
);

reg [7:0] register;
assign result = register;

always @(posedge clk_i) begin
    if (rst_i) begin
        register <= val;
    end else if (start_i) begin
        
        buffer[0] <= 0;
        buffer[1] <= buffer[0];
        buffer[2] <= buffer[1];
        buffer[3] <= buffer[2] ^ buffer[7];
        buffer[4] <= buffer[3];
        buffer[5] <= buffer[4];
        buffer[6] <= buffer[5] ^ buffer[7];
        buffer[7] <= buffer[6] ^ buffer[7];
    end
end
endmodule
