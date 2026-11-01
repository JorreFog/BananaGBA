# BananaGBA's PGO profile

`.gcda` files of a `-fprofile-generate -fprofile-update=prefer-atomic` build of this tree (threaded renderer on),
trained on the RG DS with gbastress-quick (all six scenes, 3900 frames, headless lrhost - a training run, not a
measurement), Buildroot's gcc 14.3. The Buildroot package copies `CMakeFiles/` next to its in-source build's objects
and compiles with `-fprofile-use -fprofile-partial-training -Wno-coverage-mismatch` (a file whose source changed since
is ignored for that function). Measured: -6.7 % ms/frame on top of threaded + LTO, exact (same frame/audio hashes).
Retrain after real changes: `banana/gba-pgo-train.sh` (see banana/README.md).
