
-- This may be a bug in Oracle11g Express Edition...
--   These grants should not be necessary when using private fixed
--   user database links.  The bug appears to be dependent on the
--   use of "loopback" in that permissions over the database link
--   are confused with permissions not over the database link for
--   database objects with the same name.

grant execute on glob to &1.;

declare
   sql_txt varchar2(4000);
   procedure run_sql is begin
      dbms_output.put_line(sql_txt);
      execute immediate sql_txt;
   end run_sql;
begin
   FOR buff in (
      select table_name from user_tab_privs
       where grantor    = USER
        and  privilege  = 'EXECUTE'
        and  table_name like '%_POP' )
   loop
      sql_txt := 'grant execute on ' || buff.table_name || ' to &1.';
      run_sql;
   end loop;
   FOR buff in (
      select table_name from user_tab_privs
       where grantor    = USER
        and  privilege  = 'UPDATE'
        and  table_name not like '%~_ACT' escape '~' )
   loop
      sql_txt := 'grant select, insert, update, delete on ' ||
                  buff.table_name || ' to &1.';
      run_sql;
   end loop;
end;
/
