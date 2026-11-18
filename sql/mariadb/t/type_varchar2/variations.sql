-- type_varchar2 variations (MariaDB, sql_mode=ORACLE)
SET sql_mode=ORACLE;
DROP TABLE IF EXISTS t1;

-- D1: Oracle treats '' as NULL. Does MariaDB?
CREATE TABLE t1 (a VARCHAR2(10));
INSERT INTO t1 VALUES ('');
SELECT a IS NULL AS is_null, LENGTH(a) AS len FROM t1;
DROP TABLE t1;

-- D2: length counted in characters or bytes? (10 umlauts = 20 bytes in UTF-8)
CREATE TABLE t1 (a VARCHAR2(10));
INSERT INTO t1 VALUES ('äöüäöüäöüä');
SELECT CHAR_LENGTH(a) AS chars, OCTET_LENGTH(a) AS bytes FROM t1;
DROP TABLE t1;


-- S1: explicit length semantics
CREATE TABLE t1 (a VARCHAR2(10 CHAR));
SHOW CREATE TABLE t1;
DROP TABLE t1;

CREATE TABLE t1 (a VARCHAR2(10 BYTE));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- S2: national character type
CREATE TABLE t1 (a NVARCHAR2(10));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- P1: above Oracle's default limit of 4000
CREATE TABLE t1 (a VARCHAR2(5000));
SHOW CREATE TABLE t1;
DROP TABLE t1;