# Power BI manual authoring kit

Native status: the report was completed and checked in the Windows Power BI Desktop session on 6 November 2026. See `../docs/verification-record.md`. This file retains the build specification for reproduction; the completed PBIX is included in this package.

## Import and types

1. Run `python3 scripts/build.py` first; confirm PASS.
2. In Power BI Desktop, use Get data → Text/CSV for clean `machine`, `product`, `production`, `downtime`, `delivery_order`, `dim_date` and `settings`. Rename queries exactly as file stems. Do not import `raw_*`, SQL result aggregates, orders or deliveries into this report.
3. In Transform data set IDs, names, reasons and unit to Text; all calendar columns to Date; minutes, quantities and flags to Whole number (fixture contains integers). Blank delivered_date must remain null, not a default date. Set locale explicitly if ISO date parsing requires it. Check no conversion errors.
4. Duplicate the `dim_date` query as `DateOperations` and `DateDue`; disable load for original `dim_date`. Mark each loaded date table using its `date` column. Set dates to Date (not Date/time); disable automatic date/time if using these explicit tables.
5. Load the tables, review auto-created relationships and remove any that differ from the list below. Every listed relationship is active, one-to-many, single direction from dimension to fact.

| One side | Many side |
|---|---|
| machine[machine_id] | production[machine_id] |
| machine[machine_id] | downtime[machine_id] |
| product[product_id] | production[product_id] |
| product[product_id] | downtime[product_id] |
| product[product_id] | delivery_order[product_id] |
| DateOperations[date] | production[run_date] |
| DateOperations[date] | downtime[run_date] |
| DateDue[date] | delivery_order[due_date] |

Keep `settings` disconnected. Do not relate production to downtime through run_id or orders to production. Machine filters intentionally have no relationship to delivery metrics: do not put a machine slicer on the mixed overview or delivery page. DateOperations and DateDue are independent role dates; do not synchronize their slicers.

6. Create each measure in `measures.dax` separately. Format rates as 0.0%, counts/minutes as #,##0, kg as #,##0, and snapshot as yyyy-MM-dd. Hide raw numeric columns to encourage explicit measures; hide surrogate IDs where appropriate. Import `theme.json` if desired.

## Two-page MVP layout (16:9)

**Overview**: title “Manufacturing Operations · Synthetic data”; subtitle “October 2026 · As of 31 October 2026”. Use product slicer only; no date or machine slicer. Top row: downtime rate, waste rate, on-time delivery rate, outstanding overdue cards. Second row: horizontal downtime-minutes bar by machine; waste-rate bar by product. Bottom row: delivery counts (on-time, late via delivered minus on-time, outstanding overdue) or a compact table. Each card subtitle gives its denominator. Add a small visible note that delivery metrics use the fixed as-of snapshot. Show 24 on-time, 8 late and 8 overdue as separate categories; do not label them a delivery rate denominator.

**Operations detail**: DateOperations and machine slicers; product slicer optional. Cards for planned minutes, downtime minutes, downtime rate, input kg, waste kg, waste rate. Left: downtime minutes by reason; center: downtime rate by machine; right: waste rate by product. Bottom: machine table with planned and downtime minutes and rate, plus event detail table (event_id, run_id, reason, downtime_minutes). Do not put a reason slicer on a page with a rate: it filters downtime only and changes the numerator without filtering scheduled exposure. Disable bar-chart selection interactions with rate cards/other charts where they would filter only event reason. Verify interactions manually.

**Optional delivery detail after MVP**: DateDue slicer labeled “Order due date”, product slicer, cards for delivered, on-time %, overdue; table of order_id, due_date, delivered_date and flags. No machine slicer. Optional product-waste detail can follow only after reconciliation.

Use navy text, teal bars and amber highlights for investigation. Avoid red/green performance targets: no business targets were supplied. Sort bars by value, begin axes at zero, show units, and keep synthetic/as-of labels visible on every page. Do not use production-date filters on delivery measures or imply that a machine explains delivery performance.

## Save and refresh

Save locally as a native report only after loading and checking the model. For refresh, regenerate CSVs, then Refresh in Power BI and repeat `reconciliation.md`. If moving folders, change each CSV Source path in Power Query; keep query/table names stable. Snapshot flags come from SQL, not TODAY(), so they stay reproducible. To move the snapshot, update the generator and SQL settings plus fixture dates/controls deliberately; then regenerate, refresh and reconcile. Never just change the displayed title.

## Sources for modeling guidance

- [Microsoft: star schema guidance](https://learn.microsoft.com/power-bi/guidance/star-schema)
- [Microsoft: create and manage relationships](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-create-and-manage-relationships)

These support the shared-dimension model approach; they do not verify this kit's DAX or native report behavior.
