-- Monthly revenue trend from successful payments.

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
ORDER BY revenue_month;
