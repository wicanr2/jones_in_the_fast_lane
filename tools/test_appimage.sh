export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 APPIMAGE_EXTRACT_AND_RUN=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 3
cp -r /game /tmp/g && chmod -R u+w /tmp/g
APP="/w/out/人生劇場-CHT-x86_64.AppImage"
timeout 40 "$APP" /tmp/g 2>/tmp/g.log &
sleep 12; import -window root /out/shots/appimage_copyright.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 3; import -window root /out/shots/appimage_title.png 2>/dev/null
pkill -f scummvm 2>/dev/null; echo done
