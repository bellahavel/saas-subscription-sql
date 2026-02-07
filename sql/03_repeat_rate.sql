-- What percentage of customers place repeat orders (2+ successful paid invoices)?

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
FROM counts;
