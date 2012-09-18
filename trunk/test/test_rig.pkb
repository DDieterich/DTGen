create or replace package body test_rig
is

current_global_set  global_parms.global_set%TYPE := null;
tparms              test_parms%ROWTYPE;
sql_txt             varchar2(1994);

function run_sql
   return varchar2
is
begin
   --dbms_output.put_line(sql_txt);
   execute immediate sql_txt;
   return 'SUCCESS';
exception
   when others then
      --util.err(sqlerrm);
      return sqlerrm || CHR(10) || 'SQL: ' || sql_txt;
end run_sql;

procedure get_tparms
      (parm_set_in  in  number)
is
   cursor curs is
      select * from test_parms
       where parm_set = parm_set_in;
begin
   open curs;
   fetch curs into tparms;
   close curs;
end get_tparms;

procedure basic_test
is
   junk  dual.dummy%TYPE;
begin
   select dummy into junk from dual;
end basic_test;

procedure DTC_SQLTAB
      (table_name_in  in  varchar2)
is
   action_in      test_parms.val0%TYPE := tparms.val0;
   tab_seq_in     test_parms.val1%TYPE := tparms.val1;
   column_name_in test_parms.val2%TYPE := tparms.val2;
   value_in       test_parms.val3%TYPE := tparms.val3;
   is_eff         boolean := FALSE;
   is_log         boolean := FALSE;
