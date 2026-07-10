# 人生劇場（Jones in the Fast Lane）中文化術語表

譯名基準：**當年官方中文手冊**（軟體世界珍藏版 76，1990 Sierra 原作，繁體中文）。
寫程式、翻譯、寫文件時優先用本表詞彙；手冊有的用手冊，手冊沒有的走「暫譯」欄並標註。

> 遊戲官方中文名：**人生劇場**（標題 JONES in the Fast Lane，副標未另譯）。
> 風格定調：現代都市生活模擬，語氣輕鬆詼諧；字型走**黑體/現代感**（文泉驛正黑，15px）。

## 人生四大目標

| 英文 | 官方譯名 | 備註 |
|---|---|---|
| MONEY | 財富 | 得點看財產淨值（現金+儲金+投資+資產） |
| HAPPINESS | 快樂 | 買奢侈品、娛樂、Relax 提升 |
| EDUCATION | 學歷 | 內文亦作「教育程度」，**統一用「學歷」** |
| CAREER | 職業 | 常換工作、跑職業介紹所晉升 |
| Goal Points | 目標點數 | 開局設定各目標點數，先達成者勝 |

## 地點 / 商店（棋盤 11 處）

| 英文 | 官方譯名 | 備註 |
|---|---|---|
| Employment Office | 職業介紹所 | 提供 9 個工作場所 |
| Monolith Burgers | 大石頭漢堡店 | 速食店 |
| Hi-Tech University | 高等技術大學 | 上學修學科（ENROLL 登記/選課） |
| The Factory | 工廠 | 需先修機械工程學科才錄取，薪高 |
| Q.T Clothing | Q.T 服飾店 | 買各色服裝 |
| Rent Office | 租屋中心 | 付房租、換公寓 |
| Black's Market | 布萊克超市 | 食物、樂透、報紙 |
| Socket City Appliance Store | 「多插座城市」電器專賣店 | 買家電（快樂來源） |
| Z-Mart | Z-超商 | 雜貨、演唱會/職棒預售票 |
| Bank | 銀行 | 工作、投資、存款、貸款 |
| Pawn Shop | 當舖 | PAWN 典當 / REDEEM 贖回 / BUY 買當品 |

## 角色 / 系統

| 英文 | 官方譯名 | 備註 |
|---|---|---|
| JONES | 瓊斯 / 幸福人瓊斯 | 主角兼單人模式電腦對手，代表球=灰色 |
| Week | 週 / 星期 | 指針轉一圈=一星期 |
| Rent | 房租 | 每 4 星期（一個月）付一次 |
| Lottery | 樂透 / 彩券 | 布萊克超市販售 |
| Loan | 貸款 | 銀行功能 |
| Deposit / Withdraw | 存錢 / 提款 | 銀行畫面 |
| bonds | 公債 | 投資 |
| Relax | 放鬆 / 休息 | 回家 Relax，不做會「崩潰」 |
| WORK / DONE | 工作 / 離開 | 工作地點選項 |
| cook / janitor | 廚師 / 工友 | 低階入門工作 |

## 選單 / 系統操作

| 英文 | 官方說明 |
|---|---|
| PLAY GAME | 開始新遊戲 |
| RESTORE GAME | 提取遊戲（讀檔） |
| SAVE GAME | 儲存遊戲（只存一個進度） |
| WATCH DEMO | 遊戲示範 |
| SELECT | 選擇代表人物 |
| take it easy / play fair / go for broke | 順其自然 / 公平競爭 / 讓瓊斯破產（挑戰瓊斯難度） |

## 待定（手冊未給中文，暫譯，M2 定版）

| 英文 | 暫譯 |
|---|---|
| Electronics（學科） | 電子學 |
| Pre-Engineering | 工程預科 |
| Jr. College | 專科課程 |
| See The Broker | 找證券營業員 |
| Loan Payment | 償還貸款 |
| Astro Chicken / Fries / Shakes / Cola | 太空雞 / 薯條 / 奶昔 / 可樂 |
| Socket City（地名） | 插座市（或沿用「多插座城市」） |
| Newspaper | 報紙 |
| Broke / bankrupt | 破產 |

## 一致性注意

- EDUCATION 統一「學歷」（勿混「教育程度」）。
- 標點一律全形（`build_cht.py` 有全形化安全網），省略號用 `…`。
- 半形 `%d`/`%2d`/`$` 格式符**必須原樣保留**（遊戲會填數字）。
