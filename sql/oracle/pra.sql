SET sql_mode=ORACLE;

-- V1: NUMBER with precision only (no scale)
-- Expect: some DECIMAL(10,0) or integer type
CREATE TABLE t1 (a NUMBER(10));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V2: NUMBER with the maximum Oracle precision
CREATE TABLE t1 (a NUMBER(38));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V3: precision above Oracle's limit of 38
-- Oracle rejects this. Does MariaDB?
CREATE TABLE t1 (a NUMBER(39));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V4: negative scale (valid in Oracle: rounds to hundreds)
CREATE TABLE t1 (a NUMBER(5,-2));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- V5: star for precision (valid in Oracle)
CREATE TABLE t1 (a NUMBER(*,2));
SHOW CREATE TABLE t1;
DROP TABLE t1;