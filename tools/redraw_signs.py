import sys, os
sys.path.insert(0,'/w/tools')
from sci1_pic import SCI1Pic
from PIL import Image, ImageDraw, ImageFont
from collections import Counter

pic = SCI1Pic(open('/w/extract/dump/pic.011','rb').read())
pal = pic.palette
FONT='/hostfonts/truetype/wqy/wqy-zenhei.ttc'

# (cel_idx, 中文, 招牌帶 y 起訖比例, 左右邊距 px)
SPECS = [
 (1,'保全',0.02,0.30,4),
 (2,'租屋',0.05,0.52,3),
 (3,'平價住宅',0.03,0.28,2),
 (4,'當舖',0.06,0.42,3),
 (5,'Z超商',0.22,0.60,3),
 (6,'大石頭',0.55,0.82,3),
 (7,'服飾',0.12,0.52,3),
 (8,'插座城',0.34,0.66,3),
 (9,'科技大學',0.45,0.70,3),
 (10,'職介所',0.34,0.74,3),
 (12,'銀行',0.52,0.74,2),
 (13,'超市',0.22,0.62,3),
]

def brightness(rgb): return 0.3*rgb[0]+0.59*rgb[1]+0.11*rgb[2]

reps={}
os.makedirs('/w/extract/redraw/signs',exist_ok=True)
for idx,zh,y0f,y1f,mx in SPECS:
    c=pic.cels[idx]; w,h=c['w'],c['h']
    bmp=pic.decode(idx)
    img=Image.new('RGB',(w,h))
    img.putdata([pal[b] for b in bmp[:w*h]])
    y0=int(h*y0f); y1=int(h*y1f)
    # 取招牌帶內最常見色當底(排除 clearKey)
    band=[bmp[y*w+x] for y in range(y0,y1) for x in range(mx,w-mx) if bmp[y*w+x]!=c['clear']]
    bg_idx=Counter(band).most_common(1)[0][0] if band else 0
    bg=pal[bg_idx]
    txt=(20,20,20) if brightness(bg)>120 else (245,245,245)
    d=ImageDraw.Draw(img)
    # 蓋掉原文字帶
    for y in range(y0,y1):
        for x in range(mx,w-mx):
            if bmp[y*w+x]!=c['clear']:
                img.putpixel((x,y),bg)
    # 選字級塞進帶高與寬
    bh=y1-y0; bw=w-2*mx
    fs=min(bh, (bw)//max(1,len(zh)))
    fs=max(8,min(fs,14))
    font=ImageFont.truetype(FONT,fs,index=0)
    bb=d.textbbox((0,0),zh,font=font); tw=bb[2]-bb[0]; th=bb[3]-bb[1]
    tx=(w-tw)//2-bb[0]; ty=y0+(bh-th)//2-bb[1]
    d.text((tx,ty),zh,font=font,fill=txt)
    p=f'/w/extract/redraw/signs/cel{idx}.png'
    img.save(p)
    reps[idx]=p
    print(f'cel{idx} {zh}: band y{y0}-{y1} bg{bg} txt{"暗" if txt[0]<128 else "亮"} fs{fs}')

# 加已完成的 factory(cel11)
reps[11]='/w/extract/redraw/cel11_cht.png'
print('specs done, cels:',sorted(reps))
# 存 spec 供 encode
import json; json.dump({str(k):v for k,v in reps.items()},open('/w/extract/redraw/signs/reps.json','w'))
