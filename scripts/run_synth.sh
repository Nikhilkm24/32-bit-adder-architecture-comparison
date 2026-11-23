#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v yosys >/dev/null || { echo "ERROR: yosys not found. Install Yosys." >&2; exit 1; }
if [[ ! -f lib/nangate_typ.lib ]]; then
  echo "ERROR: lib/nangate_typ.lib is missing. Add the Nangate typical Liberty file you are authorized to use." >&2
  exit 1
fi
mkdir -p synth reports
run_one() {
  local top="$1" rtl="$2" short="$3"
  echo "===== Synthesizing ${top} ====="
  yosys -p "read_verilog ${rtl}; hierarchy -check -top ${top}; synth -top ${top} -flatten -noabc; abc -liberty lib/nangate_typ.lib; clean; check; stat -liberty lib/nangate_typ.lib; write_verilog -noattr synth/${top}_netlist.v" 2>&1 | tee "reports/${short}_synth.log"
}
run_one ripple_carry_32 rtl/ripple_carry_32.v rca
run_one brent_kung_32 rtl/brent_kung_32.v bk
run_one kogge_stone_32 rtl/kogge_stone_32.v ks
run_one han_carlson_32 rtl/han_carlson_32.v hc
