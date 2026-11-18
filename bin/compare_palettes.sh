#!/usr/bin/env bash
# compare_palettes.sh - compile one figure with BOTH palettes and put them side by side.
# Usage: compare_palettes <figure.tex> [dpi]     (on PATH via ~/.local/bin, see install.sh)
# The figure must \input{figstyle} + use slot colours (c1..c5, n). Output:
#   <figure>_palette_compare.png   row 1 = original | new, row 2 = deuteranopia simulation
#   <figure>__original.{pdf,png}, <figure>__new.{pdf,png}
set -euo pipefail
TEX="$(realpath "${1:?Usage: compare_palettes.sh <figure.tex> [dpi]}")"
DPI="${2:-150}"
DIR="$(dirname "$TEX")"; BASE="$(basename "$TEX" .tex)"
KIT="$(dirname "$(realpath "$0")")"
cd "$DIR"   # fontspec/relative paths resolve against the CWD
for P in original new; do
    JOB="${BASE}__${P}"
    for pass in 1 2; do
        if ! lualatex -interaction=nonstopmode -halt-on-error -jobname="$JOB" \
                "\\def\\figpalette{$P}\\input{$BASE.tex}" > "$JOB.compile.log" 2>&1; then
            echo "ERROR: $P palette failed to compile"; grep -A3 '^!' "$JOB.compile.log" || tail -20 "$JOB.compile.log"
            exit 1
        fi
    done
    pdftoppm -png -r "$DPI" -singlefile "$JOB.pdf" "$JOB"
    rm -f "$JOB.aux" "$JOB.log" "$JOB.compile.log"
done
python3 "$KIT/stitch_compare.py" "${BASE}__original.png" "${BASE}__new.png" "${BASE}_palette_compare.png"
echo "wrote $DIR/${BASE}_palette_compare.png"
