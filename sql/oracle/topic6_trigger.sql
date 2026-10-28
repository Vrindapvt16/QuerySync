SET SERVEROUTPUT ON

CREATE OR REPLACE TRIGGER trg_emp_id
BEFORE INSERT ON employees
FOR EACH ROW
WHEN (NEW.emp_id IS NULL)
BEGIN
    :NEW.emp_id := emp_seq.NEXTVAL;
END;
/
SHOW ERRORS

INSERT INTO employees(name, dept, salary) VALUES ('Zed', 'IT', 3000);
INSERT INTO employees (emp_id, name, dept, salary) VALUES (50, 'Yara', 'HR', 3100);


SELECT emp_id, name FROM employees ORDER BY emp_id;
ROLLBACK;
SELECT emp_id, name FROM employees ORDER BY emp_id;