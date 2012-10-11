
--
-- DTGEN Un-Installation Script
-- (Must be run as the "system" or "sys as sysdba" user)
--

spool uninstall

-- Initialize Variables
--
define OWNERNAME = DTGEN     -- Schema Owner to be --oved
define APP_ABBR  = DTGEN     -- Application Abbreviation

-- Configure SQL*Plus
--
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set trimspool on
set serveroutput on format wrapped
set feedback off
set define on

prompt
prompt This will remove the following from the database:
prompt
prompt   -) User &OWNERNAME.
prompt   -) Application Roles for &APP_ABBR.
prompt
prompt Note: APEX Applications must be dropped manually
prompt Note: DTGen users must be dropped manually
prompt
prompt Press ENTER to continue
accept junk

@../supp/drop_owner &OWNERNAME.
@../supp/drop_app_role &APP_ABBR.

spool off
