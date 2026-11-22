-- Financial facts are already daily. Keep the store-date grain for reporting.
select f.store_id, s.store_name, f.date as trading_date, f.transactions,
       f.net_sales_aud, f.cogs_aud, f.gross_profit_aud
from {{ source('cafe', 'fact_daily_financial') }} f
join {{ source('cafe', 'dim_store') }} s on f.store_id = s.store_id
