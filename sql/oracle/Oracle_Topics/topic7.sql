SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE emp_pkg IS
    FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION call_count RETURN NUMBER;
END emp_pkg;
/


CREATE OR REPLACE PACKAGE BODY emp_pkg IS
    g_calls NUMBER := 0;
    FUNCTION call_count RETURN NUMBER IS 
    BEGIN
        RETURN g_calls;
    END  call_count;

    FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
    v_sal employees.salary%TYPE;
    BEGIN
        g_calls := g_calls + 3;
        SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
        RETURN v_sal;
    END get_salary;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('Checking if this runs when we change value and recomplie');
END emp_pkg;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('CURRENT COUNT: ' || emp_pkg.call_count);
    DBMS_OUTPUT.PUT_LINE('SALARY: ' || emp_pkg.get_salary(1));
END;
/






-- SET SERVEROUTPUT ON

-- CREATE OR REPLACE PACKAGE emp_pkg IS
--     --g_calls NUMBER := 0;
--     c_max_raise_pct CONSTANT NUMBER := 20;

--     FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER;
--     FUNCTION double_salary(p_id in NUMBER) RETURN NUMBER;
--     PROCEDURE show_emp(p_id IN NUMBER);

--     FUNCTION call_count RETURN NUMBER;
-- END emp_pkg;
-- /
-- SHOW ERRORS

-- CREATE OR REPLACE PACKAGE BODY emp_pkg IS

--     g_calls NUMBER := 0;

--     FUNCTION call_count RETURN NUMBER IS
--     BEGIN
--         RETURN g_calls;
--     END call_count;
    
--     FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
--     v_sal employees.salary%TYPE;
--     BEGIN
--         g_calls := g_calls + 1;
--         SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
--         RETURN v_sal;
--     EXCEPTION
--         WHEN NO_DATA_FOUND THEN
--             RETURN NULL;
--     END get_salary;

--     PROCEDURE show_emp(p_id IN NUMBER) IS
--     v_row employees%ROWTYPE;
--     BEGIN
--         SELECT * INTO v_row FROM employees WHERE emp_id = p_id;
--         DBMS_OUTPUT.PUT_LINE(v_row.name || ' (' || v_row.dept || '): ' || v_row.salary);
--     END show_emp;

--     FUNCTION double_salary(p_id IN NUMBER) RETURN NUMBER IS
--     BEGIN
--         RETURN get_salary(p_id) * 2;
--     END double_salary;

--     BEGIN
--         DBMS_OUTPUT.PUT_LINE('emp_pkg initialised');
-- END emp_pkg;
-- /

-- SHOW ERRORS


-- BEGIN
--     DBMS_OUTPUT.PUT_LINE('calls so far: ' || emp_pkg.call_count);
--     DBMS_OUTPUT.PUT_LINE(emp_pkg.get_salary(1));
--     DBMS_OUTPUT.PUT_LINE('calls so far: ' || emp_pkg.call_count);
-- END;
-- /

-- BEGIN
--   DBMS_OUTPUT.PUT_LINE(emp_pkg.g_calls);
-- END;
-- /





-- SET SERVEROUTPUT ON

-- CREATE OR REPLACE PACKAGE emp_pkg IS
--     g_calls NUMBER := 0;
--     c_max_raise_pct CONSTANT NUMBER := 20;
--     FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER;
--     PROCEDURE show_emp(p_id IN NUMBER);
--     FUNCTION double_salary(p_id IN NUMBER) RETURN NUMBER;
-- END emp_pkg;
-- /
-- SHOW ERRORS

-- CREATE OR REPLACE PACKAGE BODY emp_pkg IS
--     FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
--     v_sal employees.salary%TYPE;
--     BEGIN
--         g_calls := g_calls + 1;
--         SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
--         RETURN v_sal;
--     EXCEPTION
--         WHEN NO_DATA_FOUND THEN
--             RETURN NULL;
--     END get_salary;

--     PROCEDURE show_emp(p_id IN NUMBER) IS
--     v_row employees%ROWTYPE;
--     BEGIN
--         SELECT * INTO v_row FROM employees WHERE emp_id = p_id;
--         DBMS_OUTPUT.PUT_LINE(v_row.name || ' (' || v_row.dept || '): ' || v_row.salary);
--     END show_emp;

--     FUNCTION double_salary(p_id IN NUMBER) RETURN NUMBER IS
--         BEGIN
--             RETURN get_salary(p_id) * 2;
--         END double_salary;
-- END emp_pkg;
-- /
-- SHOW ERRORS

-- BEGIN
--     DBMS_OUTPUT.PUT_LINE('Start: ' || emp_pkg.g_calls);
--     DBMS_OUTPUT.PUT_LINE(emp_pkg.get_salary(1));
--     emp_pkg.show_emp(3);
--     DBMS_OUTPUT.PUT_LINE('max raise: ' || emp_pkg.c_max_raise_pct);
--     DBMS_OUTPUT.PUT_LINE('double salary: ' || emp_pkg.double_salary(1));
--     DBMS_OUTPUT.PUT_LINE('calls: ' || emp_pkg.g_calls);

  
-- END;
-- /