
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

spool rebuild_generate

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
prompt Running generation ...

BEGIN

   /*  Initialize  */
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&APP_ID.');

   /*  Drop/Delete Scripts  */
   generate.drop_mods;
   generate.drop_oltp;
   generate.drop_integ;
   generate.drop_ods;
   generate.drop_glob;

   /*  Create Scripts  */
   generate.create_glob;
   generate.create_ods;
   generate.create_integ;
   generate.create_oltp;
   generate.create_mods;

END;
/

commit;

prompt
prompt Creating SQL Scripts ...

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
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

spool rebuild_reload

@uninstall_db
@install_db
@comp

spool off

exit
