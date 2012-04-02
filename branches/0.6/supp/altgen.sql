
REM
REM  altgen.sql - Alternate script to generate an application
REM
REM  NOTE: This approach is an advanced option and is not recommended.
REM

set trimspool on
set serveroutput on
set define '&'
set verify off

define APP_ID = DTGEN     -- APPLICATIONS.ABBR for the Application

spool altgen
BEGIN
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&APP_ID.');
   generate.drop_usyn;
   generate.drop_mods;
   generate.drop_oltp;
   generate.drop_dist;
   generate.drop_integ;
   generate.delete_ods;
   generate.drop_ods;
   generate.drop_gdst;
   generate.drop_glob;
   generate.create_glob;
   generate.create_glob_sec;
   generate.create_gdst;
   generate.create_gdst_sec;
   generate.create_ods;
   generate.create_ods_sec;
   generate.create_integ;
   generate.create_integ_sec;
   generate.create_dist;
   generate.create_dist_sec;
   generate.create_oltp;
   generate.create_oltp_sec;
   generate.create_mods;
   generate.create_mods_sec;
   generate.create_usyn;
   generate.create_flow;
   commit;
END;
/
spool off

@select_file &APP_ID. drop_usyn
@select_file &APP_ID. drop_mods
@select_file &APP_ID. drop_oltp
@select_file &APP_ID. drop_dist
@select_file &APP_ID. drop_integ
@select_file &APP_ID. delete_ods
@select_file &APP_ID. drop_ods
@select_file &APP_ID. drop_gdst
@select_file &APP_ID. drop_glob
@select_file &APP_ID. create_glob
@select_file &APP_ID. create_glob_sec
@select_file &APP_ID. create_gdst
@select_file &APP_ID. create_gdst_sec
@select_file &APP_ID. create_ods
@select_file &APP_ID. create_ods_sec
@select_file &APP_ID. create_integ
@select_file &APP_ID. create_integ_sec
@select_file &APP_ID. create_dist
@select_file &APP_ID. create_dist_sec
@select_file &APP_ID. create_oltp
@select_file &APP_ID. create_oltp_sec
@select_file &APP_ID. create_mods
@select_file &APP_ID. create_mods_sec
@select_file &APP_ID. create_usyn
@select_file &APP_ID. create_flow

@comp_file &APP_ID.
