#!/bin/bash
# gba-pgo-train.sh plus|rgds <instrumented core.so> <build dir of that core> [frames]: PGO training on the handheld
# (headless lrhost: the training run, not a measurement) over every gbastress scene; the .gcda files come back into
# the build dir's tree. Under locked.sh.
set -u
D=$1 SO=$2 BD=$3 N=${4:-9300}
DEV=~/bananaos-0.4.3/dev.sh
dev() { "$DEV" "$D" "$@"; }
trap 'dev "rm -rf /run/gbapgo"' EXIT
dev 'mkdir -p /run/gbapgo/sys /run/gbapgo/prof && cat > /run/gbapgo/lrhost && chmod 755 /run/gbapgo/lrhost' < ~/banana-emu/common/lrhost/build-a64/lrhost || exit 1
dev 'cat > /run/gbapgo/rom.gba' < ${PGO_ROM:-$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba}
dev 'cat > /run/gbapgo/core.so' < "$SO"
dev "cd /run/gbapgo && GCOV_PREFIX=/run/gbapgo/prof GCOV_PREFIX_STRIP=0 nice -n 19 ./lrhost ./core.so rom.gba --frames $N --every 0 --sysdir sys | tail -1"
dev "cd /run/gbapgo/prof && tar -cf - ." | tar -C / -xvf - 2>/dev/null | grep -c gcda
