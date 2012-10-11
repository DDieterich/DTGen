
prompt
prompt === Compile Stored Program Units ===

set define off


-- Package Specs

prompt
prompt dtgen_util.pks
@dtgen_util.pks
/
show errors PACKAGE dtgen_util

prompt
prompt generate.pks
@generate.pks
/
show errors PACKAGE generate


-- Functions


-- Procedures


-- Views


-- Package Bodies

prompt
prompt dtgen_util.pkb
@dtgen_util.pkb
/
show errors PACKAGE BODY dtgen_util

prompt
prompt generate.pkb
@generate.pkb
/
show errors PACKAGE BODY generate


prompt
set define on
