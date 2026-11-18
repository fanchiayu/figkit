"""Same two palettes for matplotlib.  Usage:
    from figkit import PALETTES, use_style   # importable anywhere via figkit.pth in user site-packages
    P = PALETTES["new"]          # or "original"
    P["c2"]["mid"]               # -> "#D55E00"
    use_style()                  # GenSenRounded B + 1.5pt lines
Slots: c1 baseline/general, c2 contribution/Ours, c3 third/reference, c4, c5; n = neutral gray.
Keep in sync with tex/palette_original.tex / tex/palette_new.tex.
"""
TIERS = ("pale", "light", "mid", "dark")


def _fam(*hexes):
    return dict(zip(TIERS, (f"#{h}" for h in hexes)))


_NEUTRAL = _fam("E8E8E8", "9E9E9E", "424242", "1B1B1B")

PALETTES = {
    "original": {
        "name": "原配色(藍/紅/金/紫/綠)",
        "c1": _fam("D1E5F0", "8EC4DE", "3A93C3", "1065AB"),
        "c2": _fam("FEDBC7", "F6A482", "D75F4C", "B31529"),
        "c3": _fam("FFF2CC", "FFE699", "BF9000", "806000"),
        "c4": _fam("E5D4E8", "C3A4CF", "986EAC", "742881"),
        "c5": _fam("D9F1D5", "ADD4A0", "5CAE63", "1B7939"),
        "n": _NEUTRAL,
    },
    "new": {
        "name": "新配色(藍/橘/黃/霧面粉/霧面綠)",
        "c1": _fam("E6F2FE", "77AADD", "0072B2", "065D92"),
        "c2": _fam("FFEBE5", "EE8866", "D55E00", "944003"),
        "c3": _fam("F7F1D2", "EEDD88", "E69F00", "775103"),
        "c4": _fam("FEEAF0", "ECCAD4", "984E61", "7F405F"),
        "c5": _fam("E7F5E8", "A4C0A8", "77A48C", "3C5F4D"),
        "n": _NEUTRAL,
    },
}

import os
from pathlib import Path

# repo/python/figkit/__init__.py -> repo/fonts/ (the font ships with the repo); FIGKIT_FONT overrides.
FONT_PATH = os.environ.get("FIGKIT_FONT") or str(
    Path(__file__).resolve().parents[2] / "fonts" / "GenSenRounded2TW-B.otf")


def use_style():
    import matplotlib.pyplot as plt
    from matplotlib import font_manager
    font_manager.fontManager.addfont(FONT_PATH)
    plt.rcParams.update({
        "font.family": font_manager.FontProperties(fname=FONT_PATH).get_name(),
        "lines.linewidth": 1.5, "axes.linewidth": 1.5, "patch.linewidth": 1.5,
        "xtick.major.width": 1.5, "ytick.major.width": 1.5,
        "lines.solid_capstyle": "round", "lines.solid_joinstyle": "round",
    })
