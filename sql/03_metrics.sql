-- Aggregate facts separately. Never join raw event rows to production before summing planned/input.
DROP TABLE IF EXISTS metrics;
CREATE TABLE metrics AS
SELECT 'planned_minutes' metric,sum(planned_minutes) value FROM production UNION ALL
SELECT 'downtime_minutes',sum(downtime_minutes) FROM downtime UNION ALL
SELECT 'downtime_rate',1.0*(SELECT sum(downtime_minutes) FROM downtime)/sum(planned_minutes) FROM production UNION ALL
SELECT 'input_kg',sum(input_qty) FROM production UNION ALL
SELECT 'waste_kg',sum(waste_qty) FROM production UNION ALL
SELECT 'waste_rate',1.0*sum(waste_qty)/sum(input_qty) FROM production UNION ALL
SELECT 'delivered_orders',sum(is_delivered) FROM delivery_order UNION ALL
SELECT 'on_time_orders',sum(is_on_time) FROM delivery_order UNION ALL
SELECT 'on_time_rate',1.0*sum(is_on_time)/NULLIF(sum(is_delivered),0) FROM delivery_order UNION ALL
SELECT 'outstanding_overdue_orders',sum(is_outstanding_overdue) FROM delivery_order;
DROP TABLE IF EXISTS machine_metrics;
CREATE TABLE machine_metrics AS WITH p AS (SELECT machine_id,sum(planned_minutes) planned_minutes FROM production GROUP BY machine_id),
d AS (SELECT machine_id,sum(downtime_minutes) downtime_minutes FROM downtime GROUP BY machine_id)
SELECT p.*,d.downtime_minutes,1.0*d.downtime_minutes/p.planned_minutes downtime_rate FROM p JOIN d USING(machine_id);
DROP TABLE IF EXISTS product_metrics;
CREATE TABLE product_metrics AS SELECT product_id,sum(input_qty) input_kg,sum(waste_qty) waste_kg,1.0*sum(waste_qty)/sum(input_qty) waste_rate FROM production GROUP BY product_id;
DROP TABLE IF EXISTS reason_metrics;
CREATE TABLE reason_metrics AS SELECT reason,sum(downtime_minutes) downtime_minutes FROM downtime GROUP BY reason;
