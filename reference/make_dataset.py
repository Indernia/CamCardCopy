"""Generate synthetic business cards for CamCard Copy testing.

Outputs into <out>/: card PNGs (flat), photo-style JPGs (card on a desk),
an A4 print sheet PDF at true size, and ground-truth.json next to the dataset.
"""
import json, math, random, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = Path(sys.argv[1])
GT = Path(sys.argv[2])
OUT.mkdir(parents=True, exist_ok=True)

DPI = 600
MM = DPI / 25.4
W, H = round(85 * MM), round(55 * MM)  # 85 x 55 mm card

HN = "/System/Library/Fonts/HelveticaNeue.ttc"
AV = "/System/Library/Fonts/Avenir Next.ttc"
NY = "/System/Library/Fonts/NewYork.ttf"

def font(path, pt, index=0):
    return ImageFont.truetype(path, round(pt * DPI / 72), index=index)

# HelveticaNeue.ttc: 0 Regular, 1 Bold, 7 Light, 10 Medium
# Avenir Next.ttc: 0 Bold, 2 Demi Bold, 5 Medium, 7 Regular
def hn(pt, w="reg"):
    return font(HN, pt, {"reg": 0, "bold": 1, "light": 7, "med": 10}[w])

def av(pt, w="reg"):
    return font(AV, pt, {"bold": 0, "demi": 2, "med": 5, "reg": 7}[w])

def mm(v):
    return round(v * MM)


def card_standard():
    img = Image.new("RGB", (W, H), "#FFFFFF")
    d = ImageDraw.Draw(img)
    teal = "#0F6E74"
    d.rectangle([0, 0, mm(4), H], fill=teal)
    # simple geometric mark (not text)
    x0, y0 = mm(9), mm(7)
    d.polygon([(x0 + mm(2), y0 + mm(7.5)), (x0 + mm(2.8), y0 + mm(2)),
               (x0 + mm(4.2), y0 + mm(2)), (x0 + mm(5), y0 + mm(7.5))], fill=teal)
    d.polygon([(x0 + mm(2.5), y0 + mm(1.8)), (x0 + mm(3.5), y0), (x0 + mm(4.5), y0 + mm(1.8))], fill=teal)
    d.line([x0 + mm(4.8), y0 + mm(1), x0 + mm(7.5), y0 + mm(0.2)], fill="#E9A23B", width=mm(0.5))
    d.line([x0 + mm(4.8), y0 + mm(1.4), x0 + mm(7.5), y0 + mm(2.2)], fill="#E9A23B", width=mm(0.5))
    d.text((mm(18), mm(7.6)), "Harbourlight Studio", font=av(11, "demi"), fill=teal)
    d.text((mm(9), mm(20)), "Maya Lindqvist", font=hn(15, "bold"), fill="#1A1A1A")
    d.text((mm(9), mm(27.5)), "Senior Product Designer", font=hn(9), fill="#555555")
    f = hn(7.5)
    lines = [
        ("M", "+1 (202) 555-0142"),
        ("T", "+1 (202) 555-0100"),
        ("E", "maya.lindqvist@harbourlight.example"),
        ("W", "www.harbourlight.example"),
    ]
    y = mm(35)
    for label, value in lines:
        d.text((mm(9), y), label, font=hn(7.5, "bold"), fill=teal)
        d.text((mm(13), y), value, font=f, fill="#222222")
        y += mm(3.6)
    d.text((mm(9), y + mm(0.6)), "48 Pier Street, Suite 300, Portland, OR 97209",
           font=hn(7), fill="#555555")
    return img


def card_no_website():
    img = Image.new("RGB", (W, H), "#F4EFE6")
    d = ImageDraw.Draw(img)
    amber = "#C8781E"
    # lightning-bolt shape
    bx, by = mm(64), mm(8)
    bolt = [(bx + mm(6), by), (bx, by + mm(10)), (bx + mm(4.5), by + mm(10)),
            (bx + mm(2.5), by + mm(19)), (bx + mm(10), by + mm(7)),
            (bx + mm(5.5), by + mm(7)), (bx + mm(8), by)]
    d.polygon(bolt, fill=amber)
    d.text((mm(8), mm(10)), "Daniel Okafor", font=av(15, "bold"), fill="#2B2B2B")
    d.text((mm(8), mm(18)), "Licensed Electrician", font=av(9, "reg"), fill="#5A5A5A")
    d.text((mm(8), mm(23)), "Okafor Electric", font=av(9, "demi"), fill=amber)
    d.line([mm(8), mm(33), mm(40), mm(33)], fill=amber, width=mm(0.5))
    d.text((mm(8), mm(37)), "Mobile  +1 (312) 555-0187", font=av(8.5, "med"), fill="#2B2B2B")
    d.text((mm(8), mm(42)), "dan.okafor@mailbox.example", font=av(8.5, "med"), fill="#2B2B2B")
    return img


