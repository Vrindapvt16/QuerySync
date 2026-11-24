-- func_to_date variations, Oracle side
-- run with: @/scripts/t/func_to_date/variations_oracle.sql
SELECT TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') AS today FROM dual;
SELECT TO_CHAR(TO_DATE('14:30:25','HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') AS d1 FROM dual;
SELECT TO_CHAR(TO_DATE('Oct','MON'),'YYYY-MM-DD') AS d2 FROM dual;
SELECT TO_DATE('2025-02-30','YYYY-MM-DD') AS d3 FROM dual;
SELECT TO_CHAR(TO_DATE('26-OCT-25'),'YYYY-MM-DD') AS s1 FROM dual;