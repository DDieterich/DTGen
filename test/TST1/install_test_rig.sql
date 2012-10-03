
prompt
prompt === Install Test Rig ===

set define off

prompt
prompt trc.pks
@../trc.pks
/
show errors PACKAGE trc

prompt
prompt tr_btt_num.pks
@tr_btt_num.pks
/
show errors PACKAGE tr_btt_num

prompt
prompt tr_btt_dtm.pks
@tr_btt_dtm.pks
/
show errors PACKAGE tr_btt_dtm

prompt
prompt tr_btt_str.pks
@tr_btt_str.pks
/
show errors PACKAGE tr_btt_str

------------------------------------------------------------

prompt
prompt trc.pkb
@../trc.pkb
/
show errors PACKAGE BODY trc

prompt
prompt tr_btt_num.pkb
@tr_btt_num.pkb
/
show errors PACKAGE BODY tr_btt_num

prompt
prompt tr_btt_dtm.pkb
@tr_btt_dtm.pkb
/
show errors PACKAGE BODY tr_btt_dtm

prompt
prompt tr_btt_str.pkb
@tr_btt_str.pkb
/
show errors PACKAGE BODY tr_btt_str

prompt

set define on
