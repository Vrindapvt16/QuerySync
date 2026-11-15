# HR schema migration: Oracle to MariaDB (sql_mode=ORACLE)

Project area 18, Oracle compatibility and incremental migration.
Last updated: 2026-11-15.

## How to read this file

- **Confirmed** means I saw it happen in a run (an error message, a count, or a query result).
- **Not tested** means it is my reasoning only and still needs a run.
- Each finding has the same four lines: what Oracle has, what MariaDB did, the fix, and the evidence.

## Result in one paragraph

The three HR scripts (`hr_create.sql`, `hr_populate.sql`, `hr_code.sql`) now load into MariaDB with 0 errors. The row counts match Oracle's (5, 25, 27, 23, 107, 19, 10), and the history trigger really writes a row. Getting there needed changes in every file. Most of them were not PL/SQL: SQL*Plus commands, table options, and a few missing features. Two results are worth remembering. First, some things change silently without any error (`NUMBER` becomes `double`, a duplicate index appears). Second, a script that loads with 0 errors can still be wrong, because stored code is only checked when it runs.

## Environment

- MariaDB 11.8.9 in Docker (`mariadb-oracle-mode`).
- `sql_mode` in the session: `PIPES_AS_CONCAT, ANSI_QUOTES, IGNORE_SPACE, ORACLE, NO_KEY_OPTIONS, NO_TABLE_OPTIONS, NO_FIELD_OPTIONS, NO_AUTO_CREATE_USER, SIMULTANEOUS_ASSIGNMENT`.
- Oracle Free 23.26 in Docker (`oracle-free`, database `FREEPDB1`), used for comparison.
- Source: Oracle's HR sample schema, version 21 (see `SOURCES.MD`). The Oracle originals are never edited. Working copies are in `sql/mariadb/human_resources_migrated/`.

## Method

1. Reset the database: `DROP DATABASE IF EXISTS hr; CREATE DATABASE hr;`
2. Run the script in Oracle mode with `--force`, so it continues after an error.
3. Save only the errors to a log file and count them.
4. Change one thing at a time and commit each change.
5. Sort every error into one of three kinds: a real finding, a cascade from an earlier error (ignore it), or a problem with my environment.
6. Never trust "0 errors" alone. Check the result with `SHOW CREATE TABLE`, row counts, and a test run.

---

## Part 1: the installer (`hr_install.sql`, `hr_uninstall.sql`)

These were not ported. They are Oracle administration tooling, not database code. Judged by reading, not by running, except where noted.

- **SQL*Plus commands:** `SET`, `PROMPT`, `ACCEPT`, `SPOOL`, `WHENEVER SQLERROR`, `@@file`, and `&variable` substitution. These belong to the SQL*Plus client. MariaDB has no equivalent inside SQL.
- **User, tablespace and grant setup:** `CREATE USER ... QUOTA UNLIMITED ON tablespace` and the `GRANT` list are Oracle account management.
- **Oracle data dictionary views:** `all_users`, `dba_tablespaces`, `database_properties`.
  - Confirmed for `all_users`: `ERROR 1146: Table 'hr.all_users' doesn't exist`. The other two were not tested.
- **Replacement:** a short MariaDB script that drops and recreates the database and then runs the three files in order. The `run.bat` files do this.

---

## Part 2: schema (`hr_create.sql`)

Errors per step, with one change each time:

| Step | Change | Errors |
|---|---|---|
| 1 | Remove SQL*Plus commands | 75 |
| 2 | Remove names from `NOT NULL` | 47 |
| 3 | Remove `ORGANIZATION INDEX` | 44 |
| 4 | Split the `employees` ALTER | 44 |
| 5 | Add the column name to `emp_manager_fk` | 43 |
| 6 and 7 | Remove `WITH READ ONLY` and `COMMENT ON` | 0 |

The original script was not counted (step 0). Its errors were mostly misleading, see finding 1.

