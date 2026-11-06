-- SQLite dialect. Raw tables loaded by scripts/build.py. Re-running rebuilds outputs.
DROP TABLE IF EXISTS settings;
CREATE TABLE settings AS SELECT '2026-10-31' AS as_of_date;
DROP TABLE IF EXISTS machine;
CREATE TABLE machine AS SELECT * FROM raw_machine;
DROP TABLE IF EXISTS product;
CREATE TABLE product AS SELECT * FROM raw_product;
DROP TABLE IF EXISTS quality_issues;
CREATE TABLE quality_issues(source_table TEXT, record_id TEXT, issue TEXT);
INSERT INTO quality_issues SELECT 'production',run_id,'exact duplicate replay removed' FROM raw_production GROUP BY run_id HAVING count(*)>1;
DROP TABLE IF EXISTS production;
CREATE TABLE production AS
SELECT DISTINCT r.* FROM raw_production r
WHERE machine_id IN (SELECT machine_id FROM machine)
AND product_id IN (SELECT product_id FROM product)
AND unit='kg' AND planned_minutes>0 AND input_qty>0
AND waste_qty BETWEEN 0 AND input_qty
AND date(run_date) IS NOT NULL AND run_date <= (SELECT as_of_date FROM settings);
INSERT INTO quality_issues SELECT 'production',run_id,'invalid key, unit, quantity or date; quarantined' FROM raw_production WHERE run_id NOT IN (SELECT run_id FROM production);
DROP TABLE IF EXISTS downtime;
CREATE TABLE downtime AS SELECT d.*,p.run_date,p.machine_id,p.product_id,end_minute-start_minute AS downtime_minutes
FROM raw_downtime d JOIN production p USING(run_id)
WHERE start_minute>=0 AND end_minute>start_minute AND end_minute<=p.planned_minutes;
INSERT INTO quality_issues SELECT 'downtime',event_id,'missing run or invalid interval; quarantined' FROM raw_downtime WHERE event_id NOT IN (SELECT event_id FROM downtime);
DROP TABLE IF EXISTS orders;
CREATE TABLE orders AS SELECT * FROM raw_orders WHERE product_id IN (SELECT product_id FROM product)
AND date(order_date) IS NOT NULL AND date(due_date) IS NOT NULL AND order_date<=due_date
AND order_date<=(SELECT as_of_date FROM settings) AND quantity>0;
INSERT INTO quality_issues SELECT 'orders',order_id,'invalid order; quarantined' FROM raw_orders WHERE order_id NOT IN (SELECT order_id FROM orders);
DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries AS SELECT d.* FROM raw_deliveries d JOIN orders o USING(order_id)
WHERE date(delivered_date) IS NOT NULL AND delivered_date>=order_date
AND delivered_date<=(SELECT as_of_date FROM settings) AND d.quantity>0;
INSERT INTO quality_issues SELECT 'deliveries',delivery_id,'invalid order, quantity or delivery date; quarantined' FROM raw_deliveries WHERE delivery_id NOT IN (SELECT delivery_id FROM deliveries);
-- One row per order. Future extension: completion date is when cumulative quantity first reaches ordered quantity.
-- MVP permits only a single full delivery; quality checks fail rather than misclassify partial shipments.
DROP TABLE IF EXISTS delivery_order;
CREATE TABLE delivery_order AS SELECT o.*,d.delivered_date,
CASE WHEN d.order_id IS NOT NULL THEN 1 ELSE 0 END AS is_delivered,
CASE WHEN d.delivered_date<=o.due_date THEN 1 ELSE 0 END AS is_on_time,
CASE WHEN d.order_id IS NULL AND o.due_date<(SELECT as_of_date FROM settings) THEN 1 ELSE 0 END AS is_outstanding_overdue
FROM orders o LEFT JOIN deliveries d USING(order_id);
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS WITH RECURSIVE dates(d) AS (SELECT '2026-10-01' UNION ALL SELECT date(d,'+1 day') FROM dates WHERE d<'2026-10-31') SELECT d AS date FROM dates;
