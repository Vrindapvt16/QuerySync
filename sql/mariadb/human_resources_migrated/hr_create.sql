-- REGIONS
CREATE TABLE regions (
  region_id    NUMBER NOT NULL,
  region_name  VARCHAR2(25),
  CONSTRAINT reg_id_pk PRIMARY KEY (region_id)
);

-- COUNTRIES
CREATE TABLE countries (
  country_id   CHAR(2) NOT NULL,
  country_name VARCHAR2(60),
  region_id    NUMBER,
  CONSTRAINT country_c_id_pk PRIMARY KEY (country_id)
);
ALTER TABLE countries
  ADD CONSTRAINT countr_reg_fk FOREIGN KEY (region_id) REFERENCES regions(region_id);

-- LOCATIONS
CREATE TABLE locations (
  location_id    NUMBER(4),
  street_address VARCHAR2(40),
  postal_code    VARCHAR2(12),
  city           VARCHAR2(30) NOT NULL,
  state_province VARCHAR2(25),
  country_id     CHAR(2),
  CONSTRAINT loc_id_pk PRIMARY KEY (location_id)
);
ALTER TABLE locations
  ADD CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id) REFERENCES countries(country_id);

CREATE SEQUENCE locations_seq START WITH 3300 INCREMENT BY 100 MAXVALUE 9900 NOCACHE NOCYCLE;

-- DEPARTMENTS
CREATE TABLE departments (
  department_id   NUMBER(4),
  department_name VARCHAR2(30) NOT NULL,
  manager_id      NUMBER(6),
  location_id     NUMBER(4),
  CONSTRAINT dept_id_pk PRIMARY KEY (department_id)
);
ALTER TABLE departments
  ADD CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations(location_id);

CREATE SEQUENCE departments_seq START WITH 280 INCREMENT BY 10 MAXVALUE 9990 NOCACHE NOCYCLE;

-- JOBS
CREATE TABLE jobs (
  job_id     VARCHAR2(10),
  job_title  VARCHAR2(35) NOT NULL,
  min_salary NUMBER(6),
  max_salary NUMBER(6),
  CONSTRAINT job_id_pk PRIMARY KEY (job_id)
);

-- EMPLOYEES
CREATE TABLE employees (
  employee_id    NUMBER(6),
  first_name     VARCHAR2(20),
  last_name      VARCHAR2(25) NOT NULL,
  email          VARCHAR2(25) NOT NULL,
  phone_number   VARCHAR2(20),
  hire_date      DATE NOT NULL,
  job_id         VARCHAR2(10) NOT NULL,
  salary         NUMBER(8,2),
  commission_pct NUMBER(2,2),
  manager_id     NUMBER(6),
  department_id  NUMBER(4),
  CONSTRAINT emp_emp_id_pk PRIMARY KEY (employee_id),
  CONSTRAINT emp_salary_min CHECK (salary > 0),
  CONSTRAINT emp_email_uk UNIQUE (email)
);
ALTER TABLE employees ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE departments ADD CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

CREATE SEQUENCE employees_seq START WITH 207 INCREMENT BY 1 NOCACHE NOCYCLE;

-- JOB_HISTORY
CREATE TABLE job_history (
  employee_id   NUMBER(6) NOT NULL,
  start_date    DATE NOT NULL,
  end_date      DATE NOT NULL,
  job_id        VARCHAR2(10) NOT NULL,
  department_id NUMBER(4),
  CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date),
  CONSTRAINT jhist_date_interval CHECK (end_date > start_date)
);
ALTER TABLE job_history ADD CONSTRAINT jhist_job_fk FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- VIEW (WITH READ ONLY removed)
CREATE OR REPLACE VIEW emp_details_view
  (employee_id, job_id, manager_id, department_id, location_id, country_id,
   first_name, last_name, salary, commission_pct, department_name, job_title,
   city, state_province, country_name, region_name)
AS SELECT
  e.employee_id, e.job_id, e.manager_id, e.department_id, d.location_id, l.country_id,
  e.first_name, e.last_name, e.salary, e.commission_pct, d.department_name, j.job_title,
  l.city, l.state_province, c.country_name, r.region_name
FROM employees e, departments d, jobs j, locations l, countries c, regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id;

-- INDEXES
CREATE INDEX emp_department_ix ON employees (department_id);
CREATE INDEX emp_job_ix ON employees (job_id);
CREATE INDEX emp_manager_ix ON employees (manager_id);
CREATE INDEX emp_name_ix ON employees (last_name, first_name);
CREATE INDEX dept_location_ix ON departments (location_id);
CREATE INDEX jhist_job_ix ON job_history (job_id);
CREATE INDEX jhist_employee_ix ON job_history (employee_id);
CREATE INDEX jhist_department_ix ON job_history (department_id);
CREATE INDEX loc_city_ix ON locations (city);
CREATE INDEX loc_state_province_ix ON locations (state_province);
CREATE INDEX loc_country_ix ON locations (country_id);