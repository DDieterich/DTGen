
--
-- Grant Tablespace Quotas for DTGen Unit Test
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Schema Object Owner Name
--

set define '&'
set serveroutput on format wrapped

alter user &1.
   quota unlimited on test_onln_data_default
   quota unlimited on test_onln_indx_default
   quota unlimited on test_hist_data_default
   quota unlimited on test_hist_indx_default
   quota unlimited on test_onln_data_special
   quota unlimited on test_onln_indx_special
   quota unlimited on test_hist_data_special
   quota unlimited on test_hist_indx_special;
