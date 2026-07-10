# 人生劇場（Jones in the Fast Lane）繁中化 — worklist / 交接

repo：`github.com/wicanr2/jones_in_the_fast_lane`。工作目錄 `~/scummvm/jones_in_the_fast_lane/workplace`。
引擎路線：ScummVM **SCI**（非 AGS），沿用 qfg-1 的 `ZH_TWN`+Big5 繪字管線。中文化**僅放 ScummVM patch**。

## 現況快照（2026-07-10）

| 里程碑 | 狀態 |
|---|---|
| M0 可行性 + 骨架 | ✅ 偵測/dump/抽字打通，術語表建於 `docs/10-terminology.md` |
| **M1 端到端 spike** | ✅ **版權畫面繁中渲染實機驗證**（`docs/images/m1-spike-copyright-cht.png`，CHT-HIT） |
| **M2 全文字中文化** | ✅ **776 則翻譯**(773 靜態+3 supplement)；商店/大學對白+動態「第N週」實機驗證；長尾見下 |
| **M3 烘字 UI（view/pic）** | ✅ 主體：SCI1 view+pic codec 完成驗證；棋盤 12+ 招牌、14 按鈕、目標橫幅重繪實機驗證。零星標題/credits/logo 待補 |
| **M4 打包 + README** | 🔨 引擎 patch(0001+0002)+CHT 資料包(dist/game-cht)+圖文 README 完成；push GitHub |

## 引擎改動（相對 qfg-1 base，Jones 專屬）

於 `scummvm-src/`（複製自 qfg-1 已編譯樹，增量 build）：
1. `engines/advancedDetector.cpp` — 語言過濾加例外：`ZH_TWN 請求可匹配 EN_ANY 條目`（identify 過關關鍵）。
2. `engines/sci/graphics/fontchinese.cpp` — `kChineseFontFile` = **`jones_big5.fnt`**（原 qfg1_big5.fnt）。
3. `engines/sci/sci.cpp` — `getChtTranslation()` 加 `SCI_CHT_DEBUG` 環境變數 log（HIT/MISS 除錯用，behind getenv 無害）。
4. 其餘沿用 qfg-1 patch（`GfxFontChinese`、`text16.cpp` hook、`getLanguage` override、各 dump hook）。

> ⚠ M4 需把上述改動**重新生成乾淨 patch 檔**進 `patches/`（目前 live 在 scummvm-src；patches/ 內是 qfg-1 base）。

## 工具鏈修正（相對 qfg-1）

- `tools/extract_strings.py` — `clean()` 改為**保留硬換行為 `\n` 跳脫**（原正規化成空格會導致 runtime MISS）。
- `tools/build_cht.py` — 輸出檔名 `jones_big5.fnt`；字型改 **wqy-zenhei（黑體）15px**（原 qfg1 明體）。

## 關鍵指令

### 抽字（dump → skeleton）
```
# dump（timeout 包住，dump 完會 segfault 但資料已出）:
docker run --rm -v "$PWD/scummvm-src:/src" -v "$PWD/extract/game_lc:/game" \
  -v "$PWD/extract/dump:/out" -v "$PWD/tools:/tools" jones-... bash /tools/dump_res.sh
python3 tools/extract_strings.py extract/dump translation/skeleton.tsv
```

### 建 runtime（翻譯 → 字型 + tsv）
```
docker run --rm -v "$PWD:/w" -v /usr/share/fonts:/hostfonts:ro jones-tools:latest \
  python3 tools/build_cht.py translation/<canonical>.tsv dist \
  --size 15 --font /hostfonts/truetype/wqy/wqy-zenhei.ttc --face 0
cp dist/jones_big5.fnt dist/translation.tsv extract/game_lc/
```

### 引擎 build（增量）
```
docker run --rm -v "$PWD/scummvm-src:/src" -w /src qfg1-build:latest bash -c 'make -j$(nproc)'
```

### 實機跑（截圖 / 驗證）
```
# 用 qfg1-capture image（xvfb）;target config 存 language=tw:
./scummvm --path=/game --add ; sed -i 's/^language=en$/language=tw/' <ini>
SCI_CHT_DEBUG=1 ./scummvm jones   # 印 CHT-HIT/MISS
```

## 踩雷（別重踩）

- **dump hook 跑完會 segfault**（在 dumped 訊息之後），資料已完整，docker run 一律 `timeout` 包住。
- `--language=tw` **命令列**會讓 SCI identify 失敗；要嘛靠 detector 例外 patch + target config 存 `language=tw`。
- runtime 字串含 `0x0A` 硬換行，抽字/翻譯的 key **必須用 `\n` 跳脫**對齊，否則精確 match MISS。
- 遊戲目錄用**小寫檔名**（`extract/game_lc`）。

## 下一步（接續就做）：M2

1. **補抽 script 內嵌字串**：確認 `extract_ega_scripts.py` 對 SCI1 Jones 的 script 抽取，合併進 skeleton。
2. **分批派 haiku subagent 翻譯** 622+ 則（依 `docs/10-terminology.md` 術語，保留 `%d`/`\n`）。
3. `merge_translations.py` 併回 → `translation/translation.tsv`（canonical）。
4. `build_cht.py` 烘全字集 → `dist/`，實機掃各畫面驗證覆蓋率與換行觀感。

## 記憶
`~/.claude/projects/-home-anr2-scummvm-janes-in-fast-lane/memory/`（架構 + 踩雷）。

## M2 補充(2026-07-10 完成主體)

