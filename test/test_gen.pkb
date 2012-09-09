create or replace package body test_gen
is

-- SAP; Saved Application Parameters
type sap_rec_type is record
   (db_schema  applications_act.db_schema%TYPE
   ,dbid       applications_act.dbid%TYPE
   ,db_auth    applications_act.db_auth%TYPE);
type sap_aa_type is table
   of sap_rec_type
   index by applications_act.abbr%TYPE;
sap_aa  sap_aa_type;

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

/*
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
*/

------------------------------------------------------------

procedure gen_all
      (action_in     in  varchar2
      ,db_schema_in  in  varchar2)
is
   app_abbr  file_lines_act.files_nk1%TYPE;
begin
   util.set_usr(USER);
   for i in 1 .. applist_nt.COUNT
   loop
      app_abbr := applist_nt(i);
      select db_schema
            ,dbid
            ,db_auth
       into  sap_aa(app_abbr).db_schema
            ,sap_aa(app_abbr).dbid
            ,sap_aa(app_abbr).db_auth
       from  applications_act
       where abbr = app_abbr;
      update applications_act
        set  db_schema = user_aa(db_schema_in).db_schema
            ,dbid      = user_aa(db_schema_in).dbid
            ,db_auth   = user_aa(db_schema_in).db_auth
       where abbr = app_abbr;
   end loop;
   FOR j in 1 .. user_aa(db_schema_in).action_aa(action_in).COUNT
   loop
      sql_txt := 'begin generate.' ||
                  user_aa(db_schema_in).action_aa(action_in)(j).file_name ||
                 '; end;';
      --dbms_output.put_line ('SQL> ' || sql_txt);
      case user_aa(db_schema_in).action_aa(action_in)(j).applist_key
      when 'FO' then
         app_abbr := applist_nt(1);
         generate.init(app_abbr);
         --dbms_output.put_line('APP_ABBR: ' || app_abbr);
         execute immediate sql_txt;
      when 'FA' then
         FOR i in 1 .. applist_nt.COUNT
         loop
            app_abbr := applist_nt(i);
            generate.init(app_abbr);
            --dbms_output.put_line('APP_ABBR: ' || app_abbr);
            execute immediate sql_txt;
         end loop;
      when 'RA' then
         FOR i in REVERSE 1 .. applist_nt.COUNT
         loop
            app_abbr := applist_nt(i);
            generate.init(app_abbr);
            --dbms_output.put_line('APP_ABBR: ' || app_abbr);
            execute immediate sql_txt;
         end loop;
      else
         raise_application_error (-20000, 'Invalid applist_key: ' ||
            user_aa(db_schema_in).action_aa(action_in)(j).applist_key);
      end case;
   end loop;
   for i in 1 .. applist_nt.COUNT
   loop
      app_abbr := applist_nt(i);
      update applications_act
        set  db_schema = sap_aa(app_abbr).db_schema
            ,dbid      = sap_aa(app_abbr).dbid
            ,db_auth   = sap_aa(app_abbr).db_auth
       where abbr = app_abbr;
   end loop;
   commit;
   sql_txt := '';
exception
   when others then
      rollback;
      raise;
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
   for buff in (
      select value from file_lines_act
       where files_nk1 = app_abbr_in
        and  files_nk2 = file_name_in || '_sec'
       order by seq )
   loop
      dbms_output.put_line(buff.value);
   end loop;
end output_file;

procedure output_all
      (action_in     in  varchar2
      ,db_schema_in  in  varchar2)
is
   app_abbr   applications_act.abbr%TYPE;
   file_name  file_lines_act.files_nk2%TYPE;
