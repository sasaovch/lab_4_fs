`timescale 1ns / 1ps

module bist (
    input wire clk_i,
    input wire rst_i,
    input wire start_i,
    input wire [7:0] a_i,
    input wire [7:0] b_i,
    input wire test_button,
    output reg [ 12 : 0 ] y_o,
    output busy_o
);

localparam IDLE = 3'b000;
localparam START_CALC_MODE = 3'b001;    
localparam START_TEST_MODE = 3'b010;  
localparam FUNC_CALC_MODE = 3'b011;  
localparam FUNC_TEST_MODE1 = 3'b100; 
localparam FUNC_TEST_MODE2 = 3'b101; 
localparam CRC8_TEST_MODE = 3'b110; 

reg [3:0] state;
wire mode;
wire start_mode;
reg prev_mode;
reg is_test_mode_now;
reg [3:0] test_count = 0;
reg [7:0] iter_count;

reg rst;
reg start;
wire busy;
reg [7:0] a;
reg [7:0] b;
wire [4:0] y;

reg lfsr_rst;
reg lfsr_start;
reg crc8_start;
reg crc8_rst;

wire [7:0] crc8_result;
reg [7:0] crc8_init;
wire crc8_busy;

reg  [7:0] lfsr_init;
wire [7:0] lfsr1_result;
wire [7:0] lfsr2_result;

button test_button_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .in(test_button),
    .out(mode)
);

button start_button_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .in(start_i),
    .out(start_mode)
);

ab ab_inst(
    .clk_i(clk_i),
    .rst_i(rst),
    .a_i(a),
    .b_i(b),
    .start_i(start),
    .busy_o (busy),
    .y_bo(y)
);

lfsr_1 lfsr1(
    .clk_i(clk_i),
    .rst_i(lfsr_rst),
    .val(lfsr_init),
    .start_i(lfsr_start),
    .result(lfsr1_result)
);

lfsr_2 lfsr2(
    .clk_i(clk_i),
    .rst_i(lfsr_rst),
    .val(lfsr_init),
    .start_i(lfsr_start),
    .result(lfsr2_result)
);

crc8 crc(
    .clk_i(clk_i),
    .rst_i(crc8_rst),
    .init_val(crc8_init),
    .start_i(crc8_start),
    .val(y),
    .busy_o(crc8_busy),
    .result(crc8_result)
);

assign busy_o = (state != IDLE);

always @(posedge clk_i) begin
    prev_mode <= mode;
    if (prev_mode != mode && mode) begin
        is_test_mode_now <= ~is_test_mode_now;
    end
    if (rst_i) begin
        y_o <= 0;
        state <= IDLE;
        prev_mode <= 0;
        is_test_mode_now <= 0;
        crc8_rst <= 1;
        rst <= 1;
        start <= 0;
        y_o <= 0;
        lfsr_rst <= 1;
        lfsr_start <= 0;
        crc8_start <= 0;
        iter_count <= 0;
    end else begin
        case (state)
        IDLE:
            begin
                if (is_test_mode_now && start_mode) begin
                    state <= START_TEST_MODE;
                    lfsr_init <= 8'b10101010;
                    lfsr_rst <= 1;
                    crc8_rst <= 1;
                    rst <= 1;
                    iter_count <= 0;
                    y_o <= 0;
                    crc8_init <= 8'b10101010;
                    test_count <= test_count + 1;
                end else if (start_mode) begin
                    state <= START_CALC_MODE;
                    rst <= 1;
                    y_o <= 0;
                end
            end

        START_CALC_MODE:
            begin
                if (start_mode == 0) begin
                    rst <= 0;
                    a <= a_i;
                    b <= b_i;
                    start <= 1;
                    state <= FUNC_CALC_MODE;
                end
            end

        FUNC_CALC_MODE:
            begin
                start <= 0;
                if(~busy && ~start) begin  
                   y_o [4:0] <= y;
                   state <= IDLE;
                end
            end

        START_TEST_MODE:
            begin
                if (start_mode == 0) begin
                    lfsr_start <= 1;
                    lfsr_rst <= 0;
                    crc8_rst <= 0;
                    rst <= 0;
                    state <= FUNC_TEST_MODE1;
                end
            end

        FUNC_TEST_MODE1:
            begin
                a <= lfsr1_result;
                b <= lfsr2_result;
                start <= 1;
                state <= FUNC_TEST_MODE2;
            end

        FUNC_TEST_MODE2:
            begin
                start <= 0;
                if(~busy && ~start) begin  
                   crc8_start <= 1;
                   state <= CRC8_TEST_MODE;
                end
            end

        CRC8_TEST_MODE:
            begin
                crc8_start <= 0;
                if(~crc8_busy && ~crc8_start) begin  
                   if (&iter_count) begin
                        y_o [12:9] <= test_count;
                        y_o [7:0] <= crc8_result;
                        state <= IDLE;
                   end else begin
                        iter_count <= iter_count + 1;
                        state <= START_TEST_MODE;
                   end
                end
            end
        endcase
    end
end

endmodule
