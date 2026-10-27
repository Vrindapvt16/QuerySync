SET SERVEROUTPUT ON

DECLARE
    v_zero NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('outer: start');

    BEGIN
        DBMS_OUTPUT.PUT_LINE('inner: start');
        DBMS_OUTPUT.PUT_LINE(10 / v_zero);
        DBMS_OUTPUT.PUT_LINE('inner: end');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('inner: cause an error');
    end;

EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('outer: caught zero divinde');
END;
/
































-- SELECT level AS id, get_salary(level) AS salary
--   FROM dual CONNECT BY level <= 5;

-- SELECT level AS id, get_salary_strict(level) AS salary
--   FROM dual CONNECT BY level <= 5;

-- CREATE OR REPLACE PROCEDURE raise_salary(
--     p_dept IN VARCHAR2,
--     p_amount IN NUMBER
-- ) IS
-- BEGIN
--     IF p_amount <= 0 THEN
--         RAISE_APPLICATION_ERROR(-20002, 'RAISE VAL MUST BE POSTIVE!');
--     END IF;

--     UPDATE employees SET salary = salary + p_amount WHERE dept = p_dept;
--     DBMS_OUTPUT.PUT_LINE('Rows Updated: ' || SQL%ROWCOUNT);
-- END;
-- /

-- BEGIN
--     raise_salary('HR', 100);
--     raise_salary('HR', -50);
-- -- EXCEPTION
-- --     WHEN OTHERS THEN
-- --         DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLCODE || ' - - ' || SQLERRM);
-- END;
-- /


-- SELECT name, salary FROM employees WHERE dept = 'HR';
-- ROLLBACK;   



-- SET SERVEROUTPUT ON

-- CREATE OR REPLACE FUNCTION get_salary_strict(p_id IN NUMBER) RETURN NUMBER IS
--     v_sal employees.salary%TYPE;
-- BEGIN
--     SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
--     RETURN v_sal;
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         RAISE_APPLICATION_ERROR(-20001, 'NO employee with id ' || p_id);

-- END;
-- /

-- BEGIN
--     DBMS_OUTPUT.PUT_LINE(get_salary_strict(1));
--     DBMS_OUTPUT.PUT_LINE(get_salary_strict(3));
--     DBMS_OUTPUT.PUT_LINE(get_salary_strict(33));
-- EXCEPTION
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Caught: ' || SQLCODE || ' --- ' || SQLERRM);
-- END;
-- /

-- SET SERVEROUTPUT ON

-- CREATE OR REPLACE FUNCTION get_salary(p_id IN NUMBER) RETURN NUMBER IS
--     v_sal employees.salary%TYPE;
-- BEGIN
--     SELECT salary INTO v_sal FROM employees WHERE emp_id = p_id;
--     RETURN v_sal;
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         --DBMS_OUTPUT.PUT_LINE('NO USER With such ID');
--         RETURN NULL;
-- END;
-- /

-- BEGIN
--     DBMS_OUTPUT.PUT_LINE('id 1: ' || NVL(TO_CHAR(get_salary(1)), 'NULL'));
--     DBMS_OUTPUT.PUT_LINE('id 99: ' || NVL(TO_CHAR(get_salary(99)), 'NULL'));    
-- END;
-- /



-- SET SERVEROUTPUT ON

-- DECLARE
--     V_emp_id employees.emp_id%TYPE := 1;
-- BEGIN
--     INSERT INTO employees (emp_id, name, dept, salary) 
--     VALUES (V_emp_id, 'Ada', 'IT', 6000);

-- EXCEPTION
--     WHEN DUP_VAL_ON_INDEX THEN
--         DBMS_OUTPUT.PUT_LINE('Cannot insert a duplicate primary key ' || V_emp_id);
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Unexpected: ' || SQLCODE || ' - ' || SQLERRM);

-- END;
-- /








-- DECLARE
--     v_name  employees.name%TYPE;
-- BEGIN
--     SELECT name INTO v_name FROM employees WHERE dept = 'Nowhere';
--     DBMS_OUTPUT.PUT_LINE('Found: ' || v_name);
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         DBMS_OUTPUT.PUT_LINE('No rows');
--     WHEN TOO_MANY_ROWS THEN
--         DBMS_OUTPUT.PUT_LINE('More than one row');
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Unexpected: ' || SQLCODE || ' ' || SQLERRM);

-- END;
-- /











-- DECLARE
--     v_sal employees.salary%TYPE;
--     v_id NUMBER := 99;
-- BEGIN
--     SELECT salary INTO v_sal FROM employees WHERE emp_id = v_id;
--     DBMS_OUTPUT.PUT_LINE('Salary: ' || v_sal);

-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         DBMS_OUTPUT.PUT_LINE('NO SUCH EMPLOYEE ' || v_id);

-- END;
-- /








-- DECLARE
--     v_sal employees.salary%TYPE;
-- BEGIN
--     SELECT salary INTO v_sal FROM employees WHERE emp_id = 99;
--     DBMS_OUTPUT.PUT_LINE('Salary: ' || v_sal);
-- END;
-- /