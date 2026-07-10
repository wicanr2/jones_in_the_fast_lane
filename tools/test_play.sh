export HOME=/tmp/fresh XDG_RUNTIME_DIR=/tmp DISPLAY=:99 APPIMAGE_EXTRACT_AND_RUN=1
rm -rf /tmp/fresh; mkdir -p /tmp/fresh
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 3
# 裸跑(模擬雙擊,不給任何參數)
timeout 30 "/w/out/人生劇場-可玩版-x86_64.AppImage" 2>/tmp/play.log &
sleep 12; import -window root /out/shots/play_boot.png 2>/dev/null
pkill -f scummvm 2>/dev/null; echo done
echo "=== play.log ==="; grep -iE 'jones|running|language|error' /tmp/play.log | head
