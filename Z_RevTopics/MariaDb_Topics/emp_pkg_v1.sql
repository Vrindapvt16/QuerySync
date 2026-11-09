DELIMITER $$
CREATE OR REPLACE PACKAGE emp_pkg IS
  FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER;
END emp_pkg;
$$

CREATE OR REPLACE PACKAGE BODY emp_pkg IS
  FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
    v_sal employees.salary%TYPE;
  BEGIN
    SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
    RETURN v_sal;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_salary;
END emp_pkg;
$$
DELIMITER ;

SELECT emp_pkg.get_salary(1)  AS id_1,
       emp_pkg.get_salary(99) AS id_99;