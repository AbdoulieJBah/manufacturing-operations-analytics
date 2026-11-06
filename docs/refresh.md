# Open and refresh the report

The completed PBIX is included in `powerbi/Manufacturing_Operations.pbix`. Its original local source paths may need updating before refresh.

1. Run `python3 scripts/build.py` from the repository root to reproduce the synthetic data and SQL checks. The script overwrites generated raw/clean CSVs and results, but not the Power BI report.
2. Open `powerbi/Manufacturing_Operations.pbix` in Power BI Desktop on Windows.
3. If source paths point to the original authoring computer, use Transform data and update each CSV Source path to this checkout's `data/clean` folder. Preserve query names, types, transformations and relationships. Both DateOperations and DateDue derive from `dim_date.csv`.
4. Refresh and follow `powerbi/reconciliation.md`. Compare totals and filter cases with `docs/verification-record.md`, then clear selections and save.

The snapshot is fixed at 31 October 2026. Changing the displayed date alone does not update overdue flags. Snapshot, fixture dates, SQL and expected controls must be changed together and revalidated. No scheduled refresh, cloud credentials or online publishing is configured by this package.
