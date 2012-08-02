
--
--  g.sql - Sample script to create the DTGen GUI Maintenance Forms Script
--

spool g

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'
set trimspool on
set serveroutput on format wrapped
set verify off

define APP_ID = DTGEN   -- APPLICATIONS.ABBR for the Application

BEGIN
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&APP_ID.');
   generate.create_flow;
   commit;
END;
/

set linesize 4000
set pagesize 0
set feedback off
set termout off

spool install_gui.sql
execute assemble.install_script('&APP_ID.','GUI');

spool off
spool install_gui

set verify on
set termout on
set feedback 6
set pagesize 20
set linesize 80

@install_gui

spool off

HOST fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- g.LST

exit
