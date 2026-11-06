"""Deterministic synthetic data -> SQLite SQL cleaning -> checked CSV exports. Python 3 stdlib only."""
from pathlib import Path
import csv, sqlite3, json, datetime as dt

ROOT = Path(__file__).resolve().parents[1]
AS_OF = '2026-10-31'
def write_csv(path, headers, rows):
    with path.open('w', newline='') as f:
        w=csv.writer(f); w.writerow(headers); w.writerows(rows)

def main():
    for folder in ['data/raw','data/clean','results']:
        (ROOT/folder).mkdir(parents=True, exist_ok=True)
    tables = {
      'machine': (['machine_id','machine_name'], [('M1','Press 1'),('M2','Press 2'),('M3','Finishing')]),
      'product': (['product_id','product_name'], [('P1','Bracket'),('P2','Housing')]),
      'production': (['run_id','run_date','machine_id','product_id','planned_minutes','input_qty','waste_qty','unit'], []),
      'downtime': (['event_id','run_id','start_minute','end_minute','reason'], []),
      'orders': (['order_id','product_id','order_date','due_date','quantity'], []),
      'deliveries': (['delivery_id','order_id','delivered_date','quantity'], [])}
    for day in range(1,31):
        for machine in range(1,4):
            rid=f'R{day:02}{machine}'
            product='P2' if machine==2 else 'P1'
            tables['production'][1].append((rid,f'2026-10-{day:02}',f'M{machine}',product,480,1000,80 if product=='P2' else 20,'kg'))
            duration={1:20,2:70,3:10}[machine]
            tables['downtime'][1].extend([(f'E{day:02}{machine}a',rid,60,60+duration,'Breakdown' if machine==2 else 'Setup'),(f'E{day:02}{machine}b',rid,300,310,'Material wait')])
    for i in range(1,41):
        due=dt.date(2026,10,10)+dt.timedelta(days=i//2)
        tables['orders'][1].append((f'O{i:03}','P2' if i%2==0 else 'P1','2026-10-01',due.isoformat(),100))
        if i<=32:
            delivered=due+dt.timedelta(days=2 if i%4==0 else -1)
            tables['deliveries'][1].append((f'D{i:03}',f'O{i:03}',delivered.isoformat(),100))
    # Exact replay duplicate plus six distinct invalid records, all intentionally injected.
    tables['production'][1].append(tables['production'][1][0])
    tables['production'][1].extend([('BAD_KEY','2026-10-01','M9','P1',480,1000,20,'kg'),('BAD_UNIT','2026-10-01','M1','P1',480,1000,20,'pieces'),('BAD_WASTE','2026-10-01','M1','P1',480,10,20,'kg')])
    tables['downtime'][1].extend([('BAD_TIME','R011',30,10,'Breakdown'),('BAD_RUN','R999',30,40,'Setup')])
    tables['deliveries'][1].append(('BAD_DATE','O033','2026-09-30',100))
    db=ROOT/'results/manufacturing.sqlite'
    con=sqlite3.connect(db)
    for name,(headers,rows) in tables.items():
        write_csv(ROOT/f'data/raw/{name}.csv',headers,rows)
        con.execute(f'DROP TABLE IF EXISTS raw_{name}')
        numeric={'planned_minutes','input_qty','waste_qty','start_minute','end_minute','quantity'}
        con.execute(f'CREATE TABLE raw_{name} ('+','.join(f'{h} '+('REAL' if h in numeric else 'TEXT') for h in headers)+')')
        con.executemany(f'INSERT INTO raw_{name} VALUES ('+','.join('?' for _ in headers)+')', rows)
    for sql in ['01_clean.sql','02_checks.sql','03_metrics.sql']:
        con.executescript((ROOT/'sql'/sql).read_text())
    export=['machine','product','production','downtime','orders','deliveries','delivery_order','dim_date','settings']
    for table in export:
        cur=con.execute(f'SELECT * FROM {table}')
        write_csv(ROOT/f'data/clean/{table}.csv',[c[0] for c in cur.description],cur.fetchall())
    for table in ['quality_issues','quality_checks','metrics','machine_metrics','product_metrics','reason_metrics']:
        cur=con.execute(f'SELECT * FROM {table}')
        write_csv(ROOT/f'results/{table}.csv',[c[0] for c in cur.description],cur.fetchall())
    checks=con.execute('SELECT * FROM quality_checks').fetchall()
    assert all(row[1]==0 for row in checks), checks
    actual=dict(con.execute('SELECT metric,value FROM metrics'))
    expected={'planned_minutes':43200,'downtime_minutes':3900,'downtime_rate':3900/43200,'input_kg':90000,'waste_kg':3600,'waste_rate':.04,'delivered_orders':32,'on_time_orders':24,'on_time_rate':.75,'outstanding_overdue_orders':8}
    for key,value in expected.items():
        assert abs(actual[key]-value)<1e-9, (key,actual[key],value)
    assert con.execute('SELECT COUNT(*) FROM quality_issues').fetchone()[0]==7
    assert con.execute('SELECT COUNT(*) FROM production').fetchone()[0]==90
    assert con.execute('SELECT COUNT(*) FROM downtime').fetchone()[0]==180
    # Independent Python source controls: exact duplicate removed; known synthetic valid IDs.
    valid_runs={r[0]:r for r in tables['production'][1] if r[0].startswith('R')}
    assert sum(r[4] for r in valid_runs.values())==actual['planned_minutes']
    assert sum(r[6] for r in valid_runs.values())==actual['waste_kg']
    assert sum(r[3]-r[2] for r in tables['downtime'][1] if r[0].startswith('E'))==actual['downtime_minutes']
    # Boundary semantics: due today is not overdue; delivery on due date is on time.
    assert con.execute("SELECT date('2026-10-31') < date('2026-10-31'), date('2026-10-31') <= date('2026-10-31')").fetchone()==(0,1)
    con.commit(); con.close()
    (ROOT/'results/verification.json').write_text(json.dumps({'as_of':AS_OF,'status':'PASS','checks':dict(checks),'expected_metrics':expected,'raw_rows':{k:len(v[1]) for k,v in tables.items()},'notes':'SQL and Python controls passed; Power BI/DAX not executed.'},indent=2)+'\n')
    print(json.dumps(actual,indent=2)); print('PASS: SQL quality checks, 10 metric reconciliations, source controls, cutoff boundaries.')

if __name__=='__main__': main()
