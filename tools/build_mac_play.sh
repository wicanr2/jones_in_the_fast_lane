#!/usr/bin/env bash
# 從 macOS CI 的 .tar.gz 組「開箱即玩」macOS 可玩版(含遊戲檔,私人用勿散布)。
# 在 Linux 跑即可:不動已簽名的 .app(保簽名有效),遊戲+啟動器放 .app 外面。
# 依 mac-app-cross-pack 方法論 phase 2/3(注入 local 檔 + 解 quarantine)。
set -euo pipefail
W="${W:-$PWD}"
ART="$W/out/mac-artifact"
GAME="$W/extract/game_lc"
OUT="$W/out"
STAGE="$OUT/mac-play"

TGZ=$(find "$ART" -name '*.tar.gz' | head -1)
[ -z "$TGZ" ] && { echo "找不到 macOS CI 的 .tar.gz(先下載 artifact)"; exit 1; }
[ -f "$GAME/resource.map" ] || { echo "找不到遊戲檔"; exit 1; }

rm -rf "$STAGE"; mkdir -p "$STAGE"
tar xzf "$TGZ" -C "$STAGE"
# CI 的 tar 內含:人生劇場-CHT.app / cht/ / 安裝說明.txt;移除 cht(可玩版用內嵌 game)
rm -rf "$STAGE/cht" "$STAGE/安裝說明.txt"
APP=$(find "$STAGE" -maxdepth 1 -iname '*.app' | head -1)
[ -z "$APP" ] && { echo "tar 內沒有 .app"; exit 1; }

# 內嵌遊戲(game_lc 已含繁中資料)到 .app 外面(不動簽名)
cp -a "$GAME" "$STAGE/game"

# 可攜 scummvm.ini(相對 path=game,.command 會 cd 到本目錄)
cat > "$STAGE/scummvm.ini" <<'INI'
[scummvm]
versioninfo=2026.2.1git

[jones]
platform=pc
gameid=jones
description=Jones in the Fast Lane (DOS/English)
language=tw
music_driver=adlib
path=game
engineid=sci
guioptions=sndNoSpeech gameOption1 gameOption3 gameOptionE gameOptionH vga plat_pc
INI

# 啟動器:cd 到本目錄 → 跑 .app 內 binary,吃可攜 ini + 直啟 jones
cat > "$STAGE/人生劇場.command" <<'CMD'
#!/bin/bash
cd "$(dirname "$0")"
APP=$(ls -d *.app | head -1)
exec "./$APP/Contents/MacOS/scummvm" --config="$(pwd)/scummvm.ini" jones
CMD
chmod +x "$STAGE/人生劇場.command"

# 使用說明(含 Gatekeeper 解隔離)
cat > "$STAGE/使用說明.txt" <<'TXT'
人生劇場 繁體中文化 — macOS 可玩版(Apple Silicon,含遊戲檔,私人用勿散布)
======================================================================

雙擊「人生劇場.command」即可直接進入繁體中文遊戲。

⚠ 第一次執行前,macOS Gatekeeper 可能擋(未認證開發者)。開「終端機」執行一次:
   xattr -dr com.apple.quarantine "人生劇場-CHT.app"
   xattr -d com.apple.quarantine "人生劇場.command"
(或在「系統設定 → 隱私權與安全性」按「仍要打開」。)

- 人生劇場-CHT.app:繁中化 ScummVM（真 SDL2，arm64，已簽名）
- game/：原版遊戲檔 + 繁中資料（已合併）
- scummvm.ini：已設 language=Chinese(Traditional)、music_driver=adlib

★ 本包含原版遊戲資源，僅供自己使用，請勿公開散布。
★ 僅支援 Apple Silicon（M1 以後）。Intel Mac 不適用。
TXT

# 打包 .tar.gz(保 .app 結構/exec/symlink;繞 APFS DMG 不可讀)
( cd "$OUT" && tar czf "人生劇場-可玩版-macOS.tar.gz" -C mac-play . )
echo "✓ $OUT/人生劇場-可玩版-macOS.tar.gz"
ls -lh "$OUT/人生劇場-可玩版-macOS.tar.gz"
