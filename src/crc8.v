`timescale 1ns / 1ps

module crc8 (
    input wire clk_i,
    input wire rst_i,
    input wire [15:0] val,
    input wire [7:0] init_val,
    input wire start_i,
    output wire busy_o,
    output wire [7:0] result
);

localparam IDLE = 2'b00;
localparam TAKE_CUR_BIT = 2'b01;    
localparam CALC_CRC = 2'b10;  
reg [1:0] state;

assign busy_o = (state != IDLE);

reg [7:0] register;
assign result = register;

reg bit;
reg[5 : 0] counter;

always @(posedge clk_i) begin
    if (rst_i) begin
        register <= init_val;
        state <= IDLE;
        counter <= 0;
        bit <= 0;
    end else begin
        case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            state <= TAKE_CUR_BIT;
                            bit <= 0;
                            counter <= 0;
                        end
                    end
                TAKE_CUR_BIT:
                    begin
                        if (counter == 16) begin
                            state <= IDLE;
                        end else begin
                            bit <= val[counter];
                            state <= CALC_CRC;
                        end
                    end
                CALC_CRC:
                    begin
                        register[0] <= bit ^ register[7];
                        register[1] <= register[0] ^ register[7];
                        register[2] <= register[1];
                        register[3] <= register[2] ^ register[7];
                        register[4] <= register[3];
                        register[5] <= register[4];
                        register[6] <= register[5];
                        register[7] <= register[6] ^ register[7];
                        counter <= counter + 1;
                        state <= TAKE_CUR_BIT;
                    end
        endcase
    end
end
endmodule
