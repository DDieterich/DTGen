
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

create synonym &1..test_run   for &2..test_run;
create synonym &1..test_parms for &2..test_parms;
