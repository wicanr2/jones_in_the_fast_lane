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
