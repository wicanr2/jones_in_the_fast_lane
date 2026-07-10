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
  # Jones 音樂為 AdLib(OPL2)音樂,設 adlib driver
  grep -q '^music_driver=' "$INI" || sed -i '/^\[jones\]/a music_driver=adlib' "$INI"
fi
exec "$HERE/scummvm" jones
