`timescale 1ns / 1ps

module lfsr_2_test;

reg clk;
reg rst;
reg start; 
reg [ 7 : 0 ] in_test;
wire [ 7 : 0 ] out_test;   
integer i;

lfsr_2 lfsr_2_1(
    .clk_i(clk), 
    .rst_i(rst), 
    .val(in_test), 
    .start_i(start), 
    .result(out_test)
);

initial begin
    clk = 0;
    rst = 1;
    in_test = 8'b11110000;
    #10
    rst = 0;
    #10
    start = 1;
    
    for (i = 0; i < 27; i = i + 1) begin
        #10
        $display("Value %d", i[9:0], ": %d", out_test);
    end
    
    #10
    
    if (out_test == in_test) $display ( "The lfsr output is correct. test_out =", out_test, " , expected_out =" , in_test) ;
    else  $display ( "The lfsr output is incorrect. test_out =", out_test, " , expected_out =" , in_test) ;
    
    start = 0;
end   

always begin
    #5  clk = !clk;
end    

endmodule
