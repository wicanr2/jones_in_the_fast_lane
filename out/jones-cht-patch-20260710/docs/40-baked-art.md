# 40 — 烘字 UI（view/pic）中文化（M3）

Jones 有大量「烘進美術的英文字」，需重繪成中文再打成 patch（使用者選定：**完整重繪**）。

## 烘字盤點（實機勘查）

| 資源 | 內容 | 型別 |
|---|---|---|
| **pic_11**（棋盤背景） | 11 個地點招牌：RENT OFFICE、PAWN SHOP、black's market、Bank、EMPLOYMENT OFFICE、HI-TECH U、Socket City、FACTORY、Monolith、Z-Mart、Q.T | pic（vector） |
| **pic_0** | 標題 logo「JONES IN THE FAST LANE」 | pic |
| **view.005 等** | credits（actors / 人名…） | view cel |
| 其他 view | 按鈕 DONE/SELECT/ENROLL/WORK、畫面標題 JONES GOALS / SELECT YOUR CHARACTER / How Many Players | view cel |

## SCI1 VGA view 格式（逆向自 ScummVM view.cpp kViewVga + palette16.cpp）

> dump 檔前 2 bytes 為 patch header，需 strip；以下 offset 相對 resource 起始。

**View header**：`[0]u8 loopCount [1]u8 flags(0x80=有pal,0x40=未壓縮) [2:4]mirrorBits [4:6]version [6:8]palOffset [8+loop*2]loop offset 表`
**Loop header**（@loopOffset）：`[0:2]celCount [2:4]unknown [4+cel*2]cel offset 表`
**Cel header**（@celOffset）：`[0:2]w [2:4]h [4]dispX(s8) [5]dispY [6]clearKey [7]unk [8:]資料`
**Cel RLE**（單流）：控制位元組 `c`：`len=c&0x3F, op=c&0xC0`；`0x00`copy len literal／`0x40`copy len+64 literal／`0x80`fill len 以下一 byte／`0xC0`skip len（透明）。未壓縮（flags 0x40）則 `[8:]` 直接 raw w*h index。
**Palette**（@palOffset，VARIABLE）：`palOffset+260` 起，每色 4 bytes(used,r,g,b)，256 色。

## 工具：`tools/sci1_view.py`（已完成 decoder，✅ 驗證）

- `info` / `decode`（每 cel 一 PNG，套內嵌 palette）/ `verify`（對 `SCI_DUMP_ALLVIEWS` 的 PPM 逐像素比對）。
- **驗證結果：725/752 cel 與引擎 PPM 完全一致**（2 個 view 340/609 無內嵌 palette 走全域盤，index 仍正確）。
- 取 oracle PPM：`SCI_DUMP_ALLVIEWS=/out ./scummvm jones`（引擎自身 SCI1 解碼器）。

## 編碼策略（免寫 RLE 壓縮器）

flags 0x40 = 未壓縮。重繪後把整個 view **以未壓縮重建**：view header(flags 設 0x40) + loop offset 表 + loop header + cel header(8 byte) + raw w*h index。免實作 RLE 壓縮。
中文用**既有 palette 內的文字色 index** 畫（避免 RGB→index 失真）。

## M3 進度 / 待辦

- [x] SCI1 view **decoder** + oracle 驗證（`sci1_view.py`）
- [ ] SCI1 view **encoder**（未壓縮重建 + `--replace loop,cel,png`）
- [ ] 識別各 UI 文字 view/cel（credits、按鈕、標題）→ 逐一中文重繪（機械活可派 subagent）
- [ ] **pic** 格式（vector opcode，與 view 不同）：pic_11 棋盤招牌 + pic_0 標題。需另逆向 pic decoder/encoder（qfg-1 sci_view.py 的 pic 部分寫死 SCI1.1，待驗證/改寫）
- [ ] 打成 loose patch（`.v56`/`.p56` 或 SCI patch 檔）放遊戲目錄，實機驗證

## 交付

烘字 patch 一律散裝放遊戲目錄（ScummVM patch），原資源不入庫。
