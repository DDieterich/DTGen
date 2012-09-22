
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

--grant &APP_ABBR._app to &1.;
--connect &1./&2.
--set serveroutput on format wrapped
--@install_gusr
--@install_usyn
