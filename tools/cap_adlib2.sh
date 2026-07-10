export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
pulseaudio --start --exit-idle-time=-1 >/tmp/pa.log 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/tmp/s.log 2>&1
export SDL_AUDIODRIVER=pulseaudio PULSE_SINK=cap
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
timeout 60 ./scummvm --music-driver=adlib jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 0.7; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2; xdotool mousemove 472 405 click 1 2>/dev/null; sleep 4
# 到棋盤,靜置錄 32s(避免點擊聲)
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/adlib.raw 2>/dev/null &
sleep 32
pkill scummvm 2>/dev/null; pkill parec 2>/dev/null; sleep 1
ffmpeg -y -loglevel error -f s16le -ar 44100 -ac 2 -i /out/adlib.raw /out/adlib.wav 2>/dev/null
ffmpeg -i /out/adlib.wav -af volumedetect -f null /dev/null 2>&1 | grep -E "mean_volume|max_volume|Duration"
# 靜音分佈(確認持續)
ffmpeg -y -loglevel error -i /out/adlib.wav -af silencedetect=n=-45dB:d=3 -f null /dev/null 2>&1 | grep silence | head -4
