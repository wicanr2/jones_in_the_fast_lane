export HOME=/tmp/fresh XDG_RUNTIME_DIR=/tmp DISPLAY=:99 APPIMAGE_EXTRACT_AND_RUN=1
rm -rf /tmp/fresh; mkdir -p /tmp/fresh
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 3
timeout 45 "/w/out/人生劇場-可玩版-x86_64.AppImage" 2>/tmp/p.log &
sleep 11; for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3   # play-fair → goals
import -window root /out/shots/play_goals.png 2>/dev/null
pkill -f scummvm 2>/dev/null; echo done
