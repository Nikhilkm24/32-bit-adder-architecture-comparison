`timescale 1ns/1ps

// 32-bit Kogge-Stone parallel-prefix adder with carry-in and carry-out.
module kogge_stone_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    localparam integer WIDTH = 32;
    localparam integer LEVELS = 5; // ceil(log2(32))

    wire [31:0] P [0:LEVELS];
    wire [31:0] G [0:LEVELS];
    wire [32:0] carry;

    assign P[0] = A ^ B;
    assign G[0] = A & B;

    genvar s, i;
    generate
        for (s = 1; s <= LEVELS; s = s + 1) begin : prefix_stage
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_node
                if (i >= (1 << (s-1))) begin : combine
                    assign G[s][i] = G[s-1][i] |
                                      (P[s-1][i] & G[s-1][i-(1 << (s-1))]);
                    assign P[s][i] = P[s-1][i] & P[s-1][i-(1 << (s-1))];
                end else begin : pass_through
                    assign G[s][i] = G[s-1][i];
                    assign P[s][i] = P[s-1][i];
                end
            end
        end
    endgenerate

    assign carry[0] = Cin;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sum_bits
            assign Sum[i] = P[0][i] ^ carry[i];
            assign carry[i+1] = G[LEVELS][i] | (P[LEVELS][i] & Cin);
        end
    endgenerate
    assign Cout = carry[WIDTH];
endmodule
