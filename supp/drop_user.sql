
--
-- Drop User Sample Script
-- (Must be run as the "system" or "sys as sysdba" user)
--
-- &1.   -- Application User Name
--

set define '&'
set serveroutput on format wrapped

-- Initialize Variables
--

drop user &1. cascade;
