In Oracle, an empty string is NULL.
Createing an existing procedure without 'OR REPLACE' gives
an error "ORA-009955"
Changing '.env' folder after the first start doesn't change the existing database user


IF v_x = NULL THEN ...      -- never true, no error (bug)
IF v_x IS NULL THEN ...     -- correct


Oracle raised ORA-01403: no data found, which is the exception PL/SQL calls NO_DATA_FOUND.

SQL> @/scripts/topic3.sql
DECLARE
*
ERROR at line 1:
ORA-01422: exact fetch returned more than the requested number of rows (1)
Help: https://docs.oracle.com/error-help/db/ora-01422/


SQL>

we get this we we use %ROWCOUNT AFTER cursor close
*
ERROR at line 1:
ORA-01001: cursor number is invalid or does not exist
ORA-06512: at line 23
Help: https://docs.oracle.com/error-help/db/ora-01001/


SQL>


when u open the cursor again iwthout closing it

SQL> @/scripts/topic4.sql
DECLARE
*
ERROR at line 1:
ORA-06511: PL/SQL: cursor already open
ORA-06512: at line 2
ORA-06512: at line 6
Help: https://docs.oracle.com/error-help/db/ora-06511/


SQL>

- OPEN on an already-open explicit cursor raises ORA-06511 (CURSOR_ALREADY_OPEN).
- Cursor parameters: `salary > p_min` vs `>=` changes whether the boundary row is included.


//no row found bc id=99 which isn't on the table 

SQL> @/scripts/topic5.sql
DECLARE
*
ERROR at line 1:
ORA-01403: no data found
ORA-06512: at line 4
Help: https://docs.oracle.com/error-help/db/ora-01403/


SQL>

we also have zero division here 
Exercise 4 is correct too. Oracle reported -1476 and ORA-01476: divisor is equal to zero. Add it to findings.md.


- RAISE_APPLICATION_ERROR accepts only -20000 to -20999. Outside that range it raises
  ORA-21000 at run time (the function still compiles), and the intended message is lost.
- Errors that depend on data or values show up at call time; grammar errors at creation.


- Exception handled in the block: DML done before the error is NOT undone
  (Grace stayed 4100 until ROLLBACK).
- Exception unhandled (escapes the top-level block): Oracle rolls back that block's
  DML (Grace back to 4000). Earlier statements in the session are unaffected.
- DBMS_OUTPUT text is not rolled back.
goood topic for maria db 


- Exception scope: an error is matched against handlers in the current block, then
  outward. A handled error ends that block normally and execution continues after it.
  An error caught by an outer block skips the rest of the outer BEGIN section.
  With no matching handler anywhere, the error reaches the caller (ORA-01476 example).