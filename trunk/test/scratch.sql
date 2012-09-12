------------------------------------------------------------
REM Test User

declare buff T1A_NON%ROWTYPE; begin buff.seq := 31; buff.NUM_PLAIN := '456.78'; T1A_NON_dml.upd(buff); end;
/

insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, scale, description)
  select 'TST1', 'DTCE', name, seq, nk, type, len, scale, description
  from  tab_cols_act
  where tables_nk1 = 'TST1'
   and  tables_nk2 = 'DTCN';

insert into T1A_NON (id, seq, NUM_PLAIN) values (T1A_NON_dml.get_next_id, 3, NULL);

delete from t1a_non;

begin
   case glob.get_db_constraints
   when TRUE then dbms_output.put_line('TRUE');
   else dbms_output.put_line('FALSE');
   end case;
end;
/

------------------------------------------------------------
REM dtgen_test:

drop table test_schemas;
drop table test_parms;
drop table global_parms;

delete from test_schemas;
delete from test_parms;
delete from global_parms;

execute dtgen_util.data_script('TST1');
execute dtgen_util.data_script('TST2');

purge recyclebin;

grant select on global_parms to TDBST with grant option;
grant select on test_parms to TDBST with grant option;
grant select on test_schemas to TDBST with grant option;

--execute dbms_output.put_line(test_gen.gen_load('TST1',USER));
--execute dbms_output.put_line(test_gen.cleanup('TST1',USER));

------------------------------------------------------------
REM dtgen_dev:

execute glob.set_usr('Test');
execute gui_util.gen_all('TST1');
