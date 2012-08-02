
Welcome to DTGen

NOTE: The APEX GUI "f900.sql" creates database objects with the prefix
  "GUI_".  Use of this prefix for database objects in an application
  may cause problems/error with APEX GUI objects in the database.


Files and Directories:
----------------------
demo           - Directory of demonstration files and scripts directory
docs           - Directory of DTGen documentation directory
f900.sql       - APEX export of the GUI source for DTGen
install.sql    - Installs DTGen Schema. Run as sys or system.
src            - Direcotry of source code for DTGen
supp           - Directory of supplemental installation and sample scripts
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
   -) If APEX is not installed, install 4.0 or better.
      (Continue with next setp if unsure.)
      (Every Database Edition includes APEX)
   -) Login to APEX as an administrator
      (Different versions do this differently.)
	  (There should be some menu option or desktop icon to get to APEX)
      (-OR- try http://127.0.0.1:8080/apex)
	  (If the login requests a workspace, use INTERNAL, user "ADMIN", and the dba password)
	  (If the login does not request a workspace, try user "SYSTEM" and the dba password)
   -) Confirm/Install APEX 4.0 or better
	  (Lower right corner of APEX home page, ex: "Application Express 4.0.2.00.09")
	  (Upgrade to APEX 4.0 if needed: "http://www.oracle.com/technetwork/developer-tools/apex")
   -) Create a workspace on an existing Database/Schema User
      (Different versions do this differently.)
	  Existing Database/Schema User: YES
      Database or Schema Username: dtgen
	  Workspace or APEX Username: dtgen
	  Password: dtgen
   -) Logout of APEX
   -) Login to APEX as Workspace User dtgen
   -) Click on "Application Builder"
   -) Click on "Import"
   -) Click on "Browse" to open a "Choose File to Upload" window.
   -) Select "f900.sql" and click on "Open" to close the window.
   -) File Type: Database Application, Page or Component
   -) Click on "Next"
   -) Receive the screen "Successfully Imported File"
   -) Click on "Next"
   -) Review the following parameters:
      Current Workspace: DTGEN
	  Export File Application ID: 900
	  Export File Version: 2010.05.03
	  Export File Parsing Schema: DTGEN
	  Application Origin: This application was exported from another workspace.
      Parsing Schema: DTGEN
	  Build Status: Run and Build Application
      Install as Application: Reuse Application ID 900 From Export File
   -) Click on "Install"
   -) Review the following parameters:
      Application: 900 - DTGen
	  Parsing Schema: DTGEN
	  Free Space Required in KB: 0
      Install Supporting Objects: Yes
   -) Click on "Next"
   -) Click on "Install"
   -) Click on "Install Summary"
   -) All scripts have a status of SUCCESS


DTGen Un-install:
-----------------
   -) Remove the DTGen application from APEX
   -) Remove the DTGEN workspace from APEX
      (May need to login as "ADMIN" using workspace "INTERNAL")
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
