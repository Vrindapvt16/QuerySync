DELIMITER $$
CREATE OR REPLACE PACKAGE emp_pkg IS
    FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION call_count RETURN NUMBER;
END emp_pkg;
$$

CREATE OR REPLACE PACKAGE BODY emp_pkg IS
    g_calls NUMBER := 0;

    FUNCTION call_count RETURN NUMBER IS
    BEGIN
        RETURN g_calls;
    END call_count;
    
    FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
    v_sal employees.salary%TYPE;
    BEGIN
        g_calls := g_calls + 1;
        SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
    RETURN v_sal;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END get_salary; 

END emp_pkg;
$$
DELIMITER ;