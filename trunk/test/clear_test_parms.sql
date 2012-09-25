
spool clear_test_parms

connect dtgen_test/dtgen_test@XE2

delete from test_sets;
delete from test_parms;
delete from parm_sets;
delete from global_parms;

commit;

spool off
