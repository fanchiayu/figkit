#!/usr/bin/env bash
# compile_tikz <figure.tex> [dpi]  ->  <figure>.pdf + <figure>.png next to the .tex
# Engine: LuaLaTeX if the file uses fontspec or figstyle (GenSenRounded needs it), otherwise pdfLaTeX.
# Override with ENGINE=lualatex|pdflatex|xelatex.
set -euo pipefail
TEX="${1:?Usage: compile_tikz <figure.tex> [dpi]}"
DPI="${2:-300}"
[[ -f "$TEX" && "$TEX" == *.tex ]] || { echo "ERROR: not a .tex file: $TEX" >&2; exit 1; }
DIR="$(cd "$(dirname "$TEX")" && pwd)"
BASE="$(basename "$TEX" .tex)"

if [[ -z "${ENGINE:-}" ]]; then
    if grep -qE '\\usepackage(\[[^]]*\])?\{fontspec\}|\\input\{[^}]*figstyle(\.tex)?\}|!TEX program *= *lualatex' "$DIR/$BASE.tex"; then
        ENGINE=lualatex
    else
        ENGINE=pdflatex
    fi
fi
command -v "$ENGINE" >/dev/null || { echo "ERROR: $ENGINE not found" >&2; exit 1; }

cd "$DIR"   # relative paths inside the figure (e.g. fontspec Path=../fonts/) resolve against its folder
LOG="$BASE.compile.log"
for pass in 1 2; do
    if ! "$ENGINE" -interaction=nonstopmode -halt-on-error "$BASE.tex" > "$LOG" 2>&1; then
        echo "ERROR: $ENGINE failed (pass $pass). Full log: $DIR/$LOG" >&2
        grep -A3 '^!' "$LOG" >&2 || tail -20 "$LOG" >&2
        exit 1
    fi
done

if command -v pdftoppm >/dev/null; then
    pdftoppm -png -r "$DPI" -singlefile "$BASE.pdf" "$BASE"
elif command -v gs >/dev/null; then
    gs -q -dNOPAUSE -dBATCH -sDEVICE=png16m -r"$DPI" -dTextAlphaBits=4 -dGraphicsAlphaBits=4 \
       -sOutputFile="$BASE.png" "$BASE.pdf"
else
    echo "WARNING: neither pdftoppm (poppler-utils) nor gs found; PNG skipped" >&2
fi
rm -f "$BASE.aux" "$BASE.log" "$BASE.out" "$BASE.synctex.gz" "$LOG"

echo "PDF: $DIR/$BASE.pdf"
if [[ -f "$BASE.png" ]]; then echo "PNG: $DIR/$BASE.png"; fi
