Interesting point
Transactions: Oracle and MariaDB both support transactions, but you should test details such as implicit commits, DDL behaviour, isolation and rollback.

Storage: Oracle manages storage differently. MariaDB's storage-engine choice, especially InnoDB, can affect locking, foreign keys and transaction behaviour.

Don't assume that similar SQL statements always produce identical transaction behaviour.


Another difference is in parameter order of procedures
3. Important lesson for your project
Compare the two syntaxes:
Standard MariaDB	Oracle mode
IN p_id INT	p_id IN INT
OUT total INT	total OUT INT
INOUT value INT	value IN OUT INT

so IN p_id INT in maria db while p_id IN INT in oracle mode 