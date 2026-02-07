-- Export final tables to CSV files in outputs/
-- Run this after the base tables are loaded.

COPY (
  -- Top revenue customers
  WITH paid_invoices AS (
    SELECT DISTINCT
      "Invoice external ID" AS invoice_id,
      CAST("Date" AS DATE) AS paid_date
    FROM transactions
    WHERE LOWER("Type") = 'payment'
      AND LOWER("Result") = 'successful'
  ), invoice_amounts AS (
    SELECT
      "Invoice external ID" AS invoice_id,
      SUM(CAST("Amount in cents" AS DOUBLE)) / 100.0 AS invoice_amount_usd
    FROM invoice_line_items
    GROUP BY "Invoice external ID"
  ), paid_invoice_amounts AS (
    SELECT
      p.invoice_id,
      p.paid_date,
      a.invoice_amount_usd
    FROM paid_invoices p
    JOIN invoice_amounts a
      ON p.invoice_id = a.invoice_id
  ), revenue_by_customer AS (
    SELECT
      i."Customer external ID" AS customer_id,
      SUM(pia.invoice_amount_usd) AS total_revenue_usd,
      COUNT(*) AS successful_invoices
    FROM paid_invoice_amounts pia
    JOIN invoices i
      ON pia.invoice_id = i."Invoice external ID"
    GROUP BY i."Customer external ID"
  )
  SELECT *
  FROM revenue_by_customer
  ORDER BY total_revenue_usd DESC
) TO '/Users/bellahavel/Documents/New project/saas-subscription-sql/outputs/01_revenue_customers.csv' (HEADER, DELIMITER ',');

COPY (
  -- Cohort retention by acquisition month
  WITH paid_invoices AS (
    SELECT DISTINCT
      "Invoice external ID" AS invoice_id,
      CAST("Date" AS DATE) AS paid_date
    FROM transactions
    WHERE LOWER("Type") = 'payment'
      AND LOWER("Result") = 'successful'
  ), paid_activity AS (
    SELECT
      i."Customer external ID" AS customer_id,
      DATE_TRUNC('month', p.paid_date) AS activity_month
    FROM paid_invoices p
    JOIN invoices i
      ON p.invoice_id = i."Invoice external ID"
    GROUP BY i."Customer external ID", DATE_TRUNC('month', p.paid_date)
  ), cohorts AS (
    SELECT
      customer_id,
      MIN(activity_month) AS cohort_month
    FROM paid_activity
    GROUP BY customer_id
  ), cohort_activity AS (
    SELECT
      c.cohort_month,
      a.activity_month,
      DATE_DIFF('month', c.cohort_month, a.activity_month) AS month_number,
      c.customer_id
    FROM cohorts c
    JOIN paid_activity a
      ON c.customer_id = a.customer_id
  ), cohort_sizes AS (
    SELECT
      cohort_month,
      COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
  )
  SELECT
    ca.cohort_month,
    ca.month_number,
    COUNT(DISTINCT ca.customer_id) AS active_customers,
    cs.cohort_size,
    ROUND(COUNT(DISTINCT ca.customer_id) * 1.0 / cs.cohort_size, 4) AS retention_rate
  FROM cohort_activity ca
  JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
  GROUP BY ca.cohort_month, ca.month_number, cs.cohort_size
  ORDER BY ca.cohort_month, ca.month_number
) TO '/Users/bellahavel/Documents/New project/saas-subscription-sql/outputs/02_retention_by_cohort.csv' (HEADER, DELIMITER ',');

COPY (
  -- Repeat purchase rate
  WITH paid_invoices AS (
    SELECT DISTINCT
      "Invoice external ID" AS invoice_id
    FROM transactions
    WHERE LOWER("Type") = 'payment'
      AND LOWER("Result") = 'successful'
  ), customer_invoices AS (
    SELECT
      i."Customer external ID" AS customer_id,
      i."Invoice external ID" AS invoice_id
    FROM invoices i
    JOIN paid_invoices p
      ON i."Invoice external ID" = p.invoice_id
  ), counts AS (
    SELECT
      customer_id,
      COUNT(*) AS successful_invoices
    FROM customer_invoices
    GROUP BY customer_id
  )
  SELECT
    COUNT(*) AS customers_with_payments,
    SUM(CASE WHEN successful_invoices >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN successful_invoices >= 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 4) AS repeat_rate
  FROM counts
) TO '/Users/bellahavel/Documents/New project/saas-subscription-sql/outputs/03_repeat_rate.csv' (HEADER, DELIMITER ',');

COPY (
  -- Time to return (second purchase)
  WITH paid_invoices AS (
    SELECT DISTINCT
      "Invoice external ID" AS invoice_id,
      CAST("Date" AS DATE) AS paid_date
    FROM transactions
    WHERE LOWER("Type") = 'payment'
      AND LOWER("Result") = 'successful'
  ), customer_payments AS (
    SELECT
      i."Customer external ID" AS customer_id,
      p.paid_date
    FROM paid_invoices p
    JOIN invoices i
      ON p.invoice_id = i."Invoice external ID"
  ), ordered AS (
    SELECT
      customer_id,
      paid_date,
      ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY paid_date) AS rn,
      LAG(paid_date) OVER (PARTITION BY customer_id ORDER BY paid_date) AS prev_paid_date
    FROM customer_payments
  )
  SELECT
    customer_id,
    paid_date AS second_purchase_date,
    DATE_DIFF('day', prev_paid_date, paid_date) AS days_to_return
  FROM ordered
  WHERE rn = 2
  ORDER BY days_to_return ASC
) TO '/Users/bellahavel/Documents/New project/saas-subscription-sql/outputs/04_time_to_return.csv' (HEADER, DELIMITER ',');

COPY (
  -- Monthly revenue trend
  WITH paid_invoices AS (
    SELECT DISTINCT
      "Invoice external ID" AS invoice_id,
      CAST("Date" AS DATE) AS paid_date
    FROM transactions
    WHERE LOWER("Type") = 'payment'
      AND LOWER("Result") = 'successful'
  ), invoice_amounts AS (
    SELECT
      "Invoice external ID" AS invoice_id,
      SUM(CAST("Amount in cents" AS DOUBLE)) / 100.0 AS invoice_amount_usd
    FROM invoice_line_items
    GROUP BY "Invoice external ID"
  ), paid_invoice_amounts AS (
    SELECT
      p.invoice_id,
      p.paid_date,
      a.invoice_amount_usd
    FROM paid_invoices p
    JOIN invoice_amounts a
      ON p.invoice_id = a.invoice_id
  ), monthly AS (
    SELECT
      DATE_TRUNC('month', paid_date) AS revenue_month,
      SUM(invoice_amount_usd) AS revenue_usd
    FROM paid_invoice_amounts
    GROUP BY revenue_month
  )
  SELECT
    revenue_month,
    revenue_usd,
    revenue_usd - LAG(revenue_usd) OVER (ORDER BY revenue_month) AS revenue_change_mom
  FROM monthly
  ORDER BY revenue_month
) TO '/Users/bellahavel/Documents/New project/saas-subscription-sql/outputs/05_revenue_mom.csv' (HEADER, DELIMITER ',');
