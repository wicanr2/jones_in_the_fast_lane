#!/usr/bin/env bash
set -eu
# ===== 設計 token（人生劇場：90s 都市生活模擬，明亮活潑）=====
BG='#123a4a'; BGD='#0a2029'; ACCENT='#f0a828'; ACCSH='#8a5c10'; TEAL='#2aa0a0'; CREAM='#f4efe2'
# Noto Sans CJK（現代黑體，貼合都市生活模擬 + 本專案字型選擇）
FB=/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc
FR=/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc
W=1280; H=720; FPS=25; SHOT=/shots; OUT=/out; TMP=/tmp/c; mkdir -p "$TMP" "$OUT"

card(){ # $1 out $2 中標 $3 英標 $4 副標
  convert -size ${W}x${H} "radial-gradient:#1c5064-${BGD}" -font "$FB" -gravity center \
    -fill "$ACCSH" -pointsize 96 -annotate +3+3 "$2" -fill "$ACCENT" -pointsize 96 -annotate +0+0 "$2" \
    -font "$FR" -fill "$CREAM" -pointsize 46 -annotate +0+100 "$3" \
    -fill "$TEAL" -pointsize 30 -annotate +0+180 "$4" "$1"; }
slide(){ # $1 out $2 screenshot $3 字幕
  convert -size ${W}x${H} "gradient:${BG}-${BGD}" "$TMP/bg.png"
  convert "$SHOT/$2" -filter point -resize x600 -bordercolor "$ACCENT" -border 3 "$TMP/sc.png"
  convert "$TMP/bg.png" \( "$TMP/sc.png" \) -gravity north -geometry +0+18 -composite \
    -fill "#000000aa" -draw "rectangle 0,648 ${W},720" \
    -font "$FR" -fill "$CREAM" -gravity south -pointsize 36 -annotate +0+28 "$3" "$1"; }
kb(){ # $1 png $2 mp4 $3 秒（靜態+淡入淡出，不用 zoompan）
  local FO; FO=$(awk "BEGIN{print $3-0.5}")
  ffmpeg -y -loglevel error -loop 1 -i "$1" -t "$3" -r $FPS \
    -vf "fade=t=in:st=0:d=0.5,fade=t=out:st=$FO:d=0.5,format=yuv420p" \
    -threads 2 -c:v libx264 -preset veryfast -pix_fmt yuv420p "$2"; }

# ===== 分鏡（640×400 hi-res 繁中畫面）=====
card  "$TMP/00.png" '人生劇場' 'Jones in the Fast Lane' '　Sierra 1990 經典 · 繁體中文化　'
slide "$TMP/01.png" s_copyright.png '啟動畫面 · 全程繁體中文渲染 · 776 則全譯'
slide "$TMP/02.png" s_board.png     '棋盤地點招牌 · 640×400 高解析重繪成中文'
slide "$TMP/03.png" s_playfair.png  '選單 / 對話 · 「公平競爭 / 全力一搏」全繁中'
card  "$TMP/99.png" '人生劇場' 'ScummVM 繁中化 · 免費開源' 'github.com/wicanr2/jones_in_the_fast_lane'

# ===== concat + 配樂 =====
LIST="$TMP/list.txt"; : > "$LIST"
declare -A DUR=( [00]=5 [01]=7 [02]=8 [03]=7 [99]=6 )
for f in 00 01 02 03 99; do
  kb "$TMP/$f.png" "$TMP/s_$f.mp4" "${DUR[$f]}"; echo "file '$TMP/s_$f.mp4'" >> "$LIST"
done
ffmpeg -y -loglevel error -f concat -safe 0 -i "$LIST" -threads 2 -c:v libx264 -preset veryfast -pix_fmt yuv420p "$TMP/silent.mp4"
TOTAL=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/silent.mp4"); FO=$(awk "BEGIN{print $TOTAL-3}")
if [ -f /music/bgm.wav ]; then
  ffmpeg -y -loglevel error -i "$TMP/silent.mp4" -i /music/bgm.wav \
    -filter_complex "[1:a]aloop=loop=-1:size=2e9,atrim=0:$TOTAL,afade=t=in:st=0:d=2,afade=t=out:st=$FO:d=3[a]" \
    -map 0:v -map "[a]" -threads 2 -c:v libx264 -preset veryfast -c:a aac -b:a 192k -shortest -movflags +faststart \
    "$OUT/jones-cht-promo.mp4"
else
  cp "$TMP/silent.mp4" "$OUT/jones-cht-promo.mp4"
fi
echo "✓ $OUT/jones-cht-promo.mp4"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/jones-cht-promo.mp4"
