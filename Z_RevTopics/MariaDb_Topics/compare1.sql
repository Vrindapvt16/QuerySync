DELIMITER $$
CREATE OR REPLACE FUNCTION grade(p_score IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_score IS NULL THEN
    RETURN 'n/a';
  ELSIF p_score >= 90 THEN
    RETURN 'A';
  ELSIF p_score >= 70 THEN
    RETURN 'B';
  ELSIF p_score >= 50 THEN
    RETURN 'C';
  ELSE
    RETURN 'F';
  END IF;
END;
$$
DELIMITER ;

SELECT 'grade(95)'   AS test_name, grade(95)   AS answer FROM dual
UNION ALL
SELECT 'grade(60)',   grade(60)   FROM dual
UNION ALL
SELECT 'grade(10)',   grade(10)   FROM dual
UNION ALL
SELECT 'grade(NULL)', grade(NULL) FROM dual
UNION ALL
SELECT 'grade(89.5)', grade(89.5) FROM dual;