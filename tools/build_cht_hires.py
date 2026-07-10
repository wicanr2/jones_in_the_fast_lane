#!/usr/bin/env python3
"""烘 2x(高解析)Big5 點陣字型,供 640x400 模式清晰繪字。

輸出 dist/jones_big5_hi.fnt,格式與 dist/jones_big5.fnt 完全相同:
  每字 = big-endian Big5 碼(高位元已設)+ 30 列 × 4 bytes(32px 寬 1bpp,MSB 在左),
  最後 0xFFFF 終結。每字 2 + 30*4 = 122 bytes。

字型渲染邏輯(ink bbox 置中)大量參考 tools/build_cht.py 的字型烘製段落。
字集 = translation/translation_full.tsv 第二欄(中文譯文)用到的字
       ∪ 一串固定 UI/招牌字(全部要含)。
先套 translation/corrections.tsv 與 NORMALIZE/fullwidthize,再收「可 Big5 編碼」的字。

在 docker(jones-tools image)內執行,host 字型掛在 /hostfonts:
  docker run --rm -v ".../workplace:/w" -v /usr/share/fonts:/hostfonts:ro \
      jones-tools:latest python3 /w/tools/build_cht_hires.py
"""
import struct
from PIL import Image, ImageFont, ImageDraw

# --- 2x 版尺寸 ---
WIDTH = 32   # 每列 32 bits = 4 bytes
H = 30       # 30 列
FONT_SIZE = 28
FONT_PATH = "/hostfonts/truetype/wqy/wqy-zenhei.ttc"
FONT_FACE = 0

BASE = "/w"
TSV = f"{BASE}/translation/translation_full.tsv"
CORRECTIONS = f"{BASE}/translation/corrections.tsv"
OUT_FNT = f"{BASE}/dist/jones_big5_hi.fnt"

# 一定要含的 UI/招牌字(整串收字)
UI_CHARS = (
    "保全租屋平價住宅當舖超商大石頭服飾插座城科技大學職介所銀行超市工廠"
    "設定你的目標財富快樂學歷職業誰領先統計資料選擇角色開始遊戲觀看示範"
    "讀取遊戲手下留情公平競爭全力一搏是否完成工作休息購買出售典當選課"
    "遊玩退休離開第週玩家"
)

# 與 build_cht.py 同步:LLM 常產出、但不在 Big5 的字元 → Big5 等價。
NORMALIZE = {
    "⋯": "…", "‘": "「", "’": "」", "“": "『", "”": "』",
    "―": "—", "～": "∼", "‧": "·",
    "赢": "贏", "唠": "嘮", "啧": "嘖", "咔": "喀",
    "銹": "鏽", "嘚": "噠", "嚯": "哦",
    "户": "戶", "嗞": "吱", "鱝": "魟",
}


def normalize(s):
    for a, b in NORMALIZE.items():
        s = s.replace(a, b)
    return s


HALF2FULL = {",": "，", "!": "！", "?": "？", ":": "：", ";": "；"}


def _is_cjk(ch):
    return ch and "㐀" <= ch <= "鿿"


def fullwidthize(s):
    out = []
    n = len(s)
    for i, ch in enumerate(s):
        prev = s[i - 1] if i > 0 else ""
        nxt = s[i + 1] if i + 1 < n else ""
        if ch in HALF2FULL and (_is_cjk(prev) or _is_cjk(nxt)):
            out.append(HALF2FULL[ch])
        elif ch == "." and _is_cjk(prev) and not nxt.isdigit():
            out.append("。")
        else:
            out.append(ch)
    return "".join(out)


def load_corrections():
    corrections = []
    try:
        for line in open(CORRECTIONS, encoding="utf-8"):
            line = line.rstrip("\n")
            if "\t" in line and not line.startswith("#"):
                wrong, right = line.split("\t", 1)
                corrections.append((wrong, right))
    except FileNotFoundError:
        pass
    return corrections


def apply(s, corrections):
    s = normalize(s)
    s = fullwidthize(s)
    for wrong, right in corrections:
        s = s.replace(wrong, right)
    return s


def main():
    corrections = load_corrections()
    chars = set()

    # 1) translation_full.tsv 第二欄(中文譯文)
    with open(TSV, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line or "\t" not in line:
                continue
            en, zh = line.split("\t", 1)
            if not zh or zh == en:
                continue
            chars.update(apply(zh, corrections))

    # 2) UI/招牌字(全部要含)
    chars.update(apply(UI_CHARS, corrections))

    # 只保留可 Big5 編碼、且為 2-byte 的中文字
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE, index=FONT_FACE)
    glyphs = []  # (big5code, bytes)
    for ch in sorted(chars):
        try:
            b5 = ch.encode("big5")
        except UnicodeEncodeError:
            continue
        if len(b5) != 2:
            continue
        code = (b5[0] << 8) | b5[1]  # 高位元組 >=0x81 → 0x8000 已設
        # 渲染到 WIDTH×H 1bpp:以字面 ink bbox 置中(同 build_cht.py)。
        img = Image.new("L", (WIDTH, H), 0)
        d = ImageDraw.Draw(img)
        try:
            bbox = d.textbbox((0, 0), ch, font=font)
        except Exception:
            bbox = (0, 0, WIDTH, H)
        gw = bbox[2] - bbox[0]
        gh = bbox[3] - bbox[1]
        ox = (WIDTH - gw) // 2 - bbox[0]
        oy = (H - gh) // 2 - bbox[1]
        d.text((ox, oy), ch, fill=255, font=font)
        rows_bytes = bytearray()
        px = img.load()
        for y in range(H):
            for byte_i in range(WIDTH // 8):  # 4 bytes / 列
                bits = 0
                for bit in range(8):
                    x = byte_i * 8 + bit
                    on = 1 if px[x, y] >= 128 else 0
                    bits = (bits << 1) | on
                rows_bytes.append(bits)
        glyphs.append((code, bytes(rows_bytes)))

    with open(OUT_FNT, "wb") as out:
        for code, bmp in glyphs:
            out.write(struct.pack(">H", code))
            out.write(bmp)
        out.write(struct.pack(">H", 0xFFFF))  # 終結

    print(f"烘了 {len(glyphs)} 字 (H={H}, W={WIDTH}, size={FONT_SIZE}px) → {OUT_FNT}")


if __name__ == "__main__":
    main()
