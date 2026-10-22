# Illustrative constraints for a combinational adder.
# These are analysis assumptions, not a claim about a real chip interface.
# Liberty header in this project reports time_unit = 1ns and capacitance unit = 1fF.

create_clock -name VCLK -period 10.0

set_input_delay  1.0 -clock VCLK [get_ports {A[*] B[*] Cin}]
set_output_delay 1.0 -clock VCLK [get_ports {Sum[*] Cout}]

set_input_transition 0.1 [get_ports {A[*] B[*] Cin}]
set_load 5.0 [get_ports {Sum[*] Cout}]
