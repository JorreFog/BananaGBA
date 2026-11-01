#!/bin/bash
# pgo-build.sh <trained gen build dir> <new build dir> [extra C flags]: the .gcda files of a trained
# -fprofile-generate build copied into a fresh build dir's tree, then built with -fprofile-use (through buildslot)
set -eu
G=$1 N=$2 X=${3:-}
cd "$(dirname "$0")/.."
n=$(cd "$G" && find . -name '*.gcda' | wc -l); [ "$n" -gt 0 ] || { echo "no .gcda in $G (train first)"; exit 1; }
mkdir -p "$N"; (cd "$G" && find . -name '*.gcda' -print0 | cpio -0pdm --quiet "$N")
echo "$n profiles -> $N"
T=~/BananaLinux/output/rgds-plus/host/bin/aarch64-linux
~/overnight-2026-11-01/buildslot.sh banana/build.sh plus "$N" -DCMAKE_C_FLAGS="-fprofile-use -fprofile-partial-training -Wno-missing-profile $X" "${@:4}"
