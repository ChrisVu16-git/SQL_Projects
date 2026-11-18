"""Render a static operations dashboard from the committed portfolio outputs."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps

SCREENSHOTS = Path(__file__).resolve().parents[1] / "screenshots"
PAPER = "#fbf7ee"
WHITE = "#fffdf8"
INK = "#241b2d"
WINE = "#96364f"
MUTED = "#635464"
BORDER = "#bf6478"

canvas = Image.new("RGB", (1560, 1100), PAPER)
draw = ImageDraw.Draw(canvas)


def text(x, y, value, size, color=INK, bold=False, anchor="lt"):
    font = ImageFont.truetype("DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf", size)
    draw.text((x, y), value, fill=color, font=font, anchor=anchor)


def box(x, y, width, height):
    draw.rounded_rectangle((x, y, x + width, y + height), radius=8, fill=WHITE,
                           outline=BORDER, width=2)


def tile(x, y, title, value, note, symbol, width=357, height=113):
    box(x, y, width, height)
    draw.ellipse((x + 16, y + 23, x + 79, y + 86), fill=WINE)
    text(x + 47, y + 54, symbol, 25, WHITE, True, "mm")
    text(x + 94, y + 15, title, 16, MUTED, True)
    text(x + 94, y + 43, value, 34, INK, True)
    text(x + 94, y + 85, note, 15, MUTED)


def plot(filename, x, y, width, height):
    with Image.open(SCREENSHOTS / filename) as source:
        chart = ImageOps.contain(source.convert("RGB"), (width, height), Image.Resampling.LANCZOS)
    canvas.paste(chart, (x + (width - chart.width) // 2, y + (height - chart.height) // 2))


def panel(x, y, title):
    box(x, y, 480, 298)
    text(x + 16, y + 13, title, 19, INK, True)


draw.rectangle((38, 35, 103, 43), fill=WINE)
text(38, 58, "XS ESPRESSO", 28, WINE, True)
text(38, 99, "OPERATION DASHBOARD", 76, WINE, True)
text(42, 188, "Network overview  /  Jan 2023–Mar 2025  /  Portfolio dataset", 20, MUTED)

# Rounded values from the committed Power BI revenue dashboard.
for i, metric in enumerate([
    ("NET REVENUE", "A$60.03M", "Network sales", "$"),
    ("GROSS PROFIT", "A$42.11M", "After cost of goods sold", "$"),
    ("OPERATING PROFIT", "A$8.27M", "As reported in Power BI", "↗"),
    ("LABOUR COST RATIO", "≈42%", "Labour cost / net revenue", "%"),
]):
    tile(38 + 375 * i, 231, *metric)

for x, title in [(38, "SALES VS FORECAST"), (540, "HOURLY CUSTOMER DEMAND"),
                 (1042, "MARGIN & COST MIX")]:
    panel(x, 364, title)
plot("actual_vs_forecast.png", 49, 411, 458, 224)
plot("hour_weekday_heatmap.png", 551, 411, 458, 224)

# Gross profit and COGS share of net revenue, based on the rounded portfolio KPIs.
draw.pieslice((1064, 428, 1249, 613), -90, 162.54, fill=WINE)
draw.pieslice((1064, 428, 1249, 613), 162.54, 270, fill="#e5b9bd")
draw.ellipse((1110, 474, 1203, 567), fill=WHITE)
text(1156, 521, "70.1%", 22, INK, True, "mm")
for i, (colour, label, value) in enumerate([
    (WINE, "Gross margin", "70.1%"),
    ("#e5b9bd", "COGS share", "29.9%"),
]):
    y = 472 + i * 62
    draw.rounded_rectangle((1269, y, 1288, y + 19), radius=2, fill=colour)
    text(1300, y, label, 17, INK, True)
    text(1300, y + 23, value, 16, MUTED)

for x, title in [(38, "STORE SALES & PROFITABILITY"), (540, "WORKFORCE FOLLOW-UP"),
                 (1042, "STOCK & SUPPLIER INVOICES")]:
    panel(x, 680, title)
plot("store_performance_quadrant.png", 49, 723, 458, 239)

workforce = [
    ("Weekend lunch", "Review shift overlap around peak demand."),
    ("Low-demand hours", "Compare paid hours with transaction volume."),
    ("High-revenue, low-margin stores", "Check labour, occupancy and delivery costs."),
]
for index, (title, detail) in enumerate(workforce):
    y = 730 + index * 73
    text(562, y, title, 18, WINE, True)
    text(562, y + 29, detail, 16, INK)
    if index < len(workforce) - 1:
        draw.line((562, y + 58, 997, y + 58), fill="#e8cdd2", width=2)

text(1064, 730, "March 2025 · Synthetic invoice demo", 16, MUTED)
for index, (label, value) in enumerate([
    ("Open discrepancies", "5"),
    ("Open variance", "A$1,186"),
    ("Open more than 7 days", "1"),
]):
    y = 768 + index * 43
    draw.rectangle((1064, y - 5, 1499, y + 29), fill=PAPER if index % 2 == 0 else WHITE)
    text(1074, y, label, 17)
    text(1488, y, value, 18, WINE, True, "rt")
text(1064, 918, "Follow up with supervisors and suppliers.", 16, INK)
text(1064, 944, "Escalate unresolved items to the General Manager.", 15, INK)

box(38, 997, 1484, 67)
for i, (title, value) in enumerate([
    ("GROSS MARGIN", "70.1%"),
    ("TRADING DATA THROUGH", "MAR 2025"),
    ("INVOICE FOLLOW-UP", "1 AGED ITEM"),
]):
    x = 62 + 495 * i
    text(x, 1011, title, 13, MUTED, True)
    text(x, 1033, value, 21, WINE, True)
    if i < 2:
        draw.line((x + 457, 1010, x + 457, 1052), fill=BORDER, width=2)

canvas.quantize(colors=160).save(SCREENSHOTS / "company_operations_dashboard.png", optimize=True)