def card_multi_contact():
    img = Image.new("RGB", (W, H), "#FFFFFF")
    d = ImageDraw.Draw(img)
    navy = "#1D3557"
    d.rectangle([0, 0, W, mm(15)], fill=navy)
    d.polygon([(mm(6), mm(11)), (mm(10), mm(4)), (mm(14), mm(11))], fill="#A8DADC")
    d.polygon([(mm(11), mm(11)), (mm(14.5), mm(6)), (mm(18), mm(11))], fill="#FFFFFF")
    d.text((mm(21), mm(4.2)), "ALPINE FREIGHT LOGISTICS", font=hn(10, "bold"), fill="#FFFFFF")
    d.text((mm(6), mm(18.5)), "Sofia Marchetti", font=hn(13, "bold"), fill=navy)
    d.text((mm(6), mm(24.5)), "Head of Procurement", font=hn(8.5), fill="#444444")
    f, fb = hn(6.8), hn(6.8, "med")
    left = [("Mobile:", "+1 (415) 555-0123"), ("Office:", "+1 (415) 555-0198"),
            ("Fax:", "+1 (415) 555-0199")]
    y = mm(31)
    for k, v in left:
        d.text((mm(6), y), k, font=fb, fill=navy)
        d.text((mm(16), y), v, font=f, fill="#222222")
        y += mm(3.4)
    right = [("Email:", "s.marchetti@alpinefreight.example"),
             ("", "orders@alpinefreight.example"),
             ("Web:", "alpinefreight.example")]
    y = mm(31)
    for k, v in right:
        if k:
            d.text((mm(39), y), k, font=fb, fill=navy)
        d.text((mm(47), y), v, font=hn(6.2), fill="#222222")
        y += mm(3.4)
    d.line([mm(6), mm(43.5), W - mm(6), mm(43.5)], fill="#D0D7E0", width=mm(0.3))
    d.text((mm(6), mm(46)), "1200 Harbor Way, Building C, San Francisco, CA 94107",
           font=hn(6.8), fill="#444444")
    return img


def card_dark():
    img = Image.new("RGB", (W, H), "#121A2B")
    d = ImageDraw.Draw(img)
    # wave lines
    for i, col in enumerate(["#2A9D8F", "#3FB8AF", "#7FD1C7"]):
        pts = [(x, mm(53) - i * mm(1.4) + math.sin(x / mm(9) + i) * mm(0.9))
               for x in range(0, W + 1, 8)]
        d.line(pts, fill=col, width=mm(0.5))
    d.text((mm(7), mm(7)), "BRIGHTWAVE", font=av(12, "bold"), fill="#7FD1C7")
    d.text((mm(7), mm(12.2)), "Analytics Ltd", font=av(8, "reg"), fill="#B8C4D6")
    d.text((mm(7), mm(17.5)), "Priya Shah", font=av(14, "demi"), fill="#FFFFFF")
    d.text((mm(7), mm(24)), "Chief Technology Officer", font=av(8.5, "reg"), fill="#B8C4D6")
    f = av(7, "med")
    y = mm(29.5)
    for v in ["+44 7700 900123", "+44 20 7946 0958", "priya.shah@brightwave.example",
              "brightwave.example", "21 Fenwick Lane, London EC2A 4XY, UK"]:
        d.text((mm(7), y), v, font=f, fill="#E6ECF5")
        y += mm(3.1)
    return img


