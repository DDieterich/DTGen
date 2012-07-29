
prompt
prompt === Compile Stored Program Units ===

set define off


-- Package Specs

prompt
prompt assemble.pks
@assemble.pks
/
show errors PACKAGE assemble

prompt
prompt generate.pks
@generate.pks
/
show errors PACKAGE generate


-- Functions


-- Procedures


-- Package Bodies

prompt
prompt assemble.pkb
@assemble.pkb
/
show errors PACKAGE BODY assemble

prompt
prompt generate.pkb
@generate.pkb
/
show errors PACKAGE BODY generate


prompt
set define on
