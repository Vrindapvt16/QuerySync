SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE add_employee(
  p_name   IN  VARCHAR2,
  p_dept   IN  VARCHAR2,
  p_salary IN  NUMBER,
  p_id     OUT NUMBER
) IS
BEGIN
  p_id := emp_seq.NEXTVAL;
  INSERT INTO employees (emp_id, name, dept, salary)
  VALUES (p_id, p_name, p_dept, p_salary);
END;
/
SHOW ERRORS


DECLARE
  v_id NUMBER;
BEGIN
  add_employee('Maya', 'IT', 4200, v_id);
  DBMS_OUTPUT.PUT_LINE('New id: ' || v_id);
END;
/

SELECT emp_id, name FROM employees ORDER BY emp_id;
ROLLBACK;
SELECT emp_id, name FROM employees ORDER BY emp_id;

-- SET SERVEROUTPUT ON

-- DROP SEQUENCE IF EXISTS emp_seq;
-- CREATE SEQUENCE emp_seq START WITH 100 INCREMENT BY 1;

-- SELECT emp_seq.NEXTVAL FROM dual;
-- SELECT emp_seq.NEXTVAL FROM dual;
-- SELECT emp_seq.CURRVAL FROM dual;


-- INSERT INTO employees VALUES (emp_seq.NEXTVAL, 'Maya', 'IT', 4200);
-- SELECT emp_id, name FROM employees WHERE name = 'Maya';
-- ROLLBACK;
-- SELECT emp_id, name FROM employees WHERE name = 'Maya';
-- SELECT emp_seq.NEXTVAL FROM dual;

