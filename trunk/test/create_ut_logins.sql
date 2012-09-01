
--
-- Create DTGen Unit Test Logins Script
-- (Must be run as the "sys as sysdba" user)
--

set define '&'
set serveroutput on format wrapped

define TSPACE = users          -- Default Tablespace
define UT_OWNER = dtgen_test   -- Unit Test Repository Owner

-- create_owner script parameters:
-- &1. - New Schema Owner Name
-- &2. - New Schema Owner Password
-- &3. - New Schema Owner Default Tablespace

-- create_user script parameters:
-- &1.   -- New Application User Name
-- &2.   -- New Application User Password
-- &3.   -- New Schema Owner Name

define OWNERNAME = TDBST
define USR_NAME  = TDBUT
@../supp/create_owner &OWNERNAME. &OWNERNAME. &TSPACE.
@create_ut_syns &OWNERNAME. &UT_OWNER.
@../supp/create_user &USR_NAME. &USR_NAME. &OWNERNAME.
@create_ut_syns &USR_NAME. &UT_OWNER.
