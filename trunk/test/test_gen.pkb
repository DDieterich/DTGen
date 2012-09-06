create or replace package body test_gen
is

sql_txt   clob;
log_txt   clob;
gen_tst   timestamp with time zone;
LF        constant varchar2(1) := chr(10);

------------------------------------------------------------

procedure get_gen_tst
is
begin
   gen_tst := systimestamp;
end get_gen_tst;

procedure get_gen_tst
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2)
is
begin
   select gen_tstamp into gen_tst
    from  test_run
    where app_abbr  = app_abbr_in
     and  db_schema = db_schema_in;
exception
   when NO_DATA_FOUND then
      gen_tst := NULL;
   when others then
      raise;
end get_gen_tst;

function run_sql
      (run_type_in   in  number
      ,curr_curs_in  in  integer default null)
   return number
is
   fcs_txt  varchar2(2000);
   ret_num  number;
begin
   case run_type_in
   when -1 then
      execute immediate sql_txt;
      ret_num := 0;
   when 0  then
      ret_num := dbms_sql.execute(curr_curs_in);
   when -2 then
      dbms_output.put_line('SQL> ' || sql_txt);
      ret_num := 0;
   else
      ret_num := dbms_sql.execute_and_fetch(curr_curs_in);
   end case;
   sql_txt := '';
   return ret_num;
exception
   when others then
      fcs_txt := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      log_txt := log_txt || 'SQL_TXT: ' || sql_txt || LF;
      log_txt := log_txt || sqlerrm || LF;
      log_txt := log_txt || fcs_txt || LF || LF;
      sql_txt := '';
      return 0;
end run_sql;

procedure collect_sql
      (next_line_in  in  varchar2)
is
   /* This section is used by the DBMS_SQL section below
   c        integer;
   col_cnt  integer;
   descr_t  dbms_sql.desc_tab;
   buff     varchar2(4000);            */
   num_rows integer;
begin
   if next_line_in is null then
      -- Ignore Blank Lines
      return;
   end if;
   if trim(next_line_in) = '' then
      -- Ignore Blank Lines
      return;
   end if;
   if next_line_in != '/' then
      -- Add next line and continue
      sql_txt := sql_txt || next_line_in || LF;
      return;
   end if;
   -- dbms_output.put_line('SQL> ' || sql_txt);
   -- Execute and Clear the SQL Buffer
   /* This section is an alternative to the execute immediate.
         This will use DBMS_SQL to check for a query and return
         a single string from the query.
   c := dbms_sql.open_cursor;
   --dbms_output.put_line('cursor is ' || c);
   dbms_sql.parse(c, 'delete from test_run', DBMS_SQL.NATIVE);
   dbms_sql.parse(c, 'select dummy from dual', DBMS_SQL.NATIVE);
   begin
      dbms_sql.describe_columns(c, col_cnt, descr_t);
   exception
      when others then
         if sqlerrm = 'ORA-00900: invalid SQL statement' then
            col_cnt := 0;
         else
            raise;
         end if;
   end;
   --dbms_output.put_line('col_cnt is ' || col_cnt);
   if nvl(col_cnt,0) > 0 then
      --dbms_output.put_line('col_type is ' || descr_t(1).col_type);
      dbms_sql.define_column(c, 1, buff, 4000);
   end if;
   num_rows := run_sql(col_cnt, c);                 */
   num_rows := run_sql(-1);
   --dbms_output.put_line('num_rows is ' || num_rows);
   /* This section is an alternative to the execute immediate.
         This will use DBMS_SQL to check for a query and return
         a single string from the query.
   for i in 1 .. num_rows
   loop
      dbms_sql.column_value(c, 1, buff);
      --dbms_output.put_line('buff(' || i || ') = '|| buff);
   end loop;
   dbms_sql.close_cursor(c);
exception
   when others then
      if dbms_sql.is_open(c) then
         dbms_sql.close_cursor(c);
      end if;
      raise;                            */
end collect_sql;

