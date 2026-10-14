Empty strings are of NULL type in Oracle

This is about error ORA-00955
SQL> CREATE PROCEDURE say_hello IS
     BEGIN
         DBMS_OUTPUT.PUT_LINE('hello');
     END;

ORA-00955: name is already used by an existing object

https://docs.oracle.com/error-help/db/ora-00955/
Error at Line: 1 Column: 1
