
--
-- Create DTGen Unit Test Synonyms Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Schema Object Owner Name
-- &2. - Unit Test Repository Owner
--

set define '&'
set serveroutput on format wrapped

grant dtgen_ut_test to &1.;

--create synonym &1..test_run     for &2..test_run;
create synonym &1..global_parms for &2..global_parms;
create synonym &1..table_types  for &2..table_types;
create synonym &1..parm_types   for &2..parm_types;
create synonym &1..test_parms   for &2..test_parms;
create synonym &1..test_sets    for &2..test_sets;
create synonym &1..all_tests    for &2..all_tests;
create synonym &1..test_gen     for &2..test_gen;

alter user &1.
   quota unlimited on test_onln_data_default
   quota unlimited on test_onln_indx_default
   quota unlimited on test_hist_data_default
   quota unlimited on test_hist_indx_default
   quota unlimited on test_onln_data_special
   quota unlimited on test_onln_indx_special
   quota unlimited on test_hist_data_special
   quota unlimited on test_hist_indx_special;