procedure run_script
      (app_abbr_in   in  varchar2
      ,file_name_in  in  varchar2)
is
begin
   glob.set_asof_dtm(gen_tst);
   log_txt := log_txt || 'Running ' || file_name_in || LF;
   sql_txt := '';
   for buff in (
      select value from file_lines_asof
       where files_nk1 = app_abbr_in
        and  files_nk2 = file_name_in
       order by seq )
   loop
      collect_sql(buff.value);
   end loop;
   sql_txt := '';
end run_script;

function gen_load
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2)
   return clob
is
   saved_db_schema  applications_act.db_schema%TYPE;
   saved_dbid       applications_act.dbid%TYPE;
   saved_db_auth    applications_act.db_auth%TYPE;
begin
   log_txt := '';
   get_gen_tst(app_abbr_in, db_schema_in);
   if gen_tst is not null then
      raise_application_error(-20000, 'Error: Previous schema for '|| app_abbr_in ||
                                      ', ' || db_schema_in || ' has not been cleared');
   end if;
   select       db_schema,       dbid,       db_auth
    into  saved_db_schema, saved_dbid, saved_db_auth
    from  applications_act
    where abbr = app_abbr_in;
   update applications_act
     set  db_schema = user_aa(db_schema_in).db_schema
         ,dbid      = user_aa(db_schema_in).dbid
         ,db_auth   = user_aa(db_schema_in).db_auth
    where abbr = app_abbr_in;
   util.set_usr(USER);
   generate.init(app_abbr_in);
   FOR i in 1 .. user_aa(db_schema_in).app_file_aa(app_abbr_in).COUNT
   loop
      sql_txt := 'begin generate.create_' ||
                  user_aa(db_schema_in).app_file_aa(app_abbr_in)(i) ||
                 '; end;';
      --dbms_output.put_line ('SQL> ' || sql_txt);
      execute immediate sql_txt;
      sql_txt := 'begin generate.drop_' ||
                  user_aa(db_schema_in).app_file_aa(app_abbr_in)(i) ||
                 '; end;';
      --dbms_output.put_line ('SQL> ' || sql_txt);
      execute immediate sql_txt;
   end loop;
   sql_txt := '';
   get_gen_tst;
   insert into test_run (app_abbr,    db_schema,    gen_tstamp)
                 values (app_abbr_in, db_schema_in, gen_tst);
   FOR i in 1 .. user_aa(db_schema_in).app_file_aa(app_abbr_in).COUNT
   loop
      run_script(app_abbr_in, 'create_' || 
                 user_aa(db_schema_in).app_file_aa(app_abbr_in)(i));
   end loop;
   update applications_act
     set  db_schema = saved_db_schema
         ,dbid      = saved_dbid
         ,db_auth   = saved_db_auth
    where abbr = app_abbr_in;
   commit;
   return log_txt;
end gen_load;

function cleanup
      (app_abbr_in     in  varchar2
      ,db_schema_in    in  varchar2
      ,file_suffix_in  in  varchar2 default null)
   return clob
is
begin
   log_txt := '';
   get_gen_tst(app_abbr_in, db_schema_in);
   if file_suffix_in is not null then
      run_script(app_abbr_in, 'drop_'||file_suffix_in);
      commit;
      return log_txt;
   end if;
   FOR i in REVERSE 1 .. user_aa(db_schema_in).app_file_aa(app_abbr_in).COUNT
   loop
      run_script(app_abbr_in, 'drop_' ||
                 user_aa(db_schema_in).app_file_aa(app_abbr_in)(i));
   end loop;
   delete from test_run
    where app_abbr  = app_abbr_in
     and  db_schema = db_schema_in;
   commit;
   return log_txt;
end cleanup;

------------------------------------------------------------

procedure gen_all
      (vector_in     in  varchar2
      ,db_schema_in  in  varchar2)
is
   saved_db_schema  applications_act.db_schema%TYPE;
   saved_dbid       applications_act.dbid%TYPE;
   saved_db_auth    applications_act.db_auth%TYPE;
   app_abbr         applications_act.abbr%TYPE;
   sql_prefix       varchar2(100);