begin
   if upper(substr(table_name_in,length(table_name_in)-2)) = 'EFF' then
      is_eff := TRUE;
      is_log := TRUE;
   elsif upper(substr(table_name_in,length(table_name_in)-2)) = 'LOG' then
      is_log := TRUE;
   end if;
   case action_in
   when 'INSERT' then sql_txt :=
      'insert into ' || table_name_in ||
           ' (id' ||
           ', seq';
      if is_eff then sql_txt := sql_txt ||
           ', eff_beg_dtm';
      end if;
      if is_log then sql_txt := sql_txt ||
           ', aud_beg_usr' ||
           ', aud_beg_dtm';
      end if;
      sql_txt := sql_txt ||
           ', ' || column_name_in || ') ' ||
         'values ' ||
            '(' || table_name_in || '_dml.get_next_id' ||
           ', ' || tab_seq_in;
      if is_eff then sql_txt := sql_txt ||
           ', glob.get_dtm';
      end if;
      -- Don't know why "ORA-20002: Current User has not been set in the
      --   Glob Package." is thrown when glob.get_usr is evaluated by the
      --   SQL engine, instead of passing the string results from glob.get_usr.
      --   ', ''' || glob.get_usr || '''' ||
      if is_log then sql_txt := sql_txt ||
           ', glob.get_usr' ||
           ', glob.get_dtm';
      end if;
      sql_txt := sql_txt ||
           ', ' || value_in || ')';
   when 'UPDATE' then sql_txt :=
      'update ' || table_name_in ||
       ' set ' || column_name_in || ' = ' || value_in ||
      ' where seq = ' || tab_seq_in;
   when 'DELETE' then sql_txt :=
      'delete from ' || table_name_in ||
      ' where seq = ' || tab_seq_in;
   else
      raise_application_error (-20000, 'Unkown action_in: ' || action_in);
   end case;
end DTC_SQLTAB;

procedure DTC_SQLACT
      (table_name_in  in  varchar2)
is
   action_in      test_parms.val0%TYPE := tparms.val0;
   tab_seq_in     test_parms.val1%TYPE := tparms.val1;
   column_name_in test_parms.val2%TYPE := tparms.val2;
   value_in       test_parms.val3%TYPE := tparms.val3;
begin
   case action_in
   when 'INSERT' then sql_txt :=
      'insert into ' || table_name_in || '_act' ||
           ' (seq' ||
           ', ' || column_name_in || ') ' ||
         'values' ||
           ' (' || tab_seq_in ||
           ' ,' || value_in || ')';
   when 'UPDATE' then sql_txt :=
      'update ' || table_name_in || '_ACT' ||
       ' set ' || column_name_in || ' = ' || value_in ||
      ' where seq = ' || tab_seq_in;
   when 'DELETE' then sql_txt :=
      'delete from ' || table_name_in || '_ACT' ||
      ' where seq = ' || tab_seq_in;
   else
      raise_application_error (-20000, 'Unkown action_in: ' || action_in);
   end case;
end DTC_SQLACT;

procedure DTC_DMLACT
      (table_name_in  in  varchar2)
is
   action_in      test_parms.val0%TYPE := tparms.val0;
   tab_seq_in     test_parms.val1%TYPE := tparms.val1;
   column_name_in test_parms.val2%TYPE := tparms.val2;
   value_in       test_parms.val3%TYPE := tparms.val3;
   is_eff         boolean := FALSE;
begin
   case action_in
   when 'INSERT' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in  || '_ACT%ROWTYPE; ' ||
      'begin ' || 
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.ins(buff); ' ||
      'end;';
   when 'UPDATE' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in || '_ACT%ROWTYPE; ' ||
      'begin ' || 
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.id := ' || table_name_in || '_dml.get_id(buff.seq);' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.upd(buff); ' ||
      'end;';
   when 'DELETE' then
      if upper(substr(table_name_in,length(table_name_in)-2)) = 'EFF' then
         is_eff := TRUE;
      end if;
      if is_eff then
         sql_txt := 'declare ' ||
                       'x_eff_tstmp timestamp with local time zone; ';
      else
         sql_txt := '';
      end if;
      sql_txt := sql_txt ||
      'begin ' || table_name_in || '_dml.del(' ||
                  table_name_in || '_dml.get_id(' || tab_seq_in || ')';
      if is_eff then
         sql_txt := sql_txt || ', x_eff_tstmp';
      end if;
      sql_txt := sql_txt || '); end;';
   else
      raise_application_error (-20000, 'Unkown action_in: ' || action_in);
   end case;
end DTC_DMLACT;

procedure DTC_DMLTAB
      (table_name_in  in  varchar2)
is
begin
   dtc_dmlact(table_name_in);
   sql_txt := replace(sql_txt
                     ,'buff ' || table_name_in || '_ACT%ROWTYPE; '
                     ,'buff ' || table_name_in || '%ROWTYPE; ');
end DTC_DMLTAB;

procedure set_global_parms
      (global_set_in  in  varchar2)
is
begin
   if global_set_in = current_global_set then
      return;
   end if;
   for buff in (
      select * from global_parms
       where global_set = global_set_in)
   loop
      case upper(buff.db_constraints)
      when 'T' then
         glob.set_db_constraints(TRUE);
      else
         glob.set_db_constraints(FALSE);
      end case;
      case upper(buff.fold_strings)
      when 'T' then
         glob.set_fold_strings(TRUE);
      else
         glob.set_fold_strings(FALSE);
      end case;
      case upper(buff.ignore_no_change)
      when 'T' then
         glob.set_ignore_no_change(TRUE);
      else
         glob.set_ignore_no_change(FALSE);
      end case;
   end loop;
   current_global_set := global_set_in;
end set_global_parms;

function run_test_instance
      (test_name_in   in  varchar2
      ,table_type_in  in  varchar2
      ,parm_set_in    in  number)
   return varchar2
is
begin
   get_tparms(parm_set_in);
   case test_name_in
   when 'DTC_SQLTAB' then
      dtc_sqltab('T1A_' || table_type_in);
   when 'DTC_SQLACT' then
      dtc_sqlact('T1A_' || table_type_in);
   when 'DTC_DMLTAB' then
      dtc_dmltab('T1A_' || table_type_in);
   when 'DTC_DMLACT' then
      dtc_dmlact('T1A_' || table_type_in);
   else
      raise_application_error (-20000, 'Unkown test_name_in: ' || test_name_in);
   end case;
   return run_sql;
end run_test_instance;

procedure run_test
      (test_name_in   in  varchar2
      ,table_type_in  in  varchar2)
is
begin
   glob.set_usr(USER);
   for buff in (
      select parm_set from test_parms
       where parm_type = (select parm_type from test_sets
                           where test_name = test_name_in)
       order by parm_set )
   loop
      dbms_output.put_line('');
      dbms_output.put_line('Running Test ' || test_name_in ||
                                       ' ' || table_type_in ||
                        ' Using Parm_Set ' || buff.parm_set);
      dbms_output.put_line(run_test_instance(test_name_in
                                            ,table_type_in
                                            ,buff.parm_set));
   end loop;
end run_test;

procedure run_all
is
begin
   util.delete_all_data;
   for tbuff in (
      select table_type from table_types
       order by table_type desc)
   loop
      for sbuff in (
         select test_name from test_sets
          group by test_name
          order by test_name desc)
      loop
         run_test(test_name_in  => sbuff.test_name
                 ,table_type_in => tbuff.table_type);
      end loop;
   end loop;
   commit;
end run_all;


end test_rig;
/
