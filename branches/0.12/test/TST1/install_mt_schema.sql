
--
-- Install Mid-Tier Schema
--
--  &1 - ${MT_SCHEMA_CONNECT}
--  &2 - ${DB_LINK_NAME}
--  &3 - ${DB_SCHEMA}
--  &4 - ${DB_SPASS}
--  &5 - ${DB_USING_STR}
--  &6 - ${APP_ABBR}
--  &7 - ${MT_USER}
--

spool install_mt_schema.log
connect &1.
set serveroutput on format wrapped

create database link &2.
   connect to &3. identified by &4.
   using '&5.';

@create_gdst
@create_gdst_sec
@create_dist
@create_dist_sec
@create_oltp
@create_oltp_sec
@create_mods
@create_mods_sec
@comp

@install_test_rig
@install_test_rig_owner

-- NOTE: This call to this script changes the values of &1 and &2
@../../supp/grant_role_option &6._APP &7.

spool off
