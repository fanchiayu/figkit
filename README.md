# figkit

個人學術圖樣式工具包:兩套配色(A 原配色 / B 新配色)、GenSenRounded B 字型、1.5pt 線寬、圓頭箭頭,外加 Claude Code skill **`figure-style`**(規則寫在 `skill/figure-style/SKILL.md`)。

![兩套配色對照(上排一般、下排綠色盲模擬;假資料)](demo/demo_figure_palette_compare.png)

## 新電腦安裝
```bash
git clone https://github.com/fanchiayu/figkit.git ~/figkit
cd ~/figkit && ./install.sh
```
需要 TeX Live(LuaLaTeX)、poppler-utils、python3 + matplotlib/pillow/numpy;`install.sh` 會檢查,缺什麼就印出安裝指令,齊了會自動編一張 demo 圖驗證。
**更新**:`cd ~/figkit && git pull`。裝好的東西全是連到 repo 的連結,不用重跑 `install.sh`(只有 `install.sh` 本身改了才要重跑)。

`install.sh` 建立的連結(原位置若已有真實檔案,先搬到 `~/.local/state/figkit/backup-<時間>/`):

| 位置 | 指向 | 用途 |
|---|---|---|
| `~/.claude/skills/figure-style` | `skill/figure-style/` | Claude Code 畫圖/配色時自動載入規則 |
| `~/.local/bin/compile_tikz`、`compare_palettes` | `bin/` | 任何目錄可用的指令 |
| `$TEXMFHOME/tex/latex/figkit`(通常 `~/texmf`) | `tex/` | 圖檔只寫 `\input{figstyle}` |
| `$TEXMFHOME/fonts/opentype/figkit` | `fonts/` | LuaLaTeX 找字型 |
| `~/.local/share/fonts/figkit` | `fonts/` | 系統字型(系統已有此字型就跳過) |
| user site-packages 的 `figkit.pth` | `python/` | `import figkit`(venv 要 `--system-site-packages`) |

## 流程
畫一批圖之前:挑這批的代表圖 → `compare_palettes <fig.tex>` → 看 `<fig>_palette_compare.png`(A | B,下排綠色盲模擬)→ 選定 → 整批圖檔寫 `\providecommand{\figpalette}{original 或 new}`。

## 用法
| 指令 | 作用 |
|---|---|
| `compile_tikz <x.tex> [dpi]` | 編成同目錄的 PDF+PNG(用到 fontspec/figstyle 自動 LuaLaTeX;`ENGINE=` 可覆寫) |
| `compare_palettes <x.tex> [dpi]` | 同一張圖兩套配色各編一次,並排 + 綠色盲模擬 |

TikZ 圖檔:
```latex
\documentclass[border=8pt]{standalone}
\providecommand{\figpalette}{new}   % original | new
\input{figstyle}                    % 字型、線寬、箭頭、role-map、配色
```
只用槽位色 `c1`–`c5` + `n`(中性灰),各 `pale/light/mid/dark`,不寫死 hex。方塊 `slotbox=c2`、箭頭 `arr`、線寬 `\strokeW`。範例 `demo/demo_figure.tex`。

matplotlib:
```python
from figkit import PALETTES, use_style
use_style()                       # GenSenRounded B + 1.5pt
color = PALETTES["new"]["c2"]["mid"]
```

## 檔案
`tex/figstyle.tex`(共用樣式)· `tex/palette_original.tex`、`tex/palette_new.tex`(兩套,同槽位名,檔尾記弱點)· `python/figkit/__init__.py`(同一組色碼;**改色兩邊一起改**)· `bin/`(兩個指令 + `stitch_compare.py`)· `fonts/` · `skill/figure-style/SKILL.md` · `demo/`

## 字型授權
`fonts/GenSenRounded2TW-B.otf` = 源泉圓體 GenSenRounded2 TW B(ButTaiwan,基於 Adobe Source Han Sans),SIL Open Font License 1.1,全文見 `fonts/SIL_Open_Font_License_1.1.txt`。上游:<https://github.com/ButTaiwan/gensen-font>

## 坑
LuaLaTeX 字型快取(`$(kpsewhich -var-value TEXMFVAR)/luatex-cache/generic/fonts/otl/gensenrounded2tw-*`)會記住第一次載入時的檔案路徑;若那次是用相對路徑(例如別的專案寫 `Path=../fonts/`),之後其他目錄嵌字型會報 `cannot find file ''`。修法:把那幾個快取檔移走,再用 `figstyle` 編一次。
