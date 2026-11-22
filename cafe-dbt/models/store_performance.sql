-- Weight the period margin by sales across all trading days.
select store_id, store_name, sum(transactions) as transactions,
       sum(net_sales_aud) as net_sales_aud, sum(gross_profit_aud) as gross_profit_aud,
       round(100.0 * sum(gross_profit_aud) / nullif(sum(net_sales_aud), 0), 2) as gross_margin_pct
from {{ ref('store_day') }}
group by store_id, store_name
