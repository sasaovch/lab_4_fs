`timescale 1ns / 1ps

module crc8_test;

reg clk;
reg rst;
reg start;
wire busy;  
reg [ 7 : 0 ] init;
reg [ 7 : 0 ] in_test;
wire [ 7 : 0 ] out_test;   
reg [ 7 : 0 ] expected_val;

crc8 crc8_1(
    .clk_i(clk), 
    .rst_i(rst), 
    .val(in_test), 
    .init_val(init), 
    .busy_o(busy), 
    .start_i(start), 
    .result(out_test)
);

initial begin
    clk = 0;
    rst = 1;
    init = 8'b11111111;
    in_test = 8'b10101010;
    expected_val = 8'b10001100;
    #10
    rst = 0;
    #10
    start = 1;
    #10
    start = 0;
    
    while (busy) begin
        #10;
    end
    
    if (out_test == expected_val) $display ( "The crc8 output is correct. test_out = %b", out_test, " , expected_out = %b" , expected_val) ;
    else  $display ( "The crc8 output is incorrect. test_out = %b", out_test, " , expected_out = %b" , expected_val) ;

end   

always begin
    #5  clk = !clk;
end    

endmodule
