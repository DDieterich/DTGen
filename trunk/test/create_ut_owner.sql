
--
-- Create SQL*Developer Unit Test Repository Owner Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Generator Schema Object Owner Name
--

define UTO_NAME=dtgen_test
define UTO_PASS=dtgen_test

set define '&'
set serveroutput on format wrapped

-- Create New Schema Owner
--
create user &UTO_NAME. identified by &UTO_PASS.
   default tablespace users;

alter user &UTO_NAME.
   quota unlimited on users;

grant connect to &UTO_NAME.;
grant resource to &UTO_NAME.;
grant create view to &UTO_NAME.;
grant create synonym to &UTO_NAME.;
grant select on dba_roles to &UTO_NAME.;
grant select on dba_role_privs to &UTO_NAME.;
grant &1._app to &UTO_NAME.;
-- Grant Privileges needed for package creation
grant select  on &1..applications_act to &UTO_NAME. with grant option;
grant update  on &1..applications_act to &UTO_NAME. with grant option;
grant select  on &1..file_lines_act   to &UTO_NAME. with grant option;
grant select  on &1..file_lines_asof  to &UTO_NAME. with grant option;
grant execute on &1..glob             to &UTO_NAME. with grant option;
grant execute on &1..util             to &UTO_NAME. with grant option;
grant execute on &1..generate         to &UTO_NAME. with grant option;
grant execute on &1..dtgen_util       to &UTO_NAME. with grant option;

prompt NOTE: This grant may fail on a new database
grant UT_REPO_ADMINISTRATOR to &UTO_NAME. with admin option;

-- Create New Application Roles
--
@../supp/create_app_role TST1
@../supp/create_app_roles TST2

-- Unit Test Specific Role
create role dtgen_ut_test;
