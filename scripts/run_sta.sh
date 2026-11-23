#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
STA_BIN="${STA_BIN:-$(command -v sta || true)}"
if [[ -z "$STA_BIN" && -x "$HOME/OpenSTA/build/sta" ]]; then STA_BIN="$HOME/OpenSTA/build/sta"; fi
if [[ -z "$STA_BIN" && -x "/usr/local/bin/sta" ]]; then STA_BIN="/usr/local/bin/sta"; fi
if [[ -z "$STA_BIN" || ! -x "$STA_BIN" ]]; then
  echo "ERROR: OpenSTA executable not found. Set STA_BIN=/path/to/sta or install OpenSTA." >&2
  exit 1
fi
if [[ ! -f lib/nangate_typ.lib ]]; then
  echo "ERROR: lib/nangate_typ.lib is missing." >&2; exit 1
fi
for netlist in synth/ripple_carry_32_netlist.v synth/brent_kung_32_netlist.v synth/kogge_stone_32_netlist.v synth/han_carlson_32_netlist.v; do
  [[ -f "$netlist" ]] || { echo "ERROR: Missing $netlist. Run scripts/run_synth.sh first." >&2; exit 1; }
done
mkdir -p reports
"$STA_BIN" -exit sta/sta_rca.tcl 2>&1 | tee reports/rca_sta.log
"$STA_BIN" -exit sta/sta_bk.tcl  2>&1 | tee reports/bk_sta.log
"$STA_BIN" -exit sta/sta_ks.tcl  2>&1 | tee reports/ks_sta.log
"$STA_BIN" -exit sta/sta_hc.tcl  2>&1 | tee reports/hc_sta.log
