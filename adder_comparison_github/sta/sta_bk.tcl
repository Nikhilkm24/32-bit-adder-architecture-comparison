# Run from repository root with OpenSTA.
read_liberty lib/nangate_typ.lib
read_verilog synth/brent_kung_32_netlist.v
link_design brent_kung_32
read_sdc constraints.sdc

puts "\n===== BRENT-KUNG TIMING REPORT ====="
report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pin net fanout} -digits 3
