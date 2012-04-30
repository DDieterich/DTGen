
REM
REM Drop Demonstration Schema Users
REM (Must be run as the "system" or "sys as sysdba" user)
REM

spool drop_demo_users
set define '&'
set verify off

REM Initialize Variables
REM
@vars

REM Configure SQL*Plus
REM
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set trimspool on
set serveroutput on
set define on

prompt
prompt This will remove the following roles and users from the database:
prompt
prompt   -) DEMO3_app role
prompt   -) DEMO3_dml role
prompt   -) &USR_NAME. user
prompt   -) &MT_NAME. user
prompt   -) &DB_NAME. user
prompt
prompt Press ENTER to continue
accept junk

drop role DEMO3_app;
drop role DEMO3_dml;

drop user &USR_NAME. cascade;
drop user &MT_NAME. cascade;
drop user &DB_NAME. cascade;

prompt If the above statement failed with "user that is currently connected", then
prompt    re-run this script
prompt

spool off

exit
