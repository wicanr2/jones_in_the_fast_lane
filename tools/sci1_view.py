#!/usr/bin/env python3
"""Jones (SCI1 VGA) view 編解碼器。

sci_view.py 針對 SCI1.1；Jones 是 SCI1，view header 佈局不同(解 0 cel)。本檔依 ScummVM
engines/sci/graphics/view.cpp 的 kViewVga 分支 + palette16.cpp 逆向 SCI1 VGA 格式:

View header(resource 起始,dump 檔前 2 bytes 為 patch header,需 strip):
  [0]u8 loopCount  [1]u8 flags(0x80=有palette,0x40=未壓縮)
  [2:4]u16LE mirrorBits  [4:6]u16LE version  [6:8]u16LE palOffset
  [8 + loop*2]u16LE loop offset 表
Loop header(@loopOffset): [0:2]celCount [2:4]unknown [4 + cel*2]cel offset 表
Cel header(@celOffset,VGA): [0:2]w [2:4]h [4]dispX(s8) [5]dispY [6]clearKey [7]unk [8:]資料
Cel 資料: 壓縮(單流 RLE)或未壓縮(raw w*h index)。
  RLE 控制位元組 c: len=c&0x3F, op=c&0xC0
    0x00 copy len bytes literal / 0x40 copy len+64 literal / 0x80 fill len 以下一 byte / 0xC0 skip len(透明)
Palette(@palOffset, VARIABLE 格式): palOffset+260 起,每色 4 bytes(used,r,g,b),256 色。

用法:
  sci1_view.py info   <view_file>
  sci1_view.py decode <view_file> <out_dir>            # 每 cel 一張 PNG(套內嵌 palette)
  sci1_view.py verify <view_file> <ppm_dir> <vid>      # 對 SCI_DUMP_ALLVIEWS 的 view_<vid>_<l>_<c>.ppm
純 stdlib + Pillow(僅 decode/verify 存 PNG 用)。
"""
import sys, os, struct, glob

PATCH_HEADER = 2

def u8(d, o): return d[o]
def u16(d, o): return d[o] | (d[o+1] << 8)

class Cel:
    __slots__ = ('w', 'h', 'dx', 'dy', 'clear', 'bitmap')

class SCI1View:
    def __init__(self, raw):
        d = raw[PATCH_HEADER:] if raw[:1] == b'\x80' else raw
        self.data = d
        self.loop_count = u8(d, 0)
        self.flags = u8(d, 1)
        self.has_pal = bool(self.flags & 0x80)
        self.compressed = not (self.flags & 0x40)
        self.mirror_bits = u16(d, 2)
        self.pal_offset = u16(d, 6)
        self.loops = []
        for ln in range(self.loop_count):
            loff = u16(d, 8 + ln * 2)
            self.loops.append(self._read_loop(loff, ln))
        self.palette = self._read_palette() if (self.has_pal and self.pal_offset and self.pal_offset != 0x100) else None

    def _read_loop(self, loff, ln):
        d = self.data
        cel_count = u16(d, loff)
        cels = []
        for cn in range(cel_count):
            coff = u16(d, loff + 4 + cn * 2)
            cels.append(self._read_cel(coff))
        return cels

    def _read_cel(self, coff):
        d = self.data
        c = Cel()
        c.w = u16(d, coff)
        c.h = u16(d, coff + 2)
        c.dx = struct.unpack('b', d[coff+4:coff+5])[0]
        c.dy = d[coff + 5]
        c.clear = d[coff + 6]
        c.bitmap = self._decode_cel(coff + 8, c.w, c.h, c.clear)
        return c

    def _decode_cel(self, pos, w, h, clear):
        n = w * h
        out = bytearray([clear]) * n
        d = self.data
        if not self.compressed:
            out[:n] = d[pos:pos+n]
            return out
        p = pos
        i = 0
        while i < n:
            cb = d[p]; p += 1
            ln = cb & 0x3F
            op = cb & 0xC0
            if op == 0x40:
                ln += 64
                op = 0x00
            if op == 0x00:  # literal copy
                m = min(ln, n - i)
                out[i:i+m] = d[p:p+m]
                p += ln
                i += ln
            elif op == 0x80:  # fill
                col = d[p]; p += 1
                m = min(ln, n - i)
                for k in range(m):
                    out[i+k] = col
                i += ln
            else:  # 0xC0 skip (transparent = clear)
                i += ln
        return out

    def _read_palette(self):
        d = self.data
        po = self.pal_offset
        # VARIABLE 格式:palOffset+260 起,每色 4 bytes(used,r,g,b)
        base = po + 260
        pal = [(0, 0, 0)] * 256
        for c in range(256):
            o = base + c * 4
            if o + 4 > len(d):
                break
            used, r, g, b = d[o], d[o+1], d[o+2], d[o+3]
            pal[c] = (r, g, b)
        return pal


