# Comparative Analysis of 32-bit Adders Using Verilog HDL

Compare three combinational 32-bit adder architectures:

1. **Ripple-Carry Adder (RCA)** — carry propagates bit by bit.
2. **Brent–Kung (BK)** — a parallel-prefix network designed to reduce prefix-node count compared with dense prefix structures.
3. **Kogge–Stone (KS)** — a dense parallel-prefix network with logarithmic prefix depth and relatively high wiring/node count.

All designs use the same interface: `A[31:0]`, `B[31:0]`, `Cin`, `Sum[31:0]`, and `Cout`. The common testbench compares `{Cout, Sum}` against a 33-bit reference result.

> **Reproducibility note:** The starter package supplied to assemble this repository contained the RCA RTL, common testbench, constraints, and TCL scripts, but not the original Brent–Kung and Kogge–Stone source files from the user's WSL workspace. The bundled BK and KS RTL are clean, self-contained structural implementations of those architectures, created to make this repository runnable. Therefore the historical area/timing values in `reports/adder_comparison.csv` and the accompanying plots are the values reported by the earlier workspace, and **must not be assumed to reproduce from the bundled BK/KS RTL**. Rerun the flow and replace the results before making claims about the bundled source. The architecture/interface and measurement setup are documented so results can be reproduced and compared fairly.

## Repository layout

```text
.
├── rtl/
│   ├── ripple_carry_32.v
│   ├── brent_kung_32.v
│   └── kogge_stone_32.v
├── tb/
│   └── tb_all_adders.v
├── constraints.sdc
├── sta/
│   ├── sta_rca.tcl
│   ├── sta_bk.tcl
│   └── sta_ks.tcl
├── scripts/
│   ├── run_sim.sh
│   ├── run_synth.sh
│   ├── run_sta.sh
│   └── summarize_results.py
├── lib/README.md
├── reports/
│   ├── adder_comparison.csv
│   ├── area_comparison.png
│   └── timing_comparison.png
├── docs/
│   ├── ARCHITECTURES.md
│   ├── METHODOLOGY.md
│   └── RESULTS.md
├── .gitignore
└── README.md
```

## Tools

- **Icarus Verilog** (`iverilog`, `vvp`) — RTL simulation.
- **Yosys** — synthesis and technology mapping through ABC.
- **OpenSTA** — static timing analysis of mapped netlists.
- **Nangate typical Liberty library** — required for synthesis/STA, not included in this repository. Add it as `lib/nangate_typ.lib` only if you are permitted to use and redistribute/store it. See [`lib/README.md`](lib/README.md).
- **GTKWave** — optional waveform inspection.
- Python 3 — optional for parsing logs; Matplotlib is needed only to regenerate graphs.

## Quick start (Ubuntu / WSL)

Install tools using your distribution's supported package manager. Package availability/names can vary by Ubuntu release. Verify tools first:

```bash
iverilog -V
vvp -V
yosys -V
```

### 1. Run functional simulation

From the repository root:

```bash
chmod +x scripts/*.sh
./scripts/run_sim.sh
```

Expected outcome for the current testbench: 100,010 vectors (10 directed + 100,000 pseudo-random), with zero errors for RCA, BK, and KS. This is simulation testing, not a formal proof.

The script writes `sim/all_adders.vcd` and `reports/all_adders_sim.log`. Open the waveform optionally with:

```bash
gtkwave sim/all_adders.vcd
```

### 2. Synthesize all designs

Add your permitted Liberty file as `lib/nangate_typ.lib`, then run:

```bash
./scripts/run_synth.sh
```

The script writes mapped netlists under `synth/` and logs under `reports/`. It uses the same sequence for each design:

```text
read_verilog → hierarchy -check → synth -flatten -noabc
→ abc -liberty → clean → check → stat → write_verilog
```

Use the **final mapped statistics** from each log, not intermediate cell counts earlier in the log.

### 3. Run static timing analysis

The script searches for `sta` in PATH, then falls back to `~/OpenSTA/build/sta`. If needed, set `STA_BIN` explicitly:

```bash
STA_BIN="$HOME/OpenSTA/build/sta" ./scripts/run_sta.sh
```

This requires mapped netlists from the synthesis step. Reports are saved to `reports/*_sta.log`.

### 4. Summarize actual logs

After simulation, synthesis, and STA have run:

```bash
python3 scripts/summarize_results.py
```

This updates `reports/adder_comparison.csv` from the local logs. **It overwrites the historical baseline CSV.** Commit the updated CSV and regenerate the graphs only after confirming the extracted values match the reports.

### 5. Regenerate graphs (optional)

Use a virtual environment if your Ubuntu Python installation is externally managed:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib
```

Then generate plots from the updated CSV with your preferred plotting script or notebook. The checked-in PNGs illustrate the historical baseline and are labelled accordingly in the results document.

## Constraints overview

`constraints.sdc` uses an illustrative 10 ns virtual clock, 1 ns input delay, 1 ns output delay, 0.1 input transition, and output load 5.0 (library capacitance units). These are comparison assumptions, not measured product-interface requirements. The library header in the prior workspace reported a 1 ns time unit and 1 fF capacitance unit. Verify the Liberty file's area convention before reporting units as µm²; this repository uses **library area units**.

## GitHub publishing

Review all files and ensure no restricted PDK/library files, credentials, personal paths, or generated bulky artifacts are included. Then:

```bash
git init
git add .
git status
git commit -m "Add 32-bit adder architecture comparison"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git
git push -u origin main
```

Create an empty repository on GitHub first and replace the placeholder URL. Never commit private/third-party libraries unless their terms permit it.

## Scope and limitations

- Combinational RTL only; no registers, clock-tree synthesis, floorplanning, placement, routing, or parasitic extraction.
- OpenSTA timing is based on the mapped netlist and illustrative SDC, not post-layout timing.
- PPA results depend on the exact RTL, synthesis tool/version, library, mapping options, and constraints.
- Simulation vectors are finite and do not constitute formal verification.
- The current regression uses Verilog `$random`; results are deterministic for the same simulator and seed behavior, but cross-simulator random sequences can differ.

See [`docs/`](docs/) for architecture, methodology, and result notes.
