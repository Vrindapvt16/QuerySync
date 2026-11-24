# Test: func_to_date

## Source
- Original: mysql-test/suite/compat/oracle/t/func_to_date.test
  (branch/commit: <fill in>)
- Baseline script: func_to_date.sql (converted; SET sql_mode='' added at
  the top because the original runs in plain mode until it sets ORACLE;
  SET NAMES utf8mb4)
- Variations: run interactively in both clients (statements and results
  are in the Variations table below)
## Environment
- MariaDB 12.3.3 (container mariadb-oracle-mode-12), database sql_practice;
  server global sql_mode contains ORACLE
- Oracle AI Database 26ai Free 23.26.3
- TO_DATE does not exist on 11.8.9 (ERROR 1305); added in 12.3 (MDEV-19683)

## What the test checks
TO_DATE(text, format): converts text to a date using a format pattern.
Covers all format elements, odd inputs, error handling,
DEFAULT ... ON CONVERSION ERROR, NLS_DATE_LANGUAGE and recent bug fixes.

## Baseline result
Matches the .result. Differences: InnoDB instead of MyISAM (environment).
SET NAMES utf8 means utf8mb3 on this server, which broke four COLLATE
statements and showed utf8mb3 in SHOW CREATE VIEW; fixed with utf8mb4 and
rerun clean. The test freezes the clock at 2004-11-09, so missing date
parts are filled with that date in the baseline.

## Variations
| ID | Input | Oracle 26ai | MariaDB 12.3.3 | Same? |
|---|---|---|---|---|
| D1 | TO_DATE('14:30:25','HH24:MI:SS') | 2026-11-01 14:30:25 | today's date (2026-11-24/25) | no, silent |
| D2 | TO_DATE('Oct','MON') | 2026-10-01 | month Oct, day of the current date (baseline: 2004-10-09) | no, silent |
| D3 | TO_DATE('2025-02-30','YYYY-MM-DD') | ORA-01839 | NULL plus warning 1411 | no, silent |
| S1 | TO_DATE('26-OCT-25') (one argument) | 2025-10-26 | ERROR 1064 | no, gap (known) |

## Gap candidates
- G1 (silent, high impact): missing date parts. Oracle fills them with the
  current year and month and day 1; MariaDB takes today's date. The test
  comments say "Uses current day", so it looks deliberate, but it differs
  from Oracle (D1, D2 tested).
- G2 (silent, high impact): impossible dates give NULL plus warning 1411
  in MariaDB, also in sql_mode=ORACLE, and an error (ORA-01839) in Oracle.
  Only the impossible-date case was tested on Oracle. Oracle code that
  relies on the error, for example in an exception handler, silently gets
  NULL.
- G3 (syntax, known): one-argument TO_DATE is accepted by Oracle and
  rejected by MariaDB; the test expects this error, so it is a known
  limitation.

## Observations
- Bad pattern or syntax gives a loud error (3047 or 1064); bad data gives
  NULL plus warning 1411.
- The test's own "Different results compared to Oracle" section lists
  differences already known to the developers (for example RR with
  4-digit years gives NULL). They are known, not new findings.
- FF (fractional seconds) is accepted by MariaDB; per the MariaDB docs
  Oracle does not support it in TO_DATE (not tested here).
- The session's frozen clock and +03:00 time zone from the test file leak
  into later queries; use a fresh client for variations.

## Next steps
- Check whether a strict sql_mode turns the NULL of G2 into an error
- Search Jira for G1 to G3