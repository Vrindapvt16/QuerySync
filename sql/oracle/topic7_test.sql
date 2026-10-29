SET SERVEROUTPUT ON


BEGIN
    DBMS_OUTPUT.PUT_LINE('CURRENT COUNT: ' || emp_pkg.call_count);
    DBMS_OUTPUT.PUT_LINE('SALARY: ' || emp_pkg.get_salary(1));
END;
/
