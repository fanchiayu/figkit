#!/usr/bin/env bash
# install.sh — set up figkit on this machine. Safe to re-run.
# Everything is a symlink back into this repo, so `git pull` updates every machine.
set -euo pipefail
REPO="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/figkit/backup-$(date +%Y%m%d-%H%M%S)"

link() {  # link <target-in-repo> <link-path>; a real file/dir already there is moved to $BACKUP
    local tgt="$1" lnk="$2"
    mkdir -p "$(dirname "$lnk")"
    if [[ -e "$lnk" && ! -L "$lnk" ]]; then
        mkdir -p "$BACKUP"; mv "$lnk" "$BACKUP/"
        echo "  (moved existing $lnk to $BACKUP/)"
    fi
    ln -sfn "$tgt" "$lnk"
    echo "  $lnk -> $tgt"
}

echo "[1/5] Claude Code skill (figure-style)"
link "$REPO/skill/figure-style" "$HOME/.claude/skills/figure-style"

echo "[2/5] commands"
BIN="$HOME/.local/bin"
link "$REPO/bin/compile_tikz.sh"     "$BIN/compile_tikz"
link "$REPO/bin/compare_palettes.sh" "$BIN/compare_palettes"
case ":$PATH:" in
    *":$BIN:"*) ;;
    *) echo "  NOTE: $BIN is not on PATH. Add to ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo "[3/5] TeX: style + font through TEXMFHOME (so figures just write \\input{figstyle})"
if command -v kpsewhich >/dev/null; then
    TEXMFHOME="$(kpsewhich -var-value TEXMFHOME)"
    link "$REPO/tex"   "$TEXMFHOME/tex/latex/figkit"
    link "$REPO/fonts" "$TEXMFHOME/fonts/opentype/figkit"
else
    echo "  SKIPPED: TeX Live not found (no kpsewhich). Install it, then re-run ./install.sh"
fi

echo "[4/5] system font (other apps; matplotlib reads the repo copy directly)"
FONTDIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
if command -v fc-list >/dev/null \
   && fc-list : file | grep -F 'GenSenRounded2TW-B.otf' | grep -vqF -e "$FONTDIR/figkit/" -e "$REPO/fonts/"; then
    echo "  GenSenRounded2TW-B is already installed elsewhere; skipped"
else
    link "$REPO/fonts" "$FONTDIR/figkit"
    if command -v fc-cache >/dev/null; then fc-cache -f "$FONTDIR" >/dev/null || true; fi
fi

echo "[5/5] Python: import figkit"
if command -v python3 >/dev/null; then
    SITE="$(python3 -m site --user-site)"
    mkdir -p "$SITE"
    echo "$REPO/python" > "$SITE/figkit.pth"
    echo "  $SITE/figkit.pth -> $REPO/python   (in a venv: create it with --system-site-packages)"
else
    echo "  SKIPPED: python3 not found"
fi

echo
echo "Checks:"
missing=0
need() { if command -v "$1" >/dev/null; then echo "  ok       $1"; else echo "  MISSING  $1  -> $2"; missing=1; fi; }
need lualatex "TeX Live. Ubuntu: sudo apt install texlive-luatex texlive-latex-recommended texlive-latex-extra texlive-pictures"
need pdftoppm "Ubuntu: sudo apt install poppler-utils"
need python3  "Ubuntu: sudo apt install python3 python3-pip"
if command -v python3 >/dev/null; then
    if python3 -c "import matplotlib, PIL, numpy" 2>/dev/null; then echo "  ok       python: matplotlib pillow numpy"
    else echo "  MISSING  python packages -> pip install --user matplotlib pillow numpy"; missing=1; fi
fi

if [[ $missing -eq 0 && "${FIGKIT_SKIP_TEST:-0}" != 1 ]]; then
    echo
    echo "Self-test: compiling demo/demo_figure.tex in a temp folder (first LuaLaTeX run builds the font cache; can take a minute) ..."
    T="$(mktemp -d)"
    cp "$REPO/demo/demo_figure.tex" "$T/"
    if "$REPO/bin/compile_tikz.sh" "$T/demo_figure.tex" 100 >/dev/null 2>"$T/err" \
       && pdffonts "$T/demo_figure.pdf" 2>/dev/null | grep -q GenSenRounded2TW-B \
       && python3 -c "import figkit; figkit.use_style()" 2>>"$T/err"; then
        echo "  PASS: TikZ figure embeds GenSenRounded2TW-B; python figkit imports"
        rm -rf "$T"
    else
        echo "  FAIL — see $T/err (and $T/*.compile.log)"; exit 1
    fi
fi
echo
echo "Done. Skill 'figure-style' shows up in Claude Code from the next session."
