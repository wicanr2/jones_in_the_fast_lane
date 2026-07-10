#!/usr/bin/env bash
# 打包人生劇場繁中化交付物。用法:package.sh [date]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DATE="${1:-release}"
OUT="$HERE/out"
mkdir -p "$OUT"

# ── 1) CHT patch 源碼包(ScummVM patch 交付:引擎 patch + 資料 + 工具 + 文件) ──
STAGE="$OUT/jones-cht-patch-$DATE"
rm -rf "$STAGE"; mkdir -p "$STAGE"
cp -r "$HERE/patches" "$STAGE/"
cp -r "$HERE/dist/game-cht" "$STAGE/"
cp -r "$HERE/docs" "$STAGE/"
cp "$HERE/README.md" "$HERE/WORKLIST.md" "$HERE/tools/apply_patches.sh" "$STAGE/" 2>/dev/null || true
( cd "$OUT" && tar czf "jones-cht-patch-$DATE.tar.gz" "jones-cht-patch-$DATE" )
echo "✓ $OUT/jones-cht-patch-$DATE.tar.gz (ScummVM patch 源碼包)"

# ── 2) 純資料包(放進遊戲目錄即用,需已有繁中 ScummVM) ──
( cd "$HERE/dist" && tar czf "$OUT/jones-cht-data-$DATE.tar.gz" game-cht )
echo "✓ $OUT/jones-cht-data-$DATE.tar.gz (遊戲目錄資料包)"

# ── 3) Linux 執行包(繁中 ScummVM binary + 資料 + 啟動腳本;需系統 SDL2) ──
BIN="$HERE/scummvm-src/scummvm"
if [ -f "$BIN" ]; then
  LX="$OUT/jones-cht-linux-$DATE"
  rm -rf "$LX"; mkdir -p "$LX/cht"
  cp "$BIN" "$LX/scummvm"
  cp "$HERE/dist/game-cht/"* "$LX/cht/"
  cp "$HERE/README.md" "$LX/"
  cat > "$LX/run.sh" <<'RUN'
#!/usr/bin/env bash
# 用法:run.sh <jones 遊戲目錄>  (會把繁中資料複製進去並以中文啟動)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
GAME="${1:?用法: run.sh <jones 遊戲目錄(含 resource.map)>}"
cp "$HERE/cht/"* "$GAME/"
"$HERE/scummvm" --path="$GAME" --add >/dev/null 2>&1 || true
INI="$HOME/.config/scummvm/scummvm.ini"
if [ -f "$INI" ]; then
  sed -i 's/^language=en$/language=tw/' "$INI"
  # Jones 音樂為 PCjr/Tandy track(無 AdLib/MT-32),需 pcjr driver 才有配樂
  grep -q '^music_driver=' "$INI" || sed -i '/^\[jones\]/a music_driver=pcjr' "$INI"
fi
exec "$HERE/scummvm" jones
RUN
  chmod +x "$LX/run.sh"
  ( cd "$OUT" && tar czf "jones-cht-linux-$DATE.tar.gz" "jones-cht-linux-$DATE" )
  echo "✓ $OUT/jones-cht-linux-$DATE.tar.gz (Linux 執行包)"
else
  echo "⚠ 找不到 $BIN,跳過 Linux 執行包(先 build scummvm-src)"
fi

echo ""; echo "產物:"; ls -lh "$OUT"/*.tar.gz
