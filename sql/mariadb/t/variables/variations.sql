SET sql_mode=oracle;

-- ============================================================
-- PART 1: SQL & Expression Behavior
-- ============================================================

-- Test 1: NUMBER is exact in Oracle, DOUBLE in MariaDB
SELECT '--- Test 1: 0.1 + 0.2 = 0.3 ---' AS test;

DELIMITER $$

DECLARE
  x NUMBER := 0.1;
  y NUMBER := 0.2;
BEGIN
  IF x + y = 0.3 THEN
    SELECT 'equal';
  ELSE
    SELECT 'not equal';
  END IF;
END;
$$

DELIMITER ;


-- Test 2: assigning to a system variable (MariaDB-only)
SELECT '--- Test 2: system variable assignment ---' AS test;

max_sort_length := 1030;
SELECT @@max_sort_length;
max_sort_length := DEFAULT;
SELECT @@max_sort_length;


-- Test 3: date minus date
-- Oracle: number of days between the dates (11)
-- MariaDB: may give a plain number instead
SELECT '--- Test 3: date subtraction ---' AS test;

SELECT DATE '2026-12-01' - DATE '2026-11-20' AS date_minus_date FROM dual;
SELECT DATEDIFF('2026-12-01', '2026-11-20') AS datediff_days;


-- Test 4: empty string and NULL
-- Oracle: '' is NULL
-- MariaDB: '' is not NULL unless the mode flag is enabled
SELECT '--- Test 4: empty string is NULL? ---' AS test;

SELECT CASE WHEN '' IS NULL THEN 'null' ELSE 'not null' END AS empty_string FROM dual;

-- To test the Oracle-style behavior, uncomment the next two lines.
-- SET sql_mode=CONCAT(@@sql_mode, ',EMPTY_STRING_IS_NULL');
-- SELECT CASE WHEN '' IS NULL THEN 'null' ELSE 'not null' END AS empty_string FROM dual;


-- ============================================================
-- PART 2: Stored Procedures (PL/SQL Compatibility)
-- ============================================================

DROP TABLE IF EXISTS emp2;
CREATE TABLE emp2 (id INT, salary INT);
INSERT INTO emp2 VALUES (1, 100), (2, 200);

DELIMITER $$

-- Test 5: local variable with the same name as a column
-- Oracle: the column wins, so salary = 999 matches 0 rows
-- MariaDB (expected): the variable wins, so it matches 2 rows
CREATE OR REPLACE PROCEDURE t5 AS
  salary INT := 999;
  v INT;
BEGIN
  SELECT COUNT(*) INTO v FROM emp2 WHERE salary = 999;
  SELECT v AS rows_matching;
END;
$$

-- Test 6: assigning a too-long string to VARCHAR2(3)
-- Oracle: error ORA-06502 (buffer too small)
-- MariaDB (expected): truncated to 'abc' or an error, depending on mode
CREATE OR REPLACE PROCEDURE t6 AS
  s VARCHAR2(3);
BEGIN
  s := 'abcdef';
  SELECT s AS value, LENGTH(s) AS len;
END;
$$

-- Test 7: assigning to an IN parameter
-- Oracle: compile error (IN parameters are read-only)
-- MariaDB (expected): allowed, prints 2
CREATE OR REPLACE PROCEDURE t7(a IN INT) AS
BEGIN
  a := a + 1;
  SELECT a AS a_after;
END;
$$

-- Test 8: PLS_INTEGER overflow
-- Oracle: numeric overflow error
-- MariaDB (expected): out-of-range error or value clipped to 2147483647
CREATE OR REPLACE PROCEDURE t8 AS
  x PLS_INTEGER := 2147483647;
BEGIN
  x := x + 1;
  SELECT x AS x_after;
END;
$$

-- Test 9 (control): FOR loop variable shadows an outer variable
-- Oracle: prints 1, 2, then 100
-- MariaDB (expected): same
CREATE OR REPLACE PROCEDURE t9 AS
  i INT := 100;
BEGIN
  FOR i IN 1..2 LOOP
    SELECT i AS loop_i;
  END LOOP;
  SELECT i AS outer_i;
END;
$$

-- Test 10: concatenating a NULL variable
-- Oracle: 'a' || NULL || 'b' = 'ab', not NULL
-- MariaDB: depends on PIPES_AS_CONCAT / ORACLE mode behavior
CREATE OR REPLACE PROCEDURE t10 AS
  v VARCHAR2(10);
  r VARCHAR2(20);
BEGIN
  r := 'a' || v || 'b';
  SELECT r AS result, r IS NULL AS result_is_null;
END;
$$

DELIMITER ;

SELECT '--- Test 5: variable vs column name ---' AS test;
CALL t5();

SELECT '--- Test 6: VARCHAR2(3) overflow ---' AS test;
CALL t6();

SELECT '--- Test 7: assign to IN parameter ---' AS test;
CALL t7(1);

SELECT '--- Test 8: PLS_INTEGER overflow ---' AS test;
CALL t8();

SELECT '--- Test 9: FOR loop variable shadowing ---' AS test;
CALL t9();

SELECT '--- Test 10: NULL in concatenation ---' AS test;
CALL t10();


-- ============================================================
-- PART 3: Tests Likely to Raise Errors (Run Last)
-- ============================================================

-- Test 11: unquoted names and letter case (may fail on case-sensitive filesystems)
SELECT '--- Test 11: table name case ---' AS test;

DROP TABLE IF EXISTS emp;
CREATE TABLE emp (id NUMBER);
SELECT * FROM EMP;


DELIMITER $$

-- Test 12: reach a shadowed outer variable with procedure_name.variable
-- Oracle: inner_x = 2, outer_x = 1
-- MariaDB (expected): probably an error, t12.x read as table.column
CREATE OR REPLACE PROCEDURE t12 AS
  x INT := 1;
BEGIN
  DECLARE
    x INT := 2;
  BEGIN
    SELECT x AS inner_x;
    SELECT t12.x AS outer_x;
  END;
END;
$$

-- Test 13: CONSTANT variable
-- Oracle: compile error because a constant cannot be assigned
-- MariaDB: unsure, may reject CONSTANT or allow the assignment
CREATE OR REPLACE PROCEDURE t13 AS
  c CONSTANT INT := 5;
BEGIN
  c := 6;
  SELECT c AS c_after;
END;
$$

DELIMITER ;

SELECT '--- Test 12: label/procedure qualified variable ---' AS test;
CALL t12();

SELECT '--- Test 13: CONSTANT ---' AS test;
CALL t13();