#!/usr/bin/env bash
# 在 jones-mxe 容器內把 CHT ScummVM(SCI-only)跨編成 Windows x86_64 靜態 exe。
# 掛載:/w = workplace(scummvm-src 已套 patch)。輸出:/w/out/scummvm.exe
set -euo pipefail
export PATH="/usr/lib/mxe/usr/bin:${PATH}"
HOST=x86_64-w64-mingw32.static
SRC=/w/scummvm-src
B=/tmp/winbuild
OUT=/w/out

# 複製源碼到可寫 build 目錄,排除 Linux build 產物(避免污染 host 的 Linux build)
rm -rf "$B"; mkdir -p "$B"
cp -a "$SRC"/. "$B"/
cd "$B"
find . -name '*.o' -delete; find . -name '*.a' -delete
rm -f config.mk config.h config.log scummvm scummvm.exe

# mingw x86_64 恆為小端;SDL2 的 SDL_main/WinMain 讓 endianness 探測連結失敗 →
# configure 判 unknown 會中止。比照 ScummVM 對 emscripten 的做法,mingw 預設 little。
sed -i 's/^echo $_endian$/case "$_host_os" in mingw*) test "$_endian" = unknown \&\& _endian=little;; esac\necho $_endian/' configure

# 跨編 configure(SCI-only,靜態,AdLib 內建不需外部音訊庫)
./configure --host="$HOST" \
  --disable-all-engines --enable-engine=sci \
  --disable-mt32emu --disable-detection-full \
  --with-sdl-prefix="$MXE_PREFIX" \
  --enable-release --disable-debug

make -j"$(nproc)"

"${HOST}-strip" scummvm.exe 2>/dev/null || true

# 組完整 Windows 包:scummvm.exe(MXE 靜態,免 DLL)+ CHT 資料 + 啟動器
PKG="$OUT/jones-cht-windows"
rm -rf "$PKG"; mkdir -p "$PKG/cht"
cp scummvm.exe "$PKG/scummvm.exe"
cp /w/dist/game-cht/* "$PKG/cht/"
cp /w/README.md "$PKG/" 2>/dev/null || true
# run.bat:把 CHT 資料複製進遊戲目錄、加入遊戲、設中文+AdLib、啟動
cat > "$PKG/繁中啟動.bat" <<'BAT'
@echo off
chcp 65001 >nul
echo 人生劇場 繁體中文化 啟動器
set /p GAME=請把 Jones 遊戲目錄(含 resource.map)拖到這裡再按 Enter:
if not exist "%GAME%\resource.map" ( echo 找不到 resource.map & pause & exit /b )
copy /y "%~dp0cht\*" "%GAME%\" >nul
"%~dp0scummvm.exe" --path="%GAME%" --add
echo 請在 ScummVM 中把該遊戲的 language 設為 Chinese (Traditional)、music_driver 設為 adlib
"%~dp0scummvm.exe"
BAT

mkdir -p "$OUT"
( cd "$OUT" && zip -qr jones-cht-windows.zip jones-cht-windows )
echo "✓ $OUT/jones-cht-windows.zip"
file "$PKG/scummvm.exe"
echo "靜態連結檢查(應無外部 DLL 依賴或僅系統 DLL):"
"${HOST}-objdump" -p "$PKG/scummvm.exe" 2>/dev/null | grep -i 'DLL Name' | head
ls -lh "$PKG/scummvm.exe"
