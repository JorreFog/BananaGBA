#!/usr/bin/env python3
"""rasum.py <run dir>: rastats.log per phase of the ROM's phases.tsv (t since the first retro_run; the ROM's
own boot + scene inits make the alignment approximate to ~1 s). Prints a markdown table."""
import os, re, sys
run = sys.argv[1]
lines = [l for l in open(os.path.join(run, "rastats.log")) if l.startswith("rastats t=")]
ph = [(float(a), b.strip()) for a, b in (l.split("\t") for l in open(os.path.join(run, "phases.tsv")))]
rows = []
for l in lines:
    d = dict(re.findall(r"(\w+)=([\d.]+)", l))
    rows.append({k: float(v) for k, v in d.items()})
print("| phase | secs | fps avg | fps min | core ms avg | core p99 max | core cpu ms | run cpu ms | dupes | xruns |")
print("|---|---|---|---|---|---|---|---|---|---|")
for i, (st, name) in enumerate(ph):
    en = ph[i + 1][0] if i + 1 < len(ph) else 1e9
    r = [x for x in rows if st + 1 <= x["t"] < en]
    if not r:
        continue
    n = len(r)
    print(f"| {i} {name} | {n} | {sum(x['fps'] for x in r) / n:.2f} | {min(x['fps'] for x in r):.2f} | "
          f"{sum(x.get('core_ms', x['avg']) for x in r) / n:.3f} | {max(x.get('core_p99', x['p99']) for x in r):.3f} | {sum(x.get('core_cpu', 0) for x in r) / n:.3f} | {sum(x['cpu_ms'] for x in r) / n:.2f} | "
          f"{int(sum(x['dupes'] for x in r))} | {int(sum(x['xruns'] for x in r))} |")
tot = [l for l in open(os.path.join(run, "rastats.log")) if l.startswith("rastats total")]
if tot:
    print("\n" + tot[-1].strip())
