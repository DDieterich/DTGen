
REM
REM Drop Demonstration Schema Users
REM (Must be run as the "system" or "sys as sysdba" user)
REM

spool drop_demo_users
set define '&'

REM Initialize Variables
REM
define USR_NAME = dtgen_usr_demo -- DEMO User Username
define MT_NAME = dtgen_mt_demo   -- Mid-Tier DEMO Schema Username
define DB_NAME = dtgen_db_demo   -- Database DEMO Schema Username

REM Configure SQL*Plus
REM
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set trimspool on
set serveroutput on
set feedback off
set define on

prompt
prompt This will remove the following user from the database:
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
