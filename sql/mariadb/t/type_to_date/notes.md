- O1: TO_DATE() is not available on MariaDB 11.8.9:
  SELECT TO_DATE('26-OCT-25','DD-MON-RR') gives ERROR 1305 (FUNCTION
  sql_practice.TO_DATE does not exist). On 12.3.3 the same statement
  returns 2025-10-26 00:00:00. The function was added in 12.3
  (MDEV-19683); a documented version change, not a gap.

  