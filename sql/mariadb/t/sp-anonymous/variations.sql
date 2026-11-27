-- sp-anonymous variations (MariaDB 12.3.x, sql_mode=ORACLE)
SET sql_mode=ORACLE;
DROP TABLE IF EXISTS t1;
SET AUTOCOMMIT=OFF;
CREATE TABLE t1 (a INT NOT NULL PRIMARY KEY);

-- V1: unhandled error in the middle of a block. Which rows remain?
-- Oracle (tested): 10 only.
DELETE FROM t1;
INSERT INTO t1 VALUES (10);
COMMIT;
DELIMITER $$
-- expected error: duplicate key (1062)
BEGIN
  INSERT INTO t1 VALUES (20);
  INSERT INTO t1 VALUES (20);
END;
$$
DELIMITER ;
SELECT * FROM t1;

-- V2: the same, handled with WHEN OTHERS. Expectation: 10, 20 on both.
DELETE FROM t1;
INSERT INTO t1 VALUES (10);
COMMIT;
DELIMITER $$
BEGIN
  INSERT INTO t1 VALUES (20);
  INSERT INTO t1 VALUES (20);
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
$$
DELIMITER ;
SELECT * FROM t1;
