`default_nettype none
`timescale 1ns/1ns

// ARITHMETIC-LOGIC UNIT
// > Executes computations on register values
// > In this minimal implementation, the ALU supports the 4 basic arithmetic operations
// > Each thread in each core has it's own ALU
// > ADD, SUB, MUL, DIV instructions are all executed here
module alu (
    input wire clk,
    input wire reset,
    input wire enable, // If current block has less threads then block size, some ALUs will be inactive

    input wire [2:0] core_state, // I had to change it from reg to wire in order to get it to compile in EDA playground :(

    input wire [2:0] decoded_alu_arithmetic_mux,
    input wire decoded_alu_output_mux,

    input wire [7:0] rs,
    input wire [7:0] rt,
    output wire [7:0] alu_out
);
    localparam ADD = 3'b000,
        SUB = 3'b001,
        MUL = 3'b010,
        DIV = 3'b011,
        ROR = 3'b100;
        ROL = 3'b101;
        SLL = 3'b110;
        SRL = 3'b111;

    reg [7:0] alu_out_reg;
    assign alu_out = alu_out_reg;

    always @(posedge clk) begin 
        if (reset) begin 
            alu_out_reg <= 8'b0;
        end else if (enable) begin
            // Calculate alu_out when core_state = EXECUTE
            if (core_state == 3'b101) begin 
                if (decoded_alu_output_mux == 1) begin 
                    // Set values to compare with NZP register in alu_out[2:0]
                    alu_out_reg <= {5'b0, (rs - rt > 0), (rs - rt == 0), (rs - rt < 0)};
                end else begin 
                    // Execute the specified arithmetic instruction
                    case (decoded_alu_arithmetic_mux)
                        ADD: begin 
                            alu_out_reg <= rs + rt;
                        end
                        SUB: begin 
                            alu_out_reg <= rs - rt;
                        end
                        MUL: begin 
                            alu_out_reg <= rs * rt;
                        end
                        DIV: begin 
                            alu_out_reg <= rs / rt;
                        end
                        ROR: begin
                            // rotate right by (rt & 7)
                            alu_out_reg <= (rs >> (rt & 7)) | (rs << (8 - (rt & 7)));
                        end
                        ROL: begin
                            // rotate left by (rt & 7)
                            alu_out_reg <= (rs << (rt & 7)) | (rs >> (8 - (rt & 7)));
                        end
                        SLL: begin
                            // shift left logical by (rt & 7)
                            alu_out_reg <= rs << (rt & 7);
                        end
                        SRL: begin
                            // shift right logical by (rt & 7)
                            alu_out_reg <= rs >> (rt & 7);
                        end
                    endcase
                end
            end
        end
    end
endmodule
