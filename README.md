# 人生劇場（Jones in the Fast Lane）— 繁體中文化

Sierra 1990 年經典**現代都市生活模擬**遊戲的**繁體中文化**專案，跑在 **ScummVM SCI 引擎**上。
中文化以 **ScummVM patch** 形式交付（引擎繪字改動 + 散裝中文資產），不散布原遊戲資源。

> 引擎：ScummVM **SCI**（非 AGS）。技術路線＝沿用 SCI 引擎既有的日/韓 CJK 範式，新增一條
> **繁體中文（`ZH_TWN` + Big5）黑體**繪字路徑；並自寫 **SCI1 view/pic 編解碼器**重繪烘字美術。
> 譯名以**當年官方中文手冊**（軟體世界珍藏版 76）為準。

---

## 成果一覽（皆實機驗證）

| 640×400 高解析棋盤招牌 | 啟動版權畫面（清晰中文） |
|---|---|
| ![棋盤](docs/images/hires-board-cht.png) | ![版權](docs/images/hires-copyright-cht.png) |
| **選單／對話（公平競爭 / 全力一搏）** | **目標畫面（瓊斯的目標 / 目標點數）** |
| ![選單](docs/images/hires-playfair-cht.png) | ![目標](docs/images/hires-goals-cht.png) |

- **文字**：對白、選單、訊息、動態計數（如「第 N 週」「目標點數 = 200」）全繁體中文——**776 則**翻譯。
- **640×400 高解析中文**：繁中模式自動切 hi-res 畫布，中文字以 2x 直接繪入顯示緩衝（清晰不糊）；棋盤 13 塊地點招牌以專用 hi-res 字型＋座標資料疊上清晰中文。
- **烘字美術**：棋盤地點招牌（工廠、銀行、當舖、租屋、Z超商…）、14 個動作按鈕（完成/工作/購買/出售…）、目標畫面橫幅、選單按鈕（公平競爭/全力一搏）重繪成中文。
- **字型**：文泉驛正黑（現代黑體，貼合都市生活模擬調性）；低解 15px + hi-res 32×30 兩套。
- **配樂**：原版 AdLib（OPL2）音樂；另附 33 秒繁中推廣影片（`out/jones-cht-promo.mp4`）。

---

## 這是什麼遊戲？

你扮演一位剛搬進小鎮、口袋只有 **$200 老本**的市民，在棋盤式地圖上吃飯、上班、購物、上學、
投資，追逐人生四大目標——**財富、快樂、學歷、職業**。最先把四項都達到設定點數者獲勝。
可單人挑戰電腦對手「瓊斯」，或最多 4 人同樂。指針轉一圈＝一星期；每月付房租、每週要吃飯，
否則餓昏送醫、崩潰路邊。核心循環：

> 職業介紹所找工作 → 上班賺錢 → 大學進修解鎖高薪工作 → 銀行存款/投資/貸款 → 商店消費換快樂 →
> 缺錢時當舖典當或買樂透碰運氣。

## 安裝使用

1. 準備 Jones in the Fast Lane（DOS/English）原版遊戲檔（`resource.map`/`resource.001`/`resource.002`…）。
2. 取得支援繁中的 ScummVM（見「建置」）。
3. 把 `dist/game-cht/` 內全部檔案複製到遊戲目錄：
   - `translation.tsv`、`jones_big5.fnt`（文字＋低解字型）
   - `jones_big5_hi.fnt`、`jones_signs.dat`（640×400 hi-res 字型＋棋盤招牌疊繪資料）
   - `10.v56`、`11.p56`、`250.v56`、`500/501/505/506.v56`（棋盤招牌／按鈕／橫幅烘字 patch）
4. 在 ScummVM 加入遊戲，將該 target 設定：語言＝**Chinese (Traditional)**（`language=tw`）啟用中文；
   音樂驅動＝**AdLib**（`music_driver=adlib`）。★ Jones 內建 AdLib(OPL2)+MT-32 樂器庫,配樂在棋盤畫面播放(經典 Sierra OPL2 音色)。

## 建置（Docker，SCI-only）

```bash
bash tools/apply_patches.sh <scummvm-src>   # 套引擎繪字 patch(0001+0002+0003+fontchinese)
docker run --rm -v "$PWD/scummvm-src:/src" -w /src jones-build bash -c \
  "./configure --disable-all-engines --enable-engine=sci --disable-mt32emu && make -j$(nproc)"
```
ScummVM 基準版本：`2026.2.1git`。

## 文件索引

| 文件 | 內容 |
|---|---|
| [docs/00-feasibility.md](docs/00-feasibility.md) | 可行性、版本、資源盤點、技術路線、已解卡點 |
| [docs/10-terminology.md](docs/10-terminology.md) | 術語表：官方中文譯名 |
| [docs/20-engine-cjk-patch.md](docs/20-engine-cjk-patch.md) | 引擎繪字 patch 與動態字 hook |
| [docs/30-text-pipeline.md](docs/30-text-pipeline.md) | 文字抽取 → 翻譯 → 烘字流程 |
| [docs/40-baked-art.md](docs/40-baked-art.md) | SCI1 view/pic 格式逆向 + 烘字重繪 |
| [WORKLIST.md](WORKLIST.md) | 工作交接：引擎改動、工具鏈、指令、踩雷 |

## 中文手冊要點（軟體世界珍藏版 76）

**四大目標達成途徑**
- **職業**：常換工作、勤跑職業介紹所爭取晉升。
- **快樂**：有錢就買奢侈品、看秀、喝奶昔、在家放鬆（Relax）。
- **學歷**：去高等技術大學修學科，修越多學歷越高，並解鎖更好的職業。
- **財富**：累積現金、儲蓄、投資與資產淨值。

**11 處地點**：職業介紹所、大石頭漢堡店、高等技術大學、工廠、Q.T 服飾店、租屋中心、
布萊克超市、「多插座城市」電器行、Z-超商、銀行、當舖。

**操作**：游標移到目的地按確定即自動前往。`F1` 說明、`F2` 音樂、`F3` 音效、`F4` 統計、
`F5` 存檔、`F7` 讀檔、`F10` 遊戲背景、`Ctrl+Q` 離開。存檔**只有一個進度**（新存檔覆蓋舊的）。

**十二點提示**：開局先拚財源、每週吃飯、找工作從廚師/工友做起、盡量提高學歷換高薪、
適時回家放鬆、每月付房租、別帶太多現金（會被搶）、公債賠慘可貸款、走投無路買樂透、
常看報紙掌握時事（會影響職業與漢堡售價）。

## 交付原則

- 中文化**僅放 ScummVM patch**（引擎繪字改動 + Big5 黑體字 + 內容替換 TSV + view/pic 烘字 patch），
  原遊戲資源不入庫、不散布。

## 相關專案

- 英雄傳奇 I（Quest for Glory 1）繁中化（同 SCI 引擎）：<https://github.com/wicanr2/qfg-cht-1>
