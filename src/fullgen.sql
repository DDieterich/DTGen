
REM
REM  fullgen.sql - Sample script to generate all scripts for an application
REM

set define '&'
set trimspool on
set serveroutput on size 1000000 format wrapped
set verify off

define APP_ID = &1.   -- APPLICATIONS.ABBR for the Application

spool fullgen_&APP_ID.

prompt
prompt Running fullgen ...

BEGIN
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&APP_ID.');
   /*  Drop/Delete Scripts  */
   --generate.drop_usyn;
   generate.drop_mods;
   generate.drop_oltp;
   --generate.drop_dist;
   generate.drop_integ;
   --generate.delete_ods;
   generate.drop_ods;
   --generate.drop_gdst;
   generate.drop_glob;
   /*  Create Scripts  */
   generate.create_glob;
   --generate.create_gdst;
   generate.create_ods;
   generate.create_integ;
   --generate.create_dist;
   generate.create_oltp;
   generate.create_mods;
   --generate.create_usyn;
   /*  Create GUI Script  */
   --generate.create_flow;
   commit;
END;
/

prompt
prompt Creating SQL Scripts ...

set linesize 4000
set pagesize 0
set feedback off
set termout off

spool install_db.sql
execute assemble.install_script('&APP_ID.','DB');
--spool install_db_sec.sql
--execute assemble.install_script('&APP_ID.','DB','sec');
--spool install_mt.sql
--execute assemble.install_script('&APP_ID.','MT');
--spool install_mt_sec.sql
--execute assemble.install_script('&APP_ID.','MT','sec');
--spool install_usr.sql
--execute assemble.install_script('&APP_ID.','USR');
--spool install_gui.sql
--execute assemble.install_script('&APP_ID.','GUI');
spool uninstall_db.sql
execute assemble.uninstall_script('&APP_ID.','DB');
--spool uninstall_mt.sql
--execute assemble.uninstall_script('&APP_ID.','MT');
--spool uninstall_usr.sql
--execute assemble.uninstall_script('&APP_ID.','USR');
spool dtgen_dataload.ctl
execute assemble.data_script('&APP_ID.')
spool off

set verify on
set termout on
set feedback 6
set pagesize 20
set linesize 80

REM
REM  ============================================================
REM
REM  The folowing creates individual files for each script
REM
REM  NOTE: This approach is an advanced option and requires
REM     proper assembly of the install and uninstall files
REM     that are created.  Use of the ASSEMBLE package as 
REM     shown above is preferred.
REM
REM 
REM @select_file &APP_ID. drop_usyn
REM @select_file &APP_ID. drop_mods
REM @select_file &APP_ID. drop_oltp
REM @select_file &APP_ID. drop_dist
REM @select_file &APP_ID. drop_integ
REM @select_file &APP_ID. delete_ods
REM @select_file &APP_ID. drop_ods
REM @select_file &APP_ID. drop_gdst
REM @select_file &APP_ID. drop_glob
REM 
REM @select_file &APP_ID. create_glob
REM @select_file &APP_ID. create_glob_sec
REM @select_file &APP_ID. create_gdst
REM @select_file &APP_ID. create_gdst_sec
REM @select_file &APP_ID. create_ods
REM @select_file &APP_ID. create_ods_sec
REM @select_file &APP_ID. create_integ
REM @select_file &APP_ID. create_integ_sec
REM @select_file &APP_ID. create_dist
REM @select_file &APP_ID. create_dist_sec
REM @select_file &APP_ID. create_oltp
REM @select_file &APP_ID. create_oltp_sec
REM @select_file &APP_ID. create_mods
REM @select_file &APP_ID. create_mods_sec
REM @select_file &APP_ID. create_usyn
REM 
REM @select_file &APP_ID. create_flow
REM 
REM @comp_file &APP_ID.
REM 
