# 人生劇場（Jones in the Fast Lane）— 繁體中文化

Sierra 1990 年經典**現代都市生活模擬**遊戲的**繁體中文化**專案，跑在 **ScummVM SCI 引擎**上。
中文化以 **ScummVM patch** 形式交付（引擎繪字改動 + 散裝中文資產），不散布原遊戲資源。

> 引擎：ScummVM **SCI**（非 AGS）。技術路線＝沿用 SCI 引擎既有的日/韓 CJK 範式，新增一條
> **繁體中文（`ZH_TWN` + Big5）黑體**繪字路徑；並自寫 **SCI1 view/pic 編解碼器**重繪烘字美術。
> 譯名以**當年官方中文手冊**（軟體世界珍藏版 76）為準。

<p align="center">
  <img src="docs/images/hires-title-cht.png" width="480" alt="人生劇場 標題畫面"><br>
  <em>還原經典 —— 標題 logo 重繪成官方中文名「人生劇場」（金色戲單風，保留 Sierra 球標與英文副標）</em>
</p>

---

## 成果一覽（皆實機驗證）

| 640×400 高解析棋盤招牌 | 啟動版權畫面（清晰中文） |
|---|---|
| ![棋盤](docs/images/hires-board-cht.png) | ![版權](docs/images/hires-copyright-cht.png) |
| **選單／對話（公平競爭 / 全力一搏）** | **目標畫面（瓊斯的目標 / 目標點數）** |
| ![選單](docs/images/hires-playfair-cht.png) | ![目標](docs/images/hires-goals-cht.png) |

- **文字**：對白、選單、訊息、動態計數（如「第 N 週」「目標點數 = 200」）全繁體中文——**776 則**翻譯。
- **640×400 高解析中文**：繁中模式自動切 hi-res 畫布，中文字以 2x 直接繪入顯示緩衝（清晰不糊）；棋盤 13 塊地點招牌以專用 hi-res 字型＋座標資料疊上清晰中文。
- **烘字美術**：**標題 logo（人生劇場）**、棋盤地點招牌（工廠、銀行、當舖、租屋、Z超商…）、14 個動作按鈕（完成/工作/購買/出售…）、目標畫面橫幅（瓊斯的目標）、選單按鈕（公平競爭/全力一搏）重繪成中文。
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

## 下載（各平台，皆內含 CHT 引擎與資料；只需另備原版遊戲檔）

| 平台 | 檔案 | 說明 |
|---|---|---|
| **Linux** | `人生劇場-CHT-x86_64.AppImage` | 自足 AppImage，`chmod +x` 後直接執行。把遊戲目錄當參數傳給它會自動裝繁中資料並以中文啟動。 |
| **Windows** | `jones-cht-windows.zip` | MXE 靜態單一 `scummvm.exe`（免 DLL）＋ `繁中啟動.bat`。 |
| **macOS** | `人生劇場-CHT-macOS.dmg` | 由 GitHub Actions（macOS runner）建置——見 `.github/workflows/build-cht.yml`，打 tag `v*` 或手動觸發後於 Actions 產物下載。 |

> 三個平台的 binary 都是**套過 CHT 引擎 patch 的 ScummVM**（官方版沒有繁中繪字路徑）。原遊戲檔請自備，不隨附（版權）。

## 安裝使用（手動套用到既有繁中 ScummVM）

1. 準備 Jones in the Fast Lane（DOS/English）原版遊戲檔（`resource.map`/`resource.001`/`resource.002`…）。
2. 取得支援繁中的 ScummVM（用上方各平台包，或見「建置」自行編）。
3. 把 `dist/game-cht/` 內全部檔案複製到遊戲目錄：
   - `translation.tsv`、`jones_big5.fnt`（文字＋低解字型）
   - `jones_big5_hi.fnt`、`jones_signs.dat`（640×400 hi-res 字型＋棋盤招牌疊繪資料）
   - `0.p56`（標題 logo「人生劇場」）
   - `10.v56`、`11.p56`、`250.v56`、`500/501/505/506.v56`（棋盤招牌／按鈕／橫幅烘字 patch）
4. 在 ScummVM 加入遊戲，將該 target 設定：語言＝**Chinese (Traditional)**（`language=tw`）啟用中文；
   音樂驅動＝**AdLib**（`music_driver=adlib`）。★ Jones 內建 AdLib(OPL2)+MT-32 樂器庫,配樂在棋盤畫面播放(經典 Sierra OPL2 音色)。

## 建置（Docker，SCI-only）

```bash
bash tools/apply_patches.sh <scummvm-src>   # 套引擎繪字 patch(0001+0002+0003+0004+fontchinese)
docker run --rm -v "$PWD/scummvm-src:/src" -w /src jones-build bash -c \
  "./configure --disable-all-engines --enable-engine=sci --disable-mt32emu && make -j$(nproc)"
```
ScummVM 基準版本：`2026.2.1git`。

**各平台打包**（Dockerfile 在 `docker/`，腳本在 `tools/`）：

```bash
# Linux AppImage
docker build -t jones-appimage -f docker/Dockerfile.appimage docker/
docker run --rm --privileged -v "$PWD:/w" jones-appimage bash /w/tools/build_appimage.sh
# Windows(MXE 靜態 mingw)
docker build -t jones-mxe -f docker/Dockerfile.mxe docker/
docker run --rm -v "$PWD:/w" jones-mxe bash /w/tools/build_windows.sh
# macOS：GitHub Actions（.github/workflows/build-cht.yml，macos runner 產 .app/.dmg）
```

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
