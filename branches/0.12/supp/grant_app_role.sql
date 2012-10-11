
--
-- Grant Application Roles Script
-- (Must be run as the "sys as sysdba" user)
--
--  &1 - Application Abbreviation
--  &1 - Username to recieve the grants
--
grant &1._app to &2.;
