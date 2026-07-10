# 00 — 可行性評估（M0，已驗證）

## 遊戲版本

- **Jones in the Fast Lane — DOS/English**，Sierra SCI1（VGA 256 色，`sciv256.exe`）。
- 資源：`resource.map` + `resource.001/002`（無獨立 heap，字串內嵌 script）。
- ScummVM 辨識：`sci:jones`，MD5 對上內建條目（`resource.001` = `bac3ec6c…`）。
- VERSION：`1.000.060`。

## 技術路線

沿用姊妹專案 **qfg-1**（英雄傳奇1，同 ScummVM SCI 引擎）的繁中化管線：在 SCI 引擎新增
一條 `ZH_TWN` + Big5 繪字路徑（`GfxFontChinese`），文字用 content-keyed TSV 於繪字時即時替換。
交付僅 ScummVM patch（引擎改動 + 散裝中文資產），原遊戲資源不入庫。

## 文字資源盤點（SCI_DUMP_RES dump）

| 型別 | 數量 | 說明 |
|---|---|---|
| text | 39 | 主要對白/訊息字串（**622 則**精確 key，30k 字元） |
| script | 69 | 內嵌 UI 字串（選單、Player 1-4、Turn Music… 等，M2 補抽） |
| font | 8 | 原版字型 |
| view | 90 | 美術（部分含烘字 UI，M3） |
| pic | 7 | 背景圖 |

> Jones 無 `message.*` 資源，文字走 **text.\*（null 切）+ script 內嵌**，屬 SCI 早期（類 EGA）格局。

## M0/M1 已解的關鍵卡點

1. **identify 卡關**：`advancedDetector.cpp` 的語言過濾拒絕「請求 ZH_TWN 對 EN_ANY 條目」。
   → patch 加例外：ZH_TWN 請求可匹配 EN_ANY 英文條目（fan-translation 情境）。
2. **精確 match 失敗**：runtime 字串含硬換行 `0x0A`，抽字工具卻正規化成空格。
   → 修 `extract_strings.py`，硬換行保留為 `\n` 跳脫；引擎 `loadChtTranslation` 還原回 `0x0A`。
3. **啟用中文**：target config 存 `language=tw`（identify 因例外照過，執行期 `getLanguage()` 回 ZH_TWN）。

## 風險

- **view/pic 烘字 UI（M3）**：qfg-1 的 `sci_view.py` 寫死 SCI1.1 VGA 格式，Jones 為 SCI1，
  view/pic 編解碼需重新驗證甚至改寫。Jones UI 烘字量可能不小（棋盤、商店、銀行畫面）。
- **script 內嵌字串抽取（M2）**：需確認 SCI1 Jones 的 script 字串抽取涵蓋率。

## 里程碑

- [x] M0 可行性 + 骨架
- [x] M1 端到端 spike（版權畫面繁中渲染，實機驗證）
- [ ] M2 全文字中文化
- [ ] M3 烘字 UI（view/pic）
- [ ] M4 多平台打包 + 中文手冊 README
