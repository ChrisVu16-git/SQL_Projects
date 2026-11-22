-- GoogleSQL. Aggregate absolute errors at store-hour grain before calculating monthly WAPE.
SELECT DATE_TRUNC(date, MONTH) AS month_start,
       SUM(net_sales_aud) AS actual_revenue_aud,
       SUM(forecast_hourly_revenue_aud) AS forecast_revenue_aud,
       ROUND(100 * SAFE_DIVIDE(SUM(ABS(net_sales_aud - forecast_hourly_revenue_aud)),
                               SUM(ABS(net_sales_aud))), 2) AS wape_pct
FROM `xs.fact_hourly_demand`
WHERE forecast_hourly_revenue_aud IS NOT NULL
GROUP BY month_start
ORDER BY month_start;
