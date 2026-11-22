-- A missing day on either side, including a missing dimension join, fails this test.
with hourly as (
    select store_id, date, sum(transactions) as transactions, sum(net_sales_aud) as sales
    from {{ source('cafe', 'fact_hourly_demand') }}
    group by store_id, date
)
select coalesce(d.store_id, h.store_id) as store_id, coalesce(d.trading_date, h.date) as trading_date
from {{ ref('store_day') }} d
full outer join hourly h on d.store_id = h.store_id and d.trading_date = h.date
where d.store_id is null or h.store_id is null
   or d.transactions is null or h.transactions is null or d.transactions <> h.transactions
   or d.net_sales_aud is null or h.sales is null or abs(d.net_sales_aud - h.sales) > 0.011
