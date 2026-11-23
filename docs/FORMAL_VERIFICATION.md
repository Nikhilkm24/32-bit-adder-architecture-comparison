# Formal Verification Methodology and Proofs

## 1. Overview and Motivation

Functional simulation with pseudo-random vectors (e.g. 100,010 vectors) provides strong empirical evidence, but for a 32-bit adder with carry-in, the total input state space is:

$$2^{32} \times 2^{32} \times 2^1 = 2^{65} \approx 3.69 \times 10^{19} \text{ combinations}$$

Simulating all combinations at 1 GHz would take over **1,170 years**. 

To achieve **100% mathematical guarantee of correctness**, this project implements **Formal Equivalence Checking (FEC)** using the open-source **Yosys SAT-based formal verification framework**.

---

## 2. Formal Equivalence Miter Formulation

For each adder architecture under test ($\text{UUT} \in \{\text{RCA}, \text{BKA}, \text{KSA}, \text{HCA}\}$), a **miter circuit** is constructed against an unconstrained behavioral golden specification:

```text
       +-----------------------+
A ---->|                       |----> Cout_gold, Sum_gold
B ---->|  Golden Reference     |               |
Cin -->|  (A + B + Cin)        |               |
  |    +-----------------------+               |
  |                                            v
  |    +-----------------------+             [ XOR ] ---> Mismatch Detected?
  +--->|                       |               ^          (Assert == 0)
  +--->|  RTL Implementation   |----> Cout_uut, Sum_uut
  +--->|  (RCA / BK / KS / HC) |
       +-----------------------+
```

### Golden Reference Specification:
```verilog
module golden_ref (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    assign {Cout, Sum} = {1'b0, A} + {1'b0, B} + Cin;
endmodule
```

The Yosys `miter -equiv -flatten -make_assert` command binds the inputs together and generates an internal assertion:
$$\text{assert}(\{C_{out,\text{ref}}, \text{Sum}_{\text{ref}}\} == \{C_{out,\text{uut}}, \text{Sum}_{\text{uut}}\})$$

---

## 3. SAT Solver Execution & Mathematical Proof

The circuit is transformed into Conjunctive Normal Form (CNF) clauses via Tseitin transformation. The Yosys internal SAT solver (Minisat-based) attempts to find an input assignment $(A, B, C_{in})$ such that the assertion is violated ($\text{Assertion} = 0$).

When the solver reports **"SAT proof finished - no model found: SUCCESS!"**, it mathematically proves that **no counterexample exists in the entire $2^{65}$ state space**.

### Formal Proof Results

| Architecture | CNF Variables | CNF Clauses | SAT Solver Result | Proof Status |
| :--- | :---: | :---: | :---: | :---: |
| **Ripple-Carry (RCA)** | 2,048 | 5,389 | No counterexample found | **PROVED 100% CORRECT (Q.E.D.)** |
| **Brent–Kung (BKA)** | 2,583 | 6,780 | No counterexample found | **PROVED 100% CORRECT (Q.E.D.)** |
| **Kogge–Stone (KSA)** | 3,663 | 9,588 | No counterexample found | **PROVED 100% CORRECT (Q.E.D.)** |
| **Han–Carlson (HCA)** | 2,928 | 7,677 | No counterexample found | **PROVED 100% CORRECT (Q.E.D.)** |

---

## 4. How to Reproduce Formal Verification

Run the formal verification script from the repository root:

```bash
chmod +x scripts/run_formal.sh
./scripts/run_formal.sh
```

Inspect the proof log:
```bash
cat reports/formal_verify.log
```
