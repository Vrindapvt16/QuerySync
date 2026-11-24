-- func_to_date variations (MariaDB 12.3.x)
-- Run in a fresh client session so no frozen clock or time zone is left over.
SET sql_mode=ORACLE;
SET timestamp=DEFAULT;

-- D1: only a time is given. Which date is filled in?
-- Oracle (tested): the 1st of the current month.
SELECT TO_CHAR(TO_DATE('14:30:25','HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') AS d1 FROM dual;

-- D2: only a month name is given (day missing).
-- Oracle (tested): day 1 of that month, current year.
SELECT TO_CHAR(TO_DATE('Oct','MON'),'YYYY-MM-DD') AS d2 FROM dual;

-- D3: impossible date. Oracle (tested): ORA-01839.
SELECT TO_DATE('2025-02-30','YYYY-MM-DD') AS d3 FROM dual;
SHOW WARNINGS;

-- S1: one argument. Oracle (tested): accepted.
SELECT TO_CHAR(TO_DATE('26-OCT-25'),'YYYY-MM-DD') AS s1 FROM dual;