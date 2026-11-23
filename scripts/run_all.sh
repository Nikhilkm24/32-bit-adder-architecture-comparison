#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/run_formal.sh
./scripts/run_sim.sh
./scripts/run_synth.sh
./scripts/run_sta.sh
python3 scripts/summarize_results.py
python3 scripts/plot_results.py
