#!/usr/bin/env bash
# 「開箱即玩」私人版 AppImage:內嵌遊戲檔 + 繁中資料,雙擊直接進中文遊戲。
# ⚠ 含原版遊戲資源 → 僅供自己用,勿散布(版權)。發佈版請用 build_appimage.sh(不含遊戲)。
# 掛載:/w = workplace(需 extract/game_lc 內含遊戲 + cht 資料)。
# 輸出:/w/out/人生劇場-可玩版-x86_64.AppImage
set -euo pipefail
W="${W:-/w}"
BIN="$W/scummvm-src/scummvm"
GAME="$W/extract/game_lc"           # 已含遊戲 resource.* + cht 資料
OUT="$W/out"
APP="/tmp/AppDirPlay"
LINUXDEPLOY="${LINUXDEPLOY:-/opt/linuxdeploy}"
APPIMAGETOOL="${APPIMAGETOOL:-/opt/appimagetool}"
export APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64

[ -f "$BIN" ] || { echo "找不到 $BIN"; exit 1; }
[ -f "$GAME/resource.map" ] || { echo "找不到遊戲檔 $GAME/resource.map"; exit 1; }

rm -rf "$APP"; mkdir -p "$APP/usr/bin" "$APP/usr/lib" "$APP/usr/share/applications" "$APP/usr/share/icons/hicolor/256x256/apps" "$APP/game"
cp "$BIN" "$APP/usr/bin/scummvm"; chmod +x "$APP/usr/bin/scummvm"
# 內嵌遊戲 + 繁中資料(game_lc 已合併)
cp -a "$GAME"/. "$APP/game/"

cat > "$APP/usr/share/applications/jones-cht.desktop" <<'D'
[Desktop Entry]
Type=Application
Name=人生劇場 (可玩版)
Comment=Jones in the Fast Lane 繁中化 — 雙擊即玩
Exec=scummvm
Icon=jones-cht
Categories=Game;
Terminal=false
D
cp "$W/tools/assets/jones-cht-icon.png" "$APP/usr/share/icons/hicolor/256x256/apps/jones-cht.png"
cp "$W/tools/assets/jones-cht-icon.png" "$APP/jones-cht.png"

$LINUXDEPLOY --appdir "$APP" --executable "$APP/usr/bin/scummvm" \
  --desktop-file "$APP/usr/share/applications/jones-cht.desktop" \
  --icon-file "$APP/jones-cht.png" 2>&1 | tail -2

# 可玩版 AppRun:AppImage 唯讀 → 把內嵌遊戲複製到可寫 XDG data,設定一次,直啟 jones。
rm -f "$APP/AppRun"
cat > "$APP/AppRun" <<'RUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:${LD_LIBRARY_PATH:-}"
SCUMMVM="$HERE/usr/bin/scummvm"
GDIR="${XDG_DATA_HOME:-$HOME/.local/share}/jones-cht/game"
if [ ! -f "$GDIR/resource.map" ]; then
  mkdir -p "$GDIR"; cp -rn "$HERE/game/." "$GDIR/" 2>/dev/null || cp -rn "$HERE/game/"* "$GDIR/"
fi
INI="${XDG_CONFIG_HOME:-$HOME/.config}/scummvm/scummvm.ini"
if ! grep -q '^\[jones\]' "$INI" 2>/dev/null; then
  "$SCUMMVM" --path="$GDIR" --add >/dev/null 2>&1 || true
  if [ -f "$INI" ]; then
    sed -i 's/^language=en$/language=tw/' "$INI"
    grep -q '^music_driver=' "$INI" || sed -i '/^\[jones\]/a music_driver=adlib' "$INI"
  fi
fi
exec "$SCUMMVM" jones "$@"
RUN
chmod +x "$APP/AppRun"

mkdir -p "$OUT"
$APPIMAGETOOL "$APP" "$OUT/人生劇場-可玩版-x86_64.AppImage" 2>&1 | tail -3
echo "✓ $OUT/人生劇場-可玩版-x86_64.AppImage(雙擊直接進中文遊戲;含遊戲檔,勿散布)"
ls -lh "$OUT/人生劇場-可玩版-x86_64.AppImage"
