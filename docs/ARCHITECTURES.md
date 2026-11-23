# 32-bit Adder Architectures

## Common Interface

All four combinational adder modules share an identical top-level interface:

- **Inputs:** `A[31:0]`, `B[31:0]`, `Cin`
- **Outputs:** `Sum[31:0]`, `Cout`
- **Golden Reference Arithmetic:** `{Cout, Sum} = {1'b0, A} + {1'b0, B} + Cin`

---

## 1. Ripple-Carry Adder (RCA) (`rtl/ripple_carry_32.v`)

For each bit position $i \in [0, 31]$:
- $P_i = A_i \oplus B_i$
- $G_i = A_i \land B_i$
- $\text{Sum}_i = P_i \oplus C_i$
- $C_{i+1} = G_i \lor (P_i \land C_i)$

**Characteristics:**
- Simplest topology with minimal gate count and regular 1D physical layout.
- Worst-case propagation delay scales linearly: $\mathcal{O}(N)$ (32 carry stages).
- Serves as the baseline for area efficiency and minimum power.

---

## 2. Brent–Kung Parallel-Prefix Adder (BKA) (`rtl/brent_kung_32.v`)

Brent–Kung uses a sparse parallel-prefix tree:
1. **Forward Up-Sweep Tree:** 5 levels ($D = 1, 2, 4, 8, 16$) combining group generate and propagate terms at power-of-two boundaries.
2. **Reverse Down-Sweep Tree:** 4 levels ($D = 8, 4, 2, 1$) computing the intermediate prefixes.

**Characteristics:**
- **Logic Depth:** $2 \log_2 N - 2 = 9$ prefix levels.
- **Prefix Cells:** 57 cells.
- **Fan-Out:** Maximum fan-out $\le 2$, minimizing gate loading.
- Excellent compromise between logic depth and area/wiring density.

---

## 3. Kogge–Stone Parallel-Prefix Adder (KSA) (`rtl/kogge_stone_32.v`)

Kogge–Stone computes group prefixes across strictly logarithmic levels:
- At each prefix stage $s \in [1, 5]$, every eligible bit combines with a partner node at lateral distance $D = 2^{s-1}$.

**Characteristics:**
- **Logic Depth:** $\log_2 N = 5$ prefix levels (minimal depth).
- **Prefix Cells:** 129 prefix cells.
- **Wiring Density:** Very high interconnect density and wire congestion.
- Although theoretically the fastest architecture, heavy wiring and capacitive load can degrade speed in post-layout nanometer CMOS.

---

## 4. Han–Carlson Hybrid Parallel-Prefix Adder (HCA) (`rtl/han_carlson_32.v`)

The Han–Carlson architecture combines the low routing density of Brent–Kung with the shallow logic depth of Kogge–Stone:
1. **Stage 0 (Pre-processing):** Bit-level $P_0[i] = A_i \oplus B_i$ and $G_0[i] = A_i \land B_i$.
2. **Stage 1 (Brent–Kung Up-sweep):** Combines adjacent even/odd bit pairs across all odd bit positions ($i \in \{1, 3, \dots, 31\}$).
3. **Stages 2 to 5 (Inner Kogge–Stone Tree):** A dense 4-stage Kogge–Stone network runs **only on the odd bit positions** (distances 2, 4, 8, 16).
4. **Stage 6 (Down-sweep Distribution):** The resolved odd prefix carries are distributed to adjacent even positions ($i \in \{2, 4, \dots, 30\}$).
5. **Post-processing:** $C_{i+1} = G_6[i] \lor (P_6[i] \land C_{in})$, $\text{Sum}_i = P_0[i] \oplus C_i$.

**Characteristics:**
- **Logic Depth:** $\log_2 N + 1 = 6$ prefix levels (only 1 level more than Kogge–Stone).
- **Prefix Cells:** ~72 cells (~44% fewer prefix cells than Kogge–Stone).
- **Wiring Density:** Half the wiring density of Kogge–Stone.
- Modern industry favorite for high-performance integer ALUs.

---

## Architectural Comparison Matrix

| Architecture | Prefix Depth | Prefix Cells | Max Fan-out | Wiring Congestion |
| :--- | :---: | :---: | :---: | :---: |
| **Ripple-Carry (RCA)** | 32 stages | 0 (ripple) | 2 | Negligible |
| **Brent–Kung (BKA)** | 9 stages | 57 | 2 | Low |
| **Kogge–Stone (KSA)** | 5 stages | 129 | 2 | Very High |
| **Han–Carlson (HCA)** | 6 stages | 72 | 2 | Moderate |
