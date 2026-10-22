`timescale 1ns/1ps

// 32-bit combinational ripple-carry adder.
// Interface matches brent_kung_32 and kogge_stone_32.
module ripple_carry_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    wire [32:0] carry;
    assign carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_rca
            assign Sum[i] = A[i] ^ B[i] ^ carry[i];
            assign carry[i+1] = (A[i] & B[i]) |
                                (A[i] & carry[i]) |
                                (B[i] & carry[i]);
        end
    endgenerate

    assign Cout = carry[32];
endmodule
