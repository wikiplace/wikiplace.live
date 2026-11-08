"""Resample AI 'pixel art' onto a real grid at a chosen sprite size.

Generated pixel art drifts (its 'pixels' vary in size), so no single source grid
fits. Instead: crop to the artwork, split it into an N x N grid, take each cell's
dominant colour from its centre, snap to a small palette, and pad onto the
background. Output is a genuine N x N sprite plus a nearest-neighbour preview.

usage: python3 regrid.py in.png out_native.png out_preview.png N colours bg_hex pad
"""
import sys
from collections import Counter
from PIL import Image

src, out_native, out_preview = sys.argv[1:4]
n, colours, bg_hex, pad = int(sys.argv[4]), int(sys.argv[5]), sys.argv[6], int(sys.argv[7])
bg = tuple(int(bg_hex[i:i + 2], 16) for i in (0, 2, 4))

img = Image.open(src).convert("RGB")
px = img.load()
w, h = img.size

# Artwork bounds: everything far enough from the background colour.
far = lambda c: sum(abs(a - b) for a, b in zip(c, bg)) > 40
xs = [x for x in range(w) for y in range(0, h, 4) if far(px[x, y])]
ys = [y for y in range(h) for x in range(0, w, 4) if far(px[x, y])]
left, right, top, bottom = min(xs), max(xs) + 1, min(ys), max(ys) + 1
side = max(right - left, bottom - top)
cx, cy = (left + right) / 2, (top + bottom) / 2
inner = n - 2 * pad
cell = side / inner
x0, y0 = cx - side / 2, cy - side / 2

dist = lambda a, b: sum(abs(p - q) for p, q in zip(a, b))

# Palette: the source's most common colours, each distinct from those already
# taken, so small accents (a flag, one continent) keep their own colour.
counts = Counter(tuple(v // 8 * 8 for v in px[x, y]) for x in range(0, w, 2) for y in range(0, h, 2))
palette = [bg]
for colour, count in counts.most_common():
    if count < 40 or len(palette) >= colours:
        break
    if all(dist(colour, p) > 70 for p in palette):
        palette.append(colour)
snap = lambda c: min(palette, key=lambda p: dist(c, p))

sprite = Image.new("RGB", (n, n), bg)
for gy in range(inner):
    for gx in range(inner):
        sx, sy = x0 + gx * cell, y0 + gy * cell
        votes = Counter()
        for i in range(1, 6):
            for j in range(1, 6):
                x, y = int(sx + cell * i / 6), int(sy + cell * j / 6)
                votes[snap(px[x, y]) if 0 <= x < w and 0 <= y < h else bg] += 1
        sprite.putpixel((gx + pad, gy + pad), votes.most_common(1)[0][0])

sprite.save(out_native)
sprite.resize((n * 16, n * 16), Image.Resampling.NEAREST).save(out_preview)
print(f"{n}x{n}, {len(set(sprite.get_flattened_data()))} colours -> {out_native}")
