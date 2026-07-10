#!/usr/bin/env python3
"""重繪開場 credits 序列(view 1-5)的角色頭銜 → 中文。

credits 每個文字 cel:頂部一列洋紅頭銜(executive producer…)+ 下方藍色人名。
人名屬專有名詞維持原文;只把頂部洋紅頭銜列清掉重畫成中文,藍色人名列不動。
偵測頭銜列 = 頂部第一段連續非底色列(洋紅),其色即頭銜色。

輸出:patches_art/{1..5}.v56
在 jones-tools 容器內跑:
  docker run --rm -v "$PWD:/w" -v /usr/share/fonts:/hostfonts:ro jones-tools \
    python3 /w/tools/redraw_credits.py
"""
import sys
sys.path.insert(0, '/w/tools')
from sci1_view import SCI1View, encode_uncompressed, write_patch, _png_to_indices
from PIL import Image, ImageDraw, ImageFont
from collections import Counter

FONT = '/hostfonts/opentype/noto/NotoSansCJK-Bold.ttc'

# (view, loop, cel, 中文頭銜)  —— 人名不動
SPECS = [
    (1, 0, 1, '執行製作'),
    (1, 1, 1, '創意總監'),
    (1, 2, 1, '製作人'),
    (2, 0, 1, '主程式設計'),
    (2, 1, 1, '美術'),
    (2, 2, 1, '美術'),
    (3, 0, 1, '作曲'),
    (3, 1, 1, '原始設計'),
    (3, 1, 2, '原始設計'),
    (3, 2, 1, '原始設計'),
    (3, 2, 2, '原始設計'),
    (4, 0, 1, '演員'),
    (4, 1, 1, '演員'),
    (4, 2, 1, '演員'),
    (5, 0, 1, '演員'),
    (5, 1, 1, '演員'),
]


def find_title_band(bmp, w, h, bg):
    """頂部第一段連續有文字的列 = 頭銜列。回傳 (y0, y1, 頭銜主色, name_start)。
    name_start = 頭銜段之後下一段文字(人名)起點;頭銜與人名間的 gap 可讓中文放大。"""
    def textcount(y):
        return sum(1 for x in range(w) if bmp[y * w + x] != bg)
    y0 = None
    for y in range(h):
        if textcount(y) > 2:
            y0 = y
            break
    if y0 is None:
        return None
    y1 = y0
    gap = 0
    for y in range(y0, h):
        if textcount(y) > 1:
            y1 = y
            gap = 0
        else:
            gap += 1
            if gap >= 3:      # 連續 3 列近乎空白 → 頭銜段結束
                break
    # 人名段起點(頭銜段之後第一列有文字)
    name_start = h
    for y in range(y1 + 2, h):
        if textcount(y) > 2:
            name_start = y
            break
    band = [bmp[y * w + x] for y in range(y0, y1 + 1) for x in range(w) if bmp[y * w + x] != bg]
    color_idx = Counter(band).most_common(1)[0][0] if band else 0
    return y0, y1, color_idx, name_start


by_view = {}
for vid, li, ci, zh in SPECS:
    by_view.setdefault(vid, []).append((li, ci, zh))

for vid, jobs in sorted(by_view.items()):
    v = SCI1View(open(f'/w/extract/dump/view.{vid:03d}', 'rb').read())
    pal = v.palette
    reps = {}
    for li, ci, zh in jobs:
        c = v.loops[li][ci]
        w, h = c.w, c.h
        bmp = list(c.bitmap[:w * h])
        bg = Counter(bmp).most_common(1)[0][0]
        band = find_title_band(bmp, w, h, bg)
        if not band:
            print(f"  v{vid} l{li}c{ci}: 找不到頭銜列,跳過")
            continue
        y0, y1, color_idx, name_start = band
        color = pal[color_idx]
        img = Image.new('RGB', (w, h))
        img.putdata([pal[b] for b in bmp])
        d = ImageDraw.Draw(img)
        # 可用區 = 頭銜列頂 → 人名列前留 1px;中文可用這整段(含原 gap)放大更清楚
        avail_bottom = max(y1 + 1, name_start - 1)
        for y in range(y0, avail_bottom):
            for x in range(w):
                img.putpixel((x, y), pal[bg])
        bh = avail_bottom - y0
        fs = max(10, min(bh, 15))
        font = ImageFont.truetype(FONT, fs, index=0)
        bb = d.textbbox((0, 0), zh, font=font)
        tw, th = bb[2] - bb[0], bb[3] - bb[1]
        tx = (w - tw) // 2 - bb[0]
        ty = y0 + (bh - th) // 2 - bb[1]
        d.text((tx, ty), zh, font=font, fill=color)
        p = f'/w/extract/creditsdbg/cht_v{vid}_l{li}_c{ci}.png'
        img.save(p)
        reps[(li, ci)] = _png_to_indices(p, w, h, pal)
        print(f"  v{vid} l{li}c{ci} {zh}: band y{y0}-{y1} color{color_idx}{color} fs{fs}")
    data = encode_uncompressed(v, reps)
    write_patch(data, f'/w/patches_art/{vid}.v56')
    print(f"→ {vid}.v56 ({len(reps)} 頭銜)")
