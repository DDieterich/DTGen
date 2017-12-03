
Welcome to DTGen

The Wiki is in the Wiki Branch: https://github.com/DDieterich/dtgen/blob/wiki/README.md

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


DTGen Installation:
-------------------
1) Install and Confirm Oracle Database installation
   -) Install Oracle10g or higher, any Database Edition
      (Express, Personal, Standard One, Standard, or Enterprise)
   -) Confirm SQL*Plus command line connection
      (sqlplus sys/password as sysdba)
2) Install DTGen objects in database
   -) cd to the "src" sub-directory
   -) Review and optionally edit "install.sql"
      (Values for variables OWNERNAME, OWNERPASS, and TSPACE)
   -) Run the database installation script in SQL*Plus
      (sqlplus sys/password as sysdba @install)
   -) Review the output in the install.LST file.
      (The output from a successful installation is below)
3) Install DTGen application in APEX (optional)
   -) cd to the "gui" sub-directory and follow the instructions in README.txt


DTGen Data Load (optional):
---------------------------
DTGen is self-generated.  To expand the functionality of DTGen, the data used to
generate this current version of DTGen is available to load into DTGen.  Load this
data into DTGen to assist with the generation of a new version of DTGen.

 -) cd supp
 -) sqlldr dtgen/dtgen control=dtgen_dataload.ctl
 -) (Review the dtgen_dataload.log file)


DTGen Un-install:
-----------------
   -) cd to the gui sub-directory and follow the instructions in README.txt
   -) Review and optionally edit "uninstall.sql"
      (Values for variables OWNERNAME, OWNERPASS, and TSPACE)
   -) sqlplus system/password @uninstall
      (Document the uninstall.sql output)

==================================================
Output from a successful UN-installation:
-----------------------------------------

This will remove the following from the database:

-) User DTGEN
-) Application Roles for DTGEN

Note: APEX Applications must be dropped manually
Note: DTGen users must be dropped manually

Press ENTER to continue

old   1: drop user &1. cascade
new   1: drop user DTGEN cascade
old   1: drop role &1._dml
new   1: drop role DTGEN_dml
old   1: drop role &1._app
new   1: drop role DTGEN_app
SQL>


==================================================
Output from a successful installation:
--------------------------------------
Connected.

FILE_NAME
-----------------
 -) create_glob

FILE_NAME
----------------
 -) create_ods

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
------------------
***  tab_inds  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

FILE_NAME
------------------
 -) create_integ

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
------------------
***  tab_inds  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

FILE_NAME
-----------------
 -) create_oltp

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
------------------
***  tab_inds  ***

TABLE_NAME
--------------------
***  check_cons  ***

TABLE_NAME
------------------
***  programs  ***

TABLE_NAME
--------------------
***  exceptions  ***

FILE_NAME
---------------
 -) create_aa

FILE_NAME
-----------------
 -) create_mods

=== Compile Stored Program Units ===

dtgen_util.pks
No errors.

generate.pks
No errors.

dtgen_util.pkb
No errors.

generate.pkb
No errors.

SQL> exit
==================================================
