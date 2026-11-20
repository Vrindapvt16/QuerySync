# Test: variables

## Environment
- MariaDB: (version not shown in output)
- SQL mode: ORACLE
- Database: LAB

## Execution output

```text
Query OK, 0 rows affected

Query OK, 0 rows affected

+-------------------+
| @@max_sort_length |
+-------------------+
|              1030 |
+-------------------+

Query OK, 0 rows affected

Query OK, 0 rows affected

+-------------------+-----------------+
| @@max_sort_length | max_sort_length |
+-------------------+-----------------+
|              1030 |            1031 |
+-------------------+-----------------+

+-------------------+-----------------+
| @@max_sort_length | max_sort_length |
+-------------------+-----------------+
|              1030 |            1032 |
+-------------------+-----------------+

+-------------------+
| @@max_sort_length |
+-------------------+
|              1030 |
+-------------------+

Query OK, 0 rows affected

Query OK, 0 rows affected
```

## Observation

| Oracle assignment | MariaDB behavior |
|---|---|
| `max_sort_length:=1030;` (no local variable in scope) | Sets the system variable (`@@max_sort_length` = 1030) |
| `max_sort_length:=1032;` (after local `DECLARE`) | Sets only the local SP variable; `@@max_sort_length` stays 1030 |
| `max_sort_length:=DEFAULT;` (after local scope ends) | Resets the system variable to its default |

| Scenario | `@@max_sort_length` | `max_sort_length` (local) |
|---|---|---|
| Local initialized with `DEFAULT 1031` | 1030 | 1031 |
| After `max_sort_length:=1032` in inner block | 1030 | 1032 |
| After inner block ends | 1030 | out of scope |

SP variables shadow system variables in `:=` assignments. The system variable is only affected when no local variable of the same name is in scope.

**Execution status:** Successful.

**Oracle comparison:** Pending.



# Test: variations

Oracle code that behaves differently in MariaDB (ORACLE mode).

## Environment
- MariaDB: (version not recorded, fill in with `SELECT VERSION();`)
- SQL mode: ORACLE
- Database: LAB
- Platform: most likely Linux (Docker), see Test 5
- `lower_case_table_names`: not checked, probably 0 (fill in with `SHOW VARIABLES LIKE 'lower_case_table_names';`)


## Execution output

```text
Query OK, 0 rows affected

+---------------------------------+
| test                            |
+---------------------------------+
| --- Test 1: 0.1 + 0.2 = 0.3 --- |
+---------------------------------+

+-----------+
| not equal |
+-----------+
| not equal |
+-----------+

Query OK, 0 rows affected

+--------------------------------------------+
| test                                       |
+--------------------------------------------+
| --- Test 2: system variable assignment --- |
+--------------------------------------------+

Query OK, 0 rows affected

+-------------------+
| @@max_sort_length |
+-------------------+
|              1030 |
+-------------------+

Query OK, 0 rows affected

+-------------------+
| @@max_sort_length |
+-------------------+
|              1024 |
+-------------------+

+----------------------------------+
| test                             |
+----------------------------------+
| --- Test 3: date subtraction --- |
+----------------------------------+

+-----------------+
| date_minus_date |
+-----------------+
|              81 |
+-----------------+

+---------------+
| datediff_days |
+---------------+
|            11 |
+---------------+

+---------------------------------------+
| test                                  |
+---------------------------------------+
| --- Test 4: empty string is NULL? --- |
+---------------------------------------+

+--------------+
| empty_string |
+--------------+
| not null     |
+--------------+

+---------------------------------+
| test                            |
+---------------------------------+
| --- Test 5: table name case --- |
+---------------------------------+

Query OK, 0 rows affected

Query OK, 0 rows affected

--------------
SELECT * FROM EMP
--------------

ERROR 1146 (42S02) at line 65 in file: '/scripts/t/variables/variations.sql': Table 'LAB.EMP' doesn't exist
```

## Observation

All five results matched the expected behavior.

| # | Test | Oracle | MariaDB (actual) | Match with expectation |
|---|---|---|---|---|
| 1 | `0.1 + 0.2 = 0.3` with `NUMBER` | `equal` | `not equal` | Yes |
| 2 | `max_sort_length := 1030;` | Error (no such variable) | Set to 1030, `DEFAULT` reset it to 1024 | Yes |
| 3 | `DATE - DATE` | Days between dates (`11`) | `81`; `DATEDIFF` gave `11` | Yes |
| 4 | `'' IS NULL` | `null` | `not null` | Yes |
| 5 | `SELECT * FROM EMP` after `CREATE TABLE emp` | Works | Error 1146, table `LAB.EMP` doesn't exist | Yes |

### Details

**1. NUMBER vs DOUBLE**
The result was `not equal`. Oracle stores `NUMBER` as a base-10 decimal, so 0.1 + 0.2 equals 0.3 exactly. MariaDB converts `NUMBER` to `DOUBLE`, and binary floating point cannot represent 0.1 or 0.2 exactly, so the sum is slightly off from 0.3. Fix: declare `NUMBER(10,2)`, which becomes `DECIMAL(10,2)`.
The column header in the output is also `not equal`, because a `SELECT` of a literal uses the literal as its column name. This is cosmetic.

**2. System variable assignment**
In Oracle, `:=` only assigns to declared PL/SQL variables. MariaDB falls back to system variables when no local variable matches, so `max_sort_length` became 1030. `:= DEFAULT` then reset the session value to the global value, which was 1024 here. A typo that matches a system variable name could change a setting without an error.

**3. Date subtraction**
MariaDB turned the dates into `YYYYMMDD` numbers, so `20261201 - 20261120 = 81`. Oracle returns the number of days (`11`). `DATEDIFF()` returned the correct `11`. Use `DATEDIFF()` or `TIMESTAMPDIFF()` when porting date arithmetic.

**4. Empty string and NULL**
By default MariaDB treats `''` as a value, not NULL, so the result was `not null`. In Oracle `''` and `NULL` are identical, which changes behavior of `LENGTH('')`, `WHERE col = ''` and `IS NULL` checks. An `EMPTY_STRING_IS_NULL` mode flag may exist, but it was not tested.

**5. Identifier case**
`CREATE TABLE emp` succeeded, but `SELECT * FROM EMP` failed with error 1146. Oracle converts unquoted names to uppercase, so `emp` and `EMP` are the same table. This MariaDB server keeps the case of table names, which points to Linux (probably Docker) with `lower_case_table_names=0`. The error stopped the script, which is why this test is placed last.

## Summary

| Category | Tests |
|---|---|
| Datatype mapping | 1 |
| Syntax extension | 2 |
| Operator semantics | 3 |
| Value semantics | 4 |
| Identifier handling | 5 |

**Execution status:** Completed. Tests 1 to 4 ran successfully, Test 5 failed with an error that confirms the difference being tested.

**Oracle comparison:** Pending (expected Oracle results are from documentation, not from a real Oracle run).