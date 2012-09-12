create or replace package body test_rig
is

current_test_set  global_parms.test_set%TYPE := null;
sql_txt           varchar2(1993);

function run_sql
   return varchar2
is
begin
   execute immediate sql_txt;
   return 'SUCCESS';
exception
   when others then
      return sqlerrm || ', SQL> ' || sql_txt;
end run_sql;

procedure basic_test
is
   junk  dual.dummy%TYPE;
begin
   select dummy into junk from dual;
end basic_test;

procedure DTC_INSERT
      (version_in      in  varchar2
      ,table_name_in   in  varchar2
      ,tab_seq_in      in  varchar2
      ,column_name_in  in  varchar2
      ,value_in        in  varchar2)
is
begin
   case version_in
   when 'SQLTAB' then sql_txt :=
      'insert into ' || table_name_in ||
           ' (id' ||
           ', seq' ||
           ', ' || column_name_in || ') ' ||
         'values ' ||
            '(' || table_name_in || '_dml.get_next_id' ||
           ', ' || tab_seq_in ||
           ', ' || value_in || ')';
   when 'SQLACT' then sql_txt :=
      'insert into ' || table_name_in || '_act' ||
           ' (seq' ||
           ', ' || column_name_in || ') ' ||
         'values' ||
           ' (' || tab_seq_in ||
           ' ,' || value_in || ')';
   when 'DMLTAB' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in || '%ROWTYPE; ' ||
      'begin ' ||
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.ins(buff); ' ||
      'end;';
   when 'DMLACT' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in  || '_ACT%ROWTYPE; ' ||
      'begin ' || 
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.ins(buff); ' ||
      'end;';
   else
      raise_application_error (-20000, 'Unkown version_in: ' || version_in);
   end case;
end DTC_INSERT;

procedure DTC_UPDATE
      (version_in      in  varchar2
      ,table_name_in   in  varchar2
      ,tab_seq_in      in  varchar2
      ,column_name_in  in  varchar2
      ,value_in        in  varchar2)
is
begin
   case version_in
   when 'SQLTAB' then sql_txt :=
      'update ' || table_name_in ||
       ' set ' || column_name_in || ' = ' || value_in ||
      ' where seq = ' || tab_seq_in;
   when 'SQLACT' then sql_txt :=
      'update ' || table_name_in || '_ACT' ||
       ' set ' || column_name_in || ' = ' || value_in ||
      ' where seq = ' || tab_seq_in;
   when 'DMLTAB' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in  || '%ROWTYPE; ' ||
      'begin ' ||
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.id := ' || table_name_in || '_dml.get_id(buff.seq);' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.upd(buff); ' ||
      'end;';
   when 'DMLACT' then sql_txt :=
      'declare ' ||
         'buff ' || table_name_in || '_ACT%ROWTYPE; ' ||
      'begin ' || 
         'buff.seq := ' ||tab_seq_in || '; ' ||
         'buff.id := ' || table_name_in || '_dml.get_id(buff.seq);' ||
         'buff.' || column_name_in || ' := ' || value_in || '; ' ||
          table_name_in  || '_dml.upd(buff); ' ||
      'end;';
   else
      raise_application_error (-20000, 'Unkown version_in: ' || version_in);
   end case;
end DTC_UPDATE;

procedure DTC_DELETE
      (version_in      in  varchar2
      ,table_name_in   in  varchar2
      ,tab_seq_in      in  varchar2)
is
begin
   case version_in
   when 'SQLTAB' then sql_txt :=
      'delete from ' || table_name_in ||
      ' where seq = ' || tab_seq_in;
   when 'SQLACT' then sql_txt :=
      'delete from ' || table_name_in || '_ACT' ||
      ' where seq = ' || tab_seq_in;
   when 'DML' then sql_txt :=
      'declare ' ||
         'did  number; ' ||
      'begin ' ||
          table_name_in || '_dml.del(' ||
             table_name_in || '_dml.get_id(' ||
             tab_seq_in || ')); ' ||
      'end;';
   else
      raise_application_error (-20000, 'Unkown version_in: ' || version_in);
   end case;
end DTC_DELETE;

procedure set_test_set
      (test_set_in  in  varchar2)
is
begin
   if test_set_in = current_test_set then
      return;
   end if;
   for buff in (
      select * from global_parms
       where test_set = test_set_in)
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
   current_test_set := test_set_in;
end set_test_set;

function run
      (test_set_in  in  varchar2
      ,test_seq_in  in  number)
   return varchar2
is
   cursor curs is
      select * from test_parms
       where test_seq  = test_seq_in;
   buff  test_parms%ROWTYPE;
begin
   --set_test_set(test_set_in);
   open curs;
   fetch curs into buff;
   close curs;
   case buff.test_name
   when 'DTC_INSERT' then
      dtc_insert(version_in      => buff.val0
                ,table_name_in   => buff.val1
                ,tab_seq_in      => buff.val2
                ,column_name_in  => buff.val3
                ,value_in        => buff.val4);
   when 'DTC_UPDATE' then
      dtc_update(version_in      => buff.val0
                ,table_name_in   => buff.val1
                ,tab_seq_in      => buff.val2
                ,column_name_in  => buff.val3
                ,value_in        => buff.val4);
   when 'DTC_DELETE' then
      dtc_delete(version_in     => buff.val0
                ,table_name_in  => buff.val1
                ,tab_seq_in     => buff.val2);
   else
      raise_application_error (-20000, 'Unkown buff.test_name: ' || buff.test_name);
   end case;
   return run_sql;
end run;


end test_rig;
/
