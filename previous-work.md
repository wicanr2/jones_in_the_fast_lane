# previous-work.md — 人生劇場繁中化 開發交接

跨機接續用。專案：Jones in the Fast Lane（人生劇場）ScummVM SCI 繁體中文化。
工作目錄 `~/scummvm/jones_in_the_fast_lane/workplace`；GitHub `github.com/wicanr2/jones_in_the_fast_lane`（main 已 push）。

## 現況快照（2026-07-10，主體全完成）

- **M0–M4 完成**。文字 100% 繁中（776 則）；烘字美術主體（棋盤 12+ 招牌、14 按鈕、5 畫面標題、目標橫幅）重繪並實機驗證。
- 自寫 **SCI1 view+pic 編解碼器**（`tools/sci1_view.py` / `sci1_pic.py`）：decode 對引擎 oracle 725/752 pixel-perfect、RLE roundtrip 15/15。
- 引擎 patch：`patches/0001`（SCI 繁中 base，沿用 qfg-1）+ `patches/0002`（Jones/SCI1 專屬：detector ZH_TWN→EN_ANY 例外、kFormat 動態字 hook、SCI_CHT_DEBUG）+ `patches/fontchinese.{h,cpp}`。
- 打包：`out/jones-cht-{patch,data,linux}-*.tar.gz` + 推廣影片 `out/jones-cht-promo.mp4`（含原版配樂）。

## 本次做的工作（依主題）

- **文字管線**：`SCI_DUMP_RES` 抽字 → `extract_strings.py`（text，保留 `\n` 跳脫）+ `extract_ega_scripts.py`（script）→ 8 批 haiku 翻譯 → `merge_translations.py` → `build_cht.py`（wqy-zenhei 15px Big5）。`supplement.tsv` 補漏抽字。`corrections.tsv` 修 `®`/日文變體。
- **烘字**：`sci1_view.py`（view，未壓縮重建）、`sci1_pic.py`（pic 內嵌 cel，RLE 編碼）；`redraw_signs.py`/`redraw_buttons.py`/`redraw_titles.py` 批次重繪。patch `.v56`/`.p56` 放遊戲目錄。
- **推廣影片**：`make_promo.sh`（靜態+fade、金框、Noto Sans CJK 字幕）+ `promoshots.sh`（截圖）。配樂 = 原版 **PCjr** 音樂（見下）。

## 工具鏈 / harness（全 docker）

- `qfg1-build`（build ScummVM SCI）、`qfg1-capture`（xvfb 截圖）、`jones-tools`（Pillow 烘字）、`jones-video`（ffmpeg/IM/字型）、`jones-audio`（+pulseaudio 錄音樂）。Dockerfile 都在 `docker/`。
- build：`apply_patches.sh <src>` → `./configure --disable-all-engines --enable-engine=sci --disable-detection-full --disable-mt32emu && make`。

## 鐵則 / 硬約束

- 中文化**僅放 ScummVM patch**；原遊戲資源/衍生美術**不入庫**（`.gitignore` 排除 `game/`、`extract/`、`scummvm-src/`）。
- 啟用中文：target config 存 `language=tw`（**不要**命令列 `--language=tw`，會讓 SCI identify 失敗）。
- 抽字/翻譯 key 硬換行必 `\n` 跳脫；`%d`/`%2d`/`$` 格式符原樣保留。
- **配樂[HARD]用原版**：Jones 音樂是 **PCjr/Tandy track**（**無 AdLib/MT-32**）→ `music_driver=pcjr` 才有聲；`--disable-mt32emu`（此 checkout munt 缺 config.h 無法編，且 Jones 用不到）。

## 待辦 / 開放項目

- 零星未做烘字：挑戰畫面 `play fair?`/`go for broke?` 按鈕、開場 credits 人名、標題 logo `pic_0`。
- 多平台打包（Win/Mac/Android）：可比照 qog-2 的 CI/cross-compile；目前只做 Linux。
- M2 長尾：`Goal Points = N` 這類 StrCat 組字仍可能 MISS（可用 `SCI_CHT_DEBUG` MISS-collection 收尾）。

## § 在別台電腦接續（claude -r）

1. 把本包解到**相同絕對路徑** `/home/<user>/scummvm/jones_in_the_fast_lane/workplace`（session 目錄編碼才對得上）。
2. 還原 Claude session：`cp -a claude-session/projects/-home-anr2-scummvm-janes-in-fast-lane ~/.claude/projects/`。
3. 重建環境：`bash tools/apply_patches.sh scummvm-src`（scummvm-src 需先 clone pinned ScummVM 2026.2.1git 或從 git 取）→ docker build 各 image → `make`。
4. 接續對話：`cd <workplace> && claude --resume 07cf138e-bac0-4973-9ea1-43d524816253`
   （路徑不同時用 UUID 直接 resume，或改 `~/.claude/projects/<新路徑編碼>`）。

## 記憶索引

`~/.claude/projects/-home-anr2-scummvm-janes-in-fast-lane/memory/jones-cht-architecture.md`（架構+卡點+踩雷）。
repo 內 `WORKLIST.md`（唯一真相）、`docs/00–40`。
