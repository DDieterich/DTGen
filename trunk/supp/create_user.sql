
--
-- Create Application User Sample Script
-- (Must be run as the "system" or "sys as sysdba" user)
--
-- &1.   -- New Application User Name
-- &2.   -- New Application User Password
-- &3.   -- DB Schema or MT Schema Owner Name
--

set define '&'
set serveroutput on format wrapped

-- Initialize Variables
--

create user &1. identified by &2.
   default tablespace users;

grant connect to &1.;
grant create synonym to &1.;
grant &3._app to &1.;

--connect &1./&2.
--set serveroutput on format wrapped
--@install_gusr
--@install_usyn
