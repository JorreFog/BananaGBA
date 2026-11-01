#!/usr/bin/env python3
"""profcat.py <psym output>...: self time by category (idle, renderer, cpu interp, memory, dma, audio, timing, other core, frontend)"""
import re, sys
CATS = [("idle (wait/poll)", r"syscall_cancel|__libc_poll|nanosleep|futex|pthread_cond"),
        ("renderer", r"GBAVideoSoftware|_composite|_drawScanline|mosaic|Software(BG|Obj)|_postprocess|_preprocess"),
        ("cpu interpreter", r"^(ARM|Thumb|_ARM|_Thumb|_shift|_neutral|_additionS|_subtractionS|_immediate)"),
        ("memory", r"GBA(Load|Store|Memory|SetActiveRegion|Patch)|GBAView|_GBA(Load|Store)"),
        ("dma", r"DMA"),
        ("audio", r"Audio|blip|audio|_sample|mAudio|Resampler"),
        ("timing/events", r"mTiming|GBAProcessEvents|_startHblank|_startHdraw|_GBAVideo|GBATimer|GBAHalt|GBATestIRQ|GBAIRQ"),
        ("core other", r"^(GBA|_GBA|m[A-Z])"),
        ("libc copy", r"memcpy|memset|memmove"),
        ("frontend/gpu/drm", r".*")]
for f in sys.argv[1:]:
    tot = {}
    sect = False
    for l in open(f):
        if l.startswith("-- self"): sect = True; continue
        if l.startswith("-- inclusive"): break
        m = re.match(r"\s*([\d.]+)%\s+(\S+)", l)
        if not (sect and m): continue
        pct, fn = float(m.group(1)), m.group(2)
        for name, rx in CATS:
            if re.search(rx, fn):
                tot[name] = tot.get(name, 0) + pct
                break
    busy = 100 - tot.get("idle (wait/poll)", 0)
    print(f"== {f}: busy {busy:.1f} %")
    for name, _ in CATS:
        if name in tot and not name.startswith("idle"):
            print(f"  {name:18s} {tot[name]:5.1f} % of samples  ({100 * tot[name] / busy:4.1f} % of busy)")
