#!/usr/bin/env python3
"""產生 view.250 按鈕 hi-res 疊繪所需資料 + 字型。

view.250 = 14 個動作按鈕(每個 32x9 logical),烘字在 9px 被引擎 2x nearest 放大 → 塊狀糊。
方案:引擎在 hi-res 疊繪——用面色填掉按鈕內文字區,再用原生 16px 字型畫清晰中文。

輸出:
  dist/game-cht/jones_buttons.dat
    [u8 count]
    每 loop: [face u8][fg u8][n u8][n × u16 BE big5]   (loop index = record index)
  dist/game-cht/jones_btn.fnt
    16x16 1bpp:[u16 BE code][16 rows × 2 bytes]... + 0xFFFF
"""
import sys, struct
sys.path.insert(0, '/w/tools')
from sci1_view import SCI1View
from PIL import Image, ImageFont, ImageDraw
from collections import Counter

FONT = '/hostfonts/opentype/noto/NotoSansCJK-Bold.ttc'
V = SCI1View(open('/w/extract/dump/view.250', 'rb').read())
PAL = V.palette

# loop → 中文(對齊 redraw_buttons.py)
LABELS = {0: '完成', 1: '工作', 2: '完成', 3: '休息', 4: '購買', 5: '出售', 6: '典當',
          7: '選擇', 8: '下個', 9: '？', 10: '選課', 11: '遊玩', 12: '退休', 13: '離開'}

BTN_W = 16   # glyph box
BTN_H = 16
ROWB = BTN_W // 8   # 2


def nearest(rgb):
    best, bd = 0, 1 << 30
    for i, c in enumerate(PAL):
        d = (c[0]-rgb[0])**2 + (c[1]-rgb[1])**2 + (c[2]-rgb[2])**2
        if d < bd:
            bd, best = d, i
    return best


FG = nearest((24, 60, 40))   # 深色字(對比淺綠/teal 按鈕),同原烘字風格

# ── jones_buttons.dat ──
recs = []
for li in range(len(V.loops)):
    c = V.loops[li][0]
    bmp = c.bitmap
    clear = c.clear
    # 面色 = 按鈕內部最常見非 clear 非黑
    cnt = Counter(b for b in bmp if b not in (clear, 0))
    face = cnt.most_common(1)[0][0] if cnt else 0
    zh = LABELS.get(li, '')
    codes = []
    for ch in zh:
        try:
            b = ch.encode('big5')
            codes.append((b[0] << 8) | b[1] if len(b) == 2 else b[0])
        except Exception:
            pass
    recs.append((face, FG, codes))

with open('/w/dist/game-cht/jones_buttons.dat', 'wb') as fh:
    fh.write(struct.pack('<B', len(recs)))
    for face, fg, codes in recs:
        fh.write(struct.pack('<BBB', face, fg, len(codes)))
        for code in codes:
            fh.write(struct.pack('>H', code))
print('jones_buttons.dat:', len(recs), 'loops')

# ── jones_btn.fnt(16px 原生,只烘按鈕用到的字)──
chars = set()
for zh in LABELS.values():
    for ch in zh:
        try:
            ch.encode('big5'); chars.add(ch)
        except Exception:
            pass
font = ImageFont.truetype(FONT, 15, index=0)
out = bytearray()
n = 0
for ch in sorted(chars):
    b = ch.encode('big5')
    if len(b) != 2:
        continue
    code = (b[0] << 8) | b[1]
    img = Image.new('L', (BTN_W, BTN_H), 0)
    d = ImageDraw.Draw(img)
    bb = d.textbbox((0, 0), ch, font=font)
    tw, th = bb[2]-bb[0], bb[3]-bb[1]
    d.text(((BTN_W-tw)//2 - bb[0], (BTN_H-th)//2 - bb[1]), ch, font=font, fill=255)
    px = img.load()
    out += struct.pack('>H', code)
    for y in range(BTN_H):
        for bx in range(ROWB):
            byte = 0
            for bit in range(8):
                x = bx*8 + bit
                if px[x, y] >= 110:
                    byte |= (1 << (7-bit))
            out.append(byte)
    n += 1
out += struct.pack('>H', 0xFFFF)
open('/w/dist/game-cht/jones_btn.fnt', 'wb').write(out)
print('jones_btn.fnt:', n, 'glyphs', BTN_W, 'x', BTN_H)
