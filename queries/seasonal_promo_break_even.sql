-- Modelled data. One item per order, prices in AUD. Edit the offers to compare prices.
WITH offers (offer, regular_price, promo_price) AS (
    VALUES ('Summer acai bowl', 20.00, 18.00),
           ('Winter coffee and pastry', 15.00, 14.00)
), assumptions AS (
    SELECT 100 AS base_orders, 115 AS promo_orders, 0.20 AS fee, 0.2985 AS food_cost_share
), unit_economics AS (
    SELECT offer, base_orders, promo_orders,
           regular_price * (1 - fee - food_cost_share) AS base_unit,
           promo_price * (1 - fee) - regular_price * food_cost_share AS promo_unit
    FROM offers CROSS JOIN assumptions
)
-- Whole orders needed to match the full-price baseline. NULL means no positive unit contribution.
SELECT offer, round(base_orders * base_unit, 2) AS baseline_aud,
       round(promo_orders * promo_unit, 2) AS campaign_aud,
       round(promo_orders * promo_unit - base_orders * base_unit, 2) AS change_aud,
       CASE WHEN promo_unit > 0 THEN ceil(base_orders * base_unit / promo_unit) END AS break_even_orders
FROM unit_economics
ORDER BY offer;
