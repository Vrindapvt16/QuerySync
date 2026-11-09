START TRANSACTION;

UPDATE accounts
SET balance = balance - 50
WHERE account_id = 1;

SELECT * FROM accounts;





-- START TRANSACTION;

-- UPDATE accounts
-- SET balance = balance - 100
-- WHERE account_id = 1;

-- UPDATE accounts
-- SET balance = balance + 100
-- WHERE account_id = 2;

-- COMMIT;