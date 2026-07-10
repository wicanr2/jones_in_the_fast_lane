#!/usr/bin/env python3
"""design_c —— 「人生劇場」明體古典/劇場感版本。

方向:呼應「劇場」二字的戲劇質感,走古典戲單(playbill)配色 ——
深藍底 + 金色粗明體 + 淡金高光,明體橫細直粗、頓點帶古典戲劇氣。
保留上半 Sierra 球標 + SIERRA PRESENTS,下方留英文小字副標致敬。
"""
import json
from PIL import Image, ImageDraw, ImageFont

BASE = '/w/extract/titledesign'
W, H = 193, 165

# 自足:直接由原 pic.000 取調色盤與參考 cel(不依賴 scratch 檔),再產 0.p56。
# 執行:docker run --rm -v "$PWD:/w" -v /usr/share/fonts:/hostfonts:ro jones-tools:latest \
#         python3 /w/tools/redraw_title.py
import os, sys
sys.path.insert(0, '/w/tools')
from sci1_pic import SCI1Pic
os.makedirs(BASE, exist_ok=True)
_pic = SCI1Pic(open('/w/extract/dump/pic.000', 'rb').read())
PAL = [list(c) for c in _pic.palette]
_c = _pic.cels[0]
_bmp = _pic.decode(0)
_ref = Image.new('RGB', (_c['w'], _c['h']))
_ref.putdata([tuple(_pic.palette[b]) for b in _bmp[:_c['w'] * _c['h']]])
_ref.save(f'{BASE}/reference_original.png')

def snap_idx(rgb):
    best, bd = 0, 1 << 30
    for i, c in enumerate(PAL):
        d = (c[0]-rgb[0])**2 + (c[1]-rgb[1])**2 + (c[2]-rgb[2])**2
        if d < bd:
            bd, best = d, i
    return best

def snap_to_palette(img):
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            px[x, y] = tuple(PAL[snap_idx(px[x, y])])
    return img

# 便利色
PINK = tuple(PAL[144]); BOX = tuple(PAL[150]); SHADOW = tuple(PAL[156])
BLUE_DK = tuple(PAL[180]); BLUE = tuple(PAL[190]); BLUE_HI = tuple(PAL[189])
WHITE = (255, 255, 255)

def load_original():
    return Image.open(f'{BASE}/reference_original.png').convert('RGB')

# ---- 設計師改這裡 ----------------------------------------------------------
# 配色(戲單風):深藍底 + 金字 + 淡金高光 + 暗金描邊
NAVY      = tuple(PAL[183])   # (0,0,99)   標題框深藍底
NAVY_DK   = tuple(PAL[180])   # (0,0,67)   最深藍(字描邊/陰影)
GOLD      = tuple(PAL[28])    # (216,216,38) 金黃字面
GOLD_HI   = tuple(PAL[30])    # (228,228,103) 淡金高光
GOLD_DK   = tuple(PAL[27])    # (184,184,32) 暗金(字腳陰影)

img = load_original()
d = ImageDraw.Draw(img)

# 標題框:深藍底,外圈一道金框當戲台鑲邊
# 先用粉紅底蓋掉原圖殘留的 JONES/淡紫框(y=48 起),再畫深藍戲台
d.rectangle([0, 46, W, 164], fill=PINK)
d.rectangle([6, 50, 186, 161], fill=NAVY)
d.rectangle([6, 50, 186, 161], outline=GOLD_DK, width=1)
d.rectangle([8, 52, 184, 159], outline=NAVY_DK, width=1)

# 「人生劇場」粗明體,做立體 bevel
FS = 41
font = ImageFont.truetype('/hostfonts/opentype/noto/NotoSerifCJK-Black.ttc', FS, index=0)
zh = '人生劇場'
bb = d.textbbox((0, 0), zh, font=font)
tw, th = bb[2]-bb[0], bb[3]-bb[1]
tx, ty = (W-tw)//2 - bb[0], 64 - bb[1]

# 1) 深藍描邊(1px 一圈):讓金字自深藍底浮出
for dx in (-1, 0, 1):
    for dy in (-1, 0, 1):
        if dx or dy:
            d.text((tx+dx, ty+dy), zh, font=font, fill=NAVY_DK)
# 2) 暗金字腳陰影(右下)
d.text((tx+1, ty+1), zh, font=font, fill=GOLD_DK)
# 3) 金色字面
d.text((tx, ty), zh, font=font, fill=GOLD)
# 4) 淡金高光(左上一點)
d.text((tx-1, ty-1), zh, font=font, fill=GOLD_HI)
d.text((tx, ty), zh, font=font, fill=GOLD)  # 覆回主面,只留左上緣露出高光

# 中線分隔(戲台橫檔),金線
d.line([18, 118, 175, 118], fill=GOLD_DK, width=1)

# 副標:保留原英文識別,淡金小字
sub_font = ImageFont.truetype('/hostfonts/opentype/noto/NotoSansCJK-Bold.ttc', 12, index=0)
sub = 'JONES in the Fast Lane'
sbb = d.textbbox((0, 0), sub, font=sub_font)
sx = (W-(sbb[2]-sbb[0]))//2 - sbb[0]
d.text((sx+1, 130), sub, font=sub_font, fill=NAVY_DK)      # 陰影
d.text((sx, 129), sub, font=sub_font, fill=GOLD_HI)         # 淡金
# ---------------------------------------------------------------------------

img = snap_to_palette(img)
NAME = 'design_c'
png = f'{BASE}/{NAME}.png'
img.save(png)
img.resize((W*3, H*3), Image.NEAREST).save(f'{BASE}/{NAME}_3x.png')
print(f'saved {NAME}.png')

# 直接編進 pic.000 cel0 → 0.p56(SCI1 pic patch)
import subprocess
subprocess.run([sys.executable, '/w/tools/sci1_pic.py', 'replace',
                '/w/extract/dump/pic.000', '/w/dist/game-cht/0.p56', f'0,{png}'], check=True)
print('→ dist/game-cht/0.p56')
