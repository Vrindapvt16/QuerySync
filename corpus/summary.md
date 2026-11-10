# Findings: Oracle HR schema → MariaDB (sql_mode=ORACLE)

Scope: layer 1, `hr_create.sql` (tables, constraints, sequences, view, indexes, comments).
Layers 2 (`hr_populate.sql`) and 3 (`hr_code.sql`) are documented in their own sections later.

## 1. Environment

- MariaDB 11.8.9 (Docker, `mariadb-oracle-mode` container)
- `sql_mode` in session: `PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ORACLE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,SIMULTANEOUS_ASSIGNMENT`
- Source: Oracle sample schemas, Human Resources (schema version 21, release 03-FEB-2022), `sql/oracle/human_resources/`
- Oracle originals are never edited. Working copies are in `sql/mariadb/human_resources_migrated/`.

## 2. Method

1. Reset: `DROP DATABASE IF EXISTS hr; CREATE DATABASE hr;`
2. Run the script in Oracle mode with `--force` (continue after errors).
3. Save errors only to `logs/<step>.err`, count with `find /c "ERROR"`.
4. One change per step, one commit per step.
5. Classify each error: real finding / cascade (ignore) / environment problem.

Run with: `run.bat <step_name>`

## 3. Progress log

| Step | Change | Errors | Log |
|---|---|---|---|
| 0 | original, unchanged | TODO (re-run to count) | `create_step0_original` |
| 1 | removed `SET`, `rem` → `--`, removed `Prompt` | 75 | `create_step1_sqlplus.err` |
| 2 | remove constraint names from `NOT NULL` (13 places) | | `create_step2_notnull.err` |
| 3 | remove `ORGANIZATION INDEX` | | |
| 4 | | | |
| 5 | explicit columns in `REFERENCES` | | |
| 6 | remove `WITH READ ONLY` | | |
| 7 | handle `COMMENT ON` (42 statements) | | |

## 4. Step notes (diary)

### Step 0: original script
- Result: a wall of errors, mostly noise.
- Cause: SQL*Plus lines (`SET`, `rem`, `Prompt`) have no semicolon, so the client glued them onto the next real statement and the server rejected the whole thing. No `CREATE TABLE` was actually evaluated.
- Takeaway: with SQL*Plus scripts, a single unrecognised line can break the next valid statement, so error messages mislead.

### Step 1: remove SQL*Plus client commands
- 75 errors, from four root causes:

| Error | Count | Real finding? |
|---|---|---|
| 1064 near `NOT NULL` (all 7 `CREATE TABLE`) | 7 | yes, named NOT NULL constraints |
| 1064 near `READ ONLY` (view) | 1 | yes, `WITH READ ONLY` |
| 1146 table doesn't exist | 25 | no, cascade from the failed tables |
| 1064 near `ON TABLE` / `ON COLUMN` | 42 | yes, `COMMENT ON` (7 table + 35 column) |

- The 3 `CREATE SEQUENCE` statements produced no error, so they were accepted in their original Oracle form.
- Parse errors stop at the first problem in a statement, so other errors may be hidden behind these (for example `ORGANIZATION INDEX` was not reached).

## 5. Compatibility findings

Status: **Confirmed** = I saw it in a run. **Pending** = not tested yet.

