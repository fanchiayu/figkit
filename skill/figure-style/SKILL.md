---
name: figure-style
description: The user's personal figure/slide visual standard (all their machines) — two academic palettes (original / new) chosen per batch via an A/B comparison, slide colours, font GenSenRounded B, 1.5pt strokes, rounded arrows, and the ~/figkit tooling (compile_tikz, compare_palettes, palette_swatches, python `figkit`). Load BEFORE drawing or styling any figure in any project: academic/paper/thesis figures, TikZ, matplotlib plots, diagrams, flowcharts, architecture figures, bar/line charts, colour choices, slide colours. Triggers also in Chinese: 畫圖、論文圖、學術圖、示意圖、流程圖、架構圖、長條圖、折線圖、配色、顏色、簡報配色、TikZ、matplotlib。
---

# 使用者的圖面規範(跨電腦通用)

工具與指令細節:`~/figkit/README.md`。這裡是規則。本檔與工具都在 repo `github.com/fanchiayu/figkit`(公開;clone 在 `~/figkit`,`install.sh` 把本 skill 連到 `~/.claude/skills/`)。改規則/改色 = 改 repo,commit + push 後其他電腦 `git pull` 才同步;push 前先問 user。

## 1. 兩種配色,別混
- **學術圖**:兩套並存(A 原配色 / B 新配色),見 §2。
- **簡報**:主色 深藍 `#163E64` + 淺灰 `#E8E8E8`;橘 `#E97132` = 重要字;一般字黑。(橘白底對比 3.06 → 小字要粗/大。)
- user 分得很清楚;被要求配學術圖色時,不要去做簡報版面/字級。

## 2. 學術圖:每批先出 A/B 對照,user 選
1. 一批圖開工前,先挑代表圖,寫成只用槽位色的 TikZ(圖檔開頭 `\providecommand{\figpalette}{new}` + `\input{figstyle}`;或用 `figkit.PALETTES` 的 matplotlib)。
2. `compare_palettes <fig.tex>` → 把 `<fig>_palette_compare.png` 給 user 看(上排 A|B,下排綠色盲模擬)。
3. **由 user 選**,不要替 user 選;選定後整批 `\providecommand{\figpalette}{original|new}`。

槽位(兩套同名):c1 一般/既有/baseline · c2 貢獻/Ours · c3 第三類/參考 · c4 · c5 · n 中性灰(不當類別色)。四階 Pale=底、Light=填色/長條、Mid=框/線、Dark=重點字。一般字黑、次要字 `black!54`、箭頭 c1 Dark。

| 槽 | A 原配色 Pale/Light/Mid/Dark | B 新配色(Light=Tol light, Mid=Okabe-Ito) |
|---|---|---|
| c1 | 藍 `D1E5F0 8EC4DE 3A93C3 1065AB` | 藍 `E6F2FE 77AADD 0072B2 065D92` |
| c2 | 紅 `FEDBC7 F6A482 D75F4C B31529` | 橘 `FFEBE5 EE8866 D55E00 944003` |
| c3 | 金 `FFF2CC FFE699 BF9000 806000` | 黃 `F7F1D2 EEDD88 E69F00 775103` |
| c4 | 紫 `E5D4E8 C3A4CF 986EAC 742881` | 霧面粉 `FEEAF0 ECCAD4 984E61 7F405F` |
| c5 | 綠 `D9F1D5 ADD4A0 5CAE63 1B7939` | 霧面綠 `E7F5E8 A4C0A8 77A48C 3C5F4D` |
| n | 灰 `E8E8E8 9E9E9E 424242 1B1B1B` | 同左 |

真相來源 = `~/figkit/tex/palette_{original,new}.tex` 與 `~/figkit/python/figkit/__init__.py`(改色兩邊一起改,並跑 `palette_swatches ~/figkit/demo/palette_swatches.png` 更新色階圖)。user 要看色階/色碼 → 給 `~/figkit/demo/palette_swatches.png`(純色塊+色碼,不是 demo 示意圖)。A 的金 Pale/Mid = user 原本的 `FFF2CC`/`BF9000`(2026-11-19 更正,舊值 F9E6A9/C89400 與 user 原檔不符);這組是 Office 金 `FFC000` 的淺 80%/深 25%,Light/Dark 取同家族的淺 60% `FFE699`/深 50% `806000`(user 選的)。黃色不要照其他色的「Light 比 Mid 灰」比例推 — 會變米色。

