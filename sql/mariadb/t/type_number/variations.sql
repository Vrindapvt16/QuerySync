-- type_number variations (MariaDB, sql_mode=ORACLE)
-- Each block: Oracle type -> what does MariaDB do with it?
SET sql_mode=ORACLE;

-- V1: precision only
CREATE TABLE t1 (a NUMBER(10));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V2: maximum Oracle precision
CREATE TABLE t1 (a NUMBER(38));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V3: above Oracle's limit (Oracle rejects with ORA-01727)
CREATE TABLE t1 (a NUMBER(39));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V4: negative scale (valid in Oracle)
CREATE TABLE t1 (a NUMBER(5,-2));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V5: star precision (valid in Oracle)
CREATE TABLE t1 (a NUMBER(*,2));
SHOW CREATE TABLE t1;
DROP TABLE t1;


-- D2: plain NUMBER maps to DOUBLE. Does it lose exactness?
-- Oracle: 0.1 + 0.2 = 0.3 is true; 23-digit value kept exactly

CREATE TABLE t1 (a NUMBER);
INSERT INTO t1 VALUES (0.1), (0.2);
SELECT SUM(a) = 0.3 FROM t1;
INSERT INTO t1 VALUES (12345678901234567890123);
SELECT a FROM t1;
DROP TABLE t1;