# Two-minute project walkthrough

## 0:00–0:20 — Question and scope

“This project examines manufacturing downtime, material waste and delivery reliability. I used synthetic October 2026 data with a fixed snapshot of 31 October. It demonstrates analytical methods, not real company results.”

## 0:20–0:45 — Data preparation and model

“I used SQL to clean the data and quarantine deliberately injected defects. Runs, downtime events and orders have different grains. Joining events directly to runs would duplicate planned time, so I kept the facts separate and used shared dimensions. Production dates and order due dates have separate roles.”

## 0:45–1:15 — Findings

Show Operations Overview. “Downtime is 9.03% of planned minutes, waste is 4% of input mass, and 24 of 32 delivered orders arrived on time: 75%. Eight additional orders are outstanding and overdue, so they are shown separately from the delivered-order denominator.”

Show Operations Detail. “Press 2 contributes 2,400 downtime minutes and has a 16.67% downtime rate. Housing has an 8% waste rate. These suggest where to investigate, but Housing only runs on Press 2 in this fixture, so product and machine effects cannot be separated.”

## 1:15–1:45 — Validation

“SQL totals were checked against independent calculations. The Desktop verification record documents 13 passing native DAX cases after refresh and reopening, alongside slicer checks. Machine filters leave delivery measures unchanged. A day with no production returns blank rates.”

## 1:45–2:00 — Limits and next steps

“This is a small, repetitive synthetic dataset. It does not establish causes or savings. A real implementation would need requirements for partial deliveries, revised due dates and broader operational coverage.”

Practice in your own words, tracing one KPI through the SQL and DAX. Demonstrate interactions only from the actual report. No video or social post is included or published.
