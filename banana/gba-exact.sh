#!/bin/bash
# gba-exact.sh plus|rgds <frames> name=core.so ...: exactness on the handheld (headless lrhost: correctness only,
# never timing): frame + audio hashes every 300 frames of gbastress-realistic, each build vs the first. Under locked.sh.
set -u
D=$1 N=$2; shift 2
DEV=~/bananaos-0.4.3/dev.sh
dev() { "$DEV" "$D" "$@"; }
trap 'dev "rm -rf /run/gbaexact"' EXIT
dev 'mkdir -p /run/gbaexact/sys && cat > /run/gbaexact/lrhost && chmod 755 /run/gbaexact/lrhost' < ~/banana-emu/common/lrhost/build-a64/lrhost || exit 1
dev 'cat > /run/gbaexact/rom.gba' < ~/ovn-gba/tools/test-roms/gbastress-realistic.gba
first=
for a in "$@"; do
	n=${a%%=*} so=${a#*=}
	dev "cat > /run/gbaexact/$n.so" < "$so"
	h=$(dev "cd /run/gbaexact && nice -n 19 ./lrhost ./$n.so rom.gba --frames $N --every 300 --sysdir sys 2>/dev/null | md5sum | cut -c1-16")
	echo "$n $h${first:+ $( [ "$h" = "$first" ] && echo SAME || echo DIFFERENT)}"
	[ -z "$first" ] && first=$h
done
