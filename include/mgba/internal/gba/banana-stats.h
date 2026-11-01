/* BananaGBA: workload fingerprint counters (off unless BANANAGBA_STATS is set; the stress-test-roms rule: a stress
 * scene is realistic when its fingerprint sits in the range real games produce). MPL-2.0 like mGBA. */
#ifndef GBA_BANANA_STATS_H
#define GBA_BANANA_STATS_H
#include <stdint.h>
struct GBABananaStats {
	int on;
	uint64_t haltCycles, irqs, dmaUnits, dmaStarts;
};
extern struct GBABananaStats gbaBananaStats;
#define BANANA_STAT(x) do { if (__builtin_expect(gbaBananaStats.on, 0)) { x; } } while (0)
#endif
