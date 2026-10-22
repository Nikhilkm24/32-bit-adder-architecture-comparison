#!/usr/bin/env python3
"""Create area and data-arrival comparison plots from reports/adder_comparison.csv."""
from pathlib import Path
import csv
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "reports" / "adder_comparison.csv"
with source.open(newline="") as f:
    rows = list(csv.DictReader(f))
if not rows:
    raise SystemExit(f"No result rows found in {source}")

names = [r["Architecture"] for r in rows]
area = [float(r["Area_Library_Units"]) for r in rows]
arrival = [float(r["Data_Arrival_ns"]) for r in rows]

plt.figure(figsize=(9, 5.5))
bars = plt.bar(names, area)
plt.title("32-bit Adder Cell-Area Comparison")
plt.xlabel("Architecture")
plt.ylabel("Cell area (library area units)")
plt.bar_label(bars, fmt="%.3f", padding=3)
plt.tight_layout()
plt.savefig(ROOT / "reports" / "area_comparison.png", dpi=300)
plt.close()

plt.figure(figsize=(9, 5.5))
bars = plt.bar(names, arrival)
plt.title("32-bit Adder Reported Data-Arrival-Time Comparison")
plt.xlabel("Architecture")
plt.ylabel("Data arrival time (ns)")
plt.bar_label(bars, fmt="%.3f ns", padding=3)
plt.tight_layout()
plt.savefig(ROOT / "reports" / "timing_comparison.png", dpi=300)
plt.close()
print("Generated reports/area_comparison.png and reports/timing_comparison.png")
