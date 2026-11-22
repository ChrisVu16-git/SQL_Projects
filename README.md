# Data Analytics & SQL Portfolio

- **A$60.03M net sales** across the café portfolio from January 2023 to March 2025.
- **A$42.11M gross profit** left a 70.15% network gross margin over the same period.
- **119 summer açaí bowl orders** would match the contribution of 100 full-price orders at a 10% discount (modelled).
- **112 winter coffee combos** would match 100 full-price orders with A$1 off (modelled).


A collection of end-to-end data analytics projects exploring business operations and the Data Analyst job market. These projects demonstrate how I use **PostgreSQL/SQL, Python, Power BI, and data visualization** to transform structured data into practical findings and decision-focused recommendations.

The portfolio emphasizes data preparation and validation, reproducible analysis, analytical storytelling, and clear communication of business insights.

## Portfolio projects

### XS Espresso — Sales, Demand & Operational Analytics

An operations analytics project investigating customer demand, revenue forecasting, and store profitability across a multi-location café network using a portfolio demonstration dataset (January 2023–March 2025).

**Business focus:** Identify busy trading periods, evaluate store-hour forecast accuracy, and compare store performance based on revenue and operating margin.

**Tools:** PostgreSQL · SQL · Power BI · DAX · Python

**Deliverables:** Power BI dashboard, entity–relationship diagram, demand heatmap, forecast comparison, store-performance analysis, and SQL queries.

[Explore XS Espresso Analytics](XS%20Espresso%20Analytics/README.md) · [View screenshots](XS%20Espresso%20Analytics/screenshots/) · [Power BI report](XS%20Espresso%20Analytics/dashboard/XS_Espresso_Dashboard.pbix)

### Seasonal marketplace promotions · Modelled data

Compare a summer açaí bowl discount with a winter coffee-and-pastry offer. The analysis calculates unit contribution and the order volume each offer needs to preserve margin. [Campaign assumptions and results](seasonal-promotions/) · [Break-even SQL](queries/seasonal_promo_break_even.sql)

### Café pipeline

Explore [named PostgreSQL queries](queries/), the [dbt project](cafe-dbt/) and the [BigQuery pipeline](bigquery/). The models reconcile daily and hourly exports and aggregate sales and gross margin by store.

## Additional project · Data Analyst job market

A job-market analysis project examining skill demand and salary patterns in data-related job postings. It combines SQL queries with Python-based exploration and visualizations to communicate findings relevant to Data Analyst career planning.

**Business focus:** Explore which skills appear most often in job advertisements, how skill demand relates to salary, and how job-market patterns vary by role.

**Tools:** PostgreSQL · SQL · Python · Pandas · Matplotlib

**Deliverables:** SQL analysis, data-loading scripts, Jupyter notebooks, charts, documentation, and an interactive dashboard.

[Explore Job On Demand Analyse](Job%20On%20Demand%20Analyse/README.md) · [Interactive dashboard](Job%20On%20Demand%20Analyse/index.html) · [Project files](Job%20On%20Demand%20Analyse/)
