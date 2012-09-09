
--
-- Drop SQL*Developer Unit Test Repository Owner Script
-- (Must be run as the "sys as sysdba" user)
--

drop user dtgen_test cascade;

prompt NOTE: This drop may fail if the UT repository was never built
drop role UT_REPO_ADMINISTRATOR;

@drop_app_roles

drop tablespace test_onln_data_default including contents;
drop tablespace test_onln_indx_default including contents;
drop tablespace test_hist_data_default including contents;
drop tablespace test_hist_indx_default including contents;
drop tablespace test_onln_data_special including contents;
drop tablespace test_onln_indx_special including contents;
drop tablespace test_hist_data_special including contents;
drop tablespace test_hist_indx_special including contents;
