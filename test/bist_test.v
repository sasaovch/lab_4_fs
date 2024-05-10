`timescale 1ns / 1ps

module bist_logic_tb;

reg clk;
reg rst;
reg start;
reg test_button;
wire busy; 

reg [7:0] in_test_a;
reg [7:0] in_test_b;
wire [15:0] out_test;  

bist bist_logic1(
    .clk_i(clk), 
    .rst_i(rst), 
    .start_i(start), 
    .a_i(in_test_a), 
    .b_i(in_test_b), 
    .test_button(test_button),
    .y_o(out_test), 
    .busy_o(busy)
);


task test_bist_1;
    input [3:0] numb;
    input [7:0] a;
    input [7:0] b;
    input [15:0] expected_y;
    begin
        test_button = 0;
        in_test_a = a;
        in_test_b = b;
        start = 1;
        #10000
        start = 0;
        #10000
        while (busy) begin
            #10;
        end
        if (out_test[4 : 0] == expected_y) $display ( "Test ", numb, ". The func output is correct. test_out = ", out_test, " , expected_out =" , expected_y) ;
        else  $display ( "Test ", numb, ". The func output is incorrect. test_out = ", out_test, " , expected_out =" , expected_y) ;
    end
endtask
    
task test_bist_2;
    input [3:0] numb;
    input [15:0] expected_y;
    begin
        start = 1;
        #1000000
        start = 0;
        #10
        while (busy) begin
            #10;
        end
        if (out_test[12 : 0] == expected_y) $display ( "Test ", numb, ". The func output is correct. test_out = %b", out_test, " , expected_out = %b" , expected_y) ;
        else  $display ( "Test ", numb, ". The func output is incorrect. test_out = %b", out_test, " , expected_out = %b" , expected_y) ;
    end
endtask

initial begin
    clk = 0;
    rst = 1;
    #10
    rst = 0;
    $display ( "Test user mode");
    test_bist_1(1, 0, 0, 0);
    test_bist_1(2, 1, 1, 1);
    test_bist_1(3, 20, 55, 60);
    test_bist_1(4, 30, 255, 180);
    
    $display ( "Test bist mode");
    test_button = 1;
    #1000
    test_button = 0;
    test_bist_2(1, 13'b0001001010001);
    test_bist_2(2, 13'b0010001010001);
    test_bist_2(3, 13'b0011001010001);
    test_bist_2(4, 13'b0100001010001);
end   

always begin
    #5  clk = !clk;
end    

endmodule
