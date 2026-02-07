# Outputs

This folder contains the final CSV outputs generated from the SQL analyses. Each file maps to a specific business question and SQL script.

## Files
- `01_revenue_customers.csv`
  - Source SQL: `sql/01_revenue_customers.sql`
  - Description: Total revenue and successful invoice count by customer, sorted by revenue.

- `02_retention_by_cohort.csv`
  - Source SQL: `sql/02_retention_by_cohort.sql`
  - Description: Cohort retention table by acquisition month and months since first paid invoice.

- `03_repeat_rate.csv`
  - Source SQL: `sql/03_repeat_rate.sql`
  - Description: Aggregate repeat purchase rate (customers with 2+ paid invoices).

- `04_time_to_return.csv`
  - Source SQL: `sql/04_time_to_return.sql`
  - Description: Days between first and second paid invoice for each customer.

- `05_revenue_mom.csv`
  - Source SQL: `sql/05_revenue_mom.sql`
  - Description: Monthly revenue with month-over-month change.
