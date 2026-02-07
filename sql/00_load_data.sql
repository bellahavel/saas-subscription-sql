-- Load ChartMogul sample CSVs into DuckDB tables.
-- Update file patterns if your extracted filenames differ.

CREATE OR REPLACE TABLE customers AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/01_Customers.csv', union_by_name=true);

CREATE OR REPLACE TABLE contacts AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/02_Contacts.csv', union_by_name=true);

CREATE OR REPLACE TABLE plans AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/03_Plans.csv', union_by_name=true);

CREATE OR REPLACE TABLE invoices AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/04_Invoices.csv', union_by_name=true);

CREATE OR REPLACE TABLE invoice_line_items AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/05_Invoice_line_items.csv', union_by_name=true);

CREATE OR REPLACE TABLE transactions AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/06_Transactions.csv', union_by_name=true);

CREATE OR REPLACE TABLE subscription_events AS
SELECT *
FROM read_csv_auto('/Users/bellahavel/Documents/New project/saas-subscription-sql/data/07_Subscription_events.csv', union_by_name=true);

-- Quick sanity check
PRAGMA show_tables;