begin
   if lower(vector_in) = 'i' then
      sql_prefix := 'begin generate.create_';
   else
      sql_prefix := 'begin generate.drop_';
   end if;
   util.set_usr(USER);
   app_abbr := user_aa(db_schema_in).app_file_aa.FIRST;
   loop
      select       db_schema,       dbid,       db_auth
       into  saved_db_schema, saved_dbid, saved_db_auth
       from  applications_act
       where abbr = app_abbr;
      update applications_act
        set  db_schema = user_aa(db_schema_in).db_schema
            ,dbid      = user_aa(db_schema_in).dbid
            ,db_auth   = user_aa(db_schema_in).db_auth
       where abbr = app_abbr;
      generate.init(app_abbr);
      FOR i in 1 .. user_aa(db_schema_in).app_file_aa(app_abbr).COUNT
      loop
         sql_txt := sql_prefix ||
                    user_aa(db_schema_in).app_file_aa(app_abbr)(i) ||
                    '; end;';
         --dbms_output.put_line ('SQL> ' || sql_txt);
         execute immediate sql_txt;
      end loop;
      update applications_act
        set  db_schema = saved_db_schema
            ,dbid      = saved_dbid
            ,db_auth   = saved_db_auth
       where abbr = app_abbr;
      commit;
      exit when app_abbr = user_aa(db_schema_in).app_file_aa.LAST;
      app_abbr := user_aa(db_schema_in).app_file_aa.NEXT(app_abbr);
   end loop;
   sql_txt := '';
end gen_all;

procedure output_file
      (app_abbr_in   in  varchar2
      ,file_name_in  in  varchar2)
is
begin
   dbms_output.put_line('prompt');
   dbms_output.put_line('prompt ***************************');
   dbms_output.put_line('prompt Running Script ' || file_name_in);
   dbms_output.put_line('prompt ***************************');
   dbms_output.put_line('prompt');
   dbms_output.put_line('');
   for buff in (
      select value from file_lines_act
       where files_nk1 = app_abbr_in
        and  files_nk2 = file_name_in
       order by seq )
   loop
      dbms_output.put_line(buff.value);
   end loop;
end output_file;

procedure output_all
      (vector_in     in  varchar2
      ,db_schema_in  in  varchar2)
is
   app_abbr  applications_act.abbr%TYPE;
begin
   gen_all(vector_in, db_schema_in);
   if lower(vector_in) = 'i' then
      app_abbr := user_aa(db_schema_in).app_file_aa.FIRST;
      loop
         FOR i in 1 .. user_aa(db_schema_in).app_file_aa(app_abbr).COUNT
         loop
            output_file(app_abbr, 'create_' ||
                        user_aa(db_schema_in).app_file_aa(app_abbr)(i));
         end loop;
         exit when app_abbr = user_aa(db_schema_in).app_file_aa.LAST;
         app_abbr := user_aa(db_schema_in).app_file_aa.NEXT(app_abbr);
      end loop;
   else
      app_abbr := user_aa(db_schema_in).app_file_aa.LAST;
      loop
         FOR i in REVERSE 1 .. user_aa(db_schema_in).app_file_aa(app_abbr).COUNT
         loop
            output_file(app_abbr, 'drop_' ||
                        user_aa(db_schema_in).app_file_aa(app_abbr)(i));
         end loop;
         exit when app_abbr = user_aa(db_schema_in).app_file_aa.FIRST;
         app_abbr := user_aa(db_schema_in).app_file_aa.PRIOR(app_abbr);
      end loop;
   end if;
end output_all;

