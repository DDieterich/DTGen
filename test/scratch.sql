------------------------------------------------------------
REM Test User

execute test_rig.run_all;
execute test_rig.run_test('A','BTT_SQLTAB_NON_NUM_PLAIN');
execute dbms_output.put_line(test_rig.BTT_SQLTAB_NON_NUM_PLAIN('BTT_NUM_PASS',2));

------------------------------------------------------------
REM dtgen_test:

drop table test_sets;
drop table test_parms;
drop table parm_sets;
drop table global_parms;

purge recyclebin;

------------------------------------------------------------
REM dtgen_dev:

execute glob.set_usr('Test');
execute gui_util.gen_all('TST1');
