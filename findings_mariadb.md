## Test 0: employees table (MariaDB 11.8.9, sql_mode=ORACLE)

| Check | Oracle | MariaDB |
|---|---|---|
| CREATE TABLE with NUMBER, VARCHAR2 | created | created, no errors |
| NUMBER column type | NUMBER | double |
| VARCHAR2(50) | VARCHAR2(50) | varchar(50) |
| PRIMARY KEY | ok | ok |
| Identifier quoting in SHOW CREATE TABLE | n/a | double quotes (ANSI_QUOTES in sql_mode) |


## Test 2: emp_pkg (spec + body, one function) — MariaDB 11.8.9, sql_mode=ORACLE

| Check | Oracle | MariaDB |
|---|---|---|
| CREATE PACKAGE (spec) | created | created |
| CREATE PACKAGE BODY | created | created |
| %TYPE on a column | works | works |
| EXCEPTION WHEN NO_DATA_FOUND | works | works |
| pkg.get_salary(1) | 5000 | 5000 |
| pkg.get_salary(99) | NULL | NULL |
| Code changes needed | none | none (DELIMITER is a client command, not code) |



## Test: package state (MariaDB 11.8.9, sql_mode=ORACLE)

The Oracle package was run on MariaDB with no changes inside the code. Only `DELIMITER`
was added, which is a `mariadb` client command, not part of the code.

| Check | Oracle | MariaDB |
|---|---|---|
| Package body variable `g_calls NUMBER := 0;` | accepted | accepted |
| Counter after two calls (separate statements, same session) | 2 | 2 |
| Second run in the same session, no recompile | continues (4) | continues (4) |
| After reconnecting | restarts at 0 | restarts at 0 |
| `pkg.call_count()` with parentheses | works | works |
| `pkg.call_count` without parentheses | works | untested |

Not tested yet on MariaDB: reading a private package variable from outside, the
initialization block, and another session redefining the package (Oracle gave ORA-04068).


new findings woow, 
## Test: variables and constants in the package spec (MariaDB 11.8.9 vs Oracle Free 23.26)

| Check | Oracle | MariaDB |
|---|---|---|
| Spec with a variable (`g_x NUMBER;` or `g_pub NUMBER := 7;`) | accepted | ERROR 1064 syntax error |
| Spec with a constant (`c_x CONSTANT NUMBER := 7;`) | accepted | ERROR 1064 syntax error |
| Spec with only a function declaration | accepted | accepted |
| Variable declared in the body | accepted | accepted (state kept per session) |
| `SELECT emp_pkg.g_calls` (body-only variable) | PLS-00302 "component must be declared" | ERROR 1109 Unknown table 'emp_pkg' |

Consequence: Oracle code with spec constants or variables does not load unchanged.