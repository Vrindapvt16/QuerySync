CREATE USER 'student_user'@'localhost'
IDENTIFIED BY 'Student123!';


-- EXPLAIN
-- SELECT * FROM students
-- WHERE name = 'Bereket';

-- CREATE INDEX idx_student_name
-- ON students(name);



-- USE university;

-- CREATE TABLE accounts (
--     account_id INT PRIMARY KEY,
--     account_name VARCHAR(50),
--     balance DECIMAL(10,2)
-- );


-- INSERT INTO accounts VALUES
-- (1, 'Account A', 500.00),
-- (2, 'Account B', 200.00);




-- CREATE TABLE enrollments (
--     enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
--     student_id INT NOT NULL,
--     course_id INT NOT NULL,
--     enrollment_date DATE DEFAULT (CURRENT_DATE),

--     FOREIGN KEY (student_id)
--         REFERENCES students(student_id),

--     FOREIGN KEY (course_id)
--         REFERENCES courses(course_id)
-- );


-- START TRANSACTION;

-- UPDATE accounts
-- SET balance = balance - 50
-- WHERE account_id = 1;

-- SELECT * FROM accounts;



-- START TRANSACTION;

-- UPDATE accounts
-- SET balance = balance - 100
-- WHERE account_id = 1;

-- UPDATE accounts
-- SET balance = balance + 100
-- WHERE account_id = 2;

-- COMMIT;