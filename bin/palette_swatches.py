#!/usr/bin/env python3
"""palette_swatches.py - plain swatch chart of both palettes (every slot x Pale/Light/Mid/Dark, with hex).
Usage: palette_swatches [out.png]        (default: palette_swatches.png; on PATH via install.sh)
Colours are read from python/figkit (keep it in sync with tex/palette_*.tex).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "python"))   # repo copy, even without install.sh

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

from figkit import PALETTES, TIERS, use_style

ROWS = {"original": [("c1", "藍"), ("c2", "紅"), ("c3", "金"), ("c4", "紫"), ("c5", "綠"), ("n", "灰")],
        "new": [("c1", "藍"), ("c2", "橘"), ("c3", "黃"), ("c4", "霧面粉"), ("c5", "霧面綠"), ("n", "灰")]}
TITLE = {"original": "A 原配色 (original)", "new": "B 新配色 (new)"}


def luminance(h):
    c = [int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    c = [x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def main(out="palette_swatches.png"):
    use_style()
    fig, axes = plt.subplots(1, 2, figsize=(13, 6.6))
    for ax, pal in zip(axes, ("original", "new")):
        P = PALETTES[pal]
        ax.set_xlim(-0.9, 4); ax.set_ylim(-0.25, 6.6); ax.invert_yaxis(); ax.axis("off")
        ax.text(-0.9, -0.2, TITLE[pal], fontsize=15, va="bottom")
        for j, t in enumerate(TIERS):
            ax.text(j + 0.5, 0.35, t.capitalize(), ha="center", va="center", fontsize=11, color="#757575")
        for i, (slot, name) in enumerate(ROWS[pal]):
            y = i + 0.6
            ax.text(-0.1, y + 0.45, f"{slot}\n{name}", ha="right", va="center", fontsize=11, linespacing=1.3)
            for j, t in enumerate(TIERS):
                h = P[slot][t]
                ax.add_patch(FancyBboxPatch(
                    (j + 0.06, y + 0.06), 0.88, 0.78, boxstyle="round,pad=0,rounding_size=0.08",
                    facecolor=h, edgecolor="#E0E0E0" if luminance(h) > 0.8 else "none", linewidth=0.8))
                ax.text(j + 0.5, y + 0.45, h.upper(), ha="center", va="center", fontsize=10.5,
                        color="black" if luminance(h) > 0.22 else "white")
    fig.tight_layout(w_pad=3)
    fig.savefig(out, dpi=200, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    print(f"wrote {Path(out).resolve()}")


if __name__ == "__main__":
    main(*sys.argv[1:2])
