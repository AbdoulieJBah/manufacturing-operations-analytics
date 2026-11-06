DROP TABLE IF EXISTS quality_checks;
CREATE TABLE quality_checks(check_name TEXT, failures INTEGER);
INSERT INTO quality_checks VALUES
('production unique IDs',(SELECT count(*)-count(DISTINCT run_id) FROM production)),
('downtime unique IDs',(SELECT count(*)-count(DISTINCT event_id) FROM downtime)),
('order unique IDs',(SELECT count(*)-count(DISTINCT order_id) FROM orders)),
('delivery unique IDs',(SELECT count(*)-count(DISTINCT delivery_id) FROM deliveries)),
('dimension unique IDs',(SELECT count(*)-count(DISTINCT machine_id) FROM machine)+(SELECT count(*)-count(DISTINCT product_id) FROM product)),
('production keys',(SELECT count(*) FROM production WHERE machine_id NOT IN (SELECT machine_id FROM machine) OR product_id NOT IN (SELECT product_id FROM product) OR machine_id IS NULL OR product_id IS NULL)),
('production quantities units dates',(SELECT count(*) FROM production WHERE planned_minutes<=0 OR input_qty<=0 OR waste_qty<0 OR waste_qty>input_qty OR unit<>'kg' OR date(run_date) IS NULL)),
('downtime intervals',(SELECT count(*) FROM downtime WHERE downtime_minutes<=0 OR start_minute<0)),
('downtime overlapping intervals',(SELECT count(*) FROM downtime a JOIN downtime b ON a.run_id=b.run_id AND a.event_id<b.event_id AND a.start_minute<b.end_minute AND b.start_minute<a.end_minute)),
('run downtime exceeds planned',(SELECT count(*) FROM (SELECT p.run_id FROM production p JOIN downtime d USING(run_id) GROUP BY p.run_id HAVING sum(d.downtime_minutes)>max(p.planned_minutes)))),
('delivery must be single full shipment',(SELECT count(*) FROM (SELECT o.order_id FROM orders o JOIN deliveries d USING(order_id) GROUP BY o.order_id HAVING count(*)<>1 OR sum(d.quantity)<>max(o.quantity)))),
('delivery date sequence',(SELECT count(*) FROM deliveries d JOIN orders o USING(order_id) WHERE delivered_date<order_date OR delivered_date>(SELECT as_of_date FROM settings))),
('orders due date sequence',(SELECT count(*) FROM orders WHERE due_date<order_date)),
('order mart unique grain',(SELECT count(*)-count(DISTINCT order_id) FROM delivery_order)),
('fact date coverage',(SELECT count(*) FROM production WHERE run_date NOT IN (SELECT date FROM dim_date))+(SELECT count(*) FROM delivery_order WHERE due_date NOT IN (SELECT date FROM dim_date)));
