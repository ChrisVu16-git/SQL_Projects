-- XS Espresso portfolio analyses | PostgreSQL schema xs
-- 1. Demand by weekday and trading hour
SELECT EXTRACT(ISODOW FROM date)::int AS weekday_iso, hour,
       ROUND(AVG(transactions)::numeric, 2) AS avg_transactions_per_store_hour
FROM xs.fact_hourly_demand
GROUP BY 1, 2 ORDER BY 1, 2;

-- 2. Forecast performance at store-hour grain
SELECT ROUND(SUM(net_sales_aud)::numeric, 2) AS actual_revenue_aud,
       ROUND(SUM(forecast_hourly_revenue_aud)::numeric, 2) AS forecast_revenue_aud,
       ROUND((100 * SUM(ABS(net_sales_aud - forecast_hourly_revenue_aud))
          / NULLIF(SUM(net_sales_aud), 0))::numeric, 2) AS wape_pct
FROM xs.fact_hourly_demand;

-- 3. Store-level operating profitability before central costs
WITH store_performance AS (
 SELECT store_id, SUM(net_sales_aud) AS revenue_aud,
        SUM(operating_profit_before_central_costs_aud) AS operating_profit_aud
 FROM xs.fact_daily_financial GROUP BY store_id
)
SELECT s.store_name, s.store_size_model,
       ROUND(p.revenue_aud::numeric, 2) AS revenue_aud,
       ROUND(p.operating_profit_aud::numeric, 2) AS operating_profit_aud,
       ROUND((100 * p.operating_profit_aud / NULLIF(p.revenue_aud, 0))::numeric, 2)
         AS operating_margin_pct
FROM store_performance p JOIN xs.dim_store s USING (store_id)
ORDER BY revenue_aud DESC;

-- 4. Revenue reconciliation
WITH h AS (SELECT SUM(net_sales_aud) AS revenue FROM xs.fact_hourly_demand),
     d AS (SELECT SUM(net_sales_aud) AS revenue FROM xs.fact_daily_financial)
SELECT ROUND(h.revenue::numeric, 2) AS hourly_revenue_aud,
       ROUND(d.revenue::numeric, 2) AS daily_revenue_aud,
       ROUND((h.revenue - d.revenue)::numeric, 2) AS difference_aud
FROM h CROSS JOIN d;
