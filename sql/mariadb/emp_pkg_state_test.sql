SELECT emp_pkg.call_count() AS calls_before;
SELECT emp_pkg.get_salary(1) AS salary_1;
SELECT emp_pkg.get_salary(2) AS salary_2;
SELECT emp_pkg.call_count() AS calls_after;