| # | Oracle construct | MariaDB result | Status | Evidence | Workaround |
|---|---|---|---|---|---|
| 1 | SQL*Plus commands (`SET`, `Prompt`, `rem`) | syntax error, and breaks the next statement | Confirmed | step 0 and 1 logs | remove, use `--` comments |
| 2 | `COMMENT ON TABLE/COLUMN` | not supported (42 errors) | Confirmed | step 1 log | use `COMMENT` clause in table definition (pending) |
| 3 | Named `NOT NULL` (`CONSTRAINT x NOT NULL`) | error 1064 | Confirmed | step 1 log, scratch test | plain `NOT NULL` |
| 4 | `WITH READ ONLY` on view | error 1064 | Confirmed | step 1 log, scratch test | remove (view becomes updatable, a behaviour change) |
| 5 | `ORGANIZATION INDEX` | error 1064 | Confirmed in scratch test; not yet reached in real file | scratch test | remove |
| 6 | `NUMBER(p,s)` | becomes `decimal(p,s)` | Confirmed | `SHOW CREATE TABLE employees` | none needed |
| 7 | `NUMBER` (no size) | becomes `double` (floating point), silent semantic change | Confirmed | `SHOW CREATE TABLE regions` | give explicit precision |
| 8 | `DATE` | becomes `datetime` (keeps time part) | Confirmed | `DESCRIBE job_history` | none needed |
| 9 | `VARCHAR2(n)`, `CHAR(n)` | accepted, `varchar(n)` | Confirmed | `SHOW CREATE TABLE` | none needed |
| 10 | `CREATE SEQUENCE ... NOCACHE NOCYCLE` | accepted unchanged | Confirmed | no error in step 1 log | none needed |
| 11 | Sequences in `SHOW TABLES` | listed as objects, type `SEQUENCE`, engine InnoDB | Confirmed | `information_schema.tables` | note for migrators |
| 12 | `CHECK` constraints | accepted | Confirmed | `SHOW CREATE TABLE employees` | none needed |
| 13 | Circular foreign key (employees ↔ departments) | accepted once both tables exist | Confirmed | clean working run | add FK after both tables |
| 14 | `ADD ( CONSTRAINT ... CHECK ... )` parenthesized form | works (my prediction was wrong) | Confirmed for CHECK only | scratch test | none |
| 15 | `ADD ( CONSTRAINT ... PRIMARY KEY / FOREIGN KEY )` parenthesized | | Pending | | |
| 16 | `REFERENCES table` without column list | error 150 in a scratch test; cause not isolated (column list vs inline form) | Pending | scratch test `t4` | explicit column |
| 17 | `CREATE UNIQUE INDEX` followed by `ADD PRIMARY KEY` on same column | | Pending | `SHOW INDEX` after step 2 | |
| 18 | Old-style comma joins in a view | view created | Confirmed | clean working run | none needed |

## 6. Observations

- Oracle mode includes `ANSI_QUOTES`: double quotes mean identifiers, not strings. `SHOW CREATE TABLE` output is double-quoted.
- `SHOW CREATE TABLE` does not show `ENGINE` (likely due to `NO_TABLE_OPTIONS` in the mode). All tables are InnoDB (checked via `information_schema.tables`).
- Leftover tables from earlier experiments caused false errors ("already exists", "key column doesn't exist"). Always test in a freshly created database.

## 7. Open questions

- Why did 7 `CREATE TABLE` statements return 1 warning in the earlier clean run? A single test table showed none. Not reproduced yet.
- Does the original `CREATE UNIQUE INDEX` + `ADD PRIMARY KEY` pair create two indexes? (#17)

## 8. Questions for my teacher

1. Is the main deliverable a migration guide or a compatibility report? How much weight on a second code source beyond HR?
2. Silent changes like `NUMBER` → `double`: how deep should I go?
3. For unsupported features (such as `WITH READ ONLY`), is removing them acceptable, or should I find a MariaDB workaround for each?
4. Should I verify behaviour against a real Oracle run, or is the documentation enough?
5. `COMMENT ON`: delete, or convert to `COMMENT` clauses?

## 9. Next

- Step 2: `CONSTRAINT\s+\w+\s+NOT NULL` → `NOT NULL` (13 matches), then `SHOW INDEX FROM regions;`


Row 17: Confirmed: regions ends up with PRIMARY and reg_id_pk on the same column, a redundant index. Workaround: remove the standalone CREATE UNIQUE INDEX for primary keys.
Row 5: Confirmed in the real file (line 73, error 1064 near INDEX).
Progress table, step 2: 47 errors.

