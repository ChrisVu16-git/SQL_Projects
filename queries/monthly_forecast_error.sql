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
