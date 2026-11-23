# Test: type_date

## Source
- Original: mysql-test/suite/compat/oracle/t/type_date.test
  (branch/commit: <fill in>)
- References MDEV-19632 (qualified types and replication) and MDEV-23353
  (qualified data types in stored programs)
- Baseline script: type_date.sql (adapted: SET sql_mode='' for plain
  MariaDB mode, MariaDB-client DELIMITER lines, --echo/--error as comments)
- Variations: variations.sql

## Environment
- MariaDB 11.8.9, database sql_practice
- Server global sql_mode contains ORACLE, so SET sql_mode=DEFAULT gives
  Oracle mode here; the scripts use SET sql_mode='' for plain mode.
- No Oracle run was done for these DATE tests.

## What the test checks
Oracle's DATE holds date and time; MariaDB's DATE holds only the date.
The test checks how MariaDB resolves the word DATE depending on sql_mode,
how the qualified names (mariadb_schema.DATE, oracle_schema.DATE,
maxdb_schema.DATE) fix the meaning, whether ALTER understands them, and
whether they work inside stored programs.

## Baseline result
| Declaration | Created in plain mode | Created in Oracle mode |
|---|---|---|
| DATE | date | datetime |
| mariadb_schema.DATE | date | date |
| oracle_schema.DATE | datetime | datetime |
| maxdb_schema.DATE | date | date |

- Oracle mode prints real dates as mariadb_schema.date in SHOW CREATE
  TABLE; switching mode changes the display, not the stored type.
- ALTER MODIFY/CHANGE with qualifiers behaves as in the .result
  (2001-01-01 becomes 2001-01-01 00:00:00 and back).
- unknown.DATE gives error 4161, as expected.
- Stored programs (function return type, procedure parameter, local
  variable): all three rejected, as the test intends, but with error 1064
  instead of the expected 4161. Control: a function with plain RETURN DATE
  was created fine; the same function with mariadb_schema.DATE gave 1064.

Status: matches the .result except the stored-program error code and
InnoDB instead of MyISAM (environment default).

## Variations
| ID | Input | MariaDB 11.8.9 result | Conclusion |
|---|---|---|---|
| D1 | DATETIME '2001-01-01 14:30:45' changed to mariadb_schema.DATE | 2001-01-01, Note 1265 "Data truncated for column 'a' at row 1" | time of day is dropped, with a warning |
| D2 | the same column changed back to oracle_schema.DATE | 2001-01-01 00:00:00 | the original time is not recovered |

## Observations
- D1/D2: converting to a date-only type loses the time and only raises a
  Note, so the ALTER succeeds. Migration scripts that change types should
  check warnings. This is expected MariaDB behavior, not a difference
  from Oracle: Oracle has no date-only type, so the situation only arises
  on the MariaDB side. No Oracle test needed.
- Known limitation (MDEV-23353): qualified types are not usable in stored
  programs. In Oracle mode, DATE inside a routine means the datetime
  version, and the date-only spelling is not available there.
- Error-code difference 1064 vs 4161: possibly version-related, not
  confirmed.

## Gap candidates
- None new. The only limitation found is already documented (MDEV-23353).

## Next steps
- Check the 1064 vs 4161 difference against the 11.8 branch of the test
  and a newer MariaDB build
- Search Jira for the current status of MDEV-19632 and MDEV-23353


| C1 | Oracle-mode function RETURN DATE (control) | created and dropped fine | plain DATE works in routines |
| C2 | same function RETURN mariadb_schema.DATE | ERROR 1064 near 'AS' | qualified type rejected in routines |