# BananaGBA: build, test and measure

BananaGBA = libretro's mGBA (7a12d6d, the core BananaOS ships today) + BananaOS changes, as a libretro core for
BananaFront (and RetroArch, the fallback). Branches: `banana/main` (README), `banana/threaded-video` (everything below).

## What BananaGBA changes (each measured on gbastress, exact: same frame + audio hashes)
- **Threaded rendering** (`mgba_banana_threaded_video`: auto / OFF / ON; BananaOS's package: auto = on under BananaFront,
  off under RetroArch): mGBA's thread proxy, which the libretro build had compiled out, draws the picture on a second
  core while the CPU emulation runs.
- **Memory maps at load** too (BananaFront's companion export reads them once the game is loaded).
- **PGO** profile in `banana/pgo` (trained on the RG DS with gbastress) + LTO in the package.
- **Workload fingerprint** (`BANANAGBA_STATS=1`): GBA CPU busy %, IRQs, DMA, sprites, video mode every 60 frames on
  stderr - to calibrate the stress ROM against real games.
- `LIBRETRO_OPT_LEVEL` (default -O3) for A/Bs; `banana/build.sh` keeps the toolchain's flags (BANANA_CFLAGS adds).
- Memory maps: unchanged (mGBA's are complete: IWRAM, EWRAM, SRAM, ROM, BIOS, VRAM, palette, OAM, I/O) - BananaFront
  exports them to the companion (COMPANION-SPEC).

## Build
`banana/build.sh <host|plus|rgds> [build-dir] [cmake args]` - through `~/overnight-2026-11-01/buildslot.sh`.
Cross builds use BananaLinux's Buildroot toolchain (gcc 14.3, `-mcpu=cortex-a55` by default); the RG DS and the Plus
run the same aarch64 binary.

## Test (every change)
1. **Exactness on the PC**: `~/banana-emu/common/lrhost/build/lrhost <core.so> gbastress-realistic.gba --frames 9300
   --every 1500` - frame + audio hashes must equal the stock core's.
2. **Exactness on the handheld** (compiler flags, LTO/PGO): `locked.sh rgds -- banana/gba-exact.sh rgds 3000 stock=a.so new=b.so`.
3. **Speed**: `locked.sh rgds -- banana/gba-ab.sh rgds 55 <tag> 2 stock=a.so new=b.so` (quick ROM, clock pinned at
   1416 MHz, A/B/A/B, through the menu launcher with rastats.so) -> `banana/absum.py` table: core ms/frame per scene,
   thread CPU %, fps, dupes, xruns, temperature.
4. **Baselines / soaks with full data**: `banana/gba-run.sh <dev> <gpsp|mgba> <secs> <tag> [core.so]` (stress-run.sh).
5. **Profile**: `banana/gba-prof.sh <dev> mgba <tag> <unstripped core.so>` (psample per scene).

## Tools (shared, `~/banana-emu/common`)
- `lrhost/` headless libretro host (hashes, --peek, --shot; correctness only, never speed).
- `rastats/rastats.so` LD_PRELOAD frame stats for RetroArch/BananaFront (core-only ms, dupes, xruns).
- `companion/` the universal companion export (bcomp) - BananaFront publishes this core's memory maps.

## Results (2026-11-01, RG DS unless noted; exact = same frame + audio hashes as stock on the handheld)
Pinned 1416 MHz, RetroArch, quick ROM, core-only ms/frame:
| build | ms/frame | vs stock | busiest thread | process CPU |
|---|---|---|---|---|
| stock mGBA (libretro 7a12d6d, BananaOS 0.5.0) | 5.94-6.25 | - | 46-48 % | 46-48 % |
| + LTO only | 5.93 (vs 6.02) | -1.4 % | 45.8 % | 45.8 % |
| threaded renderer | 4.74 | -21 % | 35.8 % | 46 % |
| threaded + LTO | 4.67-4.74 | -22..-24 % | 35 % | 45 % |
| threaded + LTO + PGO (final) | 4.28-4.42 | **-28..-29 %** | 32-34 % | 42-44 % |
| threaded, -O2 / hidden visibility / wake every 8 or 32 lines | 4.82 / 4.81 / 4.84 / 4.92 | worse | | |
Plus: stock 6.10 -> threaded + LTO 4.75 ms (-22 %).
Low clocks (pinned): 816 MHz stock 50.6 fps / final threaded 59.8 / final unthreaded 59.3; 600 MHz 33.4 / 55.4 / 35.3.
RetroArch at its GBA profile (~1.45 GHz): stock 7.48 ms 56 % CPU, final threaded 7.46 ms 69 %, final unthreaded 7.16 ms
54 % -> threaded "auto" is off there. BananaFront (schedutil): threaded settles at 600-816 MHz vs 1.4-1.6 GHz unthreaded,
0 dupes/underruns -> on there. gpSP (dynarec) for scale: 2.9-3.1 ms/frame at the user's settings.
