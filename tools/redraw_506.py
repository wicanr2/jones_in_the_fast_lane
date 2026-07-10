#!/usr/bin/env python3
"""重繪 view 506 loop0 cel1「JONES GOALS」→「瓊斯的目標」。

base 用 extract/dump/view.506(已含 cel0=設定你的目標 的中文重繪),只換 cel1,
再 encode_uncompressed 輸出 506.v56,cel0 中文原樣保留。
"""
import sys
sys.path.insert(0, '/w/tools')
from sci1_view import SCI1View, encode_uncompressed, write_patch, _png_to_indices
from PIL import Image, ImageDraw, ImageFont
from collections import Counter

FONT = '/hostfonts/truetype/wqy/wqy-zenhei.ttc'


def bright(c):
    return 0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]


# (loop, cel, 中文, y0frac, y1frac, xmargin)
JOBS = [(0, 1, '瓊斯的目標', 0.10, 0.90, 8)]

v = SCI1View(open('/w/extract/dump/view.506', 'rb').read())
pal = v.palette
reps = {}
for li, ci, zh, y0f, y1f, mx in JOBS:
    c = v.loops[li][ci]
    w, h = c.w, c.h
    img = Image.new('RGB', (w, h))
    img.putdata([pal[b] for b in c.bitmap[:w * h]])
    d = ImageDraw.Draw(img)
    y0 = int(h * y0f)
    y1 = max(y0 + 9, int(h * y1f))
    band = [c.bitmap[y * w + x] for y in range(y0, y1)
            for x in range(mx, w - mx) if c.bitmap[y * w + x] != c.clear]
    bg_idx = Counter(band).most_common(1)[0][0] if band else 0
    bg = pal[bg_idx]
    txt = (24, 40, 96) if bright(bg) > 120 else (232, 232, 248)
    for y in range(y0, y1):
        for x in range(mx, w - mx):
            if c.bitmap[y * w + x] != c.clear:
                img.putpixel((x, y), bg)
    bh = y1 - y0
    bw = w - 2 * mx
    fs = max(9, min(bh, bw // max(1, len(zh)), 18))
    font = ImageFont.truetype(FONT, fs, index=0)
    bb = d.textbbox((0, 0), zh, font=font)
    tw = bb[2] - bb[0]
    th = bb[3] - bb[1]
    tx = (w - tw) // 2 - bb[0]
    ty = y0 + (bh - th) // 2 - bb[1]
    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        d.text((tx + dx, ty + dy), zh, font=font, fill=(0, 0, 0))
    d.text((tx, ty), zh, font=font, fill=txt)
    p = f'/w/extract/redraw/title_506_{li}_{ci}.png'
    img.save(p)
    reps[(li, ci)] = _png_to_indices(p, w, h, pal)
    print(f'v506 L{li}C{ci} {zh} band y{y0}-{y1} bg{bg_idx} fs{fs}')

data = encode_uncompressed(v, reps)
write_patch(data, '/w/patches_art/506.v56')
print('  → 506.v56')
