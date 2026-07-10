# SETUP — 在另一台機器重建人生劇場繁中化開發環境

Jones in the Fast Lane（人生劇場）ScummVM SCI 繁中化。本包讓另一台機器**重建環境**並用
`claude -r` **接續同一個 Claude 對話與記憶**（見 `previous-work.md` §跨機接續）。

## 0. 解到相同絕對路徑（★ claude -r 前提）

```bash
mkdir -p /home/anr2/scummvm/jones_in_the_fast_lane
tar --zstd -xf dev-setup-jones-YYYYMMDD.tar.zst -C /home/anr2/scummvm/jones_in_the_fast_lane
cd /home/anr2/scummvm/jones_in_the_fast_lane/workplace
```
路徑無法一致時見 `previous-work.md` 的 UUID resume 法。

## 1. 還原 Claude session（對話 + 記憶）

```bash
mkdir -p ~/.claude/projects
cp -a claude-session/projects/-home-anr2-scummvm-janes-in-fast-lane ~/.claude/projects/
# 之後:cd workplace → claude --resume 07cf138e-bac0-4973-9ea1-43d524816253
```

## 2. Docker image（全部從 Dockerfile 重建，不入包）

| image | Dockerfile | 用途 |
|---|---|---|
| `qfg1-build` | `docker/Dockerfile.build` | build ScummVM SCI |
| `qfg1-capture` | `docker/Dockerfile.capture` | xvfb 截圖/導航 |
| `jones-tools` | `docker/Dockerfile.tools` | Pillow 烘字 |
| `jones-video` | `docker/Dockerfile.video` | ffmpeg/IM 影片 |
| `jones-audio` | `docker/Dockerfile.audio` | +pulseaudio 錄配樂 |

```bash
for f in build capture tools video audio; do
  tag=$([ $f = build -o $f = capture ] && echo qfg1-$f || echo jones-$f)
  docker build -t $tag -f docker/Dockerfile.$f docker/
done
```

## 3. 重建 ScummVM 引擎（scummvm-src 不入包）

```bash
# 取 pinned ScummVM 2026.2.1git(git clone 後 checkout 對應 commit),放 scummvm-src/
bash tools/apply_patches.sh scummvm-src      # 套 0001+0002+fontchinese
docker run --rm -v "$PWD/scummvm-src:/src" -w /src qfg1-build bash -c \
  "./configure --disable-all-engines --enable-engine=sci --disable-detection-full --disable-mt32emu && make -j\$(nproc)"
```

## 4. 打包

```bash
bash tools/package.sh $(date +%Y%m%d)   # patch源碼包 / 遊戲資料包 / Linux執行包
bash tools/make_promo.sh                # 推廣影片(需 shots + music/bgm.wav)
```

## 重建注意
- `scummvm-src/`（~800M）、`extract/`、`out/`、遊戲 zip/rar **不入包**，皆可重建。
- 原遊戲資源 + 衍生美術僅本機自用，勿散布、勿入公開 repo。
- 音樂 driver 用 **pcjr**（Jones 無 AdLib/MT-32 音軌）。
