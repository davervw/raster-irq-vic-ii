#!/bin/sh -x
export ACME=${USERPROFILE}/Downloads/acme0.97win/acme
export VICE=${USERPROFILE}/Downloads/GTK3VICE-3.8-win64/bin
mkdir build 2>/dev/null
${ACME}/acme -f cbm -o build/rasterirq.prg -l build/rasterirq.lbl rasterirq.asm \
&& ${VICE}/c1541 rasterirq.d64 -attach rasterirq.d64 8 -delete rasterirq.ml -write build/rasterirq.prg rasterirq.ml\
&& rm d64_files/* \
&& ${VICE}/c1541 rasterirq.d64 -attach rasterirq.d64 8 -cd d64_files -extract \
&& ls -l d64_files \
&& ${VICE}/x64sc -moncommands build/rasterirq.lbl -autostart rasterirq.d64 >/dev/null 2>&1 &
