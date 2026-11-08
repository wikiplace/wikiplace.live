# Wikiplace logo

An open pixel-art book whose pages are a world map. It's a 128×128 sprite.

| File | Use |
| --- | --- |
| `wikiplace.aseprite` | Source, one layer per part: background, cover, pages, flag, ribbon |
| `wikiplace-128.png` | The sprite at its real size |
| `wikiplace-512.png` | 4× copy for avatars (GitHub App, org) |

## Rebuild

`source/book.lua` draws everything except the map as exact, symmetric shapes, then bends the cover and the paper by different amounts. Sizes and colours are named constants at the top of the script. To rebuild after changing one:

```sh
cd brand
aseprite -b --script-param map=source/map-128.png --script-param out=wikiplace.aseprite --script source/book.lua
aseprite -b wikiplace.aseprite --save-as wikiplace-128.png
aseprite -b wikiplace.aseprite --scale 4 --save-as wikiplace-512.png
```

The map started as an AI-generated image (`source/generated.png`) whose pixels weren't on a consistent grid. `source/regrid.py` resampled it onto a true 128×128 grid, with a palette taken from the image's main colours, to make `source/map-128.png`:

```sh
python3 source/regrid.py source/generated.png source/map-128.png /tmp/preview.png 128 20 17131A 8
```
