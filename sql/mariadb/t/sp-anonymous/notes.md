# Test: sp-anonymous

## Source
- Original: mysql-test/suite/compat/oracle/t/sp-anonymous.test
  (branch/commit: <fill in>)
- References MDEV-10655 (anonymous blocks)
- Baseline script: sp-anonymous.sql (adapted: --source/--error/--echo lines
  as comments, DELIMITER lines for the mariadb client, DROP TABLE IF EXISTS
  t1 added at the top)
- Variations: variations.sql

## Environment
- MariaDB 12.3.3 (12.3.3-MariaDB-ubu2404), container mariadb-oracle-mode-12,
  sql_mode=ORACLE, database sql_practice, InnoDB.
  From this test on I use a second compose service with a newer server,
  because TO_DATE (type_date work) needs a recent version. Earlier notes
  were run on 11.8.9.
- Oracle comparison: Oracle AI Database 26ai Free 23.26.3.0.0 (Docker),
  container oracle-free, run in SQL*Plus with "/" as block terminator.
- AUTOCOMMIT=OFF for the transaction tests and variations.

## What the test checks
Anonymous blocks (PL/SQL blocks run without CREATE PROCEDURE or CALL):
plain BEGIN NOT ATOMIC, DECLARE ... BEGIN ... END, labels and loops, and
what COMMIT, ROLLBACK and a duplicate-key error do to the surrounding
transaction, with and without an exception handler.

## Baseline result

Part 1: syntax accepted

| ID | Case in the original test | MariaDB (Oracle mode) |
|---|---|---|
| S1 | BEGIN NOT ATOMIC ... END, no declarations | runs |
| S2 | BEGIN NOT ATOMIC with DECLARE ... BEGIN ... END, label, WHILE loop | runs |
| S3 | plain BEGIN ... END and DECLARE ... BEGIN ... END (Oracle style) | runs |

Part 2: transaction behavior. Every case starts with row 10 inserted, then
the block inserts 20 and 30 (T5 and T6: 20 twice, with a primary key).

| ID | What happens | Table after (MariaDB) | Oracle |
|---|---|---|---|
| T1 | ROLLBACK inside the block | empty | same |
| T2 | ROLLBACK after the block | empty | same |
| T3 | COMMIT inside the block | 10, 20, 30 | same |
| T4 | COMMIT after the block | 10, 20, 30 | same |
| T5 | duplicate key, no handler, then COMMIT | error 1062; 10, 20 | different, see ANON-D1 |
| T6 | duplicate key, WHEN DUP_VAL_ON_INDEX THEN NULL, then COMMIT | no error; 10, 20 | same |

- T1 to T6 were repeated with declared variables (a20 INT:=20, a30
  INT:=30). Results are identical, so declaring variables does not change
  transaction behavior. ROLLBACK undoes table changes, not procedural
  variables.
- Oracle column: from documentation (not run), except T5, which was run
  as ANON-D1.
- S1, S2: BEGIN NOT ATOMIC is MariaDB syntax, so no Oracle comparison.

Status: output matches sp-anonymous.result apart from InnoDB/charset.
The one error (1062, T5) is the statement the test expects to fail.

## Variations
| ID | Input | Oracle | MariaDB (Oracle mode) | Same? |
|---|---|---|---|---|
| ANON-D1 | 10 committed; block inserts 20 twice, no handler | ORA-00001, table has 10 (tested) | error 1062, table has 10, 20 | no, silent difference |
| ANON-M1 | same, with EXCEPTION WHEN OTHERS THEN NULL | no error, table has 10, 20 (tested) | no error, table has 10, 20 | yes |

## Gap candidates (ranked by migration impact)
### ANON-G1: unhandled error does not undo the block's earlier work (ANON-D1), high impact
- Oracle treats the whole anonymous block as one statement: if an error
  leaves the block unhandled, everything the block did is rolled back.
  The Oracle run confirms it (ORA-06512 points at the second insert,
  and the first insert of 20 is gone).
- MariaDB only undoes the failing statement. The earlier insert stays in
  the open transaction.
- Both sides raise an error, so the difference is in the data left behind,
  and a client that only checks "did it fail" will not notice.
- Impact: Oracle code that relies on this will leave partial data.
  Migrated code needs explicit ROLLBACK or a handler.
- Not yet checked: whether MariaDB documents this as intended; whether it
  is the same for stored procedures.

## Low-impact differences and matches
- Anonymous blocks start no transaction of their own in either database.
  COMMIT/ROLLBACK inside a block act on the session transaction. This is
  a match (Oracle side from documentation), not a gap.
- When the error is handled inside the block, both keep the earlier insert
  (ANON-M1, tested on both).

## Observations about the method
- DELIMITER is a mariadb client command; SQL*Plus needs "/" instead.
  The two scripts are not interchangeable.
- Oracle mode accepts plain BEGIN/DECLARE blocks; NOT ATOMIC is needed
  only outside Oracle mode.
- Check AUTOCOMMIT before any transaction test. With 1, a later ROLLBACK
  cannot undo anything.
- Each variation starts with COMMIT of a known row (10) for a clean start.

## Next steps
- Jira search: MDEV-10655 and reports on anonymous block rollback.
- Run ANON-D1 inside a stored procedure, to see if the difference belongs
  to anonymous blocks or to all routines (expectation: all routines).
- Nested block: error in the inner block, handler in the outer block.
- PRAGMA AUTONOMOUS_TRANSACTION in a block (expectation: unsupported, untested).
- Re-test ANON-D1 on 13.0 or main.
- SQLCODE, SQLERRM, RAISE_APPLICATION_ERROR go to the exception test.