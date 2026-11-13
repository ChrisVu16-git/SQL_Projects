CREATE SCHEMA IF NOT EXISTS xs;

CREATE SCHEMA IF NOT EXISTS xs_stage;

-- Staging stores all values as text; raw source files remain unchanged.

CREATE TABLE IF NOT EXISTS xs_stage.store_master (
  "store_id" TEXT,
  "store_name" TEXT,
  "opening_date_model" TEXT,
  "opening_date_precision" TEXT,
  "ownership_type" TEXT,
  "opening_date_source" TEXT,
  "notes" TEXT,
  "dataset_start" TEXT,
  "dataset_end" TEXT,
  "store_size_model" TEXT,
  "base_weekday_sales_aud_model" TEXT,
  "size_classification_note" TEXT
);

CREATE TABLE IF NOT EXISTS xs.dim_store (
  "store_id" TEXT,
  "store_name" TEXT,
  "opening_date_model" DATE,
  "opening_date_precision" TEXT,
  "ownership_type" TEXT,
  "opening_date_source" TEXT,
  "notes" TEXT,
  "dataset_start" DATE,
  "dataset_end" DATE,
  "store_size_model" TEXT,
  "base_weekday_sales_aud_model" NUMERIC(20,6),
  "size_classification_note" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.staff_master (
  "employee_id" TEXT,
  "store_id" TEXT,
  "role" TEXT,
  "payment_method_model" TEXT,
  "base_rate_aud" TEXT,
  "hourly_rate_aud" TEXT,
  "notes" TEXT,
  "original_employee_id" TEXT,
  "employee_key" TEXT
);

CREATE TABLE IF NOT EXISTS xs.dim_staff_assignment (
  "employee_id" TEXT,
  "store_id" TEXT,
  "role" TEXT,
  "payment_method_model" TEXT,
  "base_rate_aud" NUMERIC(20,6),
  "hourly_rate_aud" NUMERIC(20,6),
  "notes" TEXT,
  "original_employee_id" TEXT,
  "employee_key" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.transactions (
  "transaction_id" TEXT,
  "store_id" TEXT,
  "transaction_date" TEXT,
  "transaction_time" TEXT,
  "sales_channel" TEXT,
  "food_sales_aud" TEXT,
  "drink_sales_aud" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "net_sales_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "currency" TEXT,
  "synthetic" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_transaction (
  "transaction_id" TEXT,
  "store_id" TEXT,
  "transaction_date" DATE,
  "transaction_time" VARCHAR(5),
  "sales_channel" TEXT,
  "food_sales_aud" NUMERIC(20,6),
  "drink_sales_aud" NUMERIC(20,6),
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "net_sales_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "currency" TEXT,
  "synthetic" BOOLEAN
);

CREATE TABLE IF NOT EXISTS xs_stage.daily_store_sales (
  "date" TEXT,
  "store_id" TEXT,
  "store_name" TEXT,
  "store_size" TEXT,
  "trading_status" TEXT,
  "transactions" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "net_sales_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "currency" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_daily_sales (
  "date" DATE,
  "store_id" TEXT,
  "store_name" TEXT,
  "store_size" TEXT,
  "trading_status" TEXT,
  "transactions" INTEGER,
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "net_sales_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "currency" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.daily_store_financials (
  "date" TEXT,
  "store_id" TEXT,
  "store_name" TEXT,
  "store_size" TEXT,
  "trading_status" TEXT,
  "transactions" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "net_sales_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "currency" TEXT,
  "year" TEXT,
  "gross_wages_aud" TEXT,
  "employer_super_aud" TEXT,
  "total_employer_cost_aud" TEXT,
  "paid_hours" TEXT,
  "operating_expenses_aud" TEXT,
  "occupancy_cost_aud" TEXT,
  "operating_profit_before_central_costs_aud" TEXT,
  "delivery_sales_aud" TEXT,
  "delivery_commission_aud" TEXT,
  "month" TEXT,
  "day_of_week" TEXT,
  "season" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_daily_financial (
  "date" DATE,
  "store_id" TEXT,
  "store_name" TEXT,
  "store_size" TEXT,
  "trading_status" TEXT,
  "transactions" INTEGER,
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "net_sales_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "currency" TEXT,
  "year" INTEGER,
  "gross_wages_aud" NUMERIC(20,6),
  "employer_super_aud" NUMERIC(20,6),
  "total_employer_cost_aud" NUMERIC(20,6),
  "paid_hours" NUMERIC(20,6),
  "operating_expenses_aud" NUMERIC(20,6),
  "occupancy_cost_aud" NUMERIC(20,6),
  "operating_profit_before_central_costs_aud" NUMERIC(20,6),
  "delivery_sales_aud" NUMERIC(20,6),
  "delivery_commission_aud" NUMERIC(20,6),
  "month" TEXT,
  "day_of_week" TEXT,
  "season" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.payroll_shifts (
  "date" TEXT,
  "store_id" TEXT,
  "employee_id" TEXT,
  "role" TEXT,
  "payment_method_model" TEXT,
  "shift_start" TEXT,
  "shift_end" TEXT,
  "scheduled_hours" TEXT,
  "unpaid_break_hours" TEXT,
  "paid_hours" TEXT,
  "hourly_rate_aud" TEXT,
  "gross_wages_aud" TEXT,
  "super_rate" TEXT,
  "week_start" TEXT,
  "notes" TEXT,
  "super_eligible_model" TEXT,
  "employer_super_aud" TEXT,
  "total_employer_cost_aud" TEXT,
  "fortnight_start" TEXT,
  "fortnight_end" TEXT,
  "payg_withholding_aud" TEXT,
  "net_pay_aud" TEXT,
  "year" TEXT,
  "original_role" TEXT,
  "employee_key" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_payroll_shift (
  "date" DATE,
  "store_id" TEXT,
  "employee_id" TEXT,
  "role" TEXT,
  "payment_method_model" TEXT,
  "shift_start" VARCHAR(5),
  "shift_end" VARCHAR(5),
  "scheduled_hours" NUMERIC(20,6),
  "unpaid_break_hours" NUMERIC(20,6),
  "paid_hours" NUMERIC(20,6),
  "hourly_rate_aud" NUMERIC(20,6),
  "gross_wages_aud" NUMERIC(20,6),
  "super_rate" NUMERIC(20,6),
  "week_start" DATE,
  "notes" TEXT,
  "super_eligible_model" BOOLEAN,
  "employer_super_aud" NUMERIC(20,6),
  "total_employer_cost_aud" NUMERIC(20,6),
  "fortnight_start" DATE,
  "fortnight_end" DATE,
  "payg_withholding_aud" NUMERIC(20,6),
  "net_pay_aud" NUMERIC(20,6),
  "year" INTEGER,
  "original_role" NUMERIC(20,6),
  "employee_key" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.fortnight_payroll (
  "fortnight_start" TEXT,
  "fortnight_end" TEXT,
  "store_id" TEXT,
  "payment_method_model" TEXT,
  "shifts" TEXT,
  "paid_hours" TEXT,
  "gross_wages_aud" TEXT,
  "employer_super_aud" TEXT,
  "total_employer_cost_aud" TEXT,
  "payg_withholding_aud" TEXT,
  "net_pay_aud" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_fortnight_payroll (
  "fortnight_start" DATE,
  "fortnight_end" DATE,
  "store_id" TEXT,
  "payment_method_model" TEXT,
  "shifts" INTEGER,
  "paid_hours" NUMERIC(20,6),
  "gross_wages_aud" NUMERIC(20,6),
  "employer_super_aud" NUMERIC(20,6),
  "total_employer_cost_aud" NUMERIC(20,6),
  "payg_withholding_aud" NUMERIC(20,6),
  "net_pay_aud" NUMERIC(20,6)
);

CREATE TABLE IF NOT EXISTS xs_stage.monthly_store_pnl (
  "month" TEXT,
  "store_id" TEXT,
  "transactions" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "net_sales_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "gross_wages_aud" TEXT,
  "employer_super_aud" TEXT,
  "total_employer_cost_aud" TEXT,
  "delivery_sales_aud" TEXT,
  "delivery_commission_aud" TEXT,
  "operating_expenses_aud" TEXT,
  "occupancy_cost_aud" TEXT,
  "operating_profit_before_central_costs_aud" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_monthly_pnl (
  "month" TEXT,
  "store_id" TEXT,
  "transactions" INTEGER,
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "net_sales_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "gross_wages_aud" NUMERIC(20,6),
  "employer_super_aud" NUMERIC(20,6),
  "total_employer_cost_aud" NUMERIC(20,6),
  "delivery_sales_aud" NUMERIC(20,6),
  "delivery_commission_aud" NUMERIC(20,6),
  "operating_expenses_aud" NUMERIC(20,6),
  "occupancy_cost_aud" NUMERIC(20,6),
  "operating_profit_before_central_costs_aud" NUMERIC(20,6)
);

CREATE TABLE IF NOT EXISTS xs_stage.hourly_store_demand (
  "date" TEXT,
  "store_id" TEXT,
  "hour" TEXT,
  "hour_start" TEXT,
  "hour_end" TEXT,
  "transactions" TEXT,
  "net_sales_aud" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "cogs_aud" TEXT,
  "food_sales_aud" TEXT,
  "drink_sales_aud" TEXT,
  "forecast_hourly_revenue_aud" TEXT,
  "forecast_source" TEXT,
  "forecast_variance_aud" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_hourly_demand (
  "date" DATE,
  "store_id" TEXT,
  "hour" INTEGER,
  "hour_start" VARCHAR(5),
  "hour_end" VARCHAR(5),
  "transactions" INTEGER,
  "net_sales_aud" NUMERIC(20,6),
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "food_sales_aud" NUMERIC(20,6),
  "drink_sales_aud" NUMERIC(20,6),
  "forecast_hourly_revenue_aud" NUMERIC(20,6),
  "forecast_source" TEXT,
  "forecast_variance_aud" NUMERIC(20,6)
);

CREATE TABLE IF NOT EXISTS xs_stage.hourly_staffing (
  "date" TEXT,
  "store_id" TEXT,
  "hour" TEXT,
  "hour_start" TEXT,
  "hour_end" TEXT,
  "active_staff" TEXT,
  "paid_labour_hours" TEXT,
  "gross_wages_aud" TEXT,
  "labour_cost_aud" TEXT,
  "staff_barista" TEXT,
  "staff_chef" TEXT,
  "staff_floor_adult" TEXT,
  "staff_floor_under18" TEXT,
  "staff_kitchen_hand" TEXT,
  "staff_supervisor" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_hourly_staffing (
  "date" DATE,
  "store_id" TEXT,
  "hour" INTEGER,
  "hour_start" VARCHAR(5),
  "hour_end" VARCHAR(5),
  "active_staff" NUMERIC(20,6),
  "paid_labour_hours" NUMERIC(20,6),
  "gross_wages_aud" NUMERIC(20,6),
  "labour_cost_aud" NUMERIC(20,6),
  "staff_barista" NUMERIC(20,6),
  "staff_chef" NUMERIC(20,6),
  "staff_floor_adult" NUMERIC(20,6),
  "staff_floor_under18" NUMERIC(20,6),
  "staff_kitchen_hand" NUMERIC(20,6),
  "staff_supervisor" NUMERIC(20,6)
);

CREATE TABLE IF NOT EXISTS xs_stage.labour_efficiency (
  "date" TEXT,
  "store_id" TEXT,
  "store_size" TEXT,
  "hour" TEXT,
  "transactions" TEXT,
  "net_sales_aud" TEXT,
  "forecast_hourly_revenue_aud" TEXT,
  "active_staff" TEXT,
  "paid_labour_hours" TEXT,
  "labour_cost_aud" TEXT,
  "sales_per_labour_hour_aud" TEXT,
  "labour_cost_pct" TEXT,
  "coverage_flag" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_labour_efficiency (
  "date" DATE,
  "store_id" TEXT,
  "store_size" TEXT,
  "hour" INTEGER,
  "transactions" INTEGER,
  "net_sales_aud" NUMERIC(20,6),
  "forecast_hourly_revenue_aud" NUMERIC(20,6),
  "active_staff" NUMERIC(20,6),
  "paid_labour_hours" NUMERIC(20,6),
  "labour_cost_aud" NUMERIC(20,6),
  "sales_per_labour_hour_aud" NUMERIC(20,6),
  "labour_cost_pct" NUMERIC(20,6),
  "coverage_flag" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.annual_summary (
  "year" TEXT,
  "period" TEXT,
  "stores_with_trading_days" TEXT,
  "store_trading_days" TEXT,
  "transactions" TEXT,
  "net_revenue_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "data_type" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_annual_sales (
  "year" INTEGER,
  "period" TEXT,
  "stores_with_trading_days" INTEGER,
  "store_trading_days" INTEGER,
  "transactions" INTEGER,
  "net_revenue_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "data_type" TEXT
);

CREATE TABLE IF NOT EXISTS xs_stage.annual_financial_summary (
  "year" TEXT,
  "transactions" TEXT,
  "gross_sales_aud" TEXT,
  "discount_aud" TEXT,
  "net_sales_aud" TEXT,
  "cogs_aud" TEXT,
  "gross_profit_aud" TEXT,
  "gross_wages_aud" TEXT,
  "employer_super_aud" TEXT,
  "total_employer_cost_aud" TEXT,
  "delivery_sales_aud" TEXT,
  "delivery_commission_aud" TEXT,
  "operating_expenses_aud" TEXT,
  "occupancy_cost_aud" TEXT,
  "operating_profit_before_central_costs_aud" TEXT,
  "store_trading_days" TEXT,
  "loss_making_store_days" TEXT,
  "loss_making_store_days_pct" TEXT,
  "central_overhead_aud" TEXT,
  "systemwide_profit_after_notional_central_overhead_aud" TEXT
);

CREATE TABLE IF NOT EXISTS xs.fact_annual_financial (
  "year" INTEGER,
  "transactions" INTEGER,
  "gross_sales_aud" NUMERIC(20,6),
  "discount_aud" NUMERIC(20,6),
  "net_sales_aud" NUMERIC(20,6),
  "cogs_aud" NUMERIC(20,6),
  "gross_profit_aud" NUMERIC(20,6),
  "gross_wages_aud" NUMERIC(20,6),
  "employer_super_aud" NUMERIC(20,6),
  "total_employer_cost_aud" NUMERIC(20,6),
  "delivery_sales_aud" NUMERIC(20,6),
  "delivery_commission_aud" NUMERIC(20,6),
  "operating_expenses_aud" NUMERIC(20,6),
  "occupancy_cost_aud" NUMERIC(20,6),
  "operating_profit_before_central_costs_aud" NUMERIC(20,6),
  "store_trading_days" INTEGER,
  "loss_making_store_days" INTEGER,
  "loss_making_store_days_pct" NUMERIC(20,6),
  "central_overhead_aud" NUMERIC(20,6),
  "systemwide_profit_after_notional_central_overhead_aud" NUMERIC(20,6)
);

CREATE TABLE IF NOT EXISTS xs.dim_date (
 date_key DATE PRIMARY KEY, calendar_year INT NOT NULL, month_number INT NOT NULL,
 month_start DATE NOT NULL, quarter_number INT NOT NULL, day_of_week_iso INT NOT NULL,
 is_weekend BOOLEAN NOT NULL
);
INSERT INTO xs.dim_date SELECT d::date, EXTRACT(YEAR FROM d)::int,
 EXTRACT(MONTH FROM d)::int, DATE_TRUNC('month',d)::date,
 EXTRACT(QUARTER FROM d)::int, EXTRACT(ISODOW FROM d)::int,
 EXTRACT(ISODOW FROM d) IN (6,7)
FROM generate_series('2023-01-01'::date,'2025-03-31'::date,'1 day'::interval) AS d
ON CONFLICT DO NOTHING;
