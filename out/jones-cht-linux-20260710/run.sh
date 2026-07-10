#!/usr/bin/env bash
# 用法:run.sh <jones 遊戲目錄>  (會把繁中資料複製進去並以中文啟動)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
GAME="${1:?用法: run.sh <jones 遊戲目錄(含 resource.map)>}"
cp "$HERE/cht/"* "$GAME/"
"$HERE/scummvm" --path="$GAME" --add >/dev/null 2>&1 || true
INI="$HOME/.config/scummvm/scummvm.ini"
[ -f "$INI" ] && sed -i 's/^language=en$/language=tw/' "$INI" || true
exec "$HERE/scummvm" jones
