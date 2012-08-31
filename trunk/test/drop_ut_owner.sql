
--
-- Drop SQL*Developer Unit Test Repository Owner Script
-- (Must be run as the "sys as sysdba" user)
--

drop user dtgen_test cascade;

prompt NOTE: This drop may fail if the UT repository was never built
drop role UT_REPO_ADMINISTRATOR;
