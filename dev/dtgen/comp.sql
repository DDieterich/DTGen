
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

prompt
prompt gui_util.pks
@gui_util.pks
/
show errors PACKAGE gui_util


-- Functions


-- Procedures


-- Views

prompt
prompt gui_app_tree_vw.sql
@gui_app_tree_vw.sql
/
show errors VIEW gui_app_tree_vw

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
prompt gui_util.pkb
@gui_util.pkb
/
show errors PACKAGE BODY gui_util


prompt
set define on
