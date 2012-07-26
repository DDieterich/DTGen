
prompt
prompt === Compile Stored Program Units ===

set define off


-- Package Specs

prompt
prompt assemble.pks
@assemble.pks
/
show errors assemble

prompt
prompt generate.pks
@generate.pks
/
show errors generate


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
