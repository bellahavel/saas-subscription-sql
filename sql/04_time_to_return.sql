-- How long does it take customers to return for a second purchase?

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
ORDER BY days_to_return ASC;