begin
   gen_all(action_in, db_schema_in);
   for j in 1 .. user_aa(db_schema_in).action_aa(action_in).COUNT
   loop
      file_name := user_aa(db_schema_in).action_aa(action_in)(j).file_name;
      case user_aa(db_schema_in).action_aa(action_in)(j).applist_key
      when 'FO' then
         app_abbr := applist_nt(1);
         --dbms_output.put_line('*** INSERT ' || file_name || ' for ' ||
         --                                      db_schema_in || ' ' ||
         --                                      app_abbr || ' HERE ***');
         output_file(app_abbr, file_name);
      when 'FA' then
         FOR i in 1 .. applist_nt.COUNT
         loop
            app_abbr := applist_nt(i);
            --dbms_output.put_line('*** INSERT ' || file_name || ' for ' ||
            --                                      db_schema_in || ' ' ||
            --                                      app_abbr || ' HERE ***');
            output_file(app_abbr, file_name);
         end loop;
      when 'RA' then
         FOR i in REVERSE 1 .. applist_nt.COUNT
         loop
            app_abbr := applist_nt(i);
            --dbms_output.put_line('*** INSERT ' || file_name || ' for ' ||
            --                                      db_schema_in || ' ' ||
            --                                      app_abbr || ' HERE ***');
            output_file(app_abbr, file_name);
         end loop;
      else
         raise_application_error (-20000, 'Invalid applist_key: ' ||
            user_aa(db_schema_in).action_aa(action_in)(j).applist_key);
      end case;
      case file_name
      when 'drop_usyn' then
         null;
      when 'drop_gusr' then
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''  as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
      when 'drop_integ' then
   dbms_output.put_line('select table_name   || '': '' ||');
   dbms_output.put_line('       trigger_type || '' - '' ||');
   dbms_output.put_line('       trigger_name   as remaining_table_triggers');
   dbms_output.put_line(' from  user_triggers');
   dbms_output.put_line(' where base_object_type = ''TABLE''');
   dbms_output.put_line(' order by table_name');
   dbms_output.put_line('      ,trigger_type');
   dbms_output.put_line('/');
   dbms_output.put_line('select table_name      || '': '' ||');
   dbms_output.put_line('       constraint_type || '' = '' ||');
   dbms_output.put_line('       substr(owner    || ''.'' ||');
   dbms_output.put_line('              constraint_name, 1, 40)  as remaining_constraints');
   dbms_output.put_line(' from  user_constraints');
   dbms_output.put_line(' where constraint_type not in (''P'',''U'',''R'')');
   dbms_output.put_line(' order by table_name');
   dbms_output.put_line('      ,constraint_type');
   dbms_output.put_line('      ,owner');
   dbms_output.put_line('      ,constraint_name');
   dbms_output.put_line('/');
      when 'delete_ods' then
   dbms_output.put_line('set serveroutput on format wrapped');
   dbms_output.put_line('declare');
   dbms_output.put_line('   num_rows number;');
   dbms_output.put_line('begin');
   dbms_output.put_line('   for buff in');
   dbms_output.put_line('      (select table_name from user_tables)');
   dbms_output.put_line('   loop');
   dbms_output.put_line('      execute immediate ''select count(*) into :a from '' ||');
   dbms_output.put_line('                          buff.table_name into num_rows;');
   dbms_output.put_line('      if nvl(num_rows,0) > 0 then');
   dbms_output.put_line('         dbms_output.put_line(''Table '' || buff.table_name ||');
   dbms_output.put_line('                              '' has '' || num_rows || '' rows.'');');
   dbms_output.put_line('      end if;');
   dbms_output.put_line('   end loop;');
   dbms_output.put_line('end;');
   dbms_output.put_line('/');
      when 'drop_mods' then
         null;
      when 'drop_aa' then
         null;
      when 'drop_oltp' then
         null;
      when 'drop_dist' then
   dbms_output.put_line('select view_type_owner || '': '' ||');
   dbms_output.put_line('       view_name       || ''(len '' ||');
   dbms_output.put_line('       text_length     || '')''   as remaining_views');
   dbms_output.put_line(' from  user_views');
   dbms_output.put_line(' order by view_type_owner');
   dbms_output.put_line('      ,view_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''   as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' where object_type = ''PACKAGE BODY''');
   dbms_output.put_line('  and  object_name not like ''%_POP''');
   dbms_output.put_line('  and  object_name not like ''%_TAB''');
   dbms_output.put_line('  and  object_name not in (''GLOB'', ''UTIL'')');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select table_name   || '': '' ||');
   dbms_output.put_line('       trigger_type || '' - '' ||');
   dbms_output.put_line('       trigger_name   as remaining_table_triggers');
   dbms_output.put_line(' from  user_triggers');
   dbms_output.put_line(' where base_object_type = ''TABLE''');
   dbms_output.put_line(' order by table_name');
   dbms_output.put_line('      ,trigger_type');
   dbms_output.put_line('/');
   dbms_output.put_line('select table_name      || '': '' ||');
   dbms_output.put_line('       constraint_type || '' = '' ||');
   dbms_output.put_line('       substr(owner    || ''.'' ||');
   dbms_output.put_line('              constraint_name, 1, 40)  as remaining_constraints');
   dbms_output.put_line(' from  user_constraints');
   dbms_output.put_line(' where constraint_type not in (''P'',''U'',''R'')');
   dbms_output.put_line(' order by table_name');
   dbms_output.put_line('      ,constraint_type');
   dbms_output.put_line('      ,owner');
   dbms_output.put_line('      ,constraint_name');
   dbms_output.put_line('/');
      when 'drop_ods' then
   dbms_output.put_line('select view_type_owner || '': '' ||');
   dbms_output.put_line('       view_name       || ''(len '' ||');
   dbms_output.put_line('       text_length     || '')''   as remaining_views');
   dbms_output.put_line(' from  user_views');
   dbms_output.put_line(' order by view_type_owner');
   dbms_output.put_line('      ,view_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''   as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' where object_type = ''PACKAGE BODY''');
   dbms_output.put_line('  and  object_name not like ''%_POP''');
   dbms_output.put_line('  and  object_name not like ''%_TAB''');
   dbms_output.put_line('  and  object_name not in (''GLOB'', ''UTIL'')');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''  as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' where object_type = ''PACKAGE BODY''');
   dbms_output.put_line('  and  object_name not in (''GLOB'', ''UTIL'')');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select table_name      || '' (tablespace '' ||');
   dbms_output.put_line('       tablespace_name || '')''  as remaining_tables');
   dbms_output.put_line(' from  user_tables');
   dbms_output.put_line(' where table_name != ''UTIL_LOG''');
   dbms_output.put_line(' order by table_name');
   dbms_output.put_line('/');
   dbms_output.put_line('select sequence_name || '' min:'' ||');
   dbms_output.put_line('       min_value     || '' max:'' ||');
   dbms_output.put_line('       max_value     || '' last:'' ||');
   dbms_output.put_line('       last_number  as remaining_sequences');
   dbms_output.put_line(' from  user_sequences');
   dbms_output.put_line(' order by sequence_name');
   dbms_output.put_line('/');
      when 'drop_gdst' then
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''  as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' where object_type != ''DATABASE LINK''');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
      when 'drop_dblink' then
   dbms_output.put_line('select db_link  || '': '' ||');
   dbms_output.put_line('       username || ''@''  ||');
   dbms_output.put_line('       host              remainin_database_links');
   dbms_output.put_line(' from user_db_links');
   dbms_output.put_line(' order by db_link');
   dbms_output.put_line('/');
      when 'drop_glob' then
   dbms_output.put_line('select object_type              || '': '' ||');
   dbms_output.put_line('       substr(object_name,1,30) || ''('' ||');
   dbms_output.put_line('       status                   || '')''  as remaining_objects');
   dbms_output.put_line(' from  user_objects');
   dbms_output.put_line(' order by object_type');
   dbms_output.put_line('      ,object_name');
   dbms_output.put_line('/');
      else
         if file_name like 'drop_%'  or
            file_name like 'delete_%'
         then
            raise_application_error(-20000, 'Unknown GENERATE procedure ' ||
                                             file_name);
         end if;
      end case;
   end loop;
