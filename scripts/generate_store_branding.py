from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
BRANDING_DIR = ROOT / "apps/mobile/assets/branding"
EXPORT_DIR = ROOT / "releases/store-assets"

NAVY = (7, 19, 39)
NAVY_LIGHT = (14, 116, 144)
TEAL = (18, 184, 134)
MINT = (153, 246, 228)
SUN = (255, 183, 3)
WHITE = (247, 250, 252)
TEXT_SOFT = (203, 213, 225)
SLATE = (15, 23, 42)
SLATE_SOFT = (30, 41, 59)


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=size)
            except Exception:
                continue
    return ImageFont.load_default()


def _vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    width, height = size
    image = Image.new("RGB", size, bottom)
    draw = ImageDraw.Draw(image)
    for y in range(height):
      ratio = y / max(height - 1, 1)
      color = tuple(int(top[i] * (1 - ratio) + bottom[i] * ratio) for i in range(3))
      draw.line((0, y, width, y), fill=color)
    return image


def _rounded_rect_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def _draw_route_mark(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int]) -> None:
    left, top, right, bottom = box
    width = right - left
    height = bottom - top
    stroke = max(18, width // 18)
    pin_x = left + width * 0.52
    pin_y = top + height * 0.34
    pin_r = width * 0.18

    path_points = [
        (left + width * 0.15, top + height * 0.73),
        (left + width * 0.32, top + height * 0.55),
        (left + width * 0.44, top + height * 0.62),
        (left + width * 0.56, top + height * 0.48),
        (left + width * 0.72, top + height * 0.56),
    ]
    draw.line(path_points, fill=WHITE, width=stroke, joint="curve")

    for idx in [0, 2, 4]:
        x, y = path_points[idx]
        r = stroke * 0.55
        draw.ellipse((x - r, y - r, x + r, y + r), fill=SUN if idx == 4 else MINT)

    draw.ellipse(
        (pin_x - pin_r, pin_y - pin_r, pin_x + pin_r, pin_y + pin_r),
        fill=WHITE,
    )
    inner_r = pin_r * 0.45
    draw.ellipse(
        (pin_x - inner_r, pin_y - inner_r, pin_x + inner_r, pin_y + inner_r),
        fill=TEAL,
    )
    point = [
        (pin_x, pin_y + pin_r * 1.9),
        (pin_x - pin_r * 0.85, pin_y + pin_r * 0.45),
        (pin_x + pin_r * 0.85, pin_y + pin_r * 0.45),
    ]
    draw.polygon(point, fill=WHITE)


def generate_app_icon() -> None:
    size = (1024, 1024)
    base = _vertical_gradient(size, (6, 13, 26), NAVY_LIGHT).convert("RGBA")

    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((70, 70, 610, 610), fill=(16, 185, 129, 70))
    glow_draw.ellipse((420, 500, 980, 1060), fill=(14, 165, 233, 48))
    glow = glow.filter(ImageFilter.GaussianBlur(36))
    base.alpha_composite(glow)

    plate = Image.new("RGBA", size, (0, 0, 0, 0))
    plate_draw = ImageDraw.Draw(plate)
    plate_draw.rounded_rectangle(
        (104, 104, 920, 920),
        radius=220,
        fill=(15, 23, 42, 210),
        outline=(148, 163, 184, 55),
        width=3,
    )
    plate = plate.filter(ImageFilter.GaussianBlur(0.4))
    base.alpha_composite(plate)

    draw = ImageDraw.Draw(base)
    _draw_route_mark(draw, (190, 185, 834, 835))

    mask = _rounded_rect_mask(size, 230)
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    output.paste(base, (0, 0), mask=mask)

    BRANDING_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    output.save(BRANDING_DIR / "app_icon_1024.png")
    output.resize((512, 512), Image.LANCZOS).save(EXPORT_DIR / "routevia-play-icon-512.png")


def generate_feature_graphic() -> None:
    size = (1024, 500)
    base = _vertical_gradient(size, NAVY, (12, 32, 61)).convert("RGBA")

    draw = ImageDraw.Draw(base)
    draw.ellipse((640, -80, 1120, 360), fill=(16, 185, 129, 55))
    draw.ellipse((520, 120, 1080, 620), fill=(14, 165, 233, 35))
    base = base.filter(ImageFilter.GaussianBlur(0.3))
    draw = ImageDraw.Draw(base)

    panel = (44, 42, 430, 458)
    draw.rounded_rectangle(
        panel,
        radius=72,
        fill=(15, 23, 42, 230),
        outline=(148, 163, 184, 42),
        width=2,
    )
    _draw_route_mark(draw, (90, 86, 382, 380))

    badge_font = _font(24, bold=True)
    title_font = _font(58, bold=True)
    subtitle_font = _font(28)
    bullet_font = _font(24, bold=True)

    draw.rounded_rectangle((480, 86, 708, 132), radius=22, fill=(15, 23, 42, 220))
    draw.text((504, 94), "Routevia", font=badge_font, fill=MINT)

    draw.text((480, 154), "Rota Planla", font=title_font, fill=WHITE)
    draw.text((480, 220), "& Keşfet", font=title_font, fill=WHITE)
    draw.text(
        (480, 296),
        "Gezilecek yerleri kesfet,\nplanlarini tek yerde yonet.",
        font=subtitle_font,
        fill=TEXT_SOFT,
        spacing=8,
    )

    bullets = ["Yakin oneriler", "Akilli gezi plani", "Topluluk ilhami"]
    x = 480
    y = 388
    for bullet in bullets:
        w = draw.textbbox((0, 0), bullet, font=bullet_font)[2]
        draw.rounded_rectangle(
            (x, y, x + w + 34, y + 42),
            radius=20,
            fill=(15, 23, 42, 220),
            outline=(148, 163, 184, 34),
            width=1,
        )
        draw.text((x + 18, y + 9), bullet, font=bullet_font, fill=WHITE)
        x += w + 48

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    base.convert("RGB").save(EXPORT_DIR / "routevia-feature-graphic-1024x500.png")


def generate_splash_background() -> None:
    size = (1440, 2560)
    base = _vertical_gradient(size, (6, 13, 26), NAVY_LIGHT).convert("RGBA")

    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((80, 120, 980, 1080), fill=(16, 185, 129, 62))
    glow_draw.ellipse((620, 1120, 1560, 2280), fill=(14, 165, 233, 42))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    base.alpha_composite(glow)

    plate = Image.new("RGBA", size, (0, 0, 0, 0))
    plate_draw = ImageDraw.Draw(plate)
    panel = (300, 540, 1140, 1380)
    plate_draw.rounded_rectangle(
        panel,
        radius=220,
        fill=(255, 255, 255, 18),
        outline=(255, 255, 255, 36),
        width=4,
    )
    base.alpha_composite(plate)

    draw = ImageDraw.Draw(base)
    _draw_route_mark(draw, (430, 660, 1010, 1240))

    title_font = _font(88, bold=True)
    subtitle_font = _font(40)
    draw.text((462, 1500), "Routevia", font=title_font, fill=WHITE)
    draw.text((330, 1620), "Rota planla ve kesfet", font=subtitle_font, fill=TEXT_SOFT)

    BRANDING_DIR.mkdir(parents=True, exist_ok=True)
    base.save(BRANDING_DIR / "splash_bg.png")


if __name__ == "__main__":
    generate_app_icon()
    generate_feature_graphic()
    generate_splash_background()
    print("Generated branding assets in", EXPORT_DIR)
