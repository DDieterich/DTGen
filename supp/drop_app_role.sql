
--
-- Drop DTGen Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
--  &1 - DTGen Application Abbreviation
--
drop role &1._dml;
drop role &1._app;
