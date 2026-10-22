#!/usr/bin/env python3
"""Extract mapped area/cell counts and timing fields from Yosys/OpenSTA logs."""
from pathlib import Path
import csv
import re

ROOT = Path(__file__).resolve().parents[1]
DESIGNS = [
    ("Ripple-Carry", "rca", "ripple_carry_32"),
    ("Brent-Kung", "bk", "brent_kung_32"),
    ("Kogge-Stone", "ks", "kogge_stone_32"),
]

def last_match(pattern: str, text: str):
    matches = re.findall(pattern, text, re.MULTILINE)
    return matches[-1] if matches else ""

rows = []
for name, short, top in DESIGNS:
    synth_path = ROOT / "reports" / f"{short}_synth.log"
    sta_path = ROOT / "reports" / f"{short}_sta.log"
    sim_path = ROOT / "reports" / "all_adders_sim.log"
    synth_text = synth_path.read_text(errors="replace") if synth_path.exists() else ""
    sta_text = sta_path.read_text(errors="replace") if sta_path.exists() else ""
    sim_text = sim_path.read_text(errors="replace") if sim_path.exists() else ""
    cells = last_match(r"Number of cells:\s*(\d+)", synth_text)
    area = last_match(r"Chip area for module .*?:\s*([0-9.]+)", synth_text)
    arrival = last_match(r"([0-9.]+)\s+data arrival time", sta_text)
    slack = last_match(r"([-+]?[0-9.]+)\s+slack\s+\(MET\)", sta_text)
    errors = ""
    label = {"rca": "RCA", "bk": "Brent-Kung", "ks": "Kogge-Stone"}[short]
    m = re.search(rf"{re.escape(label)} errors:\s*(\d+)", sim_text)
    if m:
        errors = m.group(1)
    rows.append({
        "Architecture": name, "Width": 32, "Test_Vectors": 100010 if sim_text else "",
        "Simulation_Errors": errors, "Mapped_Cells": cells, "Area_Library_Units": area,
        "Data_Arrival_ns": arrival, "Worst_Slack_ns": slack,
        "Timing_Status": "MET" if slack else "Not parsed / not run",
    })

out = ROOT / "reports" / "adder_comparison.csv"
with out.open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    writer.writeheader()
    writer.writerows(rows)
print(f"Wrote {out.relative_to(ROOT)}")
for row in rows:
    print(row)
