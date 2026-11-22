select store_id, trading_date
from {{ ref('store_day') }}
group by store_id, trading_date
having count(*) > 1
