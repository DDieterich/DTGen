------------------------------------------------------------
REM Test User

execute glob.set_usr('Testing');
select glob.get_usr from dual;
select glob.get_dtm from dual;
select t1a_log_dml.get_next_id from dual;
insert into t1a_non (id, key, seq, num_plain)
      values (313, 'Duane', 2, 123);
insert into t1a_log (id, key, seq, num_plain, aud_beg_usr, aud_beg_dtm)
      values (361, 'Duane', 1, 123, glob.get_usr, glob.get_dtm);
insert into TDBST.t1a_log@XE@loopback (id, key, seq, num_plain, aud_beg_usr, aud_beg_dtm)
      values (361, 'Duane', 1, 123, glob.get_usr, glob.get_dtm);

execute dbms_output.put_line(test_rig.bool_to_str(glob.get_db_constraints));
execute dbms_output.put_line(test_rig.bool_to_str(glob.get_fold_strings));
execute dbms_output.put_line(test_rig.bool_to_str(glob.get_ignore_no_change));

execute dbms_output.put_line(glob.get_dtm);
execute dbms_output.put_line(glob.get_usr);
execute dbms_output.put_line(glob.get_usr@XE@loopback);
execute dbms_output.put_line(tdbst.glob.get_usr@XE@loopback);

select global_name from global_name;

select * from dual@XE@LOOPBACK;
select * from t1a_non@XE@LOOPBACK;
select object_name, status from user_objects@XE@loopback where object_type = 'PACKAGE BODY';
execute dbms_output.put_line(TDBST.glob.get_dtm@XE@loopback);
execute dbms_output.put_line(glob.get_dtm@XE@loopback);

execute test_rig.run_all;
execute test_rig.run_test('A','BTT_SQLTAB_NON_NUM_PLAIN');
execute dbms_output.put_line(test_rig.BTT_SQLTAB_NON_NUM_PLAIN('BTT_NUM_PASS',2));

------------------------------------------------------------
REM dtgen_test:

drop package test_rig;
drop table test_sets;
drop table test_parms;
drop table parm_sets;
drop table global_parms;

purge recyclebin;

grant select on global_parms to TDBST with grant option;
grant select on parm_sets    to TDBST with grant option;
grant select on test_parms   to TDBST with grant option;
grant select on test_sets    to TDBST with grant option;

------------------------------------------------------------
REM dtgen_dev:

execute glob.set_usr('Test');
execute gui_util.gen_all('TST1');
