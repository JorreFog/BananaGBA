# BananaGBA: build, test and measure

BananaGBA = libretro's mGBA (7a12d6d, the core BananaOS ships today) + BananaOS changes, as a libretro core for
BananaFront (and RetroArch, the fallback). Branches: `banana/main` (README), `banana/threaded-video` (everything below).

## What BananaGBA changes (each measured on gbastress, exact: same frame + audio hashes)
- **Threaded rendering** (`mgba_banana_threaded_video`, default ON in BananaOS's package): mGBA's thread proxy, which
  the libretro build had compiled out, draws the picture on a second core while the CPU emulation runs.
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

## Results (2026-11-01, gbastress quick, RG DS, RetroArch, clock pinned 1416 MHz; core-only ms/frame)
| build | ms/frame | vs stock | busiest thread | process CPU |
|---|---|---|---|---|
| stock mGBA (libretro 7a12d6d, BananaOS 0.5.0) | 6.01 | - | 46.3 % | 46.3 % |
| + LTO only | 5.93 | -1.4 % | 45.8 % | 45.8 % |
| threaded renderer | 4.74-4.76 | -21 % | 35.8 % | 45.9-46.0 % |
| threaded + LTO | 4.67 | -22 % | 35.3 % | 45.4 % |
| threaded, -O2 / hidden visibility | 4.82 / 4.81 | -20 % | 36 % | 46.5 % |
All exact (frame + audio hashes equal over 3000 frames on the handheld). gpSP (dynarec) for scale: 2.9-3.1 ms/frame
at the user's settings (~1 GHz) - mGBA stays an interpreter (accuracy), BananaGBA takes a quarter off its busiest core.
