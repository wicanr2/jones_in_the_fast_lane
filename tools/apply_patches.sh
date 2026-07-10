#!/usr/bin/env bash
# 把繁中化引擎改動套進一份乾淨(或既有)的 ScummVM source 樹。
# 用法:apply_patches.sh <scummvm-src-dir>
set -euo pipefail
SRC="${1:?用法: apply_patches.sh <scummvm-src-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

# 新檔
cp "$HERE/patches/fontchinese.h"   "$SRC/engines/sci/graphics/fontchinese.h"
cp "$HERE/patches/fontchinese.cpp" "$SRC/engines/sci/graphics/fontchinese.cpp"

# 既有檔 diff。-N(forward,略過已套)+ --fuzz=2(容忍上游行號漂移,CI 對 master build 較穩)。
# 對「patch 當時的 base」是精確套用;對較新 master 靠 fuzz 容錯,失敗會明顯報錯。
P="patch -N --fuzz=2"
# 0001:SCI 繁中化引擎 base(GfxFontChinese、text16 hook、getLanguage、dump hook)
$P -p0 -d "$SRC" < "$HERE/patches/0001-sci-cht-zh_twn.patch"
# 0002:Jones/SCI1 專屬(detector ZH_TWN→EN_ANY 例外、kFormat 動態字 hook、SCI_CHT_DEBUG、640x400 hi-res 字型)
$P -p1 -d "$SRC" < "$HERE/patches/0002-jones-sci1-cht.patch"
# 0003:640x400 hi-res 棋盤招牌疊繪(drawChtBoardSigns，讀 jones_big5_hi.fnt / jones_signs.dat)
$P -p1 -d "$SRC" < "$HERE/patches/0003-jones-hires-signs.patch"
# 0004:kFormat 的 %s 參數字串也翻譯(StrCat 組字如「Goal Points = 200 !」前綴中文化)
$P -p1 -d "$SRC" < "$HERE/patches/0004-jones-cht-format-argstr.patch"

echo ">> 已套用。configure 範例(docker 內):"
echo "   ./configure --disable-all-engines --enable-engine=sci --disable-detection-full --disable-mt32emu"
