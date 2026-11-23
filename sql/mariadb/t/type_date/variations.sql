-- D1: Does converting DATETIME to MariaDB DATE lose time information?

SET sql_mode='';

DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (a DATETIME);

INSERT INTO t1 VALUES ('2001-01-01 14:30:45');

SET sql_mode=ORACLE;

SELECT * FROM t1;

-- Convert to date-only type
ALTER TABLE t1 MODIFY a mariadb_schema.DATE;

SHOW WARNINGS;
SELECT * FROM t1;

-- Convert back to Oracle-compatible DATE
ALTER TABLE t1 MODIFY a oracle_schema.DATE;

SELECT * FROM t1;

DROP TABLE t1;


-- C1 (control): a routine with plain DATE works in Oracle mode
SET sql_mode=ORACLE;
DROP FUNCTION IF EXISTS f0;
DELIMITER $$
CREATE FUNCTION f0() RETURN DATE AS
BEGIN
  RETURN CURRENT_DATE;
END;
$$
DELIMITER ;
DROP FUNCTION f0;

-- C2: the same function with the qualified type (expected: error 1064)
DELIMITER $$
CREATE FUNCTION f0() RETURN mariadb_schema.DATE AS
BEGIN
  RETURN CURRENT_DATE;
END;
$$
DELIMITER ;