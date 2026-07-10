#!/usr/bin/env bash
# 在 jones-appimage 容器內把 CHT ScummVM 打成自足 AppImage。
# 掛載:/w = workplace。輸出:/w/out/人生劇場-CHT-x86_64.AppImage
set -euo pipefail
# W 預設 /w(Docker);CI 傳 W=$PWD。工具路徑可用 env 覆寫(CI 用 /tmp/...)。
W="${W:-/w}"
BIN="$W/scummvm-src/scummvm"
CHT="$W/dist/game-cht"
OUT="$W/out"
APP="/tmp/AppDir"
LINUXDEPLOY="${LINUXDEPLOY:-/opt/linuxdeploy}"
APPIMAGETOOL="${APPIMAGETOOL:-/opt/appimagetool}"
export APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64

[ -f "$BIN" ] || { echo "找不到 $BIN(先 build 引擎)"; exit 1; }

rm -rf "$APP"; mkdir -p "$APP/usr/bin" "$APP/usr/lib" "$APP/usr/share/applications" "$APP/usr/share/icons/hicolor/256x256/apps" "$APP/cht"
cp "$BIN" "$APP/usr/bin/scummvm"; chmod +x "$APP/usr/bin/scummvm"
cp "$CHT"/* "$APP/cht/"

# .desktop
cat > "$APP/usr/share/applications/jones-cht.desktop" <<'D'
[Desktop Entry]
Type=Application
Name=人生劇場 Jones CHT
Comment=Jones in the Fast Lane 繁體中文化 (ScummVM SCI)
Exec=scummvm
Icon=jones-cht
Categories=Game;
Terminal=false
D

# icon 256x256(深藍戲單底 + 金色「人生劇場」),由 jones-video 預先產於 tools/assets/
cp "$W/tools/assets/jones-cht-icon.png" "$APP/usr/share/icons/hicolor/256x256/apps/jones-cht.png"
cp "$W/tools/assets/jones-cht-icon.png" "$APP/jones-cht.png"

# 用 linuxdeploy 把動態庫收進 AppDir(不讓它建 AppImage,-o 用自訂 AppRun 後再 appimagetool)
$LINUXDEPLOY --appdir "$APP" --executable "$APP/usr/bin/scummvm" \
  --desktop-file "$APP/usr/share/applications/jones-cht.desktop" \
  --icon-file "$APP/jones-cht.png" 2>&1 | tail -3

# 自訂 AppRun:給遊戲目錄就自動裝 CHT 資料 + 設中文/AdLib + 啟動;否則開 GUI。
# ★ 先刪 linuxdeploy 建的 AppRun symlink,否則 `>` 會穿透 symlink 覆寫 scummvm binary。
rm -f "$APP/AppRun"
cat > "$APP/AppRun" <<'RUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:${LD_LIBRARY_PATH:-}"
SCUMMVM="$HERE/usr/bin/scummvm"; CHT="$HERE/cht"
if [ -n "${1:-}" ] && [ -d "$1" ] && [ -f "$1/resource.map" ]; then
  echo "[人生劇場] 安裝繁中資料到 $1 …"
  cp "$CHT"/* "$1"/
  "$SCUMMVM" --path="$1" --add >/dev/null 2>&1 || true
  INI="${XDG_CONFIG_HOME:-$HOME/.config}/scummvm/scummvm.ini"
  if [ -f "$INI" ]; then
    sed -i 's/^language=en$/language=tw/' "$INI"
    grep -q '^music_driver=' "$INI" || sed -i '/^\[jones\]/a music_driver=adlib' "$INI"
  fi
  exec "$SCUMMVM" jones
fi
exec "$SCUMMVM" "$@"
RUN
chmod +x "$APP/AppRun"

mkdir -p "$OUT"
$APPIMAGETOOL "$APP" "$OUT/人生劇場-CHT-x86_64.AppImage" 2>&1 | tail -4
echo "✓ $OUT/人生劇場-CHT-x86_64.AppImage"
ls -lh "$OUT/人生劇場-CHT-x86_64.AppImage"
