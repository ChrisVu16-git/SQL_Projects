"""Compose the company overview from the repository's published portfolio outputs."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps

SCREENSHOTS = Path(__file__).resolve().parents[1] / "screenshots"
INK = "#152e2b"
MUTED = "#42625d"
ACCENT = "#136b5c"
PAPER = "#edf4f1"

canvas = Image.new("RGB", (1440, 1070), PAPER)
draw = ImageDraw.Draw(canvas)


def text(x, y, value, size, color=INK, bold=False):
    font = ImageFont.truetype("DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf", size)
    draw.text((x, y), value, fill=color, font=font, anchor="lt")


def panel(x, y, w, h):
    draw.rounded_rectangle((x, y, x + w, y + h), radius=13, fill="white")


def plot(filename, x, y, width, height):
    with Image.open(SCREENSHOTS / filename) as source:
        chart = ImageOps.contain(source.convert("RGB"), (width, height), Image.Resampling.LANCZOS)
    canvas.paste(chart, (x + (width - chart.width) // 2, y + (height - chart.height) // 2))


draw.rectangle((0, 0, 1440, 146), fill=INK)
text(42, 25, "XS ESPRESSO", 17, "#a6dec7", True)
text(42, 52, "Company Operations Dashboard", 47, "white", True)
text(44, 112, "Network overview  /  Jan 2023–Mar 2025  /  Portfolio dataset", 18, "#d7e8e1")

# Rounded values from the committed Power BI revenue dashboard screenshot.
for i, (name, value, detail) in enumerate([
    ("Net revenue", "A$60.03M", "Network sales"),
    ("Gross profit", "A$42.11M", "After cost of goods sold"),
    ("Operating profit", "A$8.27M", "As reported in Power BI"),
    ("Labour cost ratio", "≈42%", "Labour cost / net revenue"),
]):
    x = 42 + i * 344
    panel(x, 165, 326, 126)
    text(x + 18, 181, name, 19, MUTED)
    text(x + 18, 211, value, 34, ACCENT, True)
    text(x + 18, 259, detail, 15, MUTED)

for x, y, name in [
    (42, 311, "Sales & forecasting"),
    (729, 311, "Demand & roster planning"),
    (42, 712, "Store performance"),
    (729, 712, "Management follow-up"),
]:
    panel(x, y, 669, 383 if y == 311 else 308)
    text(x + 22, y + 19, name, 24, INK, True)

plot("actual_vs_forecast.png", 57, 359, 639, 294)
text(64, 663, "Review forecast error at store-hour level before setting rosters.", 16, MUTED)
plot("hour_weekday_heatmap.png", 744, 359, 639, 294)
text(751, 663, "Compare weekend lunchtime demand with shift overlap.", 16, MUTED)
plot("store_performance_quadrant.png", 55, 752, 644, 232)
text(64, 991, "Review cost drivers at high-revenue, low-margin stores.", 16, MUTED)

text(751, 763, "Workforce", 19, ACCENT, True)
text(751, 794, "Compare paid hours and labour cost with trading patterns.", 16, MUTED)
draw.line((751, 828, 1377, 828), fill="#d7e6e0", width=2)
text(751, 847, "Stock & supplier invoices", 19, ACCENT, True)
text(751, 879, "5 open discrepancies  /  A$1,186 pending", 21, INK, True)
text(751, 913, "March 2025 illustrative invoice snapshot", 15, MUTED)
text(751, 953, "Follow up with store supervisors and suppliers.", 16, MUTED)
text(751, 978, "Escalate unresolved discrepancies to the General Manager.", 16, MUTED)
text(42, 1040, "Sources: portfolio Power BI and SQL outputs. Invoice figures are separate synthetic examples.", 15, MUTED)

canvas.quantize(colors=150).save(SCREENSHOTS / "company_operations_dashboard.png", optimize=True)
