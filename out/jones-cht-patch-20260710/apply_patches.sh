#!/usr/bin/env bash
# 把繁中化引擎改動套進一份乾淨(或既有)的 ScummVM source 樹。
# 用法:apply_patches.sh <scummvm-src-dir>
set -euo pipefail
SRC="${1:?用法: apply_patches.sh <scummvm-src-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

# 新檔
cp "$HERE/patches/fontchinese.h"   "$SRC/engines/sci/graphics/fontchinese.h"
cp "$HERE/patches/fontchinese.cpp" "$SRC/engines/sci/graphics/fontchinese.cpp"

# 既有檔 diff
# 0001:SCI 繁中化引擎 base(GfxFontChinese、text16 hook、getLanguage、dump hook)
patch -p0 -d "$SRC" < "$HERE/patches/0001-sci-cht-zh_twn.patch"
# 0002:Jones/SCI1 專屬(detector ZH_TWN→EN_ANY 例外、kFormat 動態字 hook、SCI_CHT_DEBUG)
patch -p1 -d "$SRC" < "$HERE/patches/0002-jones-sci1-cht.patch"

echo ">> 已套用。configure 範例(docker 內):"
echo "   ./configure --disable-all-engines --enable-engine=sci --disable-detection-full --disable-mt32emu"
