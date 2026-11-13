-- Use daily financial grain for store KPIs; annual fact only for network overhead.
CREATE OR REPLACE VIEW xs.v_store_month_kpis AS
SELECT f.store_id,s.store_name,s.store_size_model,DATE_TRUNC('month',f.date)::date month_start,
 SUM(f.transactions) transactions,SUM(f.net_sales_aud) net_revenue_aud,
 SUM(f.cogs_aud) cogs_aud,SUM(f.gross_profit_aud) gross_profit_aud,
 SUM(f.total_employer_cost_aud) labour_cost_aud,
 SUM(f.operating_profit_before_central_costs_aud) store_operating_profit_aud,
 ROUND(100*SUM(f.gross_profit_aud)/NULLIF(SUM(f.net_sales_aud),0),2) gross_margin_pct,
 ROUND(100*SUM(f.total_employer_cost_aud)/NULLIF(SUM(f.net_sales_aud),0),2) labour_cost_pct,
 ROUND(100*SUM(f.operating_profit_before_central_costs_aud)/NULLIF(SUM(f.net_sales_aud),0),2) store_operating_margin_pct,
 ROUND(SUM(f.net_sales_aud)/NULLIF(SUM(f.transactions),0),2) avg_transaction_value_aud
FROM xs.fact_daily_financial f JOIN xs.dim_store s USING(store_id)
GROUP BY 1,2,3,4;
CREATE OR REPLACE VIEW xs.v_network_year_kpis AS
SELECT year,net_sales_aud net_revenue_aud,cogs_aud,gross_profit_aud,
 total_employer_cost_aud labour_cost_aud,operating_profit_before_central_costs_aud store_operating_profit_aud,
 central_overhead_aud,systemwide_profit_after_notional_central_overhead_aud systemwide_profit_aud,
 ROUND(100*gross_profit_aud/NULLIF(net_sales_aud,0),2) gross_margin_pct,
 ROUND(100*total_employer_cost_aud/NULLIF(net_sales_aud,0),2) labour_cost_pct,
 ROUND(100*operating_profit_before_central_costs_aud/NULLIF(net_sales_aud,0),2) store_operating_margin_pct,
 ROUND(100*systemwide_profit_after_notional_central_overhead_aud/NULLIF(net_sales_aud,0),2) systemwide_margin_pct,
 ROUND(net_sales_aud/NULLIF(transactions,0),2) avg_transaction_value_aud
FROM xs.fact_annual_financial;
CREATE OR REPLACE VIEW xs.v_hourly_labour_kpis AS
SELECT l.date,l.store_id,l.hour,l.transactions,l.net_sales_aud,l.active_staff,l.paid_labour_hours,l.labour_cost_aud,
 ROUND(l.net_sales_aud/NULLIF(l.paid_labour_hours,0),2) sales_per_paid_labour_hour_aud,
 ROUND(100*l.labour_cost_aud/NULLIF(l.net_sales_aud,0),2) labour_cost_pct,l.coverage_flag
FROM xs.fact_labour_efficiency l;
