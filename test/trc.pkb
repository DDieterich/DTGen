create or replace package body trc
is

-- Test Rig Common Utilities

------------------------------------------------------------
procedure get_tparms
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
is
   owner        varchar2(30);
   prog_name    varchar2(30);
   line_num     number;
   caller_type  varchar2(30);
   cursor curs is
      select * from test_parms
       where parm_set = parm_set_in
        and  parm_seq = parm_seq_in;
begin
   open curs;
   fetch curs into tparms;
   close curs;
   OWA_UTIL.WHO_CALLED_ME(owner, prog_name, line_num, caller_type);
   key_txt := upper(USER)               || ':' ||
              upper(current_global_set) || ':' ||
              upper(prog_name)          || ':' ||
              to_char(line_num)         || ':' ||
              upper(parm_set_in)        ;
end get_tparms;
------------------------------------------------------------
function basic_test
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   dual_dummy  dual.dummy%TYPE;
begin
   trc.get_tparms(parm_set_in, parm_seq_in);
   select dummy into dual_dummy from dual;
   if dual_dummy = trc.tparms.val0 then return 'SUCCESS'; end if;
   return 'FAILURE: Dual Dummy returned ' || dual_dummy ||
          ' instead of ' || trc.tparms.val0;
exception
   when others then
      return substr('FAILURE: ' || sqlerrm ||
                           '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end basic_test;
------------------------------------------------------------
function tablespace_test
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tname        varchar2(30);
   data_tspace  varchar2(30);
   indx_tspace  varchar2(30);
   loc_txt  varchar2(30);
   num_tabs  number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   tname            := trc.tparms.val0;
   data_tspace := trc.tparms.val1;
   indx_tspace := trc.tparms.val2;
   ----------------------------------------
   loc_txt := 'DATA_CHECK';
   select count(*) into num_tabs from user_tables
    where table_name = tname and tablespace_name = data_tspace;
   if num_tabs = 0 then
      return 'FAILURE: Table ' || tname ||
             ' does not exist in tablespace ' || data_tspace;
   end if;
   ----------------------------------------
   loc_txt := 'INDX_CHECK';
   select count(*) into num_tabs from user_indexes
    where table_name = tname and tablespace_name != indx_tspace;
   if num_tabs != 0 then
      return 'FAILURE: Indexes for Table ' || tname ||
             ' exist in tablespaces other than ' || indx_tspace;
   end if;
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end tablespace_test;
-----------------------------------------------------------
function bool_to_str
      (bool_in in boolean)
   return varchar2
is
begin
   if bool_in then
      return 'TRUE';
   end if;
   return 'FALSE';
end bool_to_str;
-----------------------------------------------------------
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
      case buff.db_constraints
      when 'T' then
         glob.set_db_constraints(TRUE);
      else
         glob.set_db_constraints(FALSE);
      end case;
      case buff.fold_strings
      when 'T' then
         glob.set_fold_strings(TRUE);
      else
         glob.set_fold_strings(FALSE);
      end case;
      case buff.ignore_no_change
      when 'T' then
         glob.set_ignore_no_change(TRUE);
      else
         glob.set_ignore_no_change(FALSE);
      end case;
   end loop;
   current_global_set := global_set_in;
   dbms_output.put_line('');
   dbms_output.put_line('============================================================');
   DBMS_OUTPUT.PUT_LINE('   Global_Set is ' || current_global_set);
   DBMS_OUTPUT.PUT_LINE('      glob.get_db_constraints   is ' ||
                   bool_to_str(glob.get_db_constraints));
   DBMS_OUTPUT.PUT_LINE('      glob.get_fold_strings     is ' ||
                   bool_to_str(glob.get_fold_strings));
   DBMS_OUTPUT.PUT_LINE('      glob.get_ignore_no_change is ' ||
                   bool_to_str(glob.get_ignore_no_change));
end set_global_parms;
-----------------------------------------------------------
procedure run_test
      (test_name_in  in  varchar2)
is
   LF  constant varchar2(1) := CHR(10);
   sql_txt  varchar2(4000);
   ret_txt  varchar2(4000);
begin
   glob.set_usr(USER);
   dbms_output.put_line('');
   dbms_output.put_line('Running Test ' || test_name_in);
   for buff in (
      select test_sets.parm_set, test_parms.parm_seq, test_parms.result_txt
       from  test_parms, test_sets
       where test_parms.parm_set  = test_sets.parm_set
        and  test_sets.test_name  = test_name_in
        and  test_sets.global_set = current_global_set
        and  test_sets.user_name  = USER
       order by test_sets.parm_set, test_parms.parm_seq )
   loop
      sql_txt := 'begin :a := ' || test_name_in  ||
                          '(''' || buff.parm_set ||
                          ''',' || buff.parm_seq || '); end;';
      --dbms_output.put_line('SQL> ' || sql_txt);
      execute immediate sql_txt using out ret_txt;
      if ret_txt like buff.result_txt then
         dbms_output.put_line('   Parm_Set ' || buff.parm_set ||
                                    ', SEQ ' || buff.parm_seq);
      else
         dbms_output.put_line('***Parm_Set ' || buff.parm_set ||
                                    ', SEQ ' || buff.parm_seq);
         dbms_output.put_line('---Expected: ' || replace(buff.result_txt,LF,LF||'---          '));
         dbms_output.put_line('---Received: ' || replace(ret_txt,LF,LF||'---          '));
      end if;
   end loop;
end run_test;
-----------------------------------------------------------
procedure run_global_set
      (global_set_in  in  varchar2)
is
begin
   set_global_parms(global_set_in);
   for buff in (
      select test_name from test_sets
       where test_sets.global_set = current_global_set
        and  test_sets.user_name  = USER
       group by test_name
       order by test_name desc)
   loop
      run_test(buff.test_name);
   end loop;
end run_global_set;
-----------------------------------------------------------
procedure run_all
is
begin
   --glob.delete_all_data;
   for buff in (
      select global_set from global_parms
       order by global_set)
   loop
      run_global_set(buff.global_set);
   end loop;
   commit;
end run_all;
-----------------------------------------------------------
end trc;
/
