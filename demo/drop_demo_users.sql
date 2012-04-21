
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
prompt This will remove the following users from the database:
prompt
prompt   -) &USR_NAME.
prompt   -) &MT_NAME.
prompt   -) &DB_NAME.
prompt
prompt Press ENTER to continue
accept junk

drop user &USR_NAME. cascade;

drop role &MT_NAME._app;
drop role &MT_NAME._dml;
drop user &MT_NAME. cascade;

drop role &DB_NAME._app;
drop role &DB_NAME._dml;
drop user &DB_NAME. cascade;

spool off

exit
