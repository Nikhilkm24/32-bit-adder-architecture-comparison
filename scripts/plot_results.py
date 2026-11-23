#!/usr/bin/env python3
"""Generate publication-quality comparative plots for 32-bit adders."""
from pathlib import Path
import csv
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "reports" / "adder_comparison.csv"
if not source.exists():
    raise SystemExit(f"Missing {source}. Run summarize_results.py first.")

with source.open(newline="") as f:
    rows = list(csv.DictReader(f))

if not rows:
    raise SystemExit(f"No result rows found in {source}")

names = [r["Architecture"] for r in rows]
colors = ["#2b5c8f", "#d95f02", "#7570b3", "#1b9e77"]

# 1. Area Comparison
plt.figure(figsize=(9, 5.5))
area = [float(r["Area_Library_Units"]) if r["Area_Library_Units"] else 0.0 for r in rows]
bars = plt.bar(names, area, color=colors, edgecolor="black", width=0.55)
plt.title("32-bit Adder Standard Cell Area Comparison (Nangate 45nm)", fontsize=13, fontweight="bold")
plt.xlabel("Architecture", fontsize=11, fontweight="bold")
plt.ylabel("Cell Area (Library Units)", fontsize=11, fontweight="bold")
plt.grid(axis="y", linestyle="--", alpha=0.6)
plt.bar_label(bars, fmt="%.3f", padding=4, fontsize=10, fontweight="bold")
plt.ylim(0, max(area) * 1.15)
plt.tight_layout()
plt.savefig(ROOT / "reports" / "area_comparison.png", dpi=300)
plt.close()

# 2. Timing Comparison (Data Arrival Time)
plt.figure(figsize=(9, 5.5))
arrival = [float(r["Data_Arrival_ns"]) if r["Data_Arrival_ns"] else 0.0 for r in rows]
bars = plt.bar(names, arrival, color=colors, edgecolor="black", width=0.55)
plt.title("32-bit Adder Critical Path Delay / Data Arrival (OpenSTA)", fontsize=13, fontweight="bold")
plt.xlabel("Architecture", fontsize=11, fontweight="bold")
plt.ylabel("Data Arrival Time (ns)", fontsize=11, fontweight="bold")
plt.grid(axis="y", linestyle="--", alpha=0.6)
plt.bar_label(bars, fmt="%.3f ns", padding=4, fontsize=10, fontweight="bold")
plt.ylim(0, max(arrival) * 1.18)
plt.tight_layout()
plt.savefig(ROOT / "reports" / "timing_comparison.png", dpi=300)
plt.close()

# 3. Power Comparison
if any(r.get("Total_Power_uW") for r in rows):
    plt.figure(figsize=(9, 5.5))
    power = [float(r["Total_Power_uW"]) if r.get("Total_Power_uW") else 0.0 for r in rows]
    bars = plt.bar(names, power, color=colors, edgecolor="black", width=0.55)
    plt.title("32-bit Adder Total Power Consumption (OpenSTA @ 100MHz)", fontsize=13, fontweight="bold")
    plt.xlabel("Architecture", fontsize=11, fontweight="bold")
    plt.ylabel("Total Power (μW)", fontsize=11, fontweight="bold")
    plt.grid(axis="y", linestyle="--", alpha=0.6)
    plt.bar_label(bars, fmt="%.3f μW", padding=4, fontsize=10, fontweight="bold")
    plt.ylim(0, max(power) * 1.18)
    plt.tight_layout()
    plt.savefig(ROOT / "reports" / "power_comparison.png", dpi=300)
    plt.close()

# 4. Area-Delay Product (ADP)
if any(r.get("Area_Delay_Product") for r in rows):
    plt.figure(figsize=(9, 5.5))
    adp = [float(r["Area_Delay_Product"]) if r.get("Area_Delay_Product") else 0.0 for r in rows]
    bars = plt.bar(names, adp, color=colors, edgecolor="black", width=0.55)
    plt.title("32-bit Adder Area-Delay Product (ADP = Area × Delay)", fontsize=13, fontweight="bold")
    plt.xlabel("Architecture", fontsize=11, fontweight="bold")
    plt.ylabel("ADP (Area Units × ns)", fontsize=11, fontweight="bold")
    plt.grid(axis="y", linestyle="--", alpha=0.6)
    plt.bar_label(bars, fmt="%.2f", padding=4, fontsize=10, fontweight="bold")
    plt.ylim(0, max(adp) * 1.18)
    plt.tight_layout()
    plt.savefig(ROOT / "reports" / "adp_comparison.png", dpi=300)
    plt.close()

print("All comparative plots generated successfully in reports/")
