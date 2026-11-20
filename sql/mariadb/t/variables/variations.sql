SET sql_mode=oracle;

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
-- I am not sure of the exact flag name or version, so check your docs.
-- SET sql_mode=CONCAT(@@sql_mode, ',EMPTY_STRING_IS_NULL');
-- SELECT CASE WHEN '' IS NULL THEN 'null' ELSE 'not null' END AS empty_string FROM dual;


-- Test 5: unquoted names and letter case (run last, may fail)

SELECT '--- Test 5: table name case ---' AS test;

DROP TABLE IF EXISTS emp;
CREATE TABLE emp (id NUMBER);
SELECT * FROM EMP;

