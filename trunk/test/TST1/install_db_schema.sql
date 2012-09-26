
--
-- Install Database Schema
--
--  &1 - ${DB_SCHEMA_CONNECT}
--  &2 - ${MT_SCHEMA}
--  &3 - ${APP_ABBR}
--  &4 - ${DB_USER}
--

spool install_db_schema.log
connect &1.
set serveroutput on format wrapped

@create_glob
@create_glob_sec
@create_ods
@create_ods_sec
@create_integ
@create_integ_sec
@create_oltp
@create_oltp_sec
@create_aa
@create_aa_sec
@create_mods
@create_mods_sec
@comp

@install_test_rig
@../../supp/bug_grants &2.
@../../supp/grant_role_option &3. &4.

spool off
