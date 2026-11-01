# BananaGBA: build, test and measure

BananaGBA = libretro's mGBA (7a12d6d, the core BananaOS ships today) + BananaOS changes, as a libretro core for
BananaFront (and RetroArch, the fallback). Branches: `banana/main` (README), `banana/threaded-video` (mGBA's thread
proxy in the libretro core).

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
