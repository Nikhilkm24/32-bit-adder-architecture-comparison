# Experimental methodology

## Functional verification

The common self-checking testbench instantiates all three adders and compares `{Cout, Sum}` against a 33-bit arithmetic reference. It applies ten directed vectors that include zero, all-ones, alternating patterns, carry propagation, and high-bit cases, followed by 100,000 pseudo-random vectors. Each vector is held for 1 ns before comparison.

A PASS indicates that no mismatch was observed in those simulated vectors. It is not formal equivalence proof or exhaustive testing of all input combinations.

## Synthesis and technology mapping

The same Yosys sequence is used for all architectures:

1. Read the RTL.
2. Check and select the top module.
3. Run `synth -flatten -noabc`.
4. Map logic with ABC using `lib/nangate_typ.lib`.
5. Clean the netlist and run `check`.
6. Report final statistics and write a mapped Verilog netlist.

Report the final mapped cell count and cell area from the final statistics block. Do not compare intermediate pre-mapping cell counts.

## Static timing analysis

OpenSTA reads the same Liberty library, each mapped netlist, and `constraints.sdc`. Each script calls `report_checks` for the maximum-delay path. The current constraints are illustrative and are held constant to support a relative comparison.

- Virtual clock period: 10 ns
- Input delay: 1 ns
- Output delay: 1 ns
- Input transition: 0.1 (time unit consistent with the Liberty setup)
- Output load: 5.0 (library capacitance units)

The data arrival time reported by OpenSTA includes the timing environment represented in the path report. Do not call it intrinsic cell-only adder delay without deriving that quantity explicitly from path details. Positive slack means the analyzed path meets the specified constraints in that model.

## Reproducibility record

Record tool versions, exact RTL revision, Liberty file identity/version, SDC, synthesis logs, and STA logs. Compare designs only when these are held constant. For publication, preserve a clean run of the scripts from the exact source revision being reported.
