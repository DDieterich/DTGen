
Welcome to DTGen

NOTE: The APEX GUI "f900.sql" creates database objects with the prefix
  "GUI_".  Use of this prefix for database objects in an application
  may cause problems/error with APEX GUI objects in the database.


Files and Directories:
----------------------
demo           - Directory of demonstration files and scripts
dev            - Directory of scripts to support dual version generation
docs           - Directory of DTGen documentation
gui            - Directory of Graphical User Interface files and scripts
src            - Directory of source code for DTGen
supp           - Directory of supplemental installation and sample scripts
test           - Directory of test scripts
install.sql    - Installs DTGen Schema. Run as sys or system.
uninstall.sql  - Uninstalls the DTGen Schema Owner. Run as sys or system


DTGen Installation:
-------------------
1) Install and Confirm Oracle Database installation
   -) Install Oracle10g or higher, any Database Edition
      (Express, Personal, Standard One, Standard, or Enterprise)
   -) Confirm SQL*Plus command line connection
      (sqlplus sys/password as sysdba)
2) Install DTGen objects in database
   -) Review and optionally edit "install.sql"
      (Values for variables OWNERNAME, OWNERPASS, and TSPACE)
   -) Run the database installation script in SQL*Plus
      (sqlplus sys/password as sysdba @install)
   -) Review the output in the install.LST file.
      (The output from a successful installation is below)
3) Install DTGen application in APEX (optional)
   -) cd to the gui sub-directory and follow the instructions in README.txt


DTGen Un-install:
-----------------
   -) cd to the gui sub-directory and follow the instructions in README.txt
   -) Review and optionally edit "uninstall.sql"
      (Values for variables OWNERNAME, OWNERPASS, and TSPACE)
   -) sqlplus system/password @uninstall
      (Document the uninstall.sql output)


==================================================
Output from a successful installation:
--------------------------------------
Connected.

TABLE_NAME
----------------------
***  applications  ***

TABLE_NAME
---------------
***  files  ***

TABLE_NAME
--------------------
***  file_lines  ***

TABLE_NAME
-----------------
***  domains  ***

TABLE_NAME
-----------------------
***  domain_values  ***

TABLE_NAME
----------------
***  tables  ***

TABLE_NAME
------------------
***  tab_cols  ***

TABLE_NAME
-----------------
***  indexes  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

TABLE_NAME
----------------------
***  applications  ***

TABLE_NAME
---------------
***  files  ***

TABLE_NAME
--------------------
***  file_lines  ***

TABLE_NAME
-----------------
***  domains  ***

TABLE_NAME
-----------------------
***  domain_values  ***

TABLE_NAME
----------------
***  tables  ***

TABLE_NAME
------------------
***  tab_cols  ***

TABLE_NAME
-----------------
***  indexes  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

TABLE_NAME
----------------------
***  applications  ***

TABLE_NAME
---------------
***  files  ***

TABLE_NAME
--------------------
***  file_lines  ***

TABLE_NAME
-----------------
***  domains  ***

TABLE_NAME
-----------------------
***  domain_values  ***

TABLE_NAME
----------------
***  tables  ***

TABLE_NAME
------------------
***  tab_cols  ***

TABLE_NAME
-----------------
***  indexes  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

generate.pks

Pacakge created.

assemble.pks

Package created.

generate.pkb

Package body created.

assemble.pkb

Package body created.

==================================================
