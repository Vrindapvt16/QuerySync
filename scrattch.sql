UPDATE employees_hr
SET job_id = 'SA_REP',
    department_id = 90
WHERE employee_id = 104;


-- DELIMITER $$

-- CREATE OR REPLACE TRIGGER update_job_history
-- AFTER UPDATE OF job_id, department_id ON employees_hr
-- FOR EACH ROW
-- BEGIN
--     CALL add_job_history(
--         OLD.employee_id,
--         OLD.hire_date,
--         SYSDATE(),
--         OLD.job_id,
--         OLD.department_id
--     );
-- END;
-- $$

DELIMITER ;
-- CREATE TABLE employees_hr (
--     employee_id INT PRIMARY KEY,
--     hire_date DATETIME NOT NULL,
--     job_id VARCHAR(10),
--     department_id INT
-- );

-- INSERT INTO employees_hr VALUES
-- (104, '2019-03-01', 'IT_PROG', 60);
-- DELIMITER $$

-- CREATE OR REPLACE TRIGGER update_job_history
-- AFTER UPDATE OF job_id, department_id ON employees
-- FOR EACH ROW
-- BEGIN
--     CALL add_job_history(
--         OLD.employee_id,
--         OLD.hire_date,
--         SYSDATE(),
--         OLD.job_id,
--         OLD.department_id
--     );
-- END;
-- $$

-- DELIMITER ;


-- CALL add_job_history(
--     103,
--     '2022-05-01',
--     '2024-05-01',
--     'FI_ACCOUNT',
--     100
-- );

-- SELECT * FROM job_history;

-- CALL add_job_history(
--     101,
--     '2020-01-01',
--     '2024-01-01',
--     'IT_PROG',
--     90
-- );

-- CALL add_job_history(
--     102,
--     '2021-01-01',
--     '2023-01-01',
--     'SA_REP',
--     NULL
-- );

-- CALL add_job_history(
--     101,
--     '2020-01-01',
--     '2022-01-01',
--     'IT_PROG',
--     60
-- );

-- DELIMITER $$

-- CREATE OR REPLACE PROCEDURE add_job_history
-- (
--     p_emp_id          job_history.employee_id%TYPE,
--     p_start_date      job_history.start_date%TYPE,
--     p_end_date        job_history.end_date%TYPE,
--     p_job_id          job_history.job_id%TYPE,
--     p_department_id   job_history.department_id%TYPE
-- )
-- IS
-- BEGIN
--     INSERT INTO job_history (
--         employee_id,
--         start_date,
--         end_date,
--         job_id,
--         department_id
--     )
--     VALUES (
--         p_emp_id,
--         p_start_date,
--         p_end_date,
--         p_job_id,
--         p_department_id
--     );
-- END;
-- $$

DELIMITER ;

-- CREATE TABLE job_history (
--     employee_id INT,
--     start_date DATE,
--     end_date DATE,
--     job_id VARCHAR(10),
--     department_id INT,
--     PRIMARY KEY (employee_id, start_date)
-- );


-- DELIMITER $$

-- CREATE OR REPLACE PROCEDURE secure_dml AS
-- BEGIN
--     IF TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
--        OR TO_CHAR(SYSDATE, 'DY') IN ('SAT', 'SUN') THEN

--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'You may only make changes during normal office hours';

--     END IF;
-- END;
-- $$

-- DELIMITER ;

-- CALL secure_dml();


-- DELIMITER $$

-- CREATE OR REPLACE TRIGGER secure_employees
-- BEFORE INSERT ON employees
-- FOR EACH ROW
-- BEGIN
--     CALL secure_dml();
-- END;
-- $$

-- DELIMITER ;

-- INSERT INTO employees (emp_id, name, dept, salary)
-- VALUES (5, 'Test', 'Qurey', 10000);

-- SELECT
--     TO_CHAR(SYSDATE, 'DY') IN ('SAT', 'SUN') AS is_weekend;
-- SELECT 'Sat' = 'SAT' AS normal_comparison;

-- SELECT BINARY 'Sat' = BINARY 'SAT' AS binary_comparison;

-- SELECT
--     TO_CHAR(SYSDATE, 'DY') AS weekday,
--     TO_CHAR(SYSDATE, 'HH24:MI') AS formatted_time;


-- SELECT 'Sat' IN ('SAT', 'SUN') AS in_test;
-- SELECT 'Sat' = 'SAT' AS equal_test;

-- DELIMITER $$
-- CREATE OR REPLACE PROCEDURE t_raise AS
-- BEGIN
--     --RAISE_APPLICATION_ERROR(-20205, 'test');
--     SIGNAL SQLSTATE '45000'
--     SET MESSAGE_TEXT = 'test';
-- END;
-- $$
-- DELIMITER ;

-- CALL t_raise();


-- DELIMITER $$

-- CREATE OR REPLACE PROCEDURE t_raise_mariadb()
-- AS
-- BEGIN
--     SIGNAL SQLSTATE '45000'
--     SET MESSAGE_TEXT = 'test';
-- END;
-- $$

-- DELIMITER ;