# Run from repository root with OpenSTA.
read_liberty lib/nangate_typ.lib
read_verilog synth/han_carlson_32_netlist.v
link_design han_carlson_32
read_sdc constraints.sdc

puts "\n===== HAN-CARLSON TIMING REPORT ====="
report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pin net fanout} -digits 3

puts "\n===== HAN-CARLSON POWER REPORT ====="
report_power -digits 4
