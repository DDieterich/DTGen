
--
-- DTGEN Un-Installation Script
-- (Must be run as the "system" or "sys as sysdba" user)
--

spool uninstall

-- Initialize Variables
--
define OWNERNAME = dtgen     -- Schema Owner to be --oved

-- Configure SQL*Plus
--
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set trimspool on
set serveroutput on
set feedback off
set define on

prompt
prompt This will remove the following user from the database:
prompt
prompt   -) &OWNERNAME.
prompt
prompt Note: APEX Applications must be dropped manually
prompt Note: DTGen users must be dropped manually
prompt
prompt Press ENTER to continue
accept junk

drop role &OWNERNAME._app;
drop role &OWNERNAME._dml;
drop user &OWNERNAME. cascade;

spool off
