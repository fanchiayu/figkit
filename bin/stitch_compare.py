"""stitch_compare.py <original.png> <new.png> <out.png>
Row 1: original | new.  Row 2: both under deuteranopia (Machado 2009, severity 1.0)."""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

DEUTAN = np.array([[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]])
FONT = Path(__file__).resolve().parents[1] / "fonts" / "GenSenRounded2TW-B.otf"   # ships with the repo


def deutan(img):
    a = np.asarray(img).astype(float) / 255
    lin = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
    o = np.clip(lin @ DEUTAN.T, 0, 1)
    return Image.fromarray((np.where(o <= 0.0031308, 12.92 * o, 1.055 * o ** (1 / 2.4) - 0.055) * 255).round().astype(np.uint8))


def main(orig, new, out):
    A, B = Image.open(orig).convert("RGB"), Image.open(new).convert("RGB")
    W, H = max(A.width, B.width), max(A.height, B.height)
    gap, head = 40, 60
    canvas = Image.new("RGB", (2 * W + gap, 2 * (H + head) + gap), "white")
    d = ImageDraw.Draw(canvas)
    f = ImageFont.truetype(str(FONT), max(22, W // 40))
    labels = [("A 原配色", "B 新配色"), ("A 原配色 — 綠色盲模擬", "B 新配色 — 綠色盲模擬")]
    for r, imgs in enumerate([(A, B), (deutan(A), deutan(B))]):
        y = r * (H + head + gap)
        for c, im in enumerate(imgs):
            x = c * (W + gap)
            d.text((x + 8, y + 10), labels[r][c], fill="#163E64", font=f)
            canvas.paste(im, (x, y + head))
    canvas.save(out)


if __name__ == "__main__":
    main(*sys.argv[1:4])
