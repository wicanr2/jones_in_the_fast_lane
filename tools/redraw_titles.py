import sys
sys.path.insert(0,'/w/tools')
from sci1_view import SCI1View, encode_uncompressed, write_patch, _png_to_indices
from PIL import Image, ImageDraw, ImageFont
from collections import Counter
FONT='/hostfonts/truetype/wqy/wqy-zenhei.ttc'
def bright(c): return 0.3*c[0]+0.59*c[1]+0.11*c[2]

# view: [(loop, 中文, y0frac, y1frac, xmargin)]  (banner 用整片, 面板用頂帶)
JOBS={
 501:[(0,'目標',0.12,0.88,6),(5,'財富',0.08,0.92,4)],
 505:[(0,'誰領先',0.02,0.14,8),(4,'統計資料',0.02,0.14,8)],
 500:[(0,'選擇角色',0.01,0.13,6)],
}
for vid,specs in JOBS.items():
    v=SCI1View(open(f'/w/extract/dump/view.{vid:03d}','rb').read())
    pal=v.palette; reps={}
    for li,zh,y0f,y1f,mx in specs:
        c=v.loops[li][0]; w,h=c.w,c.h
        img=Image.new('RGB',(w,h)); img.putdata([pal[b] for b in c.bitmap[:w*h]])
        d=ImageDraw.Draw(img)
        y0=int(h*y0f); y1=max(y0+9,int(h*y1f))
        band=[c.bitmap[y*w+x] for y in range(y0,y1) for x in range(mx,w-mx) if c.bitmap[y*w+x]!=c.clear]
        bg_idx=Counter(band).most_common(1)[0][0] if band else 0; bg=pal[bg_idx]
        txt=(24,40,96) if bright(bg)>120 else (232,232,248)  # 深藍/淺
        for y in range(y0,y1):
            for x in range(mx,w-mx):
                if c.bitmap[y*w+x]!=c.clear: img.putpixel((x,y),bg)
        bh=y1-y0; bw=w-2*mx
        fs=max(9,min(bh, bw//max(1,len(zh)), 18))
        font=ImageFont.truetype(FONT,fs,index=0)
        bb=d.textbbox((0,0),zh,font=font); tw=bb[2]-bb[0]; th=bb[3]-bb[1]
        tx=(w-tw)//2-bb[0]; ty=y0+(bh-th)//2-bb[1]
        # 深藍字加黑邊提升可讀
        for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            d.text((tx+dx,ty+dy),zh,font=font,fill=(0,0,0))
        d.text((tx,ty),zh,font=font,fill=txt)
        p=f'/w/extract/redraw/title_{vid}_{li}.png'; img.save(p)
        reps[(li,0)]=_png_to_indices(p,w,h,pal)
        print(f'v{vid}L{li} {zh} band y{y0}-{y1} bg{bg} fs{fs}')
    data=encode_uncompressed(v,reps)
    write_patch(data,f'/w/patches_art/{vid}.v56')
    print(f'  → {vid}.v56')
