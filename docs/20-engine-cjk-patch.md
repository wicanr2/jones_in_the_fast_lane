# 20 — 引擎繪字 patch

繁中化在 ScummVM SCI 引擎新增一條 `ZH_TWN` + Big5 繪字路徑。patch 分兩檔（見 `patches/`）：

## 0001-sci-cht-zh_twn.patch（SCI 繁中 base，沿用 qfg-1）
- `graphics/fontchinese.{h,cpp}`：`GfxFontChinese`——ASCII 走原 SCI 字型，Big5 雙位元組走 `Big5Font`。
  字型檔名 `jones_big5.fnt`（Jones 專屬）。
- `graphics/cache.cpp`：`getFont()` 在 `ZH_TWN` 時把任何 fontId 包成 `GfxFontChinese`。
- `graphics/text16.cpp`：4 個文字入口（DrawString×2 / Box / DrawStatus）在 `ZH_TWN` 時查 `getChtTranslation()` 換字串。
- `sci.cpp/h`：`getLanguage()` 覆蓋（config `language=tw` → ZH_TWN）、`loadChtTranslation()`/`getChtTranslation()`（content-keyed HashMap，`\n` 跳脫還原 0x0A）、各 `SCI_DUMP_*` hook。

## 0002-jones-sci1-cht.patch（Jones/SCI1 專屬）
- `advancedDetector.cpp`：語言過濾加例外——**請求 ZH_TWN 可匹配 EN_ANY 英文條目**（fan-translation 情境，identify 過關關鍵）。
- `engines/sci/engine/kstring.cpp`：**kFormat hook**——`ZH_TWN` 時先翻譯 format 模板（含 `%d`）再代入，
  解動態組字（`Week #%2d` → 模板譯成 `第 %2d 週` → 代入 → `第 1 週`）。
- `sci.cpp`：`getChtTranslation()` 加 `SCI_CHT_DEBUG` 環境變數 log（HIT/MISS 除錯）。

## 啟用
target config 存 `language=tw`（**不要**用命令列 `--language=tw`，會讓 SCI identify 失敗）。
