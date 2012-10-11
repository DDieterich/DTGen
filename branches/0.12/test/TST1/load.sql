
--
-- Load Script
--
--   This script replicates most of the functionality of supp/fullgen.sql.
--      This script does not generate the create_gui file, which takes
--      considerable time.
--
--   This script also uses supp/select_file.sql instead of supp/fullasm.sql
--      to enable selective creation of the contents of the SQL scripts.
--
-- &1. is the DTGEN application abbreviation
-- &2. is the DTGEN connection string
--

set define '&'
connect &2.
set serveroutput on format wrapped
whenever sqlerror exit
whenever oserror exit

prompt
prompt Running fullgen ...

BEGIN

   /*  Initialize  */
   glob.set_usr('Test Load');  -- Any string will work for this parameter
   generate.init('&1.');

   /*  Drop Scripts  */
   generate.drop_usyn;
   generate.drop_mods;
   generate.drop_oltp;
   generate.drop_dist;
   generate.drop_aa;
   generate.drop_integ;
   generate.drop_ods;
   generate.drop_gusr;
   generate.drop_gdst;
   generate.drop_glob;

   /*  Create Scripts  */
   generate.create_glob;
   generate.create_gdst;
   generate.create_gusr;
   generate.create_ods;
   generate.create_integ;
   generate.create_aa;
   generate.create_dist;
   generate.create_oltp;
   generate.create_mods;
   generate.create_usyn;

END;
/

commit;

prompt
prompt Collecting Scripts ...

--
--  ============================================================
--
--  The folowing creates individual files for each script
--
--  NOTE: This approach is an advanced option and requires
--     proper assembly of the install and uninstall files
--     that are created.  Use of the dtgen_util package as 
--     shown above is preferred.

@../../supp/select_file &1. drop_usyn
@../../supp/select_file &1. drop_mods
@../../supp/select_file &1. drop_aa
@../../supp/select_file &1. drop_oltp
@../../supp/select_file &1. drop_dist
@../../supp/select_file &1. drop_integ
@../../supp/select_file &1. drop_ods
@../../supp/select_file &1. drop_gusr
@../../supp/select_file &1. drop_gdst
@../../supp/select_file &1. drop_glob

@../../supp/select_file &1. create_glob
@../../supp/select_file &1. create_glob_sec
@../../supp/select_file &1. create_gdst
@../../supp/select_file &1. create_gdst_sec
@../../supp/select_file &1. create_gusr
@../../supp/select_file &1. create_ods
@../../supp/select_file &1. create_ods_sec
@../../supp/select_file &1. create_integ
@../../supp/select_file &1. create_integ_sec
@../../supp/select_file &1. create_dist
@../../supp/select_file &1. create_dist_sec
@../../supp/select_file &1. create_oltp
@../../supp/select_file &1. create_oltp_sec
@../../supp/select_file &1. create_aa
@../../supp/select_file &1. create_aa_sec
@../../supp/select_file &1. create_mods
@../../supp/select_file &1. create_mods_sec
@../../supp/select_file &1. create_usyn

@../../supp/comp_file &1.

set trimspool on
set feedback off
set linesize 800
spool dtgen_dataload.ctl
execute dtgen_util.data_script('&1.');
set linesize 80
set feedback 6
spool off

whenever oserror continue
whenever sqlerror continue
