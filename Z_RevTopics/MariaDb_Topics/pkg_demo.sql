DELIMITER $$
CREATE OR REPLACE PACKAGE pkg_d IS
  FUNCTION max_raise RETURN NUMBER;
END pkg_d;
$$

CREATE OR REPLACE PACKAGE BODY pkg_d IS
  c_max_raise_pct CONSTANT NUMBER := 20;
  FUNCTION max_raise RETURN NUMBER IS
  BEGIN
    RETURN c_max_raise_pct;
  END max_raise;
END pkg_d;
$$
DELIMITER ;

SELECT pkg_d.max_raise() AS x;