SET SERVEROUTPUT ON

DECLARE
    CURSOR c_rich(p_min IN NUMBER) IS SELECT name FROM employees WHERE salary > p_min;
    v_name employees.name%TYPE;
BEGIN
    open c_rich(4500);
    open c_rich(3500);

    LOOP
        FETCH c_rich INTO v_name;
        EXIT WHEN c_rich%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name);
    END LOOP;
    close c_rich;

    open c_rich(3500);
    LOOP
        FETCH c_rich INTO v_name;
        EXIT WHEN c_rich%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name);
    END LOOP;
    close c_rich;

END;
/















-- DECLARE
--     CURSOR c_rich(p_min IN NUMBER) IS
--         SELECT name FROM employees WHERE salary > p_min;
    
-- BEGIN
--     For r in c_rich(4500) LOOP
--         DBMS_OUTPUT.PUT_LINE(r.name);
--     END LOOP;
    
--     For r in c_rich(3500) LOOP
--         DBMS_OUTPUT.PUT_LINE(r.name);
--     END LOOP;

-- END;
-- /



















-- DECLARE
--         CURSOR c_dept(p_dept IN VARCHAR2) IS
--             SELECT name, salary FROM employees WHERE dept = p_dept;
-- BEGIN
--     DBMS_OUTPUT.PUT_LINE('--IT--');
--     FOR r IN c_dept('IT') LOOP
--         DBMS_OUTPUT.PUT_LINE(r.name || ' : ' || r.salary);
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE('--HR--');
--     FOR r IN c_dept('HR') LOOP
--         DBMS_OUTPUT.PUT_LINE(r.name || ' : ' || r.salary);
--     END LOOP;

-- END;
-- /













-- SET SERVEROUTPUT ON

-- DECLARE
--     CURSOR c_emp IS SELECT name FROM employees ORDER BY emp_id;
--     v_name employees.name%TYPE;
-- BEGIN
--     IF NOT c_emp%ISOPEN THEN
--         DBMS_OUTPUT.PUT_LINE('cursor is closed before OPEN');
--     END IF;

--     OPEN c_emp;
--     DBMS_OUTPUT.PUT_LINE(c_emp%ROWCOUNT);
--     IF c_emp%ISOPEN THEN
--         DBMS_OUTPUT.PUT_LINE('Cursor is open');
--     END IF;
-- DOCKER 
--     LOOP
--         FETCH c_emp INTO v_name;
--         EXIT WHEN c_emp%NOTFOUND;
--         DBMS_OUTPUT.PUT_LINE('row ' || c_emp%ROWCOUNT || ': ' || v_name);
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE('total rows fetched: ' || c_emp%ROWCOUNT);
--     close c_emp;
--     DBMS_OUTPUT.PUT_LINE('total rows fetched: ' || c_emp%ROWCOUNT);


--     IF NOT c_emp%ISOPEN THEN
--         DBMS_OUTPUT.PUT_LINE('cursor is closed after CLOSE');
--     END IF;
-- END;
-- /



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