- **語料 774 則**：text 622 + script 152（`extract_ega_scripts.py` 抽），8 批 haiku 翻譯，`merge_translations.py` 100% 命中。
- **烘字**：`build_cht.py` 用 **wqy-zenhei 15px**，1305 字；`translation/corrections.tsv` 修 `®`→`(R)`、日文變體 `薫`→`燻`。
- **build 輸入改用 `translation/translation_full.tsv`**（= `translation.tsv` canonical + `supplement.tsv`）。
- **動態字**：新增 `engines/sci/engine/kstring.cpp` 的 **kFormat hook**——ZH_TWN 時先翻譯 format 模板（含 %d）再代入，解掉「Week #%2d→第 %2d 週→第 1 週」等。
- **supplement**：`extract_ega_scripts.py` 啟發式漏抽的（前導空格/`\n\n`）challenge 對白，直接補精確 key 於 `translation/supplement.tsv`。

### M2 已知長尾（M3 playtest 時用 MISS-collection 收尾）
- `Goal Points = 200 !` 這類 **StrCat 組字**（靜態前綴+數字連接後才繪）仍可能 MISS——已補 `Goal Points = ` 前綴，待實測。
- 純格式片段 `%d!`/`%s!`（無可譯文字，產出數字，無需翻）。
- **完整性 gate**：跑一輪各畫面 `SCI_CHT_DEBUG=1` 收集所有含文字的 CHT-MISS，補進 supplement。此為 M2 最終驗收，安排在 M3 實機 playtest 一併做。

## M-hires:640×400 高解析中文（2026-07-10 完成）

引擎在 ZH_TWN 自動切 `GFX_SCREEN_UPSCALED_640x400`（`screen.cpp`），art 仍 2x nearest 放大，但**中文字改以 2x 直接繪入 display buffer** 保持清晰（rule 81）。

- **Part 1｜文字 hi-res**：`jones_big5_hi.fnt`（32×30，1310 字，`build_cht_hires.py` 由 wqy-zenhei 28px 烘）。`fontchinese.cpp` 的 `drawHires()` 逐字 2x 繪入 → 版權頁/對白/選單中文清晰不糊。
- **Part 2｜棋盤招牌疊繪**：`paint16.cpp` 的 `drawChtBoardSigns()`——drawPicture 畫完 pic 11 後，讀 `jones_signs.dat`（13 筆招牌座標/顏色/中文，`tools/gen_signs.py` 產）＋ `jones_big5_hi.fnt`，把各招牌英文帶填底色再疊清晰中文（字形縮放貼合小招牌帶）。**座標已烘成 hi-res 640×400 pixel（logical ×2），引擎端不再乘 2**。
- **patch**：新增 `patches/0003-jones-hires-signs.patch`（paint16 疊繪），`apply_patches.sh` 依序套 0001→0002→0003。
- **play-fair 對話框**：`公平競爭 / 全力一搏` 已中文化（M3 view.010 一併）。

### M-hires JONES GOALS 畫面(2026-07-10 補完)
- **橫幅 `JONES GOALS` → 瓊斯的目標**：provenance trace（`SCI_LOG_GFX`）定位為 **view 506 loop0 cel1**（135×24，與已重繪的 cel0=設定你的目標 同 loop 的另一 cel）。`tools/redraw_506.py` 以 base = 已含 cel0 中文的 `view.506` dump，只換 cel1，重新 encode → `506.v56`。
- **`Goal Points = 200 !` → 目標點數 = 200 !**：`SCI_CHT_DEBUG` 抓到實際 runtime 為 `kFormat("%s%3d !", "Goal Points = ", 200)`——`%s` 參數才是要翻的字。新增 **patch `0004`**：kFormat 的 `case 's'` 對 `%s` 參數字串也跑 `getChtTranslation`（模板本身在 0002 已翻）。資料端 `translation_full.tsv` 去重（`Goal Points = ` 統一為 目標點數，移除舊 目標分數），重建 runtime + 兩套字型。
- 兩者皆實機驗證：goals 畫面橫幅、目標點數動態字、完成鈕全繁中且 hi-res 清晰。

## M-hires 標題 logo(2026-07-10 完成)

**pic 0 標題「JONES IN THE FAST LANE」→「人生劇場」**（版權頁後那張經典 Sierra 標題）。
- 定位：pic.000 只有 1 個內嵌 cel（cel0，193×165，含 Sierra 球標 + SIERRA PRESENTS + JONES 標題框）。
- 設計：派 3 個設計師 subagent 並行出稿（忠實 3D 還原 / 現代黑體 / 明體古典戲單），使用者選 **明體古典**（金色粗明體 + 深藍戲單框，呼應「劇場」，保留 Sierra 球標與英文副標致敬）。`tools/redraw_title.py` 自足重跑（由 pic.000 取調色盤與參考 cel → 產 mockup → 呼叫 `sci1_pic.py replace` → `0.p56`）。
- 交付：`dist/game-cht/0.p56`；實機驗證標題畫面金字清晰。
- **credits（更正）**：先前誤判「無獨立 credits 畫面」。實測(AppImage 測試時)發現**標題後會自動播一段 credits 動畫序列**——封面美術 + 角色頭銜與人名（Executive Producer Ken Williams…）。人名屬專有名詞(維持原文),但頭銜 label(Executive Producer / Designed by…)仍為英文烘字，屬**未完成長尾**(需定位該序列的 view/text 再處理)。標題 logo pic_0 已完成。
