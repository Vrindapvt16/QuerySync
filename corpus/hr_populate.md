
SET VERIFY OFF
ALTER SESSION SET NLS_LANGUAGE=American;


ALTER TABLE departments
  DISABLE CONSTRAINT dept_mgr_fk;

  1. Oracle: rem (remark) and Prompt are not SQL statements; they are commands specific to the SQL*Plus command-line client. rem tells SQL*Plus to ignore the line, while Prompt prints a message to the terminal

  2.  ALTER TABLE departments DISABLE/ENABLE CONSTRAINT dept_mgr_fk;
Oracle: Oracle allows constraints (including foreign keys) to exist in either an ENABLE or DISABLE state via ALTER TABLE ... DISABLE CONSTRAINT. This is used to resolve circular references during mass inserts:

departments.manager_id references employees.employee_id.

employees.department_id references departments.department_id.

MariaDB: MariaDB (specifically the InnoDB storage engine) does not support disabling or enabling individual foreign keys in place. In MariaDB, foreign keys are either active or dropped entirely (ALTER TABLE ... DROP FOREIGN KEY).

The MariaDB Equivalent: Instead of modifying the constraint itself, you temporarily disable foreign key checking for the session during the load:

SQL
SET FOREIGN_KEY_CHECKS = 0;
-- Run inserts here
SET FOREIGN_KEY_CHECKS = 1;

After these changes we still got 
ERROR 1305 (42000) at line 2302: FUNCTION hr.TO_DATE does not exist

which means the oracle mode of maria db does recognize the hr.TO_DATE() funciton 

so TO_DATE() becomes STR_TO_DATE IN Maria db
      , TO_DATE('17-06-2013', 'dd-MM-yyyy')
      , STR_TO_DATE('17-06-2013', '%d-%m-%Y')

      

Oracle construct	MariaDB result	Status
BEGIN ... END; / anonymous blocks	work with DELIMITER /	Confirmed
TO_DATE(x, 'dd-MM-yyyy')	error 1305, function doesn’t exist	Confirmed
STR_TO_DATE(x, '%d-%m-%Y')	works, all 127 dates load	Confirmed (if counts and the date check pass)
Failing statement inside a block	whole block rolled back, 0 rows kept	Confirmed (step 1 counts)
ALTER TABLE ... DISABLE/ENABLE CONSTRAINT	removed, replaced by foreign_key_checks=0/1; the re-validation has to be done by a manual query	Not tested at the prompt
