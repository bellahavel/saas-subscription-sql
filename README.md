# SaaS Subscription Retention & Revenue Analysis (SQL-First)

## Executive Summary
This project analyzes SaaS retention and revenue using SQL only, based on a public subscription billing dataset. The results show revenue concentration among a few customers, a repeat purchase rate of 66.7%, and cohort retention that drops after the first month but stabilizes afterward. Time-to-return patterns indicate a monthly billing cadence with a few long-gap reactivations. These insights highlight the importance of early-month retention and the outsized impact of top customers on revenue stability.
Final CSV outputs are reproducible via `sql/06_export_outputs.sql`.

## Quickstart
1. Download the dataset and unzip into `saas-subscription-sql/data/`.
2. In DuckDB, run:
```sql
.read sql/00_load_data.sql
```

## Overview
This project answers real SaaS business questions about retention and revenue using SQL only. Python can be used later for visualization, but all core logic is in SQL.

## Dataset
Public SaaS-style sample data from ChartMogul (Invoice Data ZIP). It contains customers, contacts, plans, invoices, invoice line items, transactions, and subscription events.

Download the ZIP here:
- [ChartMogul Sample Invoice Data (ZIP)](https://chartmogul-samples.s3.eu-west-1.amazonaws.com/public/Sample_csv_files.zip)

Source reference:
- [ChartMogul Help Center: Adding sample data](https://help.chartmogul.com/article/120-adding-sample-data)

Note: Raw CSV files are not committed to this repo. Download the ZIP and unzip into `saas-subscription-sql/data/`.

## Project Questions (Business-First)
- Which customers generate the most revenue?
- How does retention change by acquisition month (cohort retention)?
- What percentage of customers place repeat orders?
- How long does it take customers to return for a second purchase?

## Setup (DuckDB)
1. Download the ZIP and unzip into `saas-subscription-sql/data/`.
2. Open DuckDB in this folder and run the load script:

```sql
.read sql/00_load_data.sql
```

## SQL Files
- `sql/00_load_data.sql`
- `sql/01_revenue_customers.sql`
- `sql/02_retention_by_cohort.sql`
- `sql/03_repeat_rate.sql`
- `sql/04_time_to_return.sql`
- `sql/05_revenue_mom.sql`

## Skills Demonstrated
- SQL analytics with CTEs and window functions
- Cohort analysis and retention metrics
- Revenue attribution and aggregation logic
- Business interpretation and implications

## Sample Output (Excerpt)
Example from cohort retention output:

```
cohort_month  month_number  active_customers  cohort_size  retention_rate
2025-02-01    0             2                 2            1.00
2025-02-01    1             1                 2            0.50
2025-02-01    2             1                 2            0.50
```

## Methodology and Metric Definitions
- Revenue: sum of `invoice_line_items.Amount in cents` for invoices with successful payments.
- Paid invoice: an invoice with a matching transaction where `Type = 'payment'` and `Result = 'successful'`.
- Cohort month: month of a customer’s first paid invoice.
- Retention: active customers in a month divided by cohort size (customers with any paid invoice that month).
- Repeat rate: percent of customers with 2+ paid invoices.

## Assumptions and Exclusions
- Only successful payment transactions are counted as revenue.
- Refunds are excluded from revenue calculations unless explicitly included.
- Non-subscription line items can be excluded depending on the question.
- Customers without any successful payment are excluded from retention calculations.

## Results and Business Implications

### 1) Top Revenue Customers
**Result summary:** Revenue is concentrated among a small number of customers. The highest-revenue customer generated $310.50 across 12 invoices, followed by a second tier of customers with smaller but frequent payments. Some customers contribute high revenue with only one invoice.

**Business implications:**
- Revenue concentration creates customer-level risk; losing one top customer would materially impact revenue.
- Segmenting top customers by plan or acquisition channel can reveal drivers of high lifetime value.
- One-time high-revenue customers may represent upsell opportunities or early churn after a large initial purchase.

### 2) Cohort Retention by Acquisition Month
**Result summary:** The February 2025 cohort shows 100% retention in month 0, dropping to 50% by month 1 and remaining stable afterward.

**Business implications:**
- Early-month activation is the biggest leakage point; improving onboarding could lift retention.
- A stable 50% "core" suggests a loyal subset worth analyzing for plan or usage patterns.

### 3) Repeat Purchase Rate
**Result summary:** 14 of 21 customers made two or more payments, yielding a 66.7% repeat rate.

**Business implications:**
- One-third of customers are one-and-done; converting first-time buyers into repeat customers is a high-leverage growth opportunity.

### 4) Time to Return (Second Purchase)
**Result summary:** Most customers return in ~30-32 days, consistent with a monthly billing cadence. A few customers return after long gaps (90-180 days).

**Business implications:**
- The dominant monthly cadence supports predictable subscription behavior.
- Long gaps indicate churn/reactivation behavior and suggest a need to investigate lifecycle triggers.

### 5) Monthly Revenue Trend
**Result summary:** Revenue is volatile month-to-month, with large drops and rebounds, including a spike in January 2026 followed by a decline in February 2026.

**Business implications:**
- Volatility suggests uneven acquisition or irregular billing; separating new vs. existing revenue would clarify the drivers.
- Smoothing revenue could require retention improvements and more consistent acquisition.

## Schema Mapping (ChartMogul Sample CSVs)
This dataset uses column names with spaces. The SQL files reference the exact names below.

Tables and key columns:
- `transactions`
  - `Invoice external ID` (links to `invoices`)
  - `Type`, `Result`, `Date`
- `invoices`
  - `Invoice external ID` (invoice ID)
  - `Customer external ID` (customer ID)
  - `Invoiced date`
- `invoice_line_items`
  - `Invoice external ID` (links to `invoices`)
  - `Amount in cents` (used for revenue)

Revenue logic used in this project:
- Successful payments are identified in `transactions` where `Type = 'payment'` and `Result = 'successful'`.
- Customer IDs come from `invoices` (via `Invoice external ID`).
- Revenue is calculated from `invoice_line_items.Amount in cents` for paid invoices.

## Outputs
Each SQL file returns a final table plus a short interpretation section you can paste into a write-up.

## How to Regenerate Outputs
Run the export script in DuckDB to recreate the CSVs:

```sql
.read sql/06_export_outputs.sql
```

This writes the final tables into `outputs/`.

## Limitations and Next Steps
- This is a sample dataset without acquisition channels or product usage events, which limits causal analysis of churn.
- Next analyses could include plan-level retention, churn timing, and segmentation of revenue into new vs. expansion vs. retained.
