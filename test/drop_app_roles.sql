
--
-- Drop DTGen Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
define APP_ABBR=TST1
drop role &APP_ABBR._dml;
drop role &APP_ABBR._app;
--
define APP_ABBR=TST2
drop role &APP_ABBR._dml;
drop role &APP_ABBR._app;
