
execute util.set_usr('Test');

execute gui_util.gen_all('TST1');

select SUCCESS
      ,VAL0  col
      ,VAL1  seq
      ,VAL2  val
 from test_parms
 where DB_SCHEMA = 'TDBST'
  and  TEST_NAME = 'DTC_INSERT'
 order by SEQ;

insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, scale, description)
  select 'TST1', 'DTCE', name, seq, nk, type, len, scale, description
  from  tab_cols_act
  where tables_nk1 = 'TST1'
   and  tables_nk2 = 'DTCN';

------------------------------------------------------------
execute test_gen.output_all('i',USER);
execute test_gen.output_all('u',USER);
execute dtgen_util.data_script('TST1');
execute dtgen_util.data_script('TST2');
purge recyclebin;

------------------------------------------------------------
execute dbms_output.put_line(test_gen.gen_load('TST1',USER));

execute dbms_output.put_line(test_gen.cleanup('TST1',USER));

begin
  execute immediate 'create table d1 (c1 bogus);';
end;
/

-- This needs to be in a validation that follows test_gen.gen_load
select attribute || ' on ' ||
       type      || ' '    ||
       name      || ' at ' ||
       line      || ','    ||
       position  || ' is ' ||
       text      error_text
 from  user_errors
 order by type, name, sequence, line, position;