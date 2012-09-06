
--
-- Drop DB Schema or MT Schema Owner Sample Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - DB Schema or MT Schema Owner Name
--

set define '&'
set serveroutput on format wrapped

-- Drop DB Schema or MT Schema Owner
--
drop user &1. cascade;
drop role &1._dml;
drop role &1._app;
