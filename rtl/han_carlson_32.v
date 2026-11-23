`timescale 1ns/1ps

// 32-bit Han-Carlson parallel-prefix adder with carry-in and carry-out.
// Han-Carlson combines Brent-Kung (outer sparse tree) and Kogge-Stone (inner dense prefix tree):
// Stage 0: Bit-level propagate and generate (P0, G0)
// Stage 1: Brent-Kung up-sweep on odd bit positions (distance 1)
// Stages 2..5: Kogge-Stone prefix network on odd bit positions only (distances 2, 4, 8, 16)
// Stage 6: Down-sweep distribution to even bit positions (distance 1)
// Total depth = log2(32) + 1 = 6 prefix levels.
// Significantly lower wiring density and prefix cell count (~72 cells) than Kogge-Stone (129 cells)
// with near-identical critical path delay.
module han_carlson_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    localparam integer WIDTH = 32;
    localparam integer LEVELS = 6;

    wire [31:0] P [0:LEVELS];
    wire [31:0] G [0:LEVELS];
    wire [32:0] carry;

    // Stage 0: Pre-processing
    assign P[0] = A ^ B;
    assign G[0] = A & B;

    genvar i, s;
    generate
        // Stage 1: Up-sweep on odd bit positions (combine with preceding even bit)
        for (i = 0; i < WIDTH; i = i + 1) begin : stage1
            if ((i % 2) == 1) begin : odd_combine
                assign G[1][i] = G[0][i] | (P[0][i] & G[0][i-1]);
                assign P[1][i] = P[0][i] & P[0][i-1];
            end else begin : even_pass
                assign G[1][i] = G[0][i];
                assign P[1][i] = P[0][i];
            end
        end

        // Stages 2 to 5: Kogge-Stone prefix tree on odd positions only
        for (s = 2; s <= 5; s = s + 1) begin : ks_stages
            localparam integer D = 1 << (s - 1); // D = 2, 4, 8, 16
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_node
                if (((i % 2) == 1) && (i >= D)) begin : odd_combine
                    assign G[s][i] = G[s-1][i] | (P[s-1][i] & G[s-1][i-D]);
                    assign P[s][i] = P[s-1][i] & P[s-1][i-D];
                end else begin : pass_through
                    assign G[s][i] = G[s-1][i];
                    assign P[s][i] = P[s-1][i];
                end
            end
        end

        // Stage 6: Down-sweep distribution to even bit positions
        for (i = 0; i < WIDTH; i = i + 1) begin : stage6
            if (i == 0) begin : bit0_pass
                assign G[6][0] = G[5][0];
                assign P[6][0] = P[5][0];
            end else if ((i % 2) == 0) begin : even_combine
                assign G[6][i] = G[5][i] | (P[5][i] & G[5][i-1]);
                assign P[6][i] = P[5][i] & P[5][i-1];
            end else begin : odd_pass
                assign G[6][i] = G[5][i];
                assign P[6][i] = P[5][i];
            end
        end
    endgenerate

    // Carry computation
    assign carry[0] = Cin;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_carry
            assign carry[i+1] = G[LEVELS][i] | (P[LEVELS][i] & Cin);
        end
    endgenerate

    assign Sum  = P[0] ^ carry[31:0];
    assign Cout = carry[WIDTH];
endmodule
