-- Which customers generate the most revenue?
-- Revenue is derived from invoice line items for invoices with successful payments.

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
SELECT
  customer_id,
  total_revenue_usd,
  successful_invoices
FROM revenue_by_customer
ORDER BY total_revenue_usd DESC;