def _save_png(cel, palette, path):
    from PIL import Image
    img = Image.new('RGB', (cel.w, cel.h))
    px = img.load()
    pal = palette or [(i, i, i) for i in range(256)]
    for y in range(cel.h):
        for x in range(cel.w):
            px[x, y] = pal[cel.bitmap[y * cel.w + x]]
    img.save(path)


def cmd_info(f):
    v = SCI1View(open(f, 'rb').read())
    print(f"loops={v.loop_count} flags=0x{v.flags:02x} compressed={v.compressed} "
          f"has_pal={v.has_pal} palOffset={v.pal_offset}")
    for li, cels in enumerate(v.loops):
        dims = ", ".join(f"{c.w}x{c.h}" for c in cels)
        print(f"  loop {li}: {len(cels)} cel(s): {dims}")


def cmd_decode(f, outdir):
    os.makedirs(outdir, exist_ok=True)
    v = SCI1View(open(f, 'rb').read())
    n = 0
    for li, cels in enumerate(v.loops):
        for ci, c in enumerate(cels):
            _save_png(c, v.palette, os.path.join(outdir, f"loop{li}_cel{ci}.png"))
            n += 1
    print(f"decoded {n} cel(s) → {outdir}")


def _read_ppm(path):
    with open(path, 'rb') as fh:
        assert fh.readline().strip() == b'P6'
        line = fh.readline()
        while line.startswith(b'#'):
            line = fh.readline()
        w, h = map(int, line.split())
        fh.readline()  # maxval
        data = fh.read(w * h * 3)
    return w, h, data


def cmd_verify(f, ppmdir, vid):
    v = SCI1View(open(f, 'rb').read())
    total = ok = 0
    for li, cels in enumerate(v.loops):
        for ci, c in enumerate(cels):
            ppm = os.path.join(ppmdir, f"view_{vid}_{li}_{ci}.ppm")
            if not os.path.exists(ppm):
                continue
            total += 1
            pw, ph, pdata = _read_ppm(ppm)
            if (pw, ph) != (c.w, c.h):
                print(f"  loop{li}cel{ci}: 尺寸不符 mine={c.w}x{c.h} ppm={pw}x{ph}")
                continue
            pal = v.palette or [(i, i, i) for i in range(256)]
            mism = 0
            for idx in range(c.w * c.h):
                r, g, b = pal[c.bitmap[idx]]
                if (r, g, b) != (pdata[idx*3], pdata[idx*3+1], pdata[idx*3+2]):
                    mism += 1
            if mism == 0:
                ok += 1
            else:
                print(f"  loop{li}cel{ci}: {mism}/{c.w*c.h} px 不符")
    print(f"verify: {ok}/{total} cel 與引擎 PPM 完全一致")


if __name__ == '__main__':
    cmd = sys.argv[1]
    if cmd == 'info':
        cmd_info(sys.argv[2])
    elif cmd == 'decode':
        cmd_decode(sys.argv[2], sys.argv[3])
    elif cmd == 'verify':
        cmd_verify(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        print(__doc__)
        sys.exit(1)
