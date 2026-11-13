-- Each query returns exceptions; zero rows is PASS unless otherwise stated.
-- Duplicate store IDs
SELECT store_id,COUNT(*) n FROM xs.dim_store GROUP BY store_id HAVING COUNT(*)>1;
-- Employee assignment duplicates
SELECT employee_key,COUNT(*) n FROM xs.dim_staff_assignment GROUP BY employee_key HAVING COUNT(*)>1;
-- Duplicate daily keys
SELECT store_id,date,COUNT(*) n FROM xs.fact_daily_financial GROUP BY 1,2 HAVING COUNT(*)>1;
-- Missing stores in transactions
SELECT t.store_id,COUNT(*) n FROM xs.fact_transaction t LEFT JOIN xs.dim_store s USING(store_id)
 WHERE s.store_id IS NULL GROUP BY t.store_id;
-- Missing employee assignments in payroll
SELECT p.employee_key,COUNT(*) n FROM xs.fact_payroll_shift p LEFT JOIN xs.dim_staff_assignment a USING(employee_key)
 WHERE a.employee_key IS NULL GROUP BY p.employee_key;
-- Transaction to daily reconciliation: compare both sides, including unmatched store-days
WITH tx AS (SELECT store_id,transaction_date AS date,COUNT(*) n,SUM(net_sales_aud) revenue
 FROM xs.fact_transaction GROUP BY 1,2)
SELECT COALESCE(tx.store_id,d.store_id) store_id,COALESCE(tx.date,d.date) date,
 tx.n,d.transactions,tx.revenue,d.net_sales_aud
FROM tx FULL JOIN xs.fact_daily_sales d USING(store_id,date)
WHERE tx.store_id IS NULL OR d.store_id IS NULL OR tx.n<>d.transactions OR ABS(tx.revenue-d.net_sales_aud)>0.011;
-- Daily financial to monthly P&L reconciliation (net revenue, labour, operating profit)
WITH d AS (SELECT store_id,TO_CHAR(date,'YYYY-MM') month,
 SUM(net_sales_aud) revenue,SUM(total_employer_cost_aud) labour,
 SUM(operating_profit_before_central_costs_aud) profit
 FROM xs.fact_daily_financial GROUP BY 1,2)
SELECT COALESCE(d.store_id,m.store_id) store_id,COALESCE(d.month,m.month) month,
 d.revenue,m.net_sales_aud,d.labour,m.total_employer_cost_aud,
 d.profit,m.operating_profit_before_central_costs_aud
FROM d FULL JOIN xs.fact_monthly_pnl m USING(store_id,month)
WHERE d.store_id IS NULL OR m.store_id IS NULL
 OR ABS(d.revenue-m.net_sales_aud)>0.011 OR ABS(d.labour-m.total_employer_cost_aud)>0.011
 OR ABS(d.profit-m.operating_profit_before_central_costs_aud)>0.011;
-- Monthly to annual (central overhead deducted ONCE at annual grain)
WITH m AS (SELECT LEFT(month,4)::int year,SUM(net_sales_aud) revenue,
 SUM(operating_profit_before_central_costs_aud) store_profit FROM xs.fact_monthly_pnl GROUP BY 1)
SELECT COALESCE(m.year,a.year) year,m.revenue,a.net_sales_aud,m.store_profit,
 a.operating_profit_before_central_costs_aud,
 a.systemwide_profit_after_notional_central_overhead_aud,
 a.central_overhead_aud
FROM m FULL JOIN xs.fact_annual_financial a USING(year)
WHERE m.year IS NULL OR a.year IS NULL OR ABS(m.revenue-a.net_sales_aud)>0.011
 OR ABS(m.store_profit-a.operating_profit_before_central_costs_aud)>0.011
 OR ABS(a.operating_profit_before_central_costs_aud-a.central_overhead_aud-a.systemwide_profit_after_notional_central_overhead_aud)>0.011;
-- Payroll shift totals to daily financials
WITH p AS (SELECT store_id,date,SUM(gross_wages_aud) gross,SUM(employer_super_aud) super,
 SUM(total_employer_cost_aud) cost FROM xs.fact_payroll_shift GROUP BY 1,2)
SELECT COALESCE(p.store_id,d.store_id) store_id,COALESCE(p.date,d.date) date,
 p.gross,d.gross_wages_aud,p.super,d.employer_super_aud,p.cost,d.total_employer_cost_aud
FROM p FULL JOIN xs.fact_daily_financial d USING(store_id,date)
WHERE p.store_id IS NULL OR d.store_id IS NULL OR ABS(p.gross-d.gross_wages_aud)>0.011
 OR ABS(p.super-d.employer_super_aud)>0.011 OR ABS(p.cost-d.total_employer_cost_aud)>0.011;
