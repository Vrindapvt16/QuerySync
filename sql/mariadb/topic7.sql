DELIMITER //

CREATE OR REPLACE FUNCTION student_exists(p_id IN INT)
RETURN INT AS
    student_count INT;
BEGIN
    SELECT COUNT(*) INTO student_count
    FROM students
    WHERE student_id = p_id;

    RETURN student_count;
END student_exists;
//

DELIMITER ;


-- DELIMITER //

-- CREATE OR REPLACE FUNCTION add_numbers(a IN INT, b IN INT)
-- RETURN INT AS
-- BEGIN
--     RETURN a + b;
-- END add_numbers;
-- //

DELIMITER ;

-- DELIMITER //

-- CREATE OR REPLACE PROCEDURE double_value(p_number IN OUT INT) AS
-- BEGIN
--     p_number := p_number * 2;
-- END double_value;
-- //

DELIMITER ;

-- DELIMITER //

-- CREATE OR REPLACE PROCEDURE count_students(total OUT INT) AS
-- BEGIN
--     SELECT COUNT(*) INTO total
--     FROM students;
-- END count_students;
-- //

-- DELIMITER ;