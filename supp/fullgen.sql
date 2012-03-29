
REM
REM  fullgen.sql - Sample script to generate all scripts for an application
REM

set trimspool on
set serveroutput on
set define '&'
set verify off

define APP_ID = GEN     -- APPLICATIONS.ABBR for the Application

spool gen
BEGIN
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   -- The following calls are equivalent to "generate.run('&APP_ID.');"
   generate.cr('&APP_ID.');
   generate.dr('&APP_ID.');
   generate.usr('&APP_ID.');
   generate.gui('&APP_ID.');
END;
/
spool off

set linesize 4000
set trimspool 1048576
set pagesize 0
set feedback off
set termout off

spool install_db.sql
execute assemble.install('&APP_ID.','DB','');
spool dtgen_dataload.ctl
assemble.data_script('&APP_ID.')
spool install_db_sec.sql
execute assemble.install('&APP_ID.','DB','sec');
spool install_mt.sql
execute assemble.install('&APP_ID.','MT','');
spool install_mt_sec.sql
execute assemble.install('&APP_ID.','MT','sec');
spool install_usr.sql
execute assemble.install('&APP_ID.','USR','');
spool install_gui.sql
execute assemble.install('&APP_ID.','GUI','');
spool uninstall_mt.sql
execute assemble.uninstall('&APP_ID.','MT','');
spool uninstall_usr.sql
execute assemble.uninstall('&APP_ID.','USR','');
spool uninstall_db.sql
execute assemble.uninstall('&APP_ID.','DB','');
spool off

set verify on
set termout on
set feedback 6
set pagesize 20
set linesize 80
