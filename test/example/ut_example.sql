
-- Connect as the database user that will be used to run the unit tests.
-- Then, enter the following statements:

DROP TABLe employees; 
CREATE TABLE employees
   (employee_id NUMBER PRIMARY KEY
   ,commission_pct NUMBER
   ,salary NUMBER);
INSERT INTO employees VALUES (1001, 0.2, 8400);
INSERT INTO employees VALUES (1002, 0.25, 6000);
INSERT INTO employees VALUES (1003, 0.3, 5000);
-- Next employee is not in the Sales department, thus is not on commission.
INSERT INTO employees VALUES (1004, null, 10000);
commit;

create or replace
PROCEDURE award_bonus (
  emp_id NUMBER, sales_amt NUMBER) AS
  commission    REAL;
  comm_missing  EXCEPTION;
BEGIN
  SELECT commission_pct INTO commission
    FROM employees
      WHERE employee_id = emp_id;
 
  IF commission IS NULL THEN
    RAISE comm_missing;
  ELSE
    UPDATE employees
      SET salary = salary + sales_amt*commission
        WHERE employee_id = emp_id;
  END IF;
END award_bonus;
/

CREATE TABLE award_bonus_dyn_query (emp_id NUMBER PRIMARY KEY, sales_amt NUMBER);
INSERT INTO award_bonus_dyn_query VALUES (1001, 5000);
INSERT INTO award_bonus_dyn_query VALUES (1002, 6000);
INSERT INTO award_bonus_dyn_query VALUES (1003, 2000);
