1. removed all the SQL*Plus part like REM for comments and 
SET FEEDBACK 1
parts casue they are SQL*Plus environment and formatting directives
2.
the we add a 
DELIMITER / at the top and DELIMITER;
because sections ending with ; got glued to the next pl/sql statements 



evedinece by running sample trigger code with three dt examples
1. with no row level tigger and fails
2. with row level trigger and works 
3. with row level but on multiple events in one trigger and failes 

Ask your teacher whether a faithful migration should leave them out or find a way to disable them.

-- bc the 
-- ALTER TRIGGER secure_employees DISABLE  (no MariaDB equivalent, removed)
didn't work it gets ommited and them it means that i can't make modification on night and weekends

C:\Users\gebre\Desktop\oracle-migration-lab>docker exec -it mariadb-oracle-mode mariadb -uroot -p hr
Enter password:
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 16
Server version: 11.8.9-MariaDB-ubu2404 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [hr]> DELIMITER /
MariaDB [hr]>
MariaDB [hr]> CREATE OR REPLACE TRIGGER t_a BEFORE INSERT ON employees
    -> BEGIN
    ->   secure_dml;
    -> END;
    -> /
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'BEGIN
  secure_dml;
END' at line 3
MariaDB [hr]>
MariaDB [hr]> CREATE OR REPLACE TRIGGER t_b BEFORE INSERT ON employees FOR EACH ROW
    -> BEGIN
    ->   secure_dml;
    -> END;
    -> /
Query OK, 0 rows affected (0.060 sec)

MariaDB [hr]>
MariaDB [hr]> CREATE OR REPLACE TRIGGER t_c BEFORE INSERT OR UPDATE ON employees FOR EACH ROW
    -> BEGIN
    ->   secure_dml;
    -> END;
    -> /
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'OR UPDATE ON employees FOR EACH ROW
BEGIN
  secure_dml;
END' at line 1
MariaDB [hr]>
MariaDB [hr]> DELIMITER ;
MariaDB [hr]> SHOW TRIGGERS;
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
| Trigger            | Event  | Table     | Statement                                                                                                                   | Timing | Created                | sql_mode                                                                                                                                     | Definer        | character_set_client | collation_connection  | Database Collation    |
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
| t_b                | INSERT | employees | BEGIN
  secure_dml;
END                                                                                                     | BEFORE | 2026-11-11 09:54:05.11 | PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ORACLE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,SIMULTANEOUS_ASSIGNMENT | root@localhost | utf8mb4              | utf8mb4_uca1400_ai_ci | utf8mb4_uca1400_ai_ci |
| update_job_history | UPDATE | employees | BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate,
                  :old.job_id, :old.department_id);
END | AFTER  | 2026-11-11 09:36:05.39 | PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ORACLE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,SIMULTANEOUS_ASSIGNMENT | root@localhost | utf8mb4              | utf8mb4_uca1400_ai_ci | utf8mb4_uca1400_ai_ci |
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
2 rows in set (0.002 sec)

MariaDB [hr]> SHOW TRIGGERS;
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
| Trigger            | Event  | Table     | Statement                                                                                                                   | Timing | Created                | sql_mode                                                                                                                                     | Definer        | character_set_client | collation_connection  | Database Collation    |
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
| t_b                | INSERT | employees | BEGIN
  secure_dml;
END                                                                                                     | BEFORE | 2026-11-11 09:54:05.11 | PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ORACLE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,SIMULTANEOUS_ASSIGNMENT | root@localhost | utf8mb4              | utf8mb4_uca1400_ai_ci | utf8mb4_uca1400_ai_ci |
| update_job_history | UPDATE | employees | BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate,
                  :old.job_id, :old.department_id);
END | AFTER  | 2026-11-11 09:36:05.39 | PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ORACLE,NO_KEY_OPTIONS,NO_TABLE_OPTIONS,NO_FIELD_OPTIONS,NO_AUTO_CREATE_USER,SIMULTANEOUS_ASSIGNMENT | root@localhost | utf8mb4              | utf8mb4_uca1400_ai_ci | utf8mb4_uca1400_ai_ci |
+--------------------+--------+-----------+-----------------------------------------------------------------------------------------------------------------------------+--------+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+-----------------------+-----------------------+
2 rows in set (0.001 sec)

MariaDB [hr]>