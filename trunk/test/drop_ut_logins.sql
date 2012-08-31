
--
-- Drop DTGen Unit Test Logins Script
-- (Must be run as the "sys as sysdba" user)
--

set define '&'
set serveroutput on format wrapped

-- drop_owner script parameters:
-- &1. - Schema Owner Name

-- drop_user script parameters:
-- &1. -- Application User Name

@../supp/drop_owner TDBST
@../supp/drop_user  TDBUT
