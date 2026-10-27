DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
  emp_id  NUMBER PRIMARY KEY,
  name    VARCHAR2(50),
  dept    VARCHAR2(20),
  salary  NUMBER
);

INSERT INTO employees VALUES (1, 'Ada',   'IT',    5000);
INSERT INTO employees VALUES (2, 'Linus', 'IT',    4500);
INSERT INTO employees VALUES (3, 'Grace', 'HR',    4000);
INSERT INTO employees VALUES (4, 'Alan',  'Sales', 3500);
COMMIT;