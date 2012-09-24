
--
-- Create DTGen Unit Test Synonyms Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Schema Object Owner Name
-- &2. - Unit Test Repository Owner
--

set define '&'
set serveroutput on format wrapped

grant create procedure to &1.;
grant dtgen_ut_test to &1.;
grant select on &2..global_parms to &1. with grant option;
grant select on &2..parm_sets    to &1. with grant option;
grant select on &2..test_parms   to &1. with grant option;
grant select on &2..test_sets    to &1. with grant option;

--create synonym &1..test_run     for &2..test_run;
create synonym &1..global_parms for &2..global_parms;
create synonym &1..parm_sets    for &2..parm_types;
create synonym &1..test_parms   for &2..test_parms;
create synonym &1..test_sets    for &2..test_sets;
create synonym &1..test_gen     for &2..test_gen;
