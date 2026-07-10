import sys
sys.path.insert(0,'/w/tools')
from sci1_view import SCI1View, encode_uncompressed, write_patch
from PIL import Image, ImageDraw, ImageFont
from collections import Counter

v=SCI1View(open('/w/extract/dump/view.250','rb').read())
FONT='/hostfonts/truetype/wqy/wqy-zenhei.ttc'
LABELS={0:'完成',1:'工作',2:'完成',3:'休息',4:'購買',5:'出售',6:'典當',
        7:'選擇',8:'下個',9:'？',10:'選課',11:'遊玩',12:'退休',13:'離開'}

pal=v.palette
reps={}
for li,zh in LABELS.items():
    c=v.loops[li][0]; w,h=c.w,c.h
    img=Image.new('RGB',(w,h)); img.putdata([pal[b] for b in c.bitmap[:w*h]])
    d=ImageDraw.Draw(img)
    # 面色=最常見非 clear 非黑色
    cnt=Counter(b for b in c.bitmap if b not in (c.clear,0))
    face_idx=cnt.most_common(1)[0][0]; face=pal[face_idx]
    # 蓋掉內部文字(留 2px 邊框)
    for y in range(2,h-1):
        for x in range(3,w-3):
            if c.bitmap[y*w+x]!=c.clear:
                img.putpixel((x,y),face)
    # 綠字(深色對比)
    txt=(24,72,48)
    fs=8 if len(zh)>1 else 9
    font=ImageFont.truetype(FONT,fs,index=0)
    bb=d.textbbox((0,0),zh,font=font); tw=bb[2]-bb[0]; th=bb[3]-bb[1]
    tx=(w-tw)//2-bb[0]; ty=(h-th)//2-bb[1]
    d.text((tx,ty),zh,font=font,fill=txt)
    # RGB→index
    from sci1_view import _png_to_indices
    img.save(f'/w/extract/redraw/btn{li}.png')
    reps[(li,0)]=_png_to_indices(f'/w/extract/redraw/btn{li}.png',w,h,pal)

data=encode_uncompressed(v,reps)
write_patch(data,'/w/patches_art/250.v56')
print(f'250.v56 written, {len(reps)} buttons')
