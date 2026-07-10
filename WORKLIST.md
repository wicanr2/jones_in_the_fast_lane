# 人生劇場（Jones in the Fast Lane）繁中化 — worklist / 交接

repo：`github.com/wicanr2/jones_in_the_fast_lane`。工作目錄 `~/scummvm/jones_in_the_fast_lane/workplace`。
引擎路線：ScummVM **SCI**（非 AGS），沿用 qfg-1 的 `ZH_TWN`+Big5 繪字管線。中文化**僅放 ScummVM patch**。

## 現況快照（2026-07-10）

| 里程碑 | 狀態 |
|---|---|
| M0 可行性 + 骨架 | ✅ 偵測/dump/抽字打通，術語表建於 `docs/10-terminology.md` |
| **M1 端到端 spike** | ✅ **版權畫面繁中渲染實機驗證**（`docs/images/m1-spike-copyright-cht.png`，CHT-HIT） |
| M2 全文字中文化 | 🔲 text 622 則已抽；script 內嵌字串待補抽；翻譯待做 |
| M3 烘字 UI（view/pic） | 🔲 未開始（風險：sci_view.py 寫死 SCI1.1，Jones 為 SCI1） |
| M4 多平台打包 + README | 🔲 未開始 |

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
