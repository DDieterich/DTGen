
--
-- Grant Permissions from Application Role to User with Grant Option
-- (Must be run as the OBJECT OWNER)
--
-- This explicit grant is required to allow an application user to
--   create packages on owner objects
--
-- &1.   -- Role Name
-- &2.   -- "Grantee"
--

set define '&'
set serveroutput on format wrapped

declare
   sql_txt varchar2(4000);
begin
   FOR buff in (
      select table_name, privilege from user_tab_privs
       where grantor = USER
        and  grantee = upper('&1.')
       order by table_name, privilege )
   loop
      sql_txt := 'grant ' || buff.privilege ||
                 ' on ' || buff.table_name ||
                 ' to &2. with grant option';
      dbms_output.put_line(sql_txt);
      execute immediate sql_txt;
   end loop;
end;
/
