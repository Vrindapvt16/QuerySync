DELIMITER //

CREATE OR REPLACE PROCEDURE list_students_manual AS
    student_name VARCHAR(100);

    CURSOR student_cursor IS
        SELECT name FROM students;

BEGIN
    OPEN student_cursor;

    LOOP
        FETCH student_cursor INTO student_name;

        EXIT WHEN student_cursor%NOTFOUND;

        SELECT student_name AS student_name;
    END LOOP;

    CLOSE student_cursor;
END list_students_manual;
//

DELIMITER ;

-- DELIMITER //

-- CREATE OR REPLACE PROCEDURE list_students AS

--     CURSOR student_cursor IS
--         SELECT name FROM students;

-- BEGIN
--     FOR rec IN student_cursor LOOP
--         SELECT rec.name AS student_name;
--     END LOOP;
-- END list_students;
-- //

-- DELIMITER ;

-- USE university
-- DELIMITER //

-- CREATE OR REPLACE PROCEDURE count_students_local AS
--     student_count INT;
-- BEGIN
--     SELECT COUNT(*) INTO student_count FROM students;

--     SELECT student_count AS total_students;
-- END count_students_local;
-- //

-- DELIMITER ;