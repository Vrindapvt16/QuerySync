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
- `lower_case_table_names`: (fill in with `SHOW VARIABLES LIKE 'lower_case_table_names';`)

## Script

File: `variations.sql`

```sql
SET sql_mode=oracle;

-- Test 1
DELIMITER $$
DECLARE
  x NUMBER := 0.1;
  y NUMBER := 0.2;
BEGIN
  IF x + y = 0.3 THEN
    SELECT 'equal';
  ELSE
    SELECT 'not equal';
  END IF;
END;
$$
DELIMITER ;

-- Test 2
max_sort_length := 1030;
SELECT @@max_sort_length;
max_sort_length := DEFAULT;
SELECT @@max_sort_length;

-- Test 3
SELECT DATE '2026-12-01' - DATE '2026-11-20' AS date_minus_date FROM dual;
SELECT DATEDIFF('2026-12-01', '2026-11-20') AS datediff_days;

-- Test 4
SELECT CASE WHEN '' IS NULL THEN 'null' ELSE 'not null' END AS empty_string FROM dual;

-- Test 5
DROP TABLE IF EXISTS emp;
CREATE TABLE emp (id NUMBER);
SELECT * FROM EMP;
```

## Execution output

```text
(paste the actual output here after running the script)
```

## Observation

Expected results below are based on documented behavior and reasoning. They have not yet been verified against the LAB database.

| # | Test | Oracle | MariaDB (expected) | Root cause |
|---|---|---|---|---|
| 1 | `0.1 + 0.2 = 0.3` with `NUMBER` | `equal` | `not equal` | `NUMBER` maps to `DOUBLE` (binary floating point), Oracle uses exact decimal |
| 2 | `max_sort_length := 1030;` | Error (no such variable) | Sets the system variable | MariaDB extension from MDEV-10411 |
| 3 | `DATE - DATE` | Days between dates (`11`) | A plain number (about `81`); `DATEDIFF` gives `11` | Dates become `YYYYMMDD` numbers in arithmetic |
| 4 | `'' IS NULL` | `null` | `not null` | Empty string is NULL only in Oracle |
| 5 | `SELECT * FROM EMP` after `CREATE TABLE emp` | Works | May fail on Linux or Docker | Table names follow file system case rules |

### Details

**1. NUMBER vs DOUBLE**
Oracle stores `NUMBER` as a base-10 decimal, so 0.1 + 0.2 equals 0.3 exactly. MariaDB converts `NUMBER` to `DOUBLE`, and binary floating point cannot represent 0.1 or 0.2 exactly, so the sum is slightly off from 0.3. Fix: declare `NUMBER(10,2)`, which becomes `DECIMAL(10,2)`.

**2. System variable assignment**
In Oracle, `:=` only assigns to declared PL/SQL variables. MariaDB falls back to system variables when no local variable matches. `:= DEFAULT` resets the session value to the current global value. A typo that matches a system variable name could change a setting without an error.

**3. Date subtraction**
Oracle returns the number of days. MariaDB may convert dates to `YYYYMMDD` numbers, so `20261201 - 20261120 = 81`. Use `DATEDIFF()` or `TIMESTAMPDIFF()` for correct day counts. Whether ORACLE mode changes this in a given version is not confirmed.

**4. Empty string and NULL**
In Oracle `''` and `NULL` are identical, so `LENGTH('')` is NULL and `WHERE col = ''` never matches. In MariaDB they are different values by default. An `EMPTY_STRING_IS_NULL` mode flag may exist, but the version and exact behavior are not confirmed.

**5. Identifier case**
Oracle converts unquoted names to uppercase, so `emp` and `EMP` are the same table. MariaDB tables are files, so the result depends on `lower_case_table_names` (0 on Linux, 1 on Windows, 2 on macOS).

## Summary

| Category | Tests |
|---|---|
| Datatype mapping | 1 |
| Syntax extension | 2 |
| Operator semantics | 3 |
| Value semantics | 4 |
| Identifier handling | 5 |

**Execution status:** Pending (script not yet run).

**Oracle comparison:** Pending.