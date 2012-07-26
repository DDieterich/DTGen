create or replace package body assemble as

/************************************************************
DTGEN "assemble" Package Body

Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/

FS  CONSTANT  varchar2(1)  := chr(28);  -- Field Separator character

lo_opname     varchar2(64);  -- Operation Name for LongOps
lo_num_units  number;        -- Number of Units for LongOps

USE_RCLOB     boolean      := FALSE;

----------------------------------------
procedure p
      (line_in  in  varchar2)
is
begin
   if USE_RCLOB
   then
      rclob := rclob || line_in || chr(10);
   else
      dbms_output.put_line(line_in);
   end if;
end p;
----------------------------------------
function get_aa_key_name
      (aa_key_in    in  varchar2
      ,suffix_in    in  varchar2)
   return varchar2
is
   rstr varchar2(100);
begin
   case aa_key_in
      when 'DB'  then rstr := 'Database';
      when 'MT'  then rstr := 'Mid-Tier';
      when 'GUI' then rstr := 'APEX Maintenance GUI';
      when 'USR' then rstr := 'User Synonym';
      else rstr := aa_key_in;
   end case;
   if suffix_in is not null
   then
      if suffix_in = 'sec'
      then
         rstr := rstr || ' Security';
      else
         rstr := rstr || ' ' || suffix_in;
      end if;
   end if;
   return rstr;
end get_aa_key_name;
----------------------------------------
procedure install_script
      (app_abbr_in  in  varchar2
      ,aa_key_in    in  varchar2
      ,suffix_in    in  varchar2 default '')
is
   nk2  varchar2(100);
begin
   dbms_output.enable(1000000);
   rclob := '';
   begin
      vc2_list := aa_vc2(upper(aa_key_in));
   exception
      when no_data_found then
         raise_application_error (-20000, 'aa_key_in "' || aa_key_in ||
            '" is not recognized in generate.install_script()');
      when others then
         raise;
   end;
   lo_opname := 'DTGen ' || app_abbr_in || ' Install Script Assembly';
   lo_num_units := vc2_list.count + 1;  -- Add one for util.end_longops
   util.init_longops(lo_opname, lo_num_units,
      get_aa_key_name(aa_key_in, suffix_in), 'tables');
   p('');
   p('--');
   p('--  Install ' || get_aa_key_name(aa_key_in, suffix_in) ||
        ' Scripts for ' || app_abbr_in);
   p('--');
   p('--  The ' || vc2_list.count || ' scripts included are:');
   for i in 1 .. vc2_list.count
   loop
      if suffix_in is not null
      then
         p('--    -) create_' || vc2_list(i) || '_' || suffix_in);
      else
         p('--    -) create_' || vc2_list(i));
      end if;
   end loop;
   p('--');
   p('');
   for i in 1 .. vc2_list.count
   loop
      nk2 := 'create_' || vc2_list(i);
      if suffix_in is not null
      then
         nk2 := nk2 || '_' || suffix_in;
      end if;
      p('');
      p('select '' -) '||nk2||'  '' as FILE_NAME from dual;');
      p('');
      for buff in (
         select value from file_lines_act
          where files_nk1 = upper(app_abbr_in)
           and  files_nk2 = lower(nk2)
          order by seq )
      loop
         p(buff.value);
      end loop;
      p('');
      util.add_longops (1);
   end loop;
   util.end_longops;
end install_script;
----------------------------------------
function install_script
      (app_abbr_in  in  varchar2
      ,aa_key_in    in  varchar2
      ,suffix_in    in  varchar2 default '')
   return clob
is
begin
   USE_RCLOB := TRUE;
   install_script(app_abbr_in, aa_key_in, suffix_in);
   USE_RCLOB := FALSE;
   return rclob;
end install_script;
----------------------------------------
procedure uninstall_script
      (app_abbr_in  in  varchar2
      ,aa_key_in    in  varchar2
      ,suffix_in    in  varchar2 default '')
is
   nk2  varchar2(100);
begin
   dbms_output.enable(1000000);
   rclob := '';
   begin
      vc2_list := aa_vc2(upper(aa_key_in));
   exception
      when no_data_found then
         raise_application_error (-20000, 'aa_key_in "' || aa_key_in ||
            '" is not recognized in generate.uninstall_script()');
      when others then
         raise;
   end;
   lo_opname := 'DTGen ' || app_abbr_in || ' Uninstall Script Assembly';
   lo_num_units := vc2_list.count + 1;  -- Add one for util.end_longops
   util.init_longops(lo_opname, lo_num_units,
      get_aa_key_name(aa_key_in, suffix_in), 'tables');
   p('');
   p('--');
   p('--  Uninstall ' || get_aa_key_name(aa_key_in, suffix_in) ||
        ' Scripts for ' || app_abbr_in);
   p('--');
   p('--  The ' || vc2_list.count || ' scripts included are:');
   for i in REVERSE 1 .. vc2_list.count
   loop
      if suffix_in is not null
      then
         p('--    -) drop_' || vc2_list(i) || '_' || suffix_in);
      else
         p('--    -) drop_' || vc2_list(i));
      end if;
   end loop;
   p('--');
   p('');
   for i in REVERSE 1 .. vc2_list.count
   loop
      nk2 := 'drop_' || vc2_list(i);
      if suffix_in is not null
      then
         nk2 := nk2 || '_' || suffix_in;
      end if;
      p('');
      p('select '' -) '||nk2||'  '' as FILE_NAME from dual;');
      p('');
      for buff in (
         select value from file_lines_act
          where files_nk1 = upper(app_abbr_in)
           and  files_nk2 = lower(nk2)
          order by seq )
      loop
         p(buff.value);
      end loop;
      p('');
      util.add_longops (1);
   end loop;
   util.end_longops;
end uninstall_script;
----------------------------------------
function uninstall_script
      (app_abbr_in  in  varchar2
      ,aa_key_in    in  varchar2
      ,suffix_in    in  varchar2 default '')
   return clob
is
begin
   USE_RCLOB := TRUE;
   uninstall_script(app_abbr_in, aa_key_in, suffix_in);
   USE_RCLOB := FALSE;
   return rclob;
end uninstall_script;
----------------------------------------
procedure data_script
      (app_abbr_in  in  varchar2)
is
   cursor table_cursor is
      select max(lvl) lvl
            ,tab      name
       from  (select partab
                    ,level lvl
                    ,tab
               from  (select puc.table_name  partab
                            ,uc.table_name   tab
                       from  user_constraints puc
                            ,user_tables      tab
                            ,user_constraints uc
                       where puc.constraint_name = uc.r_constraint_name
                        and  tab.table_name      = uc.table_name
                        and  uc.constraint_type  = 'R' 
                      union all
                      select null        partab
                            ,table_name  tab
                       from  user_tables)
               connect by prior tab = partab )
       where tab not in ('FILES','FILE_LINES','UTIL_LOG')
       group by tab
       order by 1, 2;
   cursor column_cursor (tab_name varchar2) is
      select vc.column_name  name
            ,vc.data_type    type
       from  user_tab_columns  vc
       where vc.table_name = tab_name || '_ACT'
        and  vc.column_name not like '%ID_PATH'
        and  vc.column_name not like '%NK_PATH'
        and  vc.column_name not in (
             select cc.column_name
              from  user_cons_columns cc
                   ,user_constraints con
              where  cc.table_name      = tab_name
               and   cc.constraint_name = con.constraint_name
               and  con.constraint_type in ('P', 'R')
               and  con.table_name      = tab_name  )
       order by vc.column_id;
   type db_list_type   is table of varchar2(32767);
   db_list    db_list_type;      -- Data Buffer Array
   cs         varchar2(32767);   -- Column String
   ss         varchar2(32767);   -- SQL String
begin
   dbms_output.enable(1000000);
   rclob := '';
   p('--');
   p('-- DTGen SQL*Loader Control File');
   p('--    Full data dump of the ' || app_abbr_in || ' application');
   p('--    ');
   p('--    Generated by DTGen (http://code.google.com/p/dtgen)');
   p('--    ' || to_char(sysdate,'Month DD, YYYY  HH:MI:SS AM'));
   p('--');
   p('-- sqlldr username/password CONTROL=FILENAME');
   p('--');
   p('load data infile *');
   lo_num_units := 0;
   for tbuff in table_cursor
   loop
      p('into table ' || tbuff.name || '_ACT APPEND when key = ''' ||
               rpad(tbuff.name,30) || FS ||
               ''' fields terminated by ''' || FS || '''');
      cs := '   (key FILLER position(1:31)';
      for cbuff in column_cursor(tbuff.name)
      loop
         cs := cs ||', ' || lower(cbuff.name) || ' ' ||
            case cbuff.type
               when 'DATE' then
                  'DATE "DD-MON-YY HH24:MI:SS"'
               when 'NUMBER' then
                  'FLOAT EXTERNAL'
               when 'VARCHAR2' then
                  'CHAR'
               when 'TIMESTAMP WITH TIME ZONE' then
                  'TIMESTAMP(9) WITH TIME ZONE "DD-MON-YYYY HH24:MI:SS.FFFFFFFFF TZR"'
               when 'TIMESTAMP WITH LOCAL TIME ZONE' then
                  'TIMESTAMP(9) WITH LOCAL TIME ZONE "DD-MON-YYYY HH24:MI:SS.FFFFFFFFF TZR"'
               else 'Datatype Error'
            end;
      end loop;
      p(cs || ')');
      lo_num_units := lo_num_units + 1;
   end loop;
   lo_num_units := lo_num_units + 1;  -- Add one for util.end_longops
   lo_opname := 'DTGen ' || app_abbr_in || ' Install Script Assembly';
   util.init_longops(lo_opname, lo_num_units, 'SQL*Loader.ctl', 'tables');
   p('BEGINDATA');
   for tbuff in table_cursor
   loop
      ss := 'select ''' || rpad(tbuff.name,30) || '''';
      ss := ss || ' || ''' || FS || ''' || ';
      for cbuff in column_cursor(tbuff.name)
      loop
         case cbuff.type
            when 'DATE' then
               ss := ss || 'to_char(' || cbuff.name ||
                          ',''DD-MON-YY HH24:MI:SS'')';
            when 'NUMBER' then
               ss := ss || cbuff.name;
            when 'VARCHAR2' then
               ss := ss || cbuff.name;
            when 'TIMESTAMP WITH TIME ZONE' then
               ss := ss || 'to_char(' || cbuff.name ||
                           ',''DD-MON-YYYY HH24:MI:SS.FFFFFFFFF TZR'')';
            when 'TIMESTAMP WITH LOCAL TIME ZONE' then
               ss := ss || 'to_char(' || cbuff.name ||
                           ',''DD-MON-YYYY HH24:MI:SS.FFFFFFFFF TZR'')';
            else
               ss := ss || 'Datatype Error on ' || cbuff.name ||
                           '(' || cbuff.type || ')';
         end case;
         ss := ss || ' || ''' || FS || ''' || ';
      end loop;
      ss := substr(ss,1,length(ss)-11) ||
            ' from ' || tbuff.name || '_ACT where ';
      -- This app_abbr_in filter is table specific
      case tbuff.name
         -- Level 1
         when 'APPLICATIONS'  then ss := ss || 'abbr = ''';
         -- Level 2
         when 'DOMAINS'       then ss := ss || 'applications_nk1 = ''';
         when 'EXCEPTIONS'    then ss := ss || 'applications_nk1 = ''';
         when 'PROGRAMS'      then ss := ss || 'applications_nk1 = ''';
         when 'TABLES'        then ss := ss || 'applications_nk1 = ''';
         -- Level 3
         when 'DOMAIN_VALUES' then ss := ss || 'domains_nk1 = ''';
         when 'CHECK_CONS'    then ss := ss || 'tables_nk1 = ''';
         when 'TAB_COLS'      then ss := ss || 'tables_nk1 = ''';
         -- Level 4
         when 'INDEXES'       then ss := ss || 'tab_cols_nk1 = ''';
         else
            raise_application_error (-20000, 'assemble.data_script(): '||
               'Unknown Table Name "' || tbuff.name || '"');
      end case;
      -- For a table with a Self-Referencing Foreign Key,
      --   This ORDER_BY will not necessarily load parent data first.
      ss := ss || app_abbr_in || ''' order by id';
      --p(ss);
      execute immediate ss bulk collect into db_list;
      for i in 1 .. db_list.count
      loop
         p(db_list(i));
      end loop;
      util.add_longops (1);
   end loop;
   util.end_longops;
end data_script;
----------------------------------------
function data_script
      (app_abbr_in  in  varchar2)
   return clob
is
begin
   USE_RCLOB := TRUE;
   data_script(app_abbr_in);
   USE_RCLOB := FALSE;
   return rclob;
end data_script;
----------------------------------------
begin
   aa_vc2('DB') := vc2_list_type
      ('glob'
      ,'ods'
      ,'integ'
      ,'oltp'
      ,'aa'
      ,'mods');
   aa_vc2('MT') := vc2_list_type
      ('gdst'
      ,'dist'
      ,'oltp'
      ,'mods');
   aa_vc2('GUI') := vc2_list_type
      ('flow');
   aa_vc2('USR') := vc2_list_type
      ('usyn');
END assemble;