def card_portrait_minimal():
    # Vertical card, no company, no phone, no address
    img = Image.new("RGB", (H, W), "#FAFAFA")
    d = ImageDraw.Draw(img)
    cx = H // 2
    r = mm(9)
    d.ellipse([cx - r, mm(20) - r, cx + r, mm(20) + r], outline="#222222", width=mm(0.7))
    d.ellipse([cx - r // 3, mm(20) - r // 3, cx + r // 3, mm(20) + r // 3], fill="#222222")

    def center(text, y, fnt, fill):
        tw = d.textlength(text, font=fnt)
        d.text((cx - tw / 2, y), text, font=fnt, fill=fill)

    center("Elena Novak", mm(40), font(NY, 14), "#111111")
    center("Freelance Photographer", mm(48), hn(8, "light"), "#444444")
    d.line([cx - mm(8), mm(57), cx + mm(8), mm(57)], fill="#999999", width=mm(0.3))
    center("hello@elenanovak.example", mm(63), hn(7.5), "#222222")
    center("elenanovak.example", mm(68), hn(7.5), "#222222")
    return img


CARDS = [
    ("card-01-standard", card_standard, ["T07", "T08", "T11", "T12", "T13", "T15"],
     "Every model field present, labelled M/T/E/W. Baseline happy path.",
     {"name": "Maya Lindqvist", "company": "Harbourlight Studio",
      "jobTitle": "Senior Product Designer", "mobile": "+1 (202) 555-0142",
      "phone": "+1 (202) 555-0100", "email": "maya.lindqvist@harbourlight.example",
      "website": "www.harbourlight.example",
      "address": "48 Pier Street, Suite 300, Portland, OR 97209"}, {}),
    ("card-02-no-website", card_no_website, ["T07", "T09"],
     "No website, office phone or address. Parser must return nil for them and must not "
     "derive a website from the email domain.",
     {"name": "Daniel Okafor", "company": "Okafor Electric",
      "jobTitle": "Licensed Electrician", "mobile": "+1 (312) 555-0187", "phone": None,
      "email": "dan.okafor@mailbox.example", "website": None, "address": None}, {}),
    ("card-03-multi-contact", card_multi_contact, ["T08", "T10"],
     "Mobile, office and fax numbers plus two emails. Fax must not land in mobile/phone; "
     "the second email has no label.",
     {"name": "Sofia Marchetti", "company": "Alpine Freight Logistics",
      "jobTitle": "Head of Procurement", "mobile": "+1 (415) 555-0123",
      "phone": "+1 (415) 555-0198", "email": "s.marchetti@alpinefreight.example",
      "website": "alpinefreight.example",
      "address": "1200 Harbor Way, Building C, San Francisco, CA 94107"},
     {"fax": "+1 (415) 555-0199", "emails": ["s.marchetti@alpinefreight.example",
                                              "orders@alpinefreight.example"]}),
    ("card-04-dark", card_dark, ["T04", "T06", "T07"],
     "Light text on a dark background with decorative lines; unlabelled phones "
     "(mobile first, landline second). Tests detection contrast and OCR on inverted colors.",
     {"name": "Priya Shah", "company": "Brightwave Analytics Ltd",
      "jobTitle": "Chief Technology Officer", "mobile": "+44 7700 900123",
      "phone": "+44 20 7946 0958", "email": "priya.shah@brightwave.example",
      "website": "brightwave.example", "address": "21 Fenwick Lane, London EC2A 4XY, UK"},
     {"note": "Company is split over two lines: 'BRIGHTWAVE' / 'Analytics Ltd'."}),
    ("card-05-portrait-minimal", card_portrait_minimal, ["T04", "T09"],
     "Portrait orientation, serif name, no company, phone or address. Company must stay nil "
     "(do not infer it from the email or website domain).",
     {"name": "Elena Novak", "company": None, "jobTitle": "Freelance Photographer",
      "mobile": None, "phone": None, "email": "hello@elenanovak.example",
      "website": "elenanovak.example", "address": None}, {}),
]


def photo_variant(card, seed):
    """Card lying on a desk: textured background, slight rotation, soft shadow."""
    rnd = random.Random(seed)
    bw, bh = 3000, 4000  # portrait phone photo
    base = (rnd.randint(90, 130), rnd.randint(75, 100), rnd.randint(55, 75))
    bg = Image.new("RGB", (bw, bh), base)
    noise = Image.effect_noise((bw // 4, bh // 4), 18).resize((bw, bh)).convert("RGB")
    bg = Image.blend(bg, noise, 0.12)
    c = card.copy()
    scale = (bw * 0.78) / max(c.width, c.height) if c.width > c.height else (bh * 0.5) / c.height
    c = c.resize((round(c.width * scale), round(c.height * scale)), Image.LANCZOS)
    angle = rnd.uniform(-7, 7)
    mask = Image.new("L", c.size, 255).rotate(angle, expand=True)
    c = c.rotate(angle, expand=True)
    shadow = Image.new("L", bg.size, 0)
    px, py = (bw - c.width) // 2, (bh - c.height) // 2
    shadow.paste(mask, (px + 25, py + 35))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    bg.paste(Image.new("RGB", bg.size, (20, 15, 10)), (0, 0), shadow.point(lambda v: v * 0.55))
    bg.paste(c, (px, py), mask)
    return bg


truth = []
images = []
for i, (cid, fn, tests, purpose, fields, extra) in enumerate(CARDS):
    img = fn()
    images.append(img)
    img.save(OUT / f"{cid}.png", dpi=(DPI, DPI))
    photo_variant(img, i).save(OUT / f"{cid}-photo.jpg", quality=90)
    entry = {"id": cid, "image": f"dataset/{cid}.png", "photo": f"dataset/{cid}-photo.jpg",
             "tests": tests, "purpose": purpose, "expected": fields}
    entry.update(extra)
    truth.append(entry)

# A4 print sheet at true size (85 x 55 mm), with light cut lines
pdpi = 300
pmm = pdpi / 25.4
sheet = Image.new("RGB", (round(210 * pmm), round(297 * pmm)), "white")
sd = ImageDraw.Draw(sheet)
slots = [(15, 15), (110, 15), (15, 80), (110, 80), (15, 145)]
for img, (sx, sy) in zip(images, slots):
    w_mm, h_mm = (85, 55) if img.width > img.height else (55, 85)
    small = img.resize((round(w_mm * pmm), round(h_mm * pmm)), Image.LANCZOS)
    x, y = round(sx * pmm), round(sy * pmm)
    sheet.paste(small, (x, y))
    sd.rectangle([x - 1, y - 1, x + small.width, y + small.height], outline="#BBBBBB", width=1)
sheet.save(OUT / "print-sheet-A4.pdf", resolution=pdpi)

GT.write_text(json.dumps(truth, indent=2, ensure_ascii=False) + "\n")
print("wrote", len(truth), "cards to", OUT)
