
DTGen Demonstration #1
   Developed by DMSTEX (http://dmstex.com)


Table of Contents:
------------------
 -) Introduction
 -) Exercise #1: Basic Generation
 -) Exercise #2: Sequences and Surrogate Primary Keys
 -) Exercise #3: Indexed Foreign Keys and Natural Keys
 -) Exercise #4: Natural Key Updatable Views
 -) Exercise #5: Full Path Hierarchy Data
 -) Exercise #6: Enforced Descrete Domains
 -) Exercise #7: Enforced Case Folding
 -) Exercise #8: Full Procedural APIs
 -) Exercise #9: Custom Check Constraints


File Descriptions in this directory:
------------------------------------
assemble.pkb       - Used by install.sql
assemble.pks       - Used by install.sql
f900.sql           - APEX export of the GUI source for DTGen
generate.pkb       - Used by install.sql
generate.pks       - Used by install.sql
install.sql        - Installs DTGen in an Oracle database
install_db.sql     - Used by install.sql
uninstall.sql      - Uninstalls DTGen


Introduction:
-------------
  The set of exercises in this demonstration is focused on basic DTGen functionality.  All functionality in this demonstration is available through both command line and graphical user interface (GUI) forms.  For simplicity in understanding the under-lying workings of DTGen, this demonstration is conducted entirely by command-line.  (No GUIs will be injured during the execution of this demonstration.)

  This demonstration directory contains several exercises.  The exercises are numbered and must be executed in sequential order.  The demo users must be created with the "create_demo_users.sql" script in the parent directory before the first exercise is run.  The demo users must be dropped with the "drop_demo_users.sql" script before the "create_demo_users.sql" script can be re-used.  The exercises also assume that the default username/password (dtgen/dtgen) is still in use for the generator.  Names and passwords are set at the top of each script and can be modified, if necessary.  Also, the DTGen database objects must be installed in the database and ready to generate code.


Exercise #1: Basic Generation
-----------------------------

  Command Line:
  -------------
  sqlplus /nolog @e1

  Based on Oracle's demobld.sql script, this exercise implements the EMP and DEPT tables using DTGen.  The script for this exercise performs the following functions:
  
  1) Removes any old DEMO1 Items from DTGEN
  2) Creates new DEMO1 Items in DTGEN
  3) Generates the DEMO1 Application in DTGEN
  4) Creates the "install_db.sql" script
  5) Runs the "install_db.sql" script
  6) Loads and Reports Data

  Steps 1-3 are captured in the "e1.LST" file:

============================================================
Login to dtgen
Connected.
Remove old DEMO Schema from DTGEN
create a DEMO Schema in DTGEN
Generate Demo1 Application
Capture install_db.sql Script
============================================================

  Step 4 is captured in the "install_db.sql" file.  This file is 78,281 bytes and has 3,145 lines.  It is not listed here.

  Steps 5 and 6 are captured in the "install.LST" file:

============================================================
Login to dtgen_db_demo
Connected.

TABLE_NAME
--------------
***  dept  ***

TABLE_NAME
-------------
***  emp  ***

TABLE_NAME
--------------
***  dept  ***

TABLE_NAME
-------------
***  emp  ***

TABLE_NAME
--------------
***  dept  ***

TABLE_NAME
-------------
***  emp  ***

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON

     EMPNO ENAME            JOB        M_EMP_NK1 HIREDATE         SAL D_DEPT_NK1
---------- ---------------- --------- ---------- --------- ---------- ----------
      7782 CLARK            MANAGER         7839 09-JUN-81       2450         10
      7698 BLAKE            MANAGER         7839 01-MAY-81       2850         30
      7566 JONES            MANAGER         7839 02-APR-81       2975         20
      7902 FORD             ANALYST         7566 03-DEC-81       3000         20
      7788 SCOTT            ANALYST         7566 09-DEC-82       3000         20
      7876 ADAMS            CLERK           7788 12-JAN-83       1100         20
      7369 SMITH            CLERK           7902 17-DEC-80        800         20
      7900 JAMES            CLERK           7698 03-DEC-81        950         30
      7844 TURNER           SALESMAN        7698 08-SEP-81       1500         30
      7654 MARTIN           SALESMAN        7698 28-SEP-81       1250         30
      7521 WARD             SALESMAN        7698 22-FEB-81       1250         30

     EMPNO ENAME            JOB        M_EMP_NK1 HIREDATE         SAL D_DEPT_NK1
---------- ---------------- --------- ---------- --------- ---------- ----------
      7499 ALLEN            SALESMAN        7698 20-FEB-81       1600         30
      7934 MILLER           CLERK           7782 23-JAN-82       1300         10
      7839 KING             PRESIDENT            17-NOV-81       5000         10
============================================================

   The successful running of the "e1.sql" script demonstrates loading creating an application in DTGen, generating the application, creating the application schema, and populating the application with data.

