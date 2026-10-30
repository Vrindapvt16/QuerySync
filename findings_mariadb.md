## Test 0: employees table (MariaDB 11.8.9, sql_mode=ORACLE)

| Check | Oracle | MariaDB |
|---|---|---|
| CREATE TABLE with NUMBER, VARCHAR2 | created | created, no errors |
| NUMBER column type | NUMBER | double |
| VARCHAR2(50) | VARCHAR2(50) | varchar(50) |
| PRIMARY KEY | ok | ok |
| Identifier quoting in SHOW CREATE TABLE | n/a | double quotes (ANSI_QUOTES in sql_mode) |


