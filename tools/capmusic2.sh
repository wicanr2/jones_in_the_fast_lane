export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
pulseaudio --start --exit-idle-time=-1 >/tmp/pa.log 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/tmp/s.log 2>&1
export SDL_AUDIODRIVER=pulseaudio PULSE_SINK=cap
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/cap.raw 2>/dev/null &
timeout 45 ./scummvm --music-driver=pcjr jones 2>/tmp/g.log &
# 不按鍵,讓標題/開場音樂連續播 ~40s
sleep 42
pkill scummvm 2>/dev/null; pkill parec 2>/dev/null; sleep 1
ffmpeg -y -loglevel error -f s16le -ar 44100 -ac 2 -i /out/cap.raw /out/music_raw.wav 2>/dev/null
echo "=== 整段音量 + 靜音分佈 ==="
ffmpeg -i /out/music_raw.wav -af volumedetect -f null /dev/null 2>&1 | grep -E "mean_volume|max_volume|Duration"
ffmpeg -y -loglevel error -i /out/music_raw.wav -af silencedetect=n=-45dB:d=2 -f null /dev/null 2>&1 | grep silence | head -6
