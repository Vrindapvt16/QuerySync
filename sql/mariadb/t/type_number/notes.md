# Test: type_number

## Source
- Original: mysql-test/suite/compat/oracle/t/type_number.test
  (branch/commit: <fill in>)
- Baseline script: type_number.sql (unchanged copy of the original)
- Variations: variations.sql

## Environment
- MariaDB 11.8.9, sql_mode=ORACLE, database sql_practice
- Oracle comparison: Oracle AI Database 26ai Free 23.26.3.0.0 (Docker)

## What the test checks
How MariaDB's Oracle mode translates the Oracle type NUMBER when a table
is created. SHOW CREATE TABLE shows the type MariaDB actually stored.

## Baseline result (matches type_number.result)
| Declared | MariaDB stores |
|---|---|
| NUMBER | DOUBLE |
| NUMBER(10,2) | DECIMAL(10,2) |

Status: passes. Note: Oracle's NUMBER without precision is an exact
decimal (up to 38 digits); DOUBLE is binary floating point.
Behavioral difference not yet tested (see Next steps).

## Variations
| ID | Input | Oracle | MariaDB (Oracle mode) | Same? |
|---|---|---|---|---|
| V1 | NUMBER(10) | accepted | DECIMAL(10,0) | yes |
| V2 | NUMBER(38) | accepted | DECIMAL(38,0) | yes |
| V3 | NUMBER(39) | rejected, ORA-01727 (precision must be 1 to 38) | accepted, DECIMAL(39,0) | no, MariaDB more permissive (low impact) |
| V4 | NUMBER(5,-2) | accepted | ERROR 1064 syntax error near '-2))' | no, gap |
| V5 | NUMBER(*,2) | accepted | ERROR 1064 syntax error near '*,2))' | no, gap |

Follow-on errors (1146, 1051 after V4 and V5) occur because the CREATE
TABLE failed; they are not separate findings.

## Gap candidates
### G1: negative scale, NUMBER(5,-2)
- Oracle stores: DATA_TYPE NUMBER, DATA_PRECISION 5, DATA_SCALE -2
- Oracle behavior: rounds to the nearest hundred.
  Inserted 12345, 12350, 12349 -> stored 12300, 12400, 12300
- MariaDB: syntax error. Note: DECIMAL has no negative scale, so a fix
  needs a design decision on how to store and round.

### G2: star precision, NUMBER(*,2)
- Oracle stores: DATA_TYPE NUMBER, DATA_PRECISION empty, DATA_SCALE 2
- MariaDB: syntax error. Possible simple fix: treat * as precision 38.

## Low-impact difference
- D1: NUMBER(39) accepted by MariaDB, rejected by Oracle.

## Observation about client scripts
Running the same .sql file in SQL*Plus gives SP2-0735 (SET sql_mode) and
SP2-0158 (SHOW CREATE TABLE). These come from the SQL*Plus client, not
the Oracle database. Oracle has no SHOW CREATE TABLE; the equivalent is
querying user_tab_columns. The test script is MariaDB-specific.


### D2: NUMBER without precision maps to DOUBLE (silent difference)
- Test: INSERT 0.1 and 0.2 into NUMBER column; SELECT SUM(a) = 0.3
  -> MariaDB returns 0 (false). Oracle NUMBER is exact decimal (true).
- Test: INSERT 12345678901234567890123 (23 digits)
  -> MariaDB returns 1.2345678901234568e22 (about 17 digits kept).
  Oracle NUMBER keeps up to 38 digits.
- No error or warning in either case.
- Intentional mapping (matches type_number.result), so a documented
  design difference and a migration risk, not a bug.
- Impact: money, totals and ID columns declared as plain NUMBER.

## Next steps
- Search Jira for existing reports of G1 and G2; link if found
- Re-test on a newer MariaDB build or main
- Test NUMBER (no precision) as DOUBLE: exactness, e.g. 0.1 + 0.2 = 0.3
  and a 23-digit value, compared with Oracle
- Test NUMBER inside PL/SQL variable declarations