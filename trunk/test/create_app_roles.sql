
--
-- Create DTGen Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1 - Application Name
-- &2 - Unit Test Owner Name
--
create role &1._dml;
create role &1._app;
grant &1._app to &1._dml;
