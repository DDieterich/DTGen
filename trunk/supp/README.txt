
DTGen "supp" (Supplemental Install and Sample) README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
bug_grants.sql     - Permission grants needed to overcome a loopback bug in Oracle
                     -) Schema/User needing access via DB link is first parameter
comp_file.sql      - SPOOL script used by an alternaitve path in fullgen.sql
create_app_role    - Creates all application roles before application installation
                     -) Application Abbreviation is the first parameter
create_owner.sql   - Used by install.sql to create the DTGen owner and roles
                     -) Must be run as sys (to grant DBMS_LOCK)
                     -) New Schema Owner Name is the first parameter
                     -) New Schema Owner Password is the second parameter
                     -) New Schema Owner Default Tablespace is the third parameter
                     -) New Schema Owner Temporary Tablespace is the fourth parameter
create_user.sql    - Script used to create an application user
                     -) Must be run by sys or system
                     -) Creates the user and synonyms and grants permissions
drop_app_role.sql  - Drops all application roles after application un-installation
                     -) Application Abbreviation is the first parameter
drop_owner.sql     - Script used to drop a DTGen owner and roles
drop_user.sql      - Script used to drop an application user
dtgen_dataload.ctl - SQL*Loader control file with data that will generate DTGen
fullasm.sql        - SPOOL script used to assemble scripts for an application
                     -) The ABBR of the application is the first parameter
                        NOTE: must be run after fullgen.sql
fullgen.sql        - Script used to generate scripts for an application
                     -) The ABBR of the application is the first parameter
grant_app_role.sql - Script to grant application role to an application user
                     -) Application Abbreviation is the first parameter
                     -) User reciebing the grants is the second parameter
grant_role_option.sql - Required for users to create Application packages
                     -) Application Abbreviation is the first parameter
                     -) User reciebing the grants is the second parameter
select_file.sql    - SPOOL script used by an alternative path in fullgen.sql


SQL Script Settings:
--------------------
SPOOL scripts
   Require the following settings before running
   -) WHENEVER OSERROR
   -) WHENEVER SQLERROR
   -) set termout
   -) connect
   Set and reset the following attributes:
   -) spool             - Reset to "off"
   -) set define        - Reset to "&"
   -) set feedback      - Reset to "6"
   -) set linesize      - Reset to "80"
   -) set pagesize      - Reset to "20"
   -) set serveroutput  - Reset to "on format wrapped"
   -) set trimspool     - Reset to "on"
   -) set verify        - Reset to "on"
NON-SPOOL scripts
   Require the following settings before running
   -) spool
   -) WHENEVER OSERROR
   -) WHENEVER SQLERROR
   -) set termout
   -) set trimspool
   -) connect
   Set and reset the following attributes:
   -) set define        - Reset to "&"
   -) set serveroutput  - Reset to "on format wrapped"

Script files created by fullasm.sql:
------------------------------------
install_db.sql     - Creates the schema objects needed for the database (data-tier)
                     -) GLOBal objects (Global Types, UTIL_LOG, and UTIL & GLOB Package)
                     -) ODS objects (Sequences, Tables, Indexes, and POP Packages)
                     -) INTEGrity objects (Table Constraints/Triggers and TAB Packages)
                     -) OLTP objects (Views, View Packages, and DML Packages)
                     -) MODuleS objects (Place holder for Tailored Packages)
install_db_sec.sql - Creates security for the schema objects needed for the database
install_mt.sql     - Creates the schema objects needed for the mid-tier
                     -) Global DIST objects (Global Synonyms, UTIL_LOG, and UTIL Package)
                     -) DISTribution objects (Distributed Synonyms, MVs, and TAB Packages)
                     -) OLTP objects (Views, View Packages, and DML Packages)
                     -) MODuleS objects (Place holder for Tailored Packages)
install_mt_sec.sql - Creates security for the schema objects needed for the mid-tier
install_usr.sql    - Creates synonyms for the application user
install_gui.sql    - Creates the Maintenance GUI (Forms, Reports, Menus, LOVs, and Preferences)
uninstall_usr.sql  - Drops synonyms for the application user
uninstall_mt.sql   - Drops the schema objects needed for the mid-tier
uninstall_db.sql   - Drops the schema objects needed for the database (data-tier)
(AID)_dataload.ctl - SQL*Loader control file with data that will generate AID
                     -) NOTE: (AID) is a placeholder for an actual application ID like "dtgen"


Script files created by an alternaitve path in fullasm.sql:
-----------------------------------------------------------
comp.sql             - Creates application specific COMPiled packages, functions, and procedures
create_dist.sql      - Creates the DISTribution objects (Distributed Synonyms, MVs, and TAB Packages)
create_dist_sec.sql  - Creates security for the DIST objects
create_flow.sql      - Creates the Maintenance GUI (Forms, Reports, Menus, LOVs, and Preferences)
create_gdst.sql      - Creates the Global DIST objects (Global Synonyms, UTIL_LOG, and UTIL Package)
create_gdst_sec.sql  - Creates security for the Global DIST objects
create_glob.sql      - Creates the GLOBal objects (Global Types, UTIL_LOG, and UTIL & GLOB Package)
create_glob_sec.sql  - Creates security for the GlOB objects
create_integ.sql     - Creates the INTEGrity objects (Table Constraints/Triggers and TAB Packages)
create_integ_sec.sql - Creates security for the INTEG objects
create_mods.sql      - Creates the MODuleS objects (Place holder for Tailored Packages)
create_mods_sec.sql  - Creates security for the MODS objects
create_ods.sql       - Creates the ODS objects (Sequences, Tables, Indexes, and POP Packages)
create_ods_sec.sql   - Creates security for the ODS objects
create_oltp.sql      - Creates the OLTP objects (Views, View Packages, and DML Packages)
create_oltp_sec.sql  - Creates security for the OLTP objects
create_usyn.sql      - Creates synonyms for the application user
delete_ods.sql       - Deletes all data from the application schema
drop_dist.sql        - Drops the DISTribution objects
drop_gdst.sql        - Drops the Global DIST objects
drop_glob.sql        - Drops the GLOBal objects
drop_integ.sql       - Drops the INTEGrity objects
drop_mods.sql        - Drops the MODuleS objects
drop_ods.sql         - Drops the ODS objects
drop_oltp.sql        - Drops the OLTP objects
drop_usyn.sql        - Drops synonyms for the application user
