# Results and interpretation

## Historical measurements reported from the original workspace

The following values were supplied from the user's previous WSL runs. They are preserved as a historical baseline, not a promise that the clean BK/KS RTL in this archive reproduces the same values. The exact original BK/KS RTL was not included in the supplied starter package; rerun simulation, synthesis, and STA on this archive before treating any metric as a result for this source revision.

| Metric | Ripple-Carry | Brent–Kung | Kogge–Stone |
|---|---:|---:|---:|
| Width | 32 | 32 | 32 |
| Test vectors per design | 100,010 | 100,010 | 100,010 |
| Simulation errors | 0 | 0 | 0 |
| Final mapped cells | 161 | 190 | 179 |
| Cell area (library area units) | 195.776 | 219.716 | 214.130 |
| Reported data arrival time (ns) | 2.186 | 1.675 | 2.041 |
| Worst slack (ns) | 6.814 | 7.325 | 6.959 |
| Timing status under the stated constraints | MET | MET | MET |

## Interpretation of the historical measurements

- RCA had the lowest reported mapped area and cell count.
- BK had the lowest reported data arrival time and the highest positive slack.
- KS was between RCA and BK for both reported area and arrival time.

These outcomes are specific to the original RTL and tool flow. They do not establish a universal ranking for the architectures. In particular, the theoretical prefix depth of an architecture does not guarantee the best mapped timing for every RTL, library, and synthesis setup.

## Area and timing percentages from the historical measurements

Using RCA's reported data arrival time as the reference:

- BK arrival time was approximately 23.38% lower than RCA.
- KS arrival time was approximately 6.63% lower than RCA.
- BK arrival time was approximately 17.93% lower than KS.

These are percentages of reported path arrival times, not necessarily intrinsic adder delay improvements.

## Units and limitations

The area figures are called **library area units** because the Liberty area convention was not independently confirmed here. Timing figures are synthesis-level static timing estimates with the specified SDC; they are not post-placement, post-routing, or silicon measurements. The historical result CSV and PNG graphs reflect this same historical baseline.
