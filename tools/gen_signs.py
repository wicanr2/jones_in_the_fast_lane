#!/usr/bin/env python3
"""產生 dist/jones_signs.dat:棋盤 pic 11 各招牌的位置/顏色/中文,供 ScummVM 640x400 hi-res 疊繪。

每個招牌一筆記錄,座標為 logical 320x200(引擎疊繪時自行 ×2)。
輸出格式(binary):
  [u8 count]
  每筆: [x u16 LE][y u16 LE][w u16 LE][bandh u16 LE][bg u8][fg u8][n u8][n × u16 BE big5碼]
"""
import sys, os, struct
from collections import Counter

sys.path.insert(0, '/w/tools')
from sci1_pic import SCI1Pic

PIC = '/w/extract/dump/pic.011'
OUT = '/w/dist/jones_signs.dat'

# (cel_idx, 中文, y0frac, y1frac, mx)  — cel_idx 直接對應 pic.cels[idx]
SPECS = [
    (1,  '保全',   0.02, 0.30, 4),
    (2,  '租屋',   0.05, 0.52, 3),
    (3,  '平價住宅', 0.03, 0.28, 2),
    (4,  '當舖',   0.06, 0.42, 3),
    (5,  'Z超商',  0.22, 0.60, 3),
    (6,  '大石頭',  0.55, 0.82, 3),
    (7,  '服飾',   0.12, 0.52, 3),
    (8,  '插座城',  0.34, 0.66, 3),
    (9,  '科技大學', 0.42, 0.70, 3),
    (10, '職介所',  0.30, 0.74, 3),
    (11, '工廠',   0.05, 0.78, 3),
    (12, '銀行',   0.52, 0.76, 2),
    (13, '超市',   0.14, 0.60, 3),
]


def brightness(rgb):
    return 0.3 * rgb[0] + 0.59 * rgb[1] + 0.11 * rgb[2]


def big5_codes(zh):
    codes = []
    for ch in zh:
        b = ch.encode('big5')
        if len(b) == 1:
            # ASCII 單位元組(如 'Z'):高位元組 0 供引擎判別
            codes.append(b[0])
        else:
            codes.append((b[0] << 8) | b[1])
    return codes


def main():
    pic = SCI1Pic(open(PIC, 'rb').read())
    pal = pic.palette
    records = []
    for idx, zh, y0f, y1f, mx in SPECS:
        c = pic.cels[idx]
        cx, cy, w, h = c['x'], c['y'], c['w'], c['h']
        clear = c['clear']
        bmp = pic.decode(idx)

        y0local = round(h * y0f)
        bandh = max(9, round(h * (y1f - y0f)))
        # band 矩形(logical 座標)
        bx = cx + mx
        by = cy + y0local
        bw = w - 2 * mx

        # bg 索引:band 區域內最常見 palette 索引(排除 clearKey)
        band = []
        for yy in range(y0local, min(y0local + bandh, h)):
            for xx in range(mx, w - mx):
                v = bmp[yy * w + xx]
                if v != clear:
                    band.append(v)
        bg = Counter(band).most_common(1)[0][0] if band else 0
        # fg 索引:依 bg 亮度
        fg = 0 if brightness(pal[bg]) > 120 else 255

        codes = big5_codes(zh)
        records.append((bx, by, bw, bandh, bg, fg, zh, codes))
        print(f"cel{idx:2d} {zh}: x={bx} y={by} w={bw} bandh={bandh} bg={bg} fg={fg}")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'wb') as fh:
        fh.write(struct.pack('<B', len(records)))
        for bx, by, bw, bandh, bg, fg, zh, codes in records:
            # 座標存 hi-res 640x400 pixel(logical 320x200 ×2),引擎端不用再乘 2
            fh.write(struct.pack('<HHHH', bx * 2, by * 2, bw * 2, bandh * 2))
            fh.write(struct.pack('<BBB', bg, fg, len(codes)))
            for code in codes:
                fh.write(struct.pack('>H', code))

    print(f"\n{OUT} size={os.path.getsize(OUT)} bytes, count={len(records)}")


if __name__ == '__main__':
    main()
