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
