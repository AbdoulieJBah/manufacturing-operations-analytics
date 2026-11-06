# Manufacturing Operations — verification record

Verified 6 November 2026 in Power BI Desktop. Synthetic October 2026 data, fixed snapshot 31 October 2026. No publication or purchase was performed.

## Evidence provenance

This record was supplied from the Windows Power BI authoring session. Local workstation paths have been removed for public sharing. The accompanying report screenshots are in `docs/images/`. Native query and relationship evidence images referenced in the original record have not been transferred to this package. The supplied PBIX is included at `powerbi/Manufacturing_Operations.pbix`. On receipt, its SHA-256 matched the recorded value exactly, its ZIP archive integrity passed, and its saved definition contained Operations Overview (18 visuals) and Operations Detail (17 visuals). This confirms file identity; native DAX checks were not rerun on the Mac.

Recorded SHA-256 of the completed PBIX: `504bce6f4378d4994908aa33e2c98590dbae76982fe083c83255ef0b1735db57`.

The final PBIX archive passed an integrity check. Both pages are 1280 × 720 (16:9). The final saved PBIX was opened in a fresh Desktop instance, and all 13 native DAX verification rows returned True after reopening. The earlier clean-CSV refresh also succeeded and passed the same checks. PBIX metadata identifies release 2026.10; the complete Desktop build number was not captured.

## Observed and independently reconciled totals

| Measure | Verified value |
|---|---:|
| Planned Minutes | 43,200 |
| Downtime Minutes | 3,900 |
| Downtime Rate | 0.09027777777777778 (9.03%) |
| Input kg | 90,000 |
| Waste kg | 3,600 |
| Waste Rate | 0.04 (4.00%) |
| Delivered Orders | 32 |
| On Time Orders | 24 |
| Late Delivered Orders | 8 |
| On Time Delivery Rate | 0.75 (75.00%) |
| Outstanding Overdue Orders | 8 |
| As Of Date | 2026-10-31 |
| Total orders | 40 |

The 8 outstanding overdue orders are excluded from the 32 delivered-order denominator. Measures remain numeric; rates use 0.00%, quantities/counts use #,##0, snapshot uses yyyy-MM-dd, and card display units are None. Native checks compare rates within 1e-12 in fractional units, tighter than the guide's tolerance.

## Model and report checks

The relationship manager showed exactly the eight specified active one-to-many relationships, with single-direction dimension-to-fact filtering. No fact-to-fact or bidirectional relationships were added. Generated automatic date dependencies were removed; settings is disconnected. Both explicit date tables retain Time category, their date columns marked as keys, and Date annotations. DateOperations and DateDue remain independent roles.

The requested 12 measures are present. Existing formulas were preserved and the nine missing measures were created individually. IDs are text. Event downtime minutes is not summarized in the detail table. All chart axes start at zero; bar charts sort descending by the displayed measure. Both pages were visually inspected. An obsolete overlapping visual was removed, text boxes were enlarged, and tables were given room for all three machine rows. The event table intentionally scrolls through its 180 rows.

## Native DAX and interaction checks

- All 13 native query cases passed before and after source refresh, and again in the reopened final PBIX: overall totals, M2, all three machines, P1, P2, 1 October, 31 October, 30 October due cohort, and all three downtime reasons.
- Machine M2 / Press 2: 14,400 planned, 2,400 downtime, 16.6666667% downtime; input 30,000, waste 2,400, waste rate 8%. Delivery measures remain unchanged under machine context. The page machine slicer was operated and its cards/charts/tables responded correctly.
- Machine bars: Press 1 900 minutes / 6.25%, Press 2 2,400 / 16.6666667%, Finishing 600 / 4.1666667%; each has 14,400 planned minutes.
- Product P1 / Bracket: 28,800 planned, 1,500 downtime, input 60,000, waste 1,200, waste 2%, delivered 16, on-time 16, overdue 4. P2 / Housing: delivered 16, on-time 8, overdue 4, waste 8%. Both product selections were operated in the Overview slicer and matched the expected cards and bars.
- DateOperations 1 October: 1,440 planned, 130 downtime, input 3,000, waste 120. The production-date slicer was operated and all six cards and operational visuals responded.
- DateOperations 31 October: no scheduled runs. Native SUM measures return BLANK, while the independent Python empty-set sums are zero. This is an intentional semantic distinction, not a mismatch. Both operational rates remain BLANK. Delivery totals remain unchanged.
- DateDue 30 October: one order, O040, outstanding overdue; delivered 0, on-time 0, overdue 1, on-time rate BLANK. The date selects an order due-date cohort and leaves operational totals unchanged. This check used native DAX filter context; no due-date slicer was added to the specified two-page design.
- Native reason totals match the actual result CSV: Breakdown 2,100; Material wait 900; Setup 900 minutes. Selecting Breakdown in the chart did not change any KPI, other chart, or table.
- Selecting Press 2 in the Overview machine bar left on-time delivery rate and every delivery-count card unchanged. Outgoing data-point filtering/highlighting is disabled for report charts/tables; slicers retain model filtering.
- All test slicers were cleared, chart selections removed, and the report saved on Overview. Final screenshots show All selections and full totals.

## Evidence and limits

Independent clean CSV calculations were compared with existing SQLite metrics and the actual machine, product and reason result CSVs; all passed. The supplied reconciliation guide was read. Native DAX results are documented separately from those independent calculations. Screenshots are direct Desktop captures, including normal application chrome. This is a synthetic portfolio report and makes no claim of real company results or measured business improvement.
