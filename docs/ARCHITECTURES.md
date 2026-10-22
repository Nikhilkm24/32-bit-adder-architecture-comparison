# Architecture notes

## Common interface

Each module is a combinational unsigned 32-bit adder:

- Inputs: `A[31:0]`, `B[31:0]`, `Cin`
- Outputs: `Sum[31:0]`, `Cout`
- Reference arithmetic: `{1'b0, A} + {1'b0, B} + Cin`

`Cout` is the 33rd result bit. Signed overflow is not separately produced.

## Ripple-Carry Adder (RCA)

For each bit `i`:

- `P[i] = A[i] XOR B[i]`
- `G[i] = A[i] AND B[i]`
- `Sum[i] = P[i] XOR carry[i]`
- `carry[i+1] = G[i] OR (P[i] AND carry[i])`

The carry chain is conceptually linear in width. RCA is commonly a compact baseline, though actual mapping and timing depend on synthesis and library.

## Brent–Kung (BK)

Brent–Kung is a parallel-prefix carry architecture. It performs an up-sweep to form group generate/propagate terms and a down-sweep to fill required prefix results. It typically uses fewer prefix nodes than a dense Kogge–Stone network, at the cost of a somewhat deeper prefix path.

The supplied `rtl/brent_kung_32.v` expresses this tree in generate loops. Always run the common regression after changing the RTL.

## Kogge–Stone (KS)

Kogge–Stone computes prefix generate/propagate terms across logarithmic stages. At each stage, each eligible bit combines with a prefix node a power-of-two distance earlier. The dense network provides shallow logic depth but can require more nodes and wiring than some alternatives.

The supplied `rtl/kogge_stone_32.v` expresses the prefix stages with generate loops. Always run the common regression after changing the RTL.

## Cin handling

Prefix networks form group generate/propagate terms for `A` and `B`; the carry-in is folded into each prefix carry as `G_prefix[i] OR (P_prefix[i] AND Cin)`. The sum uses the original bit propagate term and the incoming carry.
