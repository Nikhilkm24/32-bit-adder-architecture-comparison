#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v iverilog >/dev/null || { echo "ERROR: iverilog not found. Install Icarus Verilog." >&2; exit 1; }
command -v vvp >/dev/null || { echo "ERROR: vvp not found. Install Icarus Verilog." >&2; exit 1; }
mkdir -p sim reports
iverilog -g2012 -Wall -s tb_all_adders -o sim/all_adders.vvp \
  rtl/ripple_carry_32.v rtl/brent_kung_32.v rtl/kogge_stone_32.v tb/tb_all_adders.v
vvp sim/all_adders.vvp | tee reports/all_adders_sim.log
if ! grep -q 'PASS: All three adders match' reports/all_adders_sim.log; then
  echo "ERROR: regression did not report PASS" >&2
  exit 1
fi
