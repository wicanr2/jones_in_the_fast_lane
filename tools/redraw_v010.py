import sys; sys.path.insert(0,'/w/tools')
from sci1_view import SCI1View, encode_uncompressed, write_patch, _png_to_indices
from PIL import Image, ImageDraw, ImageFont
from collections import Counter
v=SCI1View(open('/w/extract/dump/view.010','rb').read())
FONT='/hostfonts/truetype/wqy/wqy-zenhei.ttc'
pal=v.palette
# (loop,cel,中文)
LABELS={(1,0):'開始遊戲',(1,1):'觀看示範',(1,2):'讀取遊戲',
        (2,0):'手下留情',(2,1):'公平競爭',(2,2):'全力一搏',
        (3,0):'是',(3,1):'否'}
reps={}
for (li,ci),zh in LABELS.items():
    c=v.loops[li][ci]; w,h=c.w,c.h
    img=Image.new('RGB',(w,h)); img.putdata([pal[b] for b in c.bitmap[:w*h]])
    d=ImageDraw.Draw(img)
    cnt=Counter(b for b in c.bitmap if b not in (c.clear,0))
    face=pal[cnt.most_common(1)[0][0]]
    for y in range(2,h-1):
        for x in range(3,w-3):
            if c.bitmap[y*w+x]!=c.clear: img.putpixel((x,y),face)
    fs=min(h-2, (w-8)//len(zh)); fs=max(9,min(fs,16))
    font=ImageFont.truetype(FONT,fs,index=0)
    bb=d.textbbox((0,0),zh,font=font); tw=bb[2]-bb[0]; th=bb[3]-bb[1]
    tx=(w-tw)//2-bb[0]; ty=(h-th)//2-bb[1]
    d.text((tx,ty),zh,font=font,fill=(0,0,0))  # 黑字
    p=f'/w/extract/redraw/v010_{li}_{ci}.png'; img.save(p)
    reps[(li,ci)]=_png_to_indices(p,w,h,pal)
data=encode_uncompressed(v,reps)
write_patch(data,'/w/patches_art/10.v56')
print(f'10.v56 written, {len(reps)} buttons')
