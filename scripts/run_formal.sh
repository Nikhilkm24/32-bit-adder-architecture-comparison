#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v yosys >/dev/null || { echo "ERROR: yosys not found. Install Yosys." >&2; exit 1; }
mkdir -p reports
echo "===== Running Yosys SAT Formal Verification for all 4 adders ====="
yosys -s formal/verify_formal.ys 2>&1 | tee reports/formal_verify.log
echo "Formal verification complete. Proofs logged to reports/formal_verify.log"
