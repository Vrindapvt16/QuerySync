--
-- Copyright (c) 2023 Oracle
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions rem of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
-- 
-- NAME
--   hr_code.sql - Create procedural objects for HR schema
--
-- DESCRIPTION
--    1. Creates a statement level trigger on the EMPLOYEES table
--       to allow DML during business hours.
--    2. Creates a row level trigger on the EMPLOYEES table,
--       after UPDATES on the department_id or job_id columns.
--    3. Creates a stored procedure to insert a row into the
--       JOB_HISTORY table.  
--    4. The defined row level trigger calls the stored procedure. 
--
-- SCHEMA VERSION
--   21
--
-- RELEASE DATE
--   03-FEB-2022
--
-- SUPPORTED with DB VERSIONS
--   19c and higher
-- 
-- MAJOR CHANGES IN THIS RELEASE
--   
--
-- SCHEMA DEPENDENCIES AND REQUIREMENTS
--   This script is called from the hr_install.sql script
-- 
-- INSTALL INSTRUCTIONS
--    Run the hr_install.sql script to call this script
--
-- --------------------------------------------------------------------------


-- **************************************************************************

-- procedure and statement trigger to allow dmls during business hours:

DELIMITER /
CREATE OR REPLACE PROCEDURE secure_dml
IS
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE_APPLICATION_ERROR (-20205, 
		'You may only make changes during normal office hours');
  END IF;
END secure_dml;
/

CREATE OR REPLACE TRIGGER secure_employees
  BEFORE INSERT OR UPDATE OR DELETE ON employees
BEGIN
  secure_dml;
END secure_employees;
/

ALTER TRIGGER secure_employees DISABLE/

-- **************************************************************************
-- procedure to add a row to the JOB_HISTORY table and row trigger 
-- to call the procedure when data is updated in the job_id or 
-- department_id columns in the EMPLOYEES table:

CREATE OR REPLACE PROCEDURE add_job_history
  (  p_emp_id          job_history.employee_id%type
   , p_start_date      job_history.start_date%type
   , p_end_date        job_history.end_date%type
   , p_job_id          job_history.job_id%type
   , p_department_id   job_history.department_id%type 
   )
IS
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date, 
                           job_id, department_id)
    VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END add_job_history;
/

CREATE OR REPLACE TRIGGER update_job_history
  AFTER UPDATE OF job_id, department_id ON employees
  FOR EACH ROW
BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate, 
                  :old.job_id, :old.department_id);
END;
/

DELIMITER ;
COMMIT;

