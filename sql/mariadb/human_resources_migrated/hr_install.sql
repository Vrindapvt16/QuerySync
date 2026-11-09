-- This is the installer file in the origonal file and it is written in
-- SQL PLUS and migrating most of is difficult 
-- so i used my own installed to set up the other data base files 


SET sql_mode='ORACLE';
DROP DATABASE IF EXISTS hr;
CREATE DATABASE hr;
-- optional: CREATE USER + GRANT ... ON hr.* 
USE hr;
source hr_create.sql
source hr_populate.sql
source hr_code.sql
-- then the verification SELECT from the original, which may work as is