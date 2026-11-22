# Seasonal marketplace promotions | Modelled data

Would an Instagram offer generate enough delivery orders to pay for its discount? Each scenario starts with 100 full-price orders and assumes 115 discounted orders in the same trading window.

| Offer | Regular → promo | Baseline contribution | Campaign contribution | Change | Orders to match baseline |
|---|---:|---:|---:|---:|---:|
| Summer weekday afternoon açaí bowl | A$20 → A$18 | A$1,003.00 | A$969.45 | −A$33.55 | 119 |
| Winter weekday morning coffee and pastry | A$15 → A$14 | A$752.25 | A$773.09 | +A$20.84 | 112 |

The XS Espresso portfolio’s 29.85% network cost-of-goods ratio estimates each item's ingredient cost at regular price. That dollar cost stays fixed through the promotion. The model assumes a 20% marketplace fee on the price paid. Prices, basket mix, fees and uptake are assumptions. Contribution excludes packaging, labour and advertising.

The summer offer requires 19% more orders to preserve contribution. Reducing the discount to A$1 lowers the threshold to 109 orders. The winter offer clears its threshold at 115 orders, with A$20.84 available for additional campaign costs. A pilot could compare promoted and matched stores within each season and track whether existing coffee buyers add a pastry or switch from full-price purchases.

Run the [standalone PostgreSQL query](../queries/seasonal_promo_break_even.sql) to reproduce both rows. It requires no source tables.
