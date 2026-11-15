SET sql_mode=ORACLE;

-- Check whether VARCHAR2 is a reserved word
CREATE TABLE varchar2 (varchar2 INT);
SHOW CREATE TABLE varchar2;
DROP TABLE varchar2;

-- Check VARCHAR2 datatype
CREATE TABLE t1 (a VARCHAR2(10));
SHOW CREATE TABLE t1;
DROP TABLE t1;

-- Check CAST to VARCHAR2
SELECT CAST(123 AS VARCHAR2(10)) FROM DUAL;

-- Check CAST without specifying length
SELECT CAST(123 AS VARCHAR2) FROM DUAL;

