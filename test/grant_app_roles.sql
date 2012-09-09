
--
-- Grant Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
--  &1 - Username to recieve the grants
--
define APP_ABBR=TST1
grant &APP_ABBR._app to &1.;
--
define APP_ABBR=TST2
grant &APP_ABBR._app to &1.;
