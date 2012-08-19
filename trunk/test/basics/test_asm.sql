
--
--  rebuild.sql - Script to rebuild the DTGen application using DTGen
--
--  Note: This will only rebuild the database tier.
--        It does not (re)build:
--          -) User Synonyms
--          -) Mid-Tier
--          -) Mid-Tier Security
--          -) Database Security
--          -) APEX GUI Maintenance Forms
--

spool test_asm

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'
set trimspool on
set serveroutput on format wrapped
set verify off

define APP_ID = DTGEN   -- APPLICATIONS.ABBR for the Application

prompt
prompt Assembling SQL Scripts ...

set linesize 4000
set pagesize 0
set feedback off
set termout off

spool install_db.sql
execute assemble.install_script('&APP_ID.','DB');
spool uninstall_db.sql
execute assemble.uninstall_script('&APP_ID.','DB');
spool dtgen_dataload.ctl
execute assemble.data_script('&APP_ID.')
spool off

set verify on
set termout on
set feedback 6
set pagesize 20
set linesize 80

spool test_load

connect dtgen_test/dtgen_test@XE2
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set serveroutput on format wrapped

@install_db
@comp

spool off

exit
