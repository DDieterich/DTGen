
--
-- Create Application User Sample Script
-- (Must be run as the "system" or "sys as sysdba" user)
--
-- &1.   -- New Application User Name
-- &2.   -- New Application User Password
--

set define '&'
set serveroutput on format wrapped

-- Initialize Variables
--

create user &1. identified by &2.
   default tablespace users;

grant connect to &1.;
grant create synonym to &1.;

--
-- Additional useful actions
--   Variables that must be set
--
--  &APP_ABBR  - Abbreviation of the Application to be granted to this user
--  &APP_OWNER - Owner username of the Application to be granted to this user
--  &APP_PASS  - Owner password of the Application to be granted to this user
--
--@@grant_app_role &APP_ABBR. to &1.
--connect &1./&2.
--set serveroutput on format wrapped
--@install_gusr
--@install_usyn
--connect &APP_OWNER./&APP_PASS.
--@@grant_role_option &APP_ABBR._APP &1.
