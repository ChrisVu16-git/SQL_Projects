"""Render the README dashboard from illustrative invoice reconciliation records."""
from datetime import date
from pathlib import Path

import matplotlib.pyplot as plt

AS_OF = date(2025, 3, 31)
# One row per synthetic invoice. Amounts are unresolved positive variances in AUD.
# Invoice ID, store, issue, opened, amount, next action.
OPEN = [
    ("DEMO-041", "Wetherill Park", "Quantity mismatch", date(2025, 3, 20), 486, "Request credit note"),
    ("DEMO-056", "Prestons Place", "Missing receipt", date(2025, 3, 25), 315, "Confirm stock receipt"),
    ("DEMO-063", "Glendale", "Unit price mismatch", date(2025, 3, 27), 172, "Confirm agreed price"),
    ("DEMO-071", "Jesmond", "Quantity mismatch", date(2025, 3, 29), 124, "Recount delivery"),
    ("DEMO-074", "Leppington", "Quantity mismatch", date(2025, 3, 30), 89, "Verify delivery docket"),
]
MATCHED = 68
RESOLVED_AFTER_FOLLOWUP = 7

INK = "#162c2a"
MUTED = "#4b6661"
TEAL = "#12685a"
LIGHT = "#edf4f0"
WHITE = "#ffffff"

fig = plt.figure(figsize=(14, 8.2), facecolor=LIGHT)
ax = fig.add_axes([0, 0, 1, 1], xlim=(0, 1400), ylim=(820, 0))
ax.axis("off")

def rect(x, y, width, height, fill):
    ax.add_patch(plt.Rectangle((x, y), width, height, color=fill, linewidth=0))

def label(x, y, value, size, color=INK, weight="normal", align="left"):
    ax.text(x, y, value, fontsize=size, color=color, weight=weight, va="center", ha=align)

rect(0, 0, 1400, 143, INK)
label(44, 33, "XS ESPRESSO  /  PROCUREMENT OPERATIONS", 10, "#aee2cc", "bold")
label(44, 78, "Supplier invoice reconciliation", 30, WHITE, "bold")
label(44, 117, "March 2025  ·  Snapshot at 31 March 2025  ·  Synthetic portfolio demo", 12, "#d5e7e1")

total = MATCHED + RESOLVED_AFTER_FOLLOWUP + len(OPEN)
cards = [
    ("Invoices checked", str(total), "Matched, resolved or open"),
    ("First-pass match", f"{MATCHED / total:.1%}", f"{MATCHED} of {total} invoices"),
    ("Open discrepancies", str(len(OPEN)), f"{sum((AS_OF - row[3]).days > 7 for row in OPEN)} open more than 7 days"),
    ("Open variance", f"A${sum(row[4] for row in OPEN):,}", "Amount pending reconciliation"),
]
for i, (title, value, note) in enumerate(cards):
    x = 44 + 333 * i
    rect(x, 164, 313, 118, WHITE)
    rect(x, 164, 313, 4, TEAL)
    label(x + 18, 191, title, 12, MUTED)
    label(x + 18, 224, value, 25, INK, "bold")
    label(x + 18, 259, note, 10, MUTED)

rect(44, 306, 814, 200, WHITE)
label(65, 333, "Open variance by issue", 16, INK, "bold")
totals_by_issue = {}
for _, _, issue, _, amount, _ in OPEN:
    totals_by_issue[issue] = totals_by_issue.get(issue, 0) + amount
for i, (issue, amount) in enumerate(sorted(totals_by_issue.items(), key=lambda pair: -pair[1])):
    y = 374 + i * 47
    label(65, y, issue, 11)
    rect(250, y - 8, 455, 16, LIGHT)
    rect(250, y - 8, 455 * amount / max(totals_by_issue.values()), 16, TEAL)
    label(817, y, f"A${amount:,}", 11, INK, "bold", "right")

rect(878, 306, 478, 200, WHITE)
label(900, 333, "Manager follow-up", 16, INK, "bold")
oldest = max(OPEN, key=lambda row: (AS_OF - row[3]).days)
label(900, 373, f"{oldest[0]}  ·  {oldest[1]}", 13, TEAL, "bold")
label(900, 407, f"A${oldest[4]:,} variance  ·  {(AS_OF - oldest[3]).days} days open", 12)
label(900, 442, "Supervisor verifies the received quantity.", 11, MUTED)
label(900, 470, "Supplier confirms the credit note.", 11, MUTED)

rect(44, 530, 1312, 238, WHITE)
label(65, 558, "Open exception queue", 16, INK, "bold")
rect(62, 581, 1276, 30, LIGHT)
columns = (72, 185, 399, 725, 820, 982)
for x, heading in zip(columns, ("Invoice", "Store", "Issue", "Days open", "Variance", "Next action")):
    label(x, 596, heading, 10, MUTED, "bold")
for i, (invoice, store, issue, opened, amount, next_action) in enumerate(sorted(OPEN, key=lambda row: row[3])):
    y = 627 + i * 29
    age = (AS_OF - opened).days
    if age > 7:
        rect(62, y - 14, 1276, 28, "#fff1df")
    for x, value in zip(columns, (invoice, store, issue, str(age), f"A${amount:,}", next_action)):
        label(x, y, value, 10, weight="bold" if age > 7 and x == columns[3] else "normal")

label(44, 795, "Demo records are illustrative. Invoice values do not come from XS Espresso financial or supplier records.", 10, MUTED)
output = Path(__file__).resolve().parents[1] / "screenshots" / "operational_dashboard.png"
fig.savefig(output, dpi=135)
plt.close(fig)