begin
   user_aa('TDBST').db_schema           := null;
   user_aa('TDBST').dbid                := null;
   user_aa('TDBST').db_auth             := null;
   user_aa('TDBST').app_file_aa('TST1') := file_nt_type
      ('glob'
      ,'ods'
      ,'integ'
      ,'oltp'
      ,'aa'
      ,'mods');
   --user_aa('TDBST').app_file_aa('TST2') := file_nt_type
   --   ('ods'
   --   ,'integ'
   --   ,'oltp'
   --   ,'aa'
   --   ,'mods');
   user_aa('TDBUT').db_schema           := 'TDBST';
   user_aa('TDBUT').dbid                := null;
   user_aa('TDBUT').db_auth             := null;
   user_aa('TDBUT').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TDBUT').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
   user_aa('TMTST').db_schema           := null;
   user_aa('TMTST').dbid                := 'loopback';
   user_aa('TMTST').db_auth             := 'TDBST/TDBST';
   user_aa('TMTST').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   --user_aa('TMTST').app_file_aa('TST2') := file_nt_type
   --   ('dist'
   --   ,'oltp'
   --   ,'mods');
   user_aa('TMTUT').db_schema           := 'TMTST';
   user_aa('TMTUT').dbid                := null;
   user_aa('TMTUT').db_auth             := null;
   user_aa('TMTUT').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TMTUT').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
   user_aa('TMTSTDOD').db_schema           := null;
   user_aa('TMTSTDOD').dbid                := 'loopback';
   user_aa('TMTSTDOD').db_auth             := 'TDBUT/TDBUT';
   user_aa('TMTSTDOD').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   --user_aa('TMTSTDOD').app_file_aa('TST2') := file_nt_type
   --   ('dist'
   --   ,'oltp'
   --   ,'mods');
   user_aa('TMTUTDOD').db_schema           := 'TMTSTDOD';
   user_aa('TMTUTDOD').dbid                := null;
   user_aa('TMTUTDOD').db_auth             := null;
   user_aa('TMTUTDOD').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TMTUTDOD').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
   user_aa('TDBSN').db_schema           := null;
   user_aa('TDBSN').dbid                := null;
   user_aa('TDBSN').db_auth             := null;
   user_aa('TDBSN').app_file_aa('TST1') := file_nt_type
      ('glob'
      ,'ods'
      ,'oltp'
      ,'aa'
      ,'mods');
   --user_aa('TDBSN').app_file_aa('TST2') := file_nt_type
   --   ('ods'
   --   ,'oltp'
   --   ,'aa'
   --   ,'mods');
   user_aa('TDBUN').db_schema           := 'TDBSN';
   user_aa('TDBUN').dbid                := null;
   user_aa('TDBUN').db_auth             := null;
   user_aa('TDBUN').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TDBUN').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
   user_aa('TMTSN').db_schema           := null;
   user_aa('TMTSN').dbid                := 'loopback';
   user_aa('TMTSN').db_auth             := 'TDBSN/TDBSN';
   user_aa('TMTSN').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   --user_aa('TMTSN').app_file_aa('TST2') := file_nt_type
   --   ('dist'
   --   ,'oltp'
   --   ,'mods');
   user_aa('TMTUN').db_schema           := 'TMTSN';
   user_aa('TMTUN').dbid                := null;
   user_aa('TMTUN').db_auth             := null;
   user_aa('TMTUN').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TMTUN').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
   user_aa('TMTSNDOD').db_schema           := null;
   user_aa('TMTSNDOD').dbid                := 'loopback';
   user_aa('TMTSNDOD').db_auth             := 'TDBUN/TDBUN';
   user_aa('TMTSNDOD').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   --user_aa('TMTSNDOD').app_file_aa('TST2') := file_nt_type
   --   ('dist'
   --   ,'oltp'
   --   ,'mods');
   user_aa('TMTUNDOD').db_schema           := 'TMTSNDOD';
   user_aa('TMTUNDOD').dbid                := null;
   user_aa('TMTUNDOD').db_auth             := null;
   user_aa('TMTUNDOD').app_file_aa('TST1') := file_nt_type
      ('usyn');
   --user_aa('TMTUNDOD').app_file_aa('TST2') := file_nt_type
   --   ('usyn');
end test_gen;
/