## 3. 共通樣式(已寫進 `~/figkit/tex/figstyle.tex`)
- 字體 **GenSenRounded B**(檔案在 `~/figkit/fonts/`,install.sh 連進 TEXMFHOME 與系統字型;TikZ 需 LuaLaTeX)。
- **框、線段、箭頭 1.5pt**(以最終插入尺寸計;格線不算)。user 曾說「至少 2.5pt」— 那是簡報尺度,在 ~14 cm 圖上太粗,user 看過 1.0–2.5 對照後選 1.5。
- 箭頭 `-{Stealth[round, length=3.6mm, width=3.4mm]}`,`line cap/join=round`。
- 圖以最終插入寬度繪製;要縮放就等比例換算 `\strokeW`。

## 4. 色盲:講準,不要誇大
- 量法:dataviz `validate_palette.js` 的模型(Machado 2009 severity 1.0,OKLab ΔE×100;色盲 ≥8 及格、正常 ≥15)。
- A 原配色在最嚴重二色視下 藍↔紫 3.6、金↔綠 7.2、紅↔綠 偏低;**只在「顏色是唯一線索」的線/點圖才有問題**(加標籤/線型即可)。user 的有字架構圖已模擬驗證沒問題、色弱朋友也認得出 — **不要說 A「不色盲友善」**。
- B:三色 Light 16.0 / Mid 13.1;用到 5 色時 Light 約 7–12、Pale 幾乎全撞 → 流程圖靠 Mid 框、長條/折線要圖例或直接標籤;Dark 只當字色(c2/c3 Dark 很像)。

## 5. 資料圖(matplotlib 長條/折線/散點;2026-11 VO 論文重繪時 user 逐條定的)
§3 的 1.5pt 是示意圖/TikZ 的框線;資料圖照這節。程式:`use_style(data=True)` + 每個 axes `style_axes(ax, ...)`,常數 `BASELINE_GRAY`、`MARKER_AREA`。
- **軸**:左+下 L 形,軸線/刻度 **1.0pt**(1.5、1.2 都嫌粗);**一定畫 y 軸**(示意圖那種只有底線的不要)。並排子圖**每格都標自己的 y 刻度數字和 y 軸說明**,即使共用範圍。散點圖可四邊框(`box=True`)。
- **格線**:最淺灰 `E8E8E8`,在資料後面;一般只橫線 0.8pt,散點圖橫直都要、0.5pt。
- **字級**:刻度 8、軸說明 9、圖例 8、子圖代號 A/B 11。計數(個數)的軸不加單位。
- **配色**:主色 **藍 c1 + 黃 c3**(給主要比較的方法);基準/原始方法用**灰**(`BASELINE_GRAY`:線/點 `9E9E9E`、長條填 `E8E8E8`+框 `9E9E9E`);第 4 色 **綠 c5**(並排比過,user 選綠不選紅)。**同一方法在同一篇論文所有圖同色**。不要死板照「藍→黃→紅→綠」順序填(user 推翻過)。拿不準就出 2–3 版並排讓 user 挑 — 這招很有效。
- **長條**:Light 填色 + 0.8pt Mid 邊框(純 Light、純 Mid user 都說醜)。對數軸上 0 的 bin 不畫。
- **折線**:又密又抖的資料線 1.0pt(1.5 會糊),圖例線 1.5pt;移動平均用置中視窗、邊緣不補零(`rolling(n, center=True, min_periods=1)`),免得端點掉下去的假象。
- **散點**:Mid 實心、**不加邊框**(Light 太淡、1.5pt 邊框太重);基準大小 `s≈22`(約 11 cm 寬時),乘 `MARKER_AREA`(圓 1.0/方 0.88/三角 1.25)讓三種看起來一樣大;保留不同形狀當顏色以外的線索。小點用黃 Mid 偏暗時可改亮黃(VO 用過 `E6B000`,色盤外,只限該圖)。
- **圖例**:多子圖 → 底部共用一個、一行、無框;單圖放空白角落。
- **重畫既有的圖**:保持原圖子圖長寬比(壓扁成 ~2:1 會讓點擠成一團,比原圖難看)。
- **輸出**:以最終插入寬度繪製,PDF + PNG,`pdf.fonttype 42`(CID/OpenType 嵌字,非 Type 3);交付時告訴 user 每張的插入寬度(`pdfinfo` 量),圖例文字變長會改寬度。

## 6. 驗證習慣
畫完一定實際編譯並看 PNG;示意圖裡的數字一律標「假資料」;產物放該專案慣例的產物夾。
