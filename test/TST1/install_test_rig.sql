
prompt
prompt === Install Test Rig ===

set define off

prompt
prompt trc.pks
@trc.pks
/
show errors PACKAGE trc

prompt
prompt tr_btt_num.pks
@tr_btt_num.pks
/
show errors PACKAGE tr_btt_num

------------------------------------------------------------

prompt
prompt trc.pkb
@trc.pkb
/
show errors PACKAGE BODY trc

prompt
prompt tr_btt_num.pkb
@tr_btt_num.pkb
/
show errors PACKAGE BODY tr_btt_num

prompt

set define on
