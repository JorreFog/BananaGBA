#!/usr/bin/env python3
"""absum.py <ab dir> <secs>: gba-ab.sh's runs per variant - core ms/frame per scene of the quick ROM (10 s phases),
thread CPU %, fps, dupes, xruns, temperature. Means over rounds; the spread (min-max of the run means) beside."""
import glob, os, re, sys
from collections import defaultdict
d, secs = sys.argv[1], float(sys.argv[2])
SC = ["racer", "shooter", "town", "raster", "loader"]
PH = 600 / (16777216 / 280896)          # quick ROM phase length in s
runs = defaultdict(list)
for f in sorted(glob.glob(os.path.join(d, "*-[0-9]*.txt"))):
    name = os.path.basename(f).rsplit("-", 1)[0]
    txt = open(f).read()
    rows = []
    for l in txt.splitlines():
        if l.startswith("rastats t="):
            rows.append({k: float(v) for k, v in re.findall(r"(\w+)=([\d.]+)", l)})
    def cpu(block):
        m = re.search(r"== %s\n(.*?)(?:\n==|\Z)" % block, txt, re.S)
        out = {}
        for l in (m.group(1).splitlines() if m else []):
            p = l.rsplit(" ", 2)
            if len(p) == 3:
                out.setdefault(p[0], 0)
                out[p[0]] += int(p[1]) + int(p[2])
        return out
    c0, c1 = cpu("cpu0"), cpu("cpu1")
    thr = {k: (c1.get(k, 0) - c0.get(k, 0)) / (secs * 100) * 100 for k in c1}
    tm = re.search(r"^temp (\d+) (\d+) freq (\d+)", txt, re.M)
    rows = [r for r in rows if r["t"] >= 3]           # warm-up
    if not rows:
        continue
    per = defaultdict(list)
    for r in rows:
        per[SC[int(r["t"] // PH) % 5]].append(r.get("core_ms", 0))
    runs[name].append({
        "core": sum(r.get("core_ms", 0) for r in rows) / len(rows),
        "cpu": sum(r.get("core_cpu", 0) for r in rows) / len(rows),
        "fps": sum(r["fps"] for r in rows) / len(rows),
        "dupes": sum(r["dupes"] for r in rows), "xruns": sum(r["xruns"] for r in rows),
        "scene": {k: sum(v) / len(v) for k, v in per.items()},
        "main": thr.get("retroarch", 0), "total": sum(thr.values()),
        "temp": (int(tm.group(1)) / 1000, int(tm.group(2)) / 1000) if tm else (0, 0), "freq": int(tm.group(3)) if tm else 0})
base = None
print("| variant | runs | core ms/frame | spread | vs first | core cpu ms | fps | RA main thread % | process % | dupes | xruns | temp start-end | " + " | ".join(SC) + " |")
print("|" + "---|" * (12 + len(SC)))
for n, rs in runs.items():
    k = len(rs)
    core = sum(r["core"] for r in rs) / k
    base = base or core
    sp = max(r["core"] for r in rs) - min(r["core"] for r in rs)
    sc = " | ".join(f"{sum(r['scene'].get(s, 0) for r in rs) / k:.3f}" for s in SC)
    print(f"| {n} | {k} | {core:.3f} | {sp:.3f} | {100 * (core / base - 1):+.1f} % | {sum(r['cpu'] for r in rs) / k:.3f} | "
          f"{sum(r['fps'] for r in rs) / k:.2f} | {sum(r['main'] for r in rs) / k:.1f} | {sum(r['total'] for r in rs) / k:.1f} | "
          f"{sum(r['dupes'] for r in rs):.0f} | {sum(r['xruns'] for r in rs):.0f} | "
          f"{sum(r['temp'][0] for r in rs) / k:.0f}-{sum(r['temp'][1] for r in rs) / k:.0f} C | {sc} |")
print(f"\nclock pinned: {', '.join(str(r['freq']) for rs in runs.values() for r in rs)} kHz (scaling_cur_freq at the end)")
