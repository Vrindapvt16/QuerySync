SET SERVEROUTPUT ON

DECLARE
    CURSOR c_name IS
        SELECT name, dept FROM employees;

    v_name employees.name%TYPE;
    v_department employees.dept%TYPE;
BEGIN
    OPEN c_name;
    LOOP
        FETCH c_name INTO v_name, v_department;
        EXIT WHEN c_name%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' works ' || v_department);
    END LOOP;
    CLOSE c_name;
END;
/




-- SET SERVEROUTPUT ON

-- DECLARE
--     CURSOR c_call IS SELECT * FROM employees ORDER BY salary DESC;
-- BEGIN
--     FOR r c_call LOOP
--         DBMS_OUTPUT.PUT_LINE(r.name || ' (' || r.dept || '): ' || r.salary);
--     END LOOP;
-- END;
-- /









-- DECLARE
--     CURSOR c_it IS
--         SELECT name, salary FROM employees WHERE dept = 'IT';

--     v_name employees.name%TYPE;
--     v_salary employees.salary%TYPE;

-- BEGIN
--     OPEN c_it;
--     LOOP
--         FETCH c_it INTO v_name, v_salary;
--         EXIT WHEN c_it%NOTFOUND;
--         DBMS_OUTPUT.PUT_LINE(v_name || ' EARNS ' || v_salary);
--     END LOOP;
--     CLOSE c_it;
-- END;
-- /