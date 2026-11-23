# Experimental Methodology & Verification Flow

## 1. Dual-Track Verification Framework

To guarantee absolute functional correctness, this project uses a two-tier verification approach:

### Tier 1: Formal Equivalence Checking (Mathematical Proof)
- **Tool:** Yosys SAT Solver.
- **Coverage:** Complete state space ($2^{65} \approx 3.69 \times 10^{19}$ input states).
- **Technique:** Miter circuit comparing each implementation ($RCA, BKA, KSA, HCA$) directly against the golden specification $\{C_{out}, \text{Sum}\} = A + B + C_{in}$.
- **Result:** $100\%$ formally proven equivalent with zero counterexamples.

### Tier 2: Dynamic Functional Simulation (Corner + Regression)
- **Tool:** Icarus Verilog (`iverilog` v12) + `vvp`.
- **Vectors Checked:** 100,010 total vectors:
  - 10 Directed corner cases: zeroes, all-ones with carry, alternating checkerboard (`0xAAAAAAAA` and `0x55555555`), carry propagation chains, high-bit overflow.
  - 100,000 pseudo-random vectors generated via `$random`.
- **Result:** 0 mismatches observed across all four designs.
- **Waveform Inspection:** First 110 vectors dumped to `sim/all_adders.vcd` for GTKWave visualization.

---

## 2. Logic Synthesis and Technology Mapping

The logic synthesis flow maps each Verilog RTL design to the **Nangate 45nm Open Cell Library** (`nangate_typ.lib`):

1. **Read RTL:** `read_verilog <rtl>`
2. **Hierarchy Check:** `hierarchy -check -top <module>`
3. **Synthesis Pass:** `synth -top <module> -flatten -noabc`
4. **Technology Mapping:** `abc -liberty lib/nangate_typ.lib`
5. **Netlist Optimization:** `clean; check`
6. **Statistics & Netlist Generation:** `stat -liberty lib/nangate_typ.lib; write_verilog -noattr synth/<module>_netlist.v`

---

## 3. Static Timing Analysis (STA) & Power Modeling

Static Timing Analysis is executed using **OpenSTA** on the mapped gate-level netlists with standard constraints defined in `constraints.sdc`:

- **Virtual Clock Period:** 10.0 ns (100 MHz target)
- **Input External Delay:** 1.0 ns
- **Output External Delay:** 1.0 ns
- **Input Pin Transition (Slew):** 0.1 ns
- **Output Pin Load Capacitance:** 5.0 fF

### Evaluated Metrics:
1. **Critical Path Data Arrival Time ($t_{\text{arrival}}$):** Total propagation delay from input transition through the longest combinational path to the output.
2. **Worst Slack ($t_{\text{slack}}$):** $T_{\text{required}} - t_{\text{arrival}}$. Positive slack indicates timing closure.
3. **Power Consumption:** Measured using OpenSTA's Liberty-based cell power tables:
   - Internal Power (cell internal switching)
   - Switching Power (interconnect and load charging)
   - Static Leakage Power (sub-threshold / gate leakage)
   - Total Power = Internal + Switching + Leakage
4. **Area-Delay Product (ADP):**
   $$\text{ADP} = \text{Cell Area} \times t_{\text{arrival}}$$