end output_all;

begin
   -- Application List
   applist_nt := applist_nt_type('TST1', 'TST2');
   -- FA - Forward All
   -- FO - Forard first Only
   -- RA - Reverse All
   -- NOTE: RO (Reverse last Only) would be the same as FO
   ----------------------------------------
   user_aa('TDBST').db_schema    := null;
   user_aa('TDBST').dbid         := null;
   user_aa('TDBST').db_auth      := null;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_glob';
   user_aa('TDBST').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_ods';
   user_aa('TDBST').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.file_name :=       'create_oltp';
   user_aa('TDBST').action_aa  ('install')(3) := fileapp_rec;
   fileapp_rec.file_name :=       'create_aa';
   user_aa('TDBST').action_aa  ('install')(4) := fileapp_rec;
   fileapp_rec.file_name :=       'create_mods';
   user_aa('TDBST').action_aa  ('install')(5) := fileapp_rec;
   fileapp_rec.file_name :=       'create_integ';
   user_aa('TDBST').action_aa  ('install')(6) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_integ';
   user_aa('TDBST').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.file_name :=       'delete_ods';
   user_aa('TDBST').action_aa('uninstall')(2) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_mods';
   user_aa('TDBST').action_aa('uninstall')(3) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_aa';
   user_aa('TDBST').action_aa('uninstall')(4) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_oltp';
   user_aa('TDBST').action_aa('uninstall')(5) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_ods';
   user_aa('TDBST').action_aa('uninstall')(6) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_glob';
   user_aa('TDBST').action_aa('uninstall')(7) := fileapp_rec;
   ----------------------------------------
   user_aa('TDBUT').db_schema    := 'TDBST';
   user_aa('TDBUT').dbid         := null;
   user_aa('TDBUT').db_auth      := null;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_gusr';
   user_aa('TDBUT').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_usyn';
   user_aa('TDBUT').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_usyn';
   user_aa('TDBUT').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_gusr';
   user_aa('TDBUT').action_aa('uninstall')(2) := fileapp_rec;
   ----------------------------------------
   user_aa('TMTST').db_schema    := null;
   user_aa('TMTST').dbid         := 'loopback';
   user_aa('TMTST').db_auth      := 'connect to TDBST identified by TDBST';
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_dblink';
   user_aa('TMTST').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_gdst';
   user_aa('TMTST').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_dist';
   user_aa('TMTST').action_aa  ('install')(3) := fileapp_rec;
   fileapp_rec.file_name :=       'create_oltp';
   user_aa('TMTST').action_aa  ('install')(4) := fileapp_rec;
   fileapp_rec.file_name :=       'create_mods';
   user_aa('TMTST').action_aa  ('install')(5) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_mods';
   user_aa('TMTST').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_oltp';
   user_aa('TMTST').action_aa('uninstall')(2) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_dist';
   user_aa('TMTST').action_aa('uninstall')(3) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_gdst';
   user_aa('TMTST').action_aa('uninstall')(4) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_dblink';
   user_aa('TMTST').action_aa('uninstall')(5) := fileapp_rec;
   ----------------------------------------
   user_aa('TMTUT').db_schema    := 'TMTST';
   user_aa('TMTUT').dbid         := null;
   user_aa('TMTUT').db_auth      := null;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_gusr';
   user_aa('TMTUT').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_usyn';
   user_aa('TMTUT').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_usyn';
   user_aa('TMTUT').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_gusr';
   user_aa('TMTUT').action_aa('uninstall')(2) := fileapp_rec;
   ----------------------------------------
   user_aa('TMTSTDOD').db_schema := null;
   user_aa('TMTSTDOD').dbid      := 'loopback';
   user_aa('TMTSTDOD').db_auth   := 'connect to TDBUT identified by TDBUT';
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_dblink';
   user_aa('TMTSTDOD').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_gdst';
   user_aa('TMTSTDOD').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_dist';
   user_aa('TMTSTDOD').action_aa  ('install')(3) := fileapp_rec;
   fileapp_rec.file_name :=       'create_oltp';
   user_aa('TMTSTDOD').action_aa  ('install')(4) := fileapp_rec;
   fileapp_rec.file_name :=       'create_mods';
   user_aa('TMTSTDOD').action_aa  ('install')(5) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_mods';
   user_aa('TMTSTDOD').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_oltp';
   user_aa('TMTSTDOD').action_aa('uninstall')(2) := fileapp_rec;
   fileapp_rec.file_name :=       'drop_dist';
   user_aa('TMTSTDOD').action_aa('uninstall')(3) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_gdst';
   user_aa('TMTSTDOD').action_aa('uninstall')(4) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_dblink';
   user_aa('TMTSTDOD').action_aa('uninstall')(5) := fileapp_rec;
   ----------------------------------------
   user_aa('TMTUTDOD').db_schema := 'TMTSTDOD';
   user_aa('TMTUTDOD').dbid      := null;
   user_aa('TMTUTDOD').db_auth   := null;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'create_gusr';
   user_aa('TMTUTDOD').action_aa  ('install')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FA';
   fileapp_rec.file_name :=       'create_usyn';
   user_aa('TMTUTDOD').action_aa  ('install')(2) := fileapp_rec;
   fileapp_rec.applist_key := 'RA';
   fileapp_rec.file_name :=       'drop_usyn';
   user_aa('TMTUTDOD').action_aa('uninstall')(1) := fileapp_rec;
   fileapp_rec.applist_key := 'FO';
   fileapp_rec.file_name :=       'drop_gusr';
   user_aa('TMTUTDOD').action_aa('uninstall')(2) := fileapp_rec;
   ----------------------------------------
/*
   user_aa('TDBSN').db_schema           := null;
   user_aa('TDBSN').dbid                := null;
   user_aa('TDBSN').db_auth             := null;
   user_aa('TDBSN').app_file_aa('TST1') := file_nt_type
      ('glob'
      ,'ods'
      ,'oltp'
      ,'aa'
      ,'mods');
   user_aa('TDBSN').app_file_aa('TST2') := file_nt_type
      ('ods'
      ,'oltp'
      ,'aa'
      ,'mods');
   ----------------------------------------
   user_aa('TDBUN').db_schema           := 'TDBSN';
   user_aa('TDBUN').dbid                := null;
   user_aa('TDBUN').db_auth             := null;
   user_aa('TDBUN').app_file_aa('TST1') := file_nt_type
      ('gusr'
      ,'usyn');
   user_aa('TDBUN').app_file_aa('TST2') := file_nt_type
      ('usyn');
   ----------------------------------------
   user_aa('TMTSN').db_schema           := null;
   user_aa('TMTSN').dbid                := 'loopback';
   user_aa('TMTSN').db_auth             := 'connect to TDBSN identified by TDBSN';
   user_aa('TMTSN').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_aa('TMTSN').app_file_aa('TST2') := file_nt_type
      ('dist'
      ,'oltp'
      ,'mods');
   ----------------------------------------
   user_aa('TMTUN').db_schema           := 'TMTSN';
   user_aa('TMTUN').dbid                := null;
   user_aa('TMTUN').db_auth             := null;
   user_aa('TMTUN').app_file_aa('TST1') := file_nt_type
      ('gusr'
      ,'usyn');
   user_aa('TMTUN').app_file_aa('TST2') := file_nt_type
      ('usyn');
   ----------------------------------------
   user_aa('TMTSNDOD').db_schema           := null;
   user_aa('TMTSNDOD').dbid                := 'loopback';
   user_aa('TMTSNDOD').db_auth             := 'connect to TDBUN identified by TDBUN';
   user_aa('TMTSNDOD').app_file_aa('TST1') := file_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_aa('TMTSNDOD').app_file_aa('TST2') := file_nt_type
      ('dist'
      ,'oltp'
      ,'mods');
   ----------------------------------------
   user_aa('TMTUNDOD').db_schema           := 'TMTSNDOD';
   user_aa('TMTUNDOD').dbid                := null;
   user_aa('TMTUNDOD').db_auth             := null;
   user_aa('TMTUNDOD').app_file_aa('TST1') := file_nt_type
      ('gusr'
      ,'usyn');
   user_aa('TMTUNDOD').app_file_aa('TST2') := file_nt_type
      ('usyn');
*/
end test_gen;
/
