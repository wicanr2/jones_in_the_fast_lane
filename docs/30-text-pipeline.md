# 30 — 文字抽取 → 翻譯 → 烘字 流程

## 抽字
```bash
# 引擎 SCI_DUMP_RES dump 出 text/script/font 等資源(timeout 包住,dump 完會 segfault 但資料已出)
docker run --rm -e ... jones-capture bash /tools/dump_res.sh
python3 tools/extract_strings.py extract/dump translation/skeleton.tsv    # text.* → 精確 key(保留 \n 跳脫)
python3 tools/extract_ega_scripts.py extract/dump translation/script_skeleton.tsv  # script.* 內嵌字串
```
Jones 文字＝`text.*`（39 個，622 則）+ `script.*`（69 個，152 則內嵌 UI 字）。無 message 資源。

## 翻譯
- 合併 text+script → `skeleton_all.tsv`（774 則），切 8 批派 haiku subagent 翻譯（依 `docs/10-terminology.md`）。
- `merge_translations.py`：以 strip 後英文比對併回 canonical `translation.tsv`（保留精確 key）。100% 命中。
- `supplement.tsv`：抽字啟發式漏抽的（前導空格/`\n\n`）字串直接補精確 key。

## 烘字 → runtime
```bash
docker run --rm -v "$PWD:/w" -v /usr/share/fonts:/hostfonts:ro jones-tools \
  python3 tools/build_cht.py translation/translation_full.tsv dist \
  --size 15 --font /hostfonts/truetype/wqy/wqy-zenhei.ttc --face 0 \
  --corrections translation/corrections.tsv
```
- 產 `dist/translation.tsv`（英文\tBig5 bytes）+ `dist/jones_big5.fnt`（Big5 點陣，1305 字）。
- `corrections.tsv`：修非 Big5 字元（`®`→`(R)`、日文變體 `薫`→`燻`）。
- `build_cht.py` 內建全形化 + NORMALIZE 安全網。

## 關鍵坑
- runtime 字串含 `0x0A` 硬換行，抽字/翻譯 key **必須用 `\n` 跳脫**對齊，否則精確 match MISS。
- `%d`/`%2d`/`%s`/`$` 格式符原樣保留（含譯文側）。
