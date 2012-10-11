
--
-- Create DTGen Unit Test Synonyms Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Schema Object Owner Name
-- &2. - Unit Test Repository Owner
--

set define '&'
set serveroutput on format wrapped

define SCHEMA_OWNER=&1.
define UTREP_OWNER=&2.

grant create procedure to &1.;

-- NOTE: This call to this script changes the values of &1 and &2
@../../supp/grant_app_role UTP &SCHEMA_OWNER.

create synonym &SCHEMA_OWNER..global_parms for &UTREP_OWNER..global_parms;
create synonym &SCHEMA_OWNER..parm_sets    for &UTREP_OWNER..parm_types;
create synonym &SCHEMA_OWNER..test_parms   for &UTREP_OWNER..test_parms;
create synonym &SCHEMA_OWNER..test_sets    for &UTREP_OWNER..test_sets;