### Things that do not work

**1. SQL*Plus lines (`rem`, `Prompt`, `SET`)**
- Oracle: client commands without a semicolon.
- MariaDB: error 1064. The client glues each such line onto the next real statement, so the server rejects both. In the first run no `CREATE TABLE` was actually evaluated, and nearly every later error was a cascade.
- Fix: change `rem` to `--`, delete `Prompt` and `SET` lines.
- Evidence: step 0 and step 1 logs.
- Lesson: in SQL*Plus scripts one unknown line can hide the real errors that follow it.

**2. Named `NOT NULL` constraints**
- Oracle: `CONSTRAINT region_id_nn NOT NULL`
- MariaDB: error 1064 near `NOT NULL`. This hit all 7 tables, 13 places in total.
- Fix: plain `NOT NULL`.
- Evidence: step 1 log, then step 2 (75 down to 47).

**3. `ORGANIZATION INDEX`**
- Oracle: stores a table as an index, used on `countries`.
- MariaDB: error 1064 near `INDEX`.
- Fix: remove it.
- Evidence: step 2 log (line 73), gone in step 3.

**4. `WITH READ ONLY` on the view**
- Oracle: makes `emp_details_view` read-only.
- MariaDB: error 1064 near `READ ONLY`.
- Fix: removed. The view is now updatable, which is a change in behaviour.
- Evidence: logs from step 1 to step 5.
- Idea, not tested: give users `SELECT` only, to keep the original intent.

**5. `COMMENT ON TABLE` and `COMMENT ON COLUMN`**
- Oracle: 42 comment statements (7 on tables, 35 on columns).
- MariaDB: error 1064 near `ON TABLE` or `ON COLUMN`.
- Fix: the whole section was removed, so the documentation inside the database is lost.
- Not tested: moving each comment into a `COMMENT` clause of its `CREATE TABLE`.
- Evidence: step 1 log.

### Things that fail without a clear message

**6. A failed `ALTER TABLE ... ADD ( ... )` applies none of its clauses**
- Oracle: one ALTER with four clauses (primary key and three foreign keys) for `employees`.
- MariaDB: the whole statement failed with error 150, and `employees` was left with no primary key, no foreign keys, and a nullable `employee_id`. The script carried on without any further sign.
- Fix: split it into four separate statements. Only one then failed.
- Evidence: `SHOW CREATE TABLE employees` after step 2, and the step 4 log.

**7. A self-referencing foreign key failed in the script**
- Oracle: `REFERENCES employees` with no column name.
- MariaDB: error 150 in the script (the `emp_manager_fk` line).
- Fix: name the column, `REFERENCES employees (employee_id)`.
- Cause not found. The same form worked when typed at the prompt, both before and after the primary key existed. The same form without a column name also worked for `departments` and `jobs` in the script.
- Evidence: step 4 log, and four tests at the prompt.

**8. Error 150 can mean "the table I point at does not exist"**
- When `countries` failed to create, the `locations` foreign key failed with error 150, which says "incorrectly formed".
- Evidence: step 2 log, and it disappeared in step 3 when `countries` was created.

**9. A duplicate index**
- Oracle: `CREATE UNIQUE INDEX x` followed by `ADD CONSTRAINT x PRIMARY KEY` on the same column gives one index.
- MariaDB: two identical unique indexes (`PRIMARY` and the one you created). Seen on `regions`, `employees` and `job_history`.
- Fix: delete the standalone `CREATE UNIQUE INDEX` lines for primary keys. Not yet done, so the migrated script still creates them.
- Evidence: `SHOW INDEX FROM regions`, and `SHOW CREATE TABLE` for the other two.

### Things that change type

