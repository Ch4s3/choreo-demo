"""Burn the narration from demo.tape's `# CAPTION:` lines into the vhs render.

    vhs demo.tape && python3 captions.py

Reads demo-raw.mp4, writes demo.mp4 (captions in a band under the terminal)
and demo.gif. Each caption starts where its marker sits in the tape and lasts
until the next one. Start times are computed from the tape's visible steps
(typing at TypingSpeed, Sleeps; hidden steps take no video time), then scaled
so the total matches the rendered clip.
"""
import json, re, subprocess, sys, tempfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

TAPE, RAW, MP4, GIF = "demo.tape", "demo-raw.mp4", "demo.mp4", "demo.gif"
BAND_H, BG, FG = 110, (17, 17, 27), (205, 214, 244)
FONT = "/System/Library/Fonts/SFNS.ttf"


def ms(tok):
    m = re.fullmatch(r"([\d.]+)(ms|s)", tok)
    return float(m.group(1)) * (1 if m.group(2) == "ms" else 1000)


def timeline(tape):
    t, hidden, speed, caps = 0.0, False, 50.0, []
    for line in tape.splitlines():
        line = line.strip()
        if line.startswith("# CAPTION:"):
            caps.append((t, line[len("# CAPTION:"):].strip()))
        elif line.startswith("Set TypingSpeed"):
            speed = ms(line.split()[-1])
        elif line == "Hide":
            hidden = True
        elif line == "Show":
            hidden = False
        elif hidden:
            continue
        elif line.startswith("Sleep"):
            t += ms(line.split()[1])
        elif line.startswith("Type "):
            t += speed * len(json.loads(line[5:]))
    return t, caps


def duration(path):
    out = subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                                   "-of", "csv=p=0", path], text=True)
    return float(out)


def size(path):
    out = subprocess.check_output(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                                   "stream=width,height", "-of", "csv=p=0", path], text=True)
    w, h = out.strip().split(",")
    return int(w), int(h)


def banner(text, width, path):
    img = Image.new("RGB", (width, BAND_H), BG)
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, 30)
    w = d.textlength(text, font=font)
    while w > width - 80 and font.size > 18:
        font = ImageFont.truetype(FONT, font.size - 1)
        w = d.textlength(text, font=font)
    d.text(((width - w) / 2, (BAND_H - font.size) / 2 - 4), text, font=font, fill=FG)
    img.save(path)


def main():
    planned, caps = timeline(Path(TAPE).read_text())
    real = duration(RAW)
    scale = real / planned if planned else 1.0
    w, h = size(RAW)
    tmp = Path(tempfile.mkdtemp())
    inputs, chain, last = ["-i", RAW], [f"[0]pad={w}:{h + BAND_H}:0:0:color=0x11111b[v0]"], "v0"
    for i, (start, text) in enumerate(caps):
        end = caps[i + 1][0] * scale if i + 1 < len(caps) else real + 1
        png = tmp / f"cap{i}.png"
        banner(text, w, png)
        inputs += ["-i", str(png)]
        chain.append(f"[{last}][{i + 1}]overlay=0:{h}:enable='between(t,{start * scale:.2f},{end:.2f})'[v{i + 1}]")
        last = f"v{i + 1}"
        print(f"{start * scale:6.2f}s  {text}")
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(chain),
                           "-map", f"[{last}]", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", MP4])
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", "-i", MP4, "-filter_complex",
                           "fps=12,scale=960:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse", GIF])
    print(f"planned {planned / 1000:.1f}s, rendered {real:.1f}s; wrote {MP4} and {GIF}")


if __name__ == "__main__":
    sys.exit(main())
