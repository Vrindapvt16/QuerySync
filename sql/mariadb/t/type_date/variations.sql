-- (added, not in original) start from a clean state
DROP TABLE IF EXISTS t1;

SET sql_mode=ORACLE;
CREATE TABLE t1 (a DATE);
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- MDEV-19632: qualified type names
SET sql_mode=DEFAULT;
-- expected error: Unknown data type: 'unknown.date'
CREATE TABLE t1 (a unknown.DATE);

SET sql_mode=DEFAULT;
CREATE TABLE t1 (
  def_date DATE,
  mdb_date mariadb_schema.DATE,
  ora_date oracle_schema.DATE,
  max_date maxdb_schema.DATE
);
SHOW CREATE TABLE t1;
SET sql_mode=ORACLE;
SHOW CREATE TABLE t1;
DROP TABLE t1;

SET sql_mode=ORACLE;
CREATE TABLE t1 (
  def_date DATE,
  mdb_date mariadb_schema.DATE,
  ora_date oracle_schema.DATE,
  max_date maxdb_schema.DATE
);
SHOW CREATE TABLE t1;
SET sql_mode=DEFAULT;
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- ALTER..MODIFY and ALTER..CHANGE understand qualifiers
SET sql_mode=DEFAULT;
CREATE TABLE t1 (a DATE);
INSERT INTO t1 VALUES ('2001-01-01');
SET sql_mode=ORACLE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

ALTER TABLE t1 MODIFY a DATE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

ALTER TABLE t1 MODIFY a mariadb_schema.DATE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

ALTER TABLE t1 MODIFY a oracle_schema.DATE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

ALTER TABLE t1 CHANGE a b mariadb_schema.DATE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

ALTER TABLE t1 CHANGE b a oracle_schema.DATE;
SHOW CREATE TABLE t1;
SELECT * FROM t1;

DROP TABLE t1;

-- Qualified types in stored routines: not supported yet (MDEV-23353)
-- all three statements below are expected to fail with
-- "Unknown data type: '`mariadb_schema`.`DATE`'"
SET sql_mode=ORACLE;
DELIMITER $$
CREATE FUNCTION f1() RETURN mariadb_schema.DATE AS
BEGIN
  RETURN CURRENT_DATE;
END;
$$
CREATE PROCEDURE p1(a mariadb_schema.DATE) AS
BEGIN
  NULL;
END;
$$
CREATE PROCEDURE p1() AS
  a mariadb_schema.DATE;
BEGIN
  NULL;
END;
$$
DELIMITER ;