**10. Data types**
- `NUMBER(p,s)` becomes `decimal(p,s)`. For example `NUMBER(6)` becomes `decimal(6,0)`.
- `NUMBER` with no size becomes `double`, which is floating point. `regions.region_id` is a `double` primary key. Oracle's `NUMBER` is exact, so this is a silent change. Give the column an explicit size.
- `DATE` becomes `datetime`, so it keeps a time part. Hire dates show `00:00:00`. That matches Oracle, where `DATE` also holds a time.
- `VARCHAR2(n)` becomes `varchar(n)`, and `CHAR(n)` is accepted.
- Evidence: `SHOW CREATE TABLE`, `DESCRIBE job_history`.

### Things that work as they are

- `CREATE SEQUENCE ... START WITH ... INCREMENT BY ... NOCACHE NOCYCLE` was accepted unchanged. Sequences show up in `SHOW TABLES` as type `SEQUENCE`, stored in InnoDB.
- `CHECK` constraints, including `end_date > start_date`.
- A composite primary key.
- The circular foreign key between `employees` and `departments`, once both tables exist.
- Old-style comma joins with `WHERE` inside a view.
- The parenthesized `ALTER TABLE ... ADD ( CONSTRAINT ... )` form worked for `CHECK`, `PRIMARY KEY` and `FOREIGN KEY` with named columns.

### Notes on Oracle mode

- `ANSI_QUOTES` is on, so double quotes mean identifiers, not strings. `SHOW CREATE TABLE` prints names in double quotes.
- `SHOW CREATE TABLE` hides the engine because `NO_TABLE_OPTIONS` is set. All tables are InnoDB (checked in `information_schema.tables`).

---

## Part 3: data (`hr_populate.sql`)

Errors: 2 in step 1 (both `TO_DATE`), 0 in step 2.

**11. Anonymous PL/SQL blocks work**
- Oracle: data inserted inside `BEGIN ... END; /` blocks.
- MariaDB: works with `DELIMITER /` at the top and `DELIMITER ;` at the end. Without it, the client would cut each block at its first semicolon.
- Evidence: after step 1, five tables loaded completely (regions 5, countries 25, departments 27, locations 23, jobs 19).

**12. `TO_DATE` does not exist**
- Oracle: `TO_DATE('17-06-2013', 'dd-MM-yyyy')`
- MariaDB: `ERROR 1305: FUNCTION hr.TO_DATE does not exist`. Oracle mode does not provide this function.
- Fix: `STR_TO_DATE('17-06-2013', '%d-%m-%Y')`, 127 places (107 hire dates and 20 job history dates). The format letters differ: `dd-MM-yyyy` becomes `%d-%m-%Y`.
- Evidence: step 1 log. After the fix, 0 errors and `hire_date` of employee 100 is 2013-06-17 00:00:00.

**13. A failing statement stops its block**
- When a block hit the `TO_DATE` error, no rows from that block were loaded (employees 0, job_history 0), while the other blocks loaded fully.
- Not tested: whether rows inserted before the failing statement are rolled back. The failing statement was the first one in each block, so this run cannot show it.

**14. `ALTER TABLE ... DISABLE / ENABLE CONSTRAINT`**
- Oracle: `dept_mgr_fk` is disabled during the load and enabled afterwards, because `departments` and `employees` point at each other.
- MariaDB: removed. The load runs between `SET foreign_key_checks=0;` and `SET foreign_key_checks=1;` instead.
- Not tested: whether MariaDB rejects `DISABLE CONSTRAINT` at the prompt.
- Important difference: Oracle's `ENABLE` checks the rows that are already there. Turning `foreign_key_checks` back on does not. I checked by hand: no department has a manager who does not exist (the query returned 0).

**15. Counts after the load**
- regions 5, countries 25, departments 27, locations 23, employees 107, jobs 19, job_history 10. All match Oracle's own verification numbers.

**16. Other SQL*Plus lines**
- `SET VERIFY OFF`, `ALTER SESSION SET NLS_LANGUAGE=American`, `Prompt` and `rem` were removed. Same cause as finding 1.

---

## Part 4: code (`hr_code.sql`)

Errors: 2 in step 1, 3 in step 2 (a missing word), 0 afterwards.

**17. A statement-level trigger on three events**
- Oracle: `BEFORE INSERT OR UPDATE OR DELETE ON employees`, with no `FOR EACH ROW`.
- MariaDB: error 1064. Three small tests at the prompt:
  - without `FOR EACH ROW`: fails
  - with `FOR EACH ROW`, one event: works
  - with `FOR EACH ROW`, `INSERT OR UPDATE` in one trigger: fails
- Fix: three triggers, one per event, each `FOR EACH ROW`, each with its own name (`secure_employees_ins`, `_upd`, `_del`).
- Mistakes I made on the way: leaving out `ON employees`, and giving all three triggers the same name. With `CREATE OR REPLACE` the same name would silently replace the earlier ones.
- Difference in behaviour (reasoning, not tested): the Oracle trigger runs once per statement and the MariaDB ones once per row.

**18. `ALTER TRIGGER ... DISABLE`**
- Oracle: `secure_employees` is created and immediately disabled, so it never blocks anything.
- MariaDB: error 1064. There is no equivalent statement.
- Result: the three MariaDB triggers are active. They call `secure_dml`, which should block changes to `employees` outside 08:00 to 18:00 and at weekends.
- Not yet tested: the blocked update. Not yet confirmed: that Oracle shows the trigger as `DISABLED`.
- Open question for the teacher: should a faithful migration leave these triggers out, or find a way to disable them?
- Nearest equivalent: drop the three triggers.

**19. `RAISE_APPLICATION_ERROR` loads without an error**
- Oracle: `secure_dml` calls `RAISE_APPLICATION_ERROR(-20205, '...')` outside office hours.
- MariaDB: `hr_code.sql` loaded with no error and no edit to that line. The procedure only runs the call when the time check fails, and MariaDB does not check it until then. During office hours `secure_dml` ran silently.
- This means "loads with 0 errors" does not prove the code works. The call has not run yet, so whether it works is still open.
- Candidate replacement, not yet tried here: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...'`.

**20. What works in procedures and triggers**
- `CREATE OR REPLACE PROCEDURE ... IS ... END name;` loads.
- `%type` in parameters (`job_history.employee_id%type`) works. The procedure ran from the trigger.
- `:old.column` and `sysdate` inside a trigger work.
- `TO_CHAR(SYSDATE, 'HH24:MI')` and `TO_CHAR(SYSDATE, 'DY')` work. The day name comes back as `Wed` or `Sun`, not upper case.
- The trigger `update_job_history` fires and writes a history row. Updating `department_id` of employee 104 took `job_history` from 10 rows to 11. After a rollback it was back to 10.
- `AFTER UPDATE OF job_id, department_id` loads without an error. Whether the column list limits when the trigger fires has not been tested.

---

## Part 5: the Oracle side

- HR is installed in `oracle-free` (account `HR`, 7 tables). The installer ran completely.
- My practice account `BEKI` has 1 table. Both accounts have a table called `EMPLOYEES`, and they are different tables. Always check `SHOW USER` first.
- Confirmed with `dba_users` and `dba_tables`.

---

## Still to do

- Run the blocked-update test in MariaDB (finding 18 and 19) and write down the exact error.
- Test whether the `UPDATE OF` column list limits the trigger (update `phone_number` and see whether `job_history` grows), in both databases.
- Confirm that `SECURE_EMPLOYEES` is `DISABLED` in Oracle (`user_triggers`).
- Compare the same tests in Oracle and MariaDB side by side.
- Check that the three logs in `logs/final` are empty (`prereq_create`, `prereq_populate`, and the code log).
- Optional: remove the duplicate indexes, convert the 42 comments, find the cause of finding 7.
- Open: one warning appeared on the seven `CREATE TABLE` statements in an early clean run and could not be reproduced.