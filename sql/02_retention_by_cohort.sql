-- How does retention change by acquisition month (cohort retention)?
-- Uses first successful payment month as acquisition month.

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
ORDER BY ca.cohort_month, ca.month_number;
