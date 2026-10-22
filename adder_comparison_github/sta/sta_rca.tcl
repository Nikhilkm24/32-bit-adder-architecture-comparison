# Run from repository root with OpenSTA.
read_liberty lib/nangate_typ.lib
read_verilog synth/ripple_carry_32_netlist.v
link_design ripple_carry_32
read_sdc constraints.sdc

puts "\n===== RIPPLE-CARRY TIMING REPORT ====="
report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pin net fanout} -digits 3
