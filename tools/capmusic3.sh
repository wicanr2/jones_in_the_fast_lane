export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
pulseaudio --start --exit-idle-time=-1 >/tmp/pa.log 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/tmp/s.log 2>&1
export SDL_AUDIODRIVER=pulseaudio PULSE_SINK=cap
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
timeout 60 ./scummvm --music-driver=pcjr jones 2>/tmp/g.log &
sleep 6
# 導航到棋盤
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 0.8; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
# 到棋盤,開始錄(此時若有 board 音樂會連續播)
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/cap.raw 2>/dev/null &
sleep 20
pkill scummvm 2>/dev/null; pkill parec 2>/dev/null; sleep 1
ffmpeg -y -loglevel error -f s16le -ar 44100 -ac 2 -i /out/cap.raw /out/music_raw.wav 2>/dev/null
ffmpeg -i /out/music_raw.wav -af volumedetect -f null /dev/null 2>&1 | grep -E "mean_volume|max_volume|Duration"
echo "=== 開場有無 music init ==="; grep -iE "kDoSound.*init|kDoSound.*play" /tmp/g.log | head -6
