-- XS Espresso | Portfolio analytical queries
-- PostgreSQL schema: xs

-- 1. Hour × weekday demand heatmap: average transactions per store-hour.
SELECT EXTRACT(ISODOW FROM date)::int AS weekday_iso,
       hour,
       COUNT(*) AS recorded_store_hours,
       SUM(transactions) AS total_transactions,
       ROUND(SUM(transactions)::numeric / NULLIF(COUNT(*),0), 2)
           AS avg_transactions_per_store_hour
FROM xs.fact_hourly_demand
GROUP BY 1, 2
ORDER BY 1, 2;

-- 2. Forecast validation at the original store-hour grain.
SELECT DATE_TRUNC('month', date)::date AS month_start,
       SUM(net_sales_aud) AS actual_revenue_aud,
       SUM(forecast_hourly_revenue_aud) AS forecast_revenue_aud,
       SUM(ABS(net_sales_aud - forecast_hourly_revenue_aud)) AS absolute_error_aud,
       ROUND(
         100.0 * SUM(ABS(net_sales_aud - forecast_hourly_revenue_aud))
         / NULLIF(SUM(ABS(net_sales_aud)), 0), 2
       ) AS wape_pct
FROM xs.fact_hourly_demand
WHERE forecast_hourly_revenue_aud IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- 3. Store performance quadrants (operating margin before central costs).
WITH store_metrics AS (
  SELECT store_id,
         SUM(net_sales_aud) AS net_revenue_aud,
         SUM(operating_profit_before_central_costs_aud) AS operating_profit_aud,
         100.0 * SUM(operating_profit_before_central_costs_aud)
           / NULLIF(SUM(net_sales_aud), 0) AS operating_margin_pct
  FROM xs.fact_daily_financial
  GROUP BY store_id
),
thresholds AS (
  SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY net_revenue_aud) AS median_revenue,
         percentile_cont(0.5) WITHIN GROUP (ORDER BY operating_margin_pct) AS median_margin
  FROM store_metrics
)
SELECT s.store_id, d.store_name, d.store_size_model,
       ROUND(s.net_revenue_aud::numeric, 2) AS net_revenue_aud,
       ROUND(s.operating_profit_aud::numeric, 2) AS operating_profit_aud,
       ROUND(s.operating_margin_pct::numeric, 2) AS operating_margin_pct,
       CASE
         WHEN s.net_revenue_aud >= t.median_revenue
          AND s.operating_margin_pct >= t.median_margin THEN 'High revenue / High margin'
         WHEN s.net_revenue_aud >= t.median_revenue THEN 'High revenue / Low margin'
         WHEN s.operating_margin_pct >= t.median_margin THEN 'Low revenue / High margin'
         ELSE 'Low revenue / Low margin'
       END AS performance_quadrant
FROM store_metrics s
JOIN xs.dim_store d USING (store_id)
CROSS JOIN thresholds t
ORDER BY s.net_revenue_aud DESC;
