
--
-- Create DTGen Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
define APP_ABBR=TST1
create role &APP_ABBR._dml;
create role &APP_ABBR._app;
grant &APP_ABBR._app to &APP_ABBR_dml.;
--
define APP_ABBR=TST2
create role &APP_ABBR._dml;
create role &APP_ABBR._app;
grant &APP_ABBR._app to &APP_ABBR_dml.;
