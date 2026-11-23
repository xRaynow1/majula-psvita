from PIL import Image

def convert_vita_png(src, dst, size):
    img = Image.open(src).convert("RGBA").resize(size, Image.Resampling.LANCZOS)
    img_8bit = img.convert("P", palette=Image.ADAPTIVE, colors=256)
    img_8bit.save(dst, format="PNG", optimize=True)

convert_vita_png("bg.png", "bg_vita.png", (840, 500))
