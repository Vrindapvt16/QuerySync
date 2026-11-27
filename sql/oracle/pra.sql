-- sp-anonymous variations, Oracle side
DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (a INT NOT NULL PRIMARY KEY);

-- V1 (already tested): unhandled error in the middle of a block
DELETE FROM t1;
INSERT INTO t1 VALUES (10);
COMMIT;
BEGIN
  INSERT INTO t1 VALUES (20);
  INSERT INTO t1 VALUES (20);
END;
/
SELECT * FROM t1;

-- V2: handled with WHEN OTHERS
DELETE FROM t1;
INSERT INTO t1 VALUES (10);
COMMIT;
BEGIN
  INSERT INTO t1 VALUES (20);
  INSERT INTO t1 VALUES (20);
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/
SELECT * FROM t1;

-- -- V3: SQLCODE and SQLERRM
-- DELETE FROM t1;
-- DELETE FROM err_log;
-- INSERT INTO t1 VALUES (10);
-- COMMIT;
-- DECLARE
--   v_code INT;
--   v_msg VARCHAR2(200);
-- BEGIN
--   INSERT INTO t1 VALUES (20);
--   INSERT INTO t1 VALUES (20);
-- EXCEPTION
--   WHEN DUP_VAL_ON_INDEX THEN
--     v_code := SQLCODE;
--     v_msg := SQLERRM;
--     INSERT INTO err_log VALUES (v_code, v_msg);
-- END;
-- /
-- SELECT * FROM err_log;

-- -- V4: RAISE_APPLICATION_ERROR
-- DELETE FROM t1;
-- INSERT INTO t1 VALUES (10);
-- COMMIT;
-- BEGIN
--   INSERT INTO t1 VALUES (30);
--   RAISE_APPLICATION_ERROR(-20001, 'my message');
-- END;
-- /
-- SELECT * FROM t1;

-- -- V5: user-defined exception
-- DELETE FROM err_log;
-- COMMIT;
-- DECLARE
--   my_err EXCEPTION;
-- BEGIN
--   RAISE my_err;
-- EXCEPTION
--   WHEN my_err THEN
--     INSERT INTO err_log VALUES (1, 'caught my_err');
-- END;
-- /
-- SELECT * FROM err_log;


-- -- DROP TABLE t1;
-- -- CREATE TABLE t1 (a INT NOT NULL PRIMARY KEY);
-- -- INSERT INTO t1 VALUES (10);

-- -- BEGIN
-- --   INSERT INTO t1 VALUES (20);
-- --   INSERT INTO t1 VALUES (20);
-- -- EXCEPTION
-- --   WHEN DUP_VAL_ON_INDEX THEN
-- --     NULL;
-- -- END;
-- -- /
-- -- SELECT * FROM t1;



