# Native verification and repeat-check checklist

The supplied Desktop record dated 6 November 2026 documents completed native checks; see `../docs/verification-record.md`. Repeat the checklist after changing sources, measures or relationships. SQL results alone do not establish native correctness.

1. Clear all filters: planned 43,200; downtime 3,900; downtime 9.0277778%; input 90,000 kg; waste 3,600 kg; waste 4%; delivered 32; on-time 24; delivery rate 75%; overdue 8. As-of 2026-10-31.
2. M2 on operations detail: planned 14,400; downtime 2,400; downtime 16.6666667%; waste 2,400 / input 30,000 = 8%.
3. Product P1: planned 28,800; downtime 1,500; waste 1,200 / 60,000 = 2%; delivered 16; on-time 16; overdue 4. P2: delivered 16; on-time 8; overdue 4.
4. DateOperations = 2026-10-01 only: planned 1,440; downtime 130; input 3,000; waste 120. DateOperations = 2026-10-31 only: no scheduled runs; rate should be blank, not an invented zero. Verify all cards respond consistently and titles explain blanks.
5. DateDue = 2026-10-30 in native DAX filter context (no due-date slicer in the delivered report): order O040 is outstanding overdue, so delivered 0, overdue 1, and on-time rate blank. A due-date filter selects an order cohort; it does not filter by delivery date.
6. Confirm reason bar interactions cannot misleadingly filter downtime rate. Confirm machine slicers are absent on mixed/delivery pages. Reset filters before screenshots.
7. Refresh from clean CSVs, close/reopen the saved report, rerun checks and review for import errors, blank visuals, incorrect relationships and clipped labels. Compare percentages with tolerance 0.000001 percentage points before display rounding; counts and quantities must match exactly.

Record new results separately after any changes. On 31 October the native SUM measures and operational rates return BLANK, rather than the zero returned by Python empty sums.
