SET sql_mode=ORACLE;
CREATE TABLE t1 (a DATE);
SHOW CREATE TABLE t1;
DROP TABLE t1;


-- 
--  MDEV-19632 Replication aborts with ER_SLAVE_CONVERSION_FAILED upon CREATE ... SELECT in ORACLE mode
-- 

SET sql_mode='';
--   ER_UNKNOWN_DATA_TYPE
CREATE TABLE t1 (a unknown.DATE);


SET sql_mode='';
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
SET sql_mode='';
SHOW CREATE TABLE t1;
DROP TABLE t1;


-- 
--  ALTER..MODIFY and ALTER..CHANGE understand qualifiers 
-- 

SET sql_mode='';
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

--  Qualified syntax is not supported yet in SP
--  See MDEV-23353 Qualified data types in SP
--  For now it's trying to parse mariadb_schema as a package name
-- 

SET sql_mode=ORACLE;
DELIMITER $$
--   ER_UNKNOWN_DATA_TYPE
CREATE FUNCTION f1() RETURN mariadb_schema.DATE AS
BEGIN
  RETURN CURRENT_DATE;
END;
$$
--   ER_UNKNOWN_DATA_TYPE
CREATE PROCEDURE p1(a mariadb_schema.DATE) AS
BEGIN
  NULL;
END;
$$
--   ER_UNKNOWN_DATA_TYPE
CREATE PROCEDURE p1() AS
  a mariadb_schema.DATE;
BEGIN
  NULL;
END;
$$
DELIMITER ;