`timescale 1ns/1ps

// 32-bit Brent-Kung parallel-prefix adder with carry-in and carry-out.
// Interface is intentionally identical to ripple_carry_32 and kogge_stone_32.
module brent_kung_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    localparam integer WIDTH = 32;
    localparam integer LEVELS = 9; // 5 up-sweep + 4 down-sweep levels

    wire [31:0] P [0:LEVELS];
    wire [31:0] G [0:LEVELS];
    wire [32:0] carry;

    assign P[0] = A ^ B;
    assign G[0] = A & B;

    genvar s, i;
    generate
        // Brent-Kung up-sweep: form group prefixes at power-of-two boundaries.
        for (s = 1; s <= 5; s = s + 1) begin : up_sweep
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_node
                if (((i + 1) % (1 << s)) == 0) begin : combine
                    assign G[s][i] = G[s-1][i] |
                                      (P[s-1][i] & G[s-1][i-(1 << (s-1))]);
                    assign P[s][i] = P[s-1][i] & P[s-1][i-(1 << (s-1))];
                end else begin : pass_through
                    assign G[s][i] = G[s-1][i];
                    assign P[s][i] = P[s-1][i];
                end
            end
        end

        // Down-sweep: fill the remaining prefix nodes with fewer nodes than KS.
        for (s = 1; s <= 4; s = s + 1) begin : down_sweep
            localparam integer STAGE = 10 - s;
            for (i = 0; i < WIDTH; i = i + 1) begin : bit_node
                if (((i + 1) >= (3 * (1 << (s-1)))) &&
                    (((i + 1) % (1 << s)) == (1 << (s-1)))) begin : combine
                    assign G[STAGE][i] = G[STAGE-1][i] |
                        (P[STAGE-1][i] & G[STAGE-1][i-(1 << (s-1))]);
                    assign P[STAGE][i] = P[STAGE-1][i] & P[STAGE-1][i-(1 << (s-1))];
                end else begin : pass_through
                    assign G[STAGE][i] = G[STAGE-1][i];
                    assign P[STAGE][i] = P[STAGE-1][i];
                end
            end
        end
    endgenerate

    assign carry[0] = Cin;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sum_bits
            assign Sum[i] = P[0][i] ^ carry[i];
            if (i == 0) begin : first_carry
                assign carry[i+1] = G[LEVELS][i] | (P[LEVELS][i] & Cin);
            end else begin : prefix_carry
                assign carry[i+1] = G[LEVELS][i] | (P[LEVELS][i] & Cin);
            end
        end
    endgenerate
    assign Cout = carry[WIDTH];
endmodule
