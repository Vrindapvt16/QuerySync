# Test: sp-anonymous

## Source
- Original: mysql-test/suite/compat/oracle/t/sp-anonymous.test
  (branch/commit: \<fill in>)
- Baseline script: sp-anonymous.sql (runnable copy of the original test)
- Variations: variations.sql

## Environment
- MariaDB 12.3.3, sql_mode=ORACLE, database sql_practice
- Oracle comparison: Oracle AI Database 26ai Free 23.26.3.0.0 (Docker)
- MariaDB storage engine: InnoDB
- AUTOCOMMIT=OFF for transaction and variation tests

## What the test checks
How MariaDB Oracle mode handles anonymous compound statements (anonymous PL/SQL-style blocks).

The test explores:
- Basic anonymous block execution using BEGIN NOT ATOMIC ... END.
- Variable declarations inside anonymous blocks.
- Nested blocks, labels and WHILE loops.
- Transaction behaviour inside anonymous blocks, including COMMIT and ROLLBACK.
- Duplicate-key errors and exception handling inside anonymous blocks.

## Baseline result
- Basic anonymous block containing SELECT executes successfully.
- DECLARE statements work inside anonymous blocks.
- Nested BEGIN/END blocks, labels and WHILE loops execute successfully.
- Variables can be initialized with DEFAULT or :=.
- Blocks execute directly without CREATE PROCEDURE or CALL.

Status: tested successfully in MariaDB Oracle mode for the cases included in the original test.

## Transaction behaviour

### T1: ROLLBACK inside anonymous block
- INSERT 10 before the block.
- INSERT 20 and 30 inside the block.
- ROLLBACK inside the block.
- Result: table is empty.

Explanation: with AUTOCOMMIT=OFF, the ROLLBACK undoes all uncommitted changes in the current transaction, including the insert performed before the block.

### T2: ROLLBACK outside anonymous block
- INSERT 10 before the block.
- INSERT 20 and 30 inside the block.
- ROLLBACK after the block.
- Result: table is empty.

Finding: the anonymous block does not automatically create an independent transaction. Its DML statements participate in the current session transaction.

### T3: COMMIT inside anonymous block
- INSERT 10 before the block.
- INSERT 20 and 30 inside the block.
- COMMIT inside the block.
- Result: table contains 10, 20, 30.

### T4: COMMIT outside anonymous block
- INSERT 10 before the block.
- INSERT 20 and 30 inside the block.
- COMMIT after the block.
- Result: table contains 10, 20, 30.

Finding: COMMIT inside or outside the block commits the current transaction, including successful inserts performed before the block.

### T5: Duplicate-key error without an exception handler
- INSERT 10 before the block.
- Insert 20 successfully inside the block.
- Attempt to insert 20 again.
- The second insert raises error 1062.
- After an explicit COMMIT, the table contains 10 and 20.

Finding: the duplicate-key error does not automatically roll back earlier successful statements in the anonymous block.

### T6: Duplicate-key error with DUP_VAL_ON_INDEX
- Insert 20 twice inside the block.
- Catch the duplicate-key error using WHEN DUP_VAL_ON_INDEX THEN NULL.
- Result after COMMIT: table contains 10 and 20.

Finding: the handler catches the error, and the first successful insert remains.

### T7: Variables and transaction control
- Declare variables and initialize them using :=.
- Use the variables in INSERT statements.
- Test ROLLBACK and COMMIT inside and outside the block.
- Results match the corresponding tests without declarations.

Finding: declaring variables does not change the transaction behaviour of the block. ROLLBACK affects database changes, not the values of procedural variables.

## Variations

### V1: Unhandled duplicate-key error inside an anonymous block

Input:
- Insert 10 and COMMIT.
- Inside the block, insert 20 twice.
- The second insert violates the primary key.

| Database | Result |
|---|---|
| Oracle | 10 |
| MariaDB (Oracle mode) | 10, 20 |

- Oracle raises ORA-00001 and rolls back the successful insert of 20 made inside the failed anonymous block.
- MariaDB raises error 1062 but preserves the first successful insert of 20 in the current transaction.

Status: behavioural difference.

### V2: Duplicate-key error handled with WHEN OTHERS

Input:
- Insert 10 and COMMIT.
- Inside the block, insert 20 twice.
- Catch the error using WHEN OTHERS THEN NULL.

| Database | Result |
|---|---|
| Oracle | 10, 20 |
| MariaDB (Oracle mode) | 10, 20 |

- Both databases catch the duplicate-key error.
- The first successful insert of 20 remains.
- No error escapes the block.

Status: matching behaviour.

## Compatibility findings

### G1: Unhandled exceptions and rollback behaviour
- Oracle rolls back successful DML performed earlier in an anonymous block when an unhandled exception terminates the block.
- MariaDB preserves earlier successful DML statements in the current transaction.
- An explicit MariaDB ROLLBACK can undo those changes if they have not been committed.
- When the exception is handled inside the block, both databases preserve the earlier successful insert in the tested scenario.

Impact: potentially important for Oracle applications that rely on automatic rollback of failed anonymous blocks. Migrated applications may need explicit transaction or error-handling logic.

### G2: Transaction scope of anonymous blocks
- MariaDB anonymous blocks do not create an independent transaction in the tested cases.
- COMMIT and ROLLBACK inside a block affect the current session transaction.
- The same transaction effects occur when COMMIT or ROLLBACK is executed outside the block.

Status: tested MariaDB behaviour. Oracle-side comparison of all transaction variations is not yet documented.

## Observations about the test method
- DELIMITER is a MariaDB command-line client instruction, not SQL executed by the database server. It is needed to send the entire compound block instead of splitting it at internal semicolons.
- Running anonymous blocks directly in SQL*Plus requires the Oracle block terminator `/` on a separate line.
- MariaDB uses BEGIN NOT ATOMIC for anonymous compound statements in Oracle mode; Oracle uses BEGIN ... END.
- The MariaDB baseline test and Oracle comparison scripts are not directly interchangeable because they use different syntax and client commands.
- AUTOCOMMIT must be checked explicitly when testing transaction behaviour. With AUTOCOMMIT=1, successful statements are committed immediately and cannot be undone by a later ROLLBACK.
- The table uses InnoDB so that transaction rollback can be tested.
- An explicit COMMIT before each variation establishes a clean, committed starting value of 10.

## Next steps
- Search Jira for existing reports related to anonymous block exception rollback behaviour.
- Re-test the exception-handling difference on a newer MariaDB build or main.
- Compare additional Oracle transaction-control variations if needed.
- Keep SQLCODE, SQLERRM, RAISE_APPLICATION_ERROR and user-defined exception tests for a separate exception-handling test file.