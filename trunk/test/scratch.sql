------------------------------------------------------------
REM Test User

select t1a_non_seq.nextval from dual;
select T1A_EFF_dml.get_id(11) from dual;

select * from T1A_EFF;

begin
   case glob.get_db_constraints
   when TRUE then dbms_output.put_line('TRUE');
   else dbms_output.put_line('FALSE');
   end case;
end;
/

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
execute dbms_output.put_line(test_rig.run_test_instance('DTC_SQLTAB', 'NON', 111));
execute dbms_output.put_line(test_rig.run_test_instance('DTC_SQLACT', 'NON', 111));
execute test_rig.run_test('DTC_SQLTAB','LOG');

------------------------------------------------------------
REM dtgen_test:

select count(*) from all_tests;
select * from all_tests;

drop package test_rig;
drop view all_tests;
drop table test_sets;
drop table test_parms;
drop table parm_types;
drop table table_types;
drop table global_parms;

delete from test_sets;
delete from test_parms;
delete from parm_types;
delete from table_types;
delete from global_parms;

execute dtgen_util.data_script('TST1');
execute dtgen_util.data_script('TST2');

purge recyclebin;

grant select on global_parms to TDBST with grant option;
grant select on table_types  to TDBST with grant option;
grant select on parm_types   to TDBST with grant option;
grant select on test_parms   to TDBST with grant option;
grant select on test_sets    to TDBST with grant option;
grant select on all_tests    to TDBST with grant option;

--execute dbms_output.put_line(test_gen.gen_load('TST1',USER));
--execute dbms_output.put_line(test_gen.cleanup('TST1',USER));

------------------------------------------------------------
REM dtgen_dev:

insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, scale, description)
  select 'TST1', 'DTCE', name, seq, nk, type, len, scale, description
  from  tab_cols_act
  where tables_nk1 = 'TST1'
   and  tables_nk2 = 'DTCN';

execute glob.set_usr('Test');
execute gui_util.gen_all('TST1');

------------------------------------------------------------
REM System Admin

grant tst1_dml to tdbst;
grant tst2_dml to tdbst;
grant tst1_dml to tmtst;
grant tst2_dml to tmtst;