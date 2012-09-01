create or replace package body test_gen
is

sql_txt   clob;
gen_tst   timestamp with time zone;

procedure run_sql
      (next_line_in  in  varchar2)
is
begin
   if next_line_in = '/' then
      dbms_output.put_line('SQL> ' || sql_txt);
      --execute immediate sql_txt;
      sql_txt := '';
   else
      sql_txt := sql_txt || next_line_in || chr(10);
   end if;
exception
   when others then
      dbms_output.put_line('SQL_TXT: ' || sql_txt);
      raise;
end run_sql;

procedure gen_load
      (app_abbr_in  in  varchar2
      ,username_in  in  varchar2)
is
   saved_db_schema  applications_act.db_schema%TYPE;
   saved_dbid       applications_act.dbid%TYPE;
   saved_db_auth    applications_act.db_auth%TYPE;
begin
   select       db_schema,       dbid,       db_auth
    into  saved_db_schema, saved_dbid, saved_db_auth
    from  applications_act
    where abbr = app_abbr_in;
   update applications_act
     set  db_schema = user_parms_aa(username_in).db_schema
         ,dbid      = user_parms_aa(username_in).dbid
         ,db_auth   = user_parms_aa(username_in).db_auth
    where abbr = app_abbr_in;
   generate.init(app_abbr_in);
   FOR i in 1 .. user_parms_aa(username_in).file_list_nt.COUNT
   loop
      execute immediate 'generate.create_' || user_parms_aa(username_in).file_list_nt(i);
      execute immediate 'generate.drop_'   || user_parms_aa(username_in).file_list_nt(i);
   end loop;
   gen_tst := systimestamp;
   delete from test_run where schema_name = username_in;
   insert into test_run (app_abbr, schema_name, gen_tstamp)
      values (app_abbr_in, username_in, gen_tst);
   commit;
   glob.set_asof_dtm(gen_tst);
   sql_txt := '';
   FOR i in 1 .. user_parms_aa(username_in).file_list_nt.COUNT
   loop
      for buff in (
         select seq, value from file_lines_asof
          where files_nk1 = app_abbr_in
          and  files_nk2 = 'create_' || user_parms_aa(username_in).file_list_nt(i) )
      loop
         run_sql(buff.value);
      end loop;
   end loop;
   sql_txt := '';
end gen_load;

procedure cleanup
      (app_abbr_in  in  varchar2
      ,username_in  in  varchar2)
is
begin
   select gen_tstamp into gen_tst
    from  test_run
    where schema_name = username_in;
   glob.set_asof_dtm(gen_tst);
   sql_txt := '';
   FOR i in 1 .. user_parms_aa(username_in).file_list_nt.COUNT
   loop
      for buff in (
         select seq, value from file_lines_asof
          where files_nk1 = app_abbr_in
           and  files_nk2 = 'drop_' || user_parms_aa(username_in).file_list_nt(i) )
      loop
         run_sql(buff.value);
      end loop;
   end loop;
   sql_txt := '';
end cleanup;

begin
   user_parms_aa('TDBST').db_schema    := null;
   user_parms_aa('TDBST').dbid         := null;
   user_parms_aa('TDBST').db_auth      := null;
   user_parms_aa('TDBST').file_list_nt := file_list_nt_type
      ('glob'
      ,'ods'
      ,'integ'
      ,'oltp'
      ,'aa'
      ,'mods');
   user_parms_aa('TDBUT').db_schema    := 'TDBST';
   user_parms_aa('TDBUT').dbid         := null;
   user_parms_aa('TDBUT').db_auth      := null;
   user_parms_aa('TDBUT').file_list_nt := file_list_nt_type
      ('usyn');
   user_parms_aa('TMTST').db_schema    := null;
   user_parms_aa('TMTST').dbid         := 'loopback';
   user_parms_aa('TMTST').db_auth      := 'TDBST/TDBST';
   user_parms_aa('TMTST').file_list_nt := file_list_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_parms_aa('TMTUT').db_schema    := 'TMTST';
   user_parms_aa('TMTUT').dbid         := null;
   user_parms_aa('TMTUT').db_auth      := null;
   user_parms_aa('TMTUT').file_list_nt := file_list_nt_type
      ('usyn');
   user_parms_aa('TMTSTDOD').db_schema    := null;
   user_parms_aa('TMTSTDOD').dbid         := 'loopback';
   user_parms_aa('TMTSTDOD').db_auth      := 'TDBUT/TDBUT';
   user_parms_aa('TMTSTDOD').file_list_nt := file_list_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_parms_aa('TMTUTDOD').db_schema    := 'TMTSTDOD';
   user_parms_aa('TMTUTDOD').dbid         := null;
   user_parms_aa('TMTUTDOD').db_auth      := null;
   user_parms_aa('TMTUTDOD').file_list_nt := file_list_nt_type
      ('usyn');
   user_parms_aa('TDBSN').db_schema    := null;
   user_parms_aa('TDBSN').dbid         := null;
   user_parms_aa('TDBSN').db_auth      := null;
   user_parms_aa('TDBSN').file_list_nt := file_list_nt_type
      ('glob'
      ,'ods'
      ,'oltp'
      ,'aa'
      ,'mods');
   user_parms_aa('TDBUN').db_schema    := 'TDBSN';
   user_parms_aa('TDBUN').dbid         := null;
   user_parms_aa('TDBUN').db_auth      := null;
   user_parms_aa('TDBUN').file_list_nt := file_list_nt_type
      ('usyn');
   user_parms_aa('TMTSN').db_schema    := null;
   user_parms_aa('TMTSN').dbid         := 'loopback';
   user_parms_aa('TMTSN').db_auth      := 'TDBSN/TDBSN';
   user_parms_aa('TMTSN').file_list_nt := file_list_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_parms_aa('TMTUN').db_schema    := 'TMTSN';
   user_parms_aa('TMTUN').dbid         := null;
   user_parms_aa('TMTUN').db_auth      := null;
   user_parms_aa('TMTUN').file_list_nt := file_list_nt_type
      ('usyn');
   user_parms_aa('TMTSNDOD').db_schema    := null;
   user_parms_aa('TMTSNDOD').dbid         := 'loopback';
   user_parms_aa('TMTSNDOD').db_auth      := 'TDBUN/TDBUN';
   user_parms_aa('TMTSNDOD').file_list_nt := file_list_nt_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   user_parms_aa('TMTUNDOD').db_schema    := 'TMTSNDOD';
   user_parms_aa('TMTUNDOD').dbid         := null;
   user_parms_aa('TMTUNDOD').db_auth      := null;
   user_parms_aa('TMTUNDOD').file_list_nt := file_list_nt_type
      ('usyn');
end test_gen;
/
