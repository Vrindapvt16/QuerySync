# Test: type_varchar2

## Source
- Original: mysql-test/suite/compat/oracle/t/type_varchar2.test
  (branch/commit: <fill in>)
- References MDEV-11275 (sql_mode=ORACLE: CAST(..AS VARCHAR(N)))
- Baseline script: type_varchar2.sql (copy of the original, with comments added)
- Variations: variations.sql

## Environment
- MariaDB 11.8.9, sql_mode=ORACLE, database sql_practice
- Oracle comparison: Oracle AI Database 26ai Free 23.26.3.0.0 (Docker)

## What the test checks
How MariaDB's Oracle mode handles the Oracle type VARCHAR2: whether the
name is usable as an identifier, how VARCHAR2(n) is translated, and how
CAST to VARCHAR2 behaves with and without a length.

## Baseline result (matches type_varchar2.result)
| Test | MariaDB (Oracle mode) | Oracle |
|---|---|---|
| varchar2 as table/column name | accepted, int(11) | rejected, ORA-00903 |
| CREATE TABLE t1 (a VARCHAR2(10)) | stored as varchar(10) | accepted |
| CAST(123 AS VARCHAR2(10)) | 123 | 123 |
| CAST(123 AS VARCHAR2) | syntax error 1064 (expected) | ORA-00906, missing left parenthesis |

Status: passes. The last MariaDB error is the expected result
(--error ER_PARSE_ERROR in the .test file) and Oracle also rejects it,
so MariaDB matches Oracle there.

## Baseline difference
- B1: VARCHAR2 is usable as an identifier in MariaDB Oracle mode; Oracle
  treats it as a reserved word (ORA-00903). The test file comment states
  this is intentional on the MariaDB side. Permissiveness, low impact,
  since Oracle code cannot contain such a name. Only the table-name case
  was run in Oracle; the column-name case was not tested.

## Variations
| ID | Input | Oracle | MariaDB (Oracle mode) | Same? |
|---|---|---|---|---|
| D1 | INSERT '' then check IS NULL | NULL (IS_NULL = TRUE) | not NULL, LENGTH 0 | no, silent difference |
| D2 | 10 umlauts into VARCHAR2(10) | ORA-12899 (actual 20, maximum 10) | accepted; CHAR_LENGTH 10, OCTET_LENGTH 20 | no, MariaDB more permissive |
| S1a | VARCHAR2(10 CHAR) | accepted | ERROR 1064 near 'CHAR))' | no, gap |
| S1b | VARCHAR2(10 BYTE) | accepted | ERROR 1064 near 'BYTE))' | no, gap |
| S2 | NVARCHAR2(10) | accepted | ERROR 4161 Unknown data type: 'NVARCHAR2' | no, gap |
| P1 | VARCHAR2(5000) | ORA-00910 (length too long) | accepted, varchar(5000) | no, MariaDB more permissive |

Follow-on errors (1146 and 1051 after S1a, S1b and S2) occur because the
CREATE TABLE failed; they are not separate findings.

## Gap candidates (ranked by migration impact)
### G1: empty string is NULL in Oracle (D1), silent difference, high impact
- Oracle: '' is stored as NULL. IS NULL is true and LENGTH is NULL.
- MariaDB Oracle mode: '' stays an empty string. IS NULL is 0, LENGTH is 0.
- No error or warning on either side.
- Consequence (Oracle documentation, not tested here): a NOT NULL column
  rejects '' in Oracle but accepts it in MariaDB, and WHERE col IS NULL
  finds blank strings in Oracle but not in MariaDB.
- Not yet checked: whether this is intentional or already documented by
  MariaDB for Oracle mode.

### G2: explicit length semantics, VARCHAR2(n CHAR) and (n BYTE) (S1), high impact
- Oracle accepts both; MariaDB gives a syntax error.
- CHAR is very common in real Oracle code.
- Possible fix direction (unverified): accepting CHAR matches MariaDB's
  existing behavior (varchar length counts characters). BYTE has no
  direct MariaDB equivalent, so it needs a design decision.

### G3: NVARCHAR2 (S2), medium impact
- Oracle accepts NVARCHAR2(10); MariaDB reports an unknown data type.
- Possible fix direction (unverified): alias to an existing national
  character type, if MariaDB has a suitable one.

## Low-impact differences
- B1: VARCHAR2 usable as an identifier in MariaDB (see above).
- D2: Length unit differs. MariaDB varchar(10) counts characters; Oracle's
  default VARCHAR2(10) counts bytes (documented default, consistent with
  the ORA-12899 result). Direction matters: Oracle to MariaDB is safe,
  MariaDB to Oracle can fail for non-ASCII data.
  Also: LENGTH() counts characters in Oracle mode (returned 10 for the
  umlaut string); use OCTET_LENGTH() for bytes.
- P1: MariaDB accepts VARCHAR2(5000); Oracle rejects it with its standard
  4000-byte limit (the limit depends on a server setting; this container
  uses the default).

## Observations about the method
- Client scripts: running the .sql file in SQL*Plus gives SP2-0158
  (SHOW CREATE TABLE) errors. These come from the client, not the Oracle
  database. The test script is MariaDB-specific.
- Leftover state: the first run was spoiled by an old t1 from an earlier
  test (ERROR 1050 / ORA-00955), which made SHOW CREATE TABLE print the
  old column type. Fix: variations.sql starts with DROP TABLE IF EXISTS t1.
- Script flaw found and fixed: the first D2 query used LENGTH(), which
  reported 10 for bytes; replaced with OCTET_LENGTH(). On the Oracle side
  that query also failed because CHAR_LENGTH is a MariaDB function
  (ORA-00904); the Oracle equivalent is LENGTH / LENGTHB.

## Next steps
- Search Jira for existing reports of G1, G2, G3; link if found
- Re-test on a newer MariaDB build or main
- Check whether varchar2 is also rejected as a column name in Oracle
  (optional, low value)