
prompt
prompt === Install Test Rig Owner ===

set define off

prompt
prompt tr_btt_num_owner.pks
@tr_btt_num_owner.pks
/
show errors PACKAGE tr_btt_num_owner

prompt
prompt tr_btt_dtm_owner.pks
@tr_btt_dtm_owner.pks
/
show errors PACKAGE tr_btt_dtm_owner

prompt
prompt tr_btt_str_owner.pks
@tr_btt_str_owner.pks
/
show errors PACKAGE tr_btt_str_owner

------------------------------------------------------------

prompt
prompt tr_btt_num_owner.pkb
@tr_btt_num_owner.pkb
/
show errors PACKAGE BODY tr_btt_num_owner

prompt
prompt tr_btt_dtm_owner.pkb
@tr_btt_dtm_owner.pkb
/
show errors PACKAGE BODY tr_btt_dtm_owner

prompt
prompt tr_btt_str_owner.pkb
@tr_btt_str_owner.pkb
/
show errors PACKAGE BODY tr_btt_str_owner

prompt

set define on
