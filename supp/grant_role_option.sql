
--
-- Grant Permissions from Application Role to User with Grant Option
-- (Must be run as the OBJECT OWNER)
--
-- This explicit grant is required to allow an application user to
--   create packages on owner objects
--
-- &1.   -- Application Role Name
-- &2.   -- "Grantee"
--

set define '&'
set serveroutput on format wrapped

declare
   sql_txt varchar2(4000);
begin
   FOR buff in (
      select * from user_tab_privs
       where grantor = USER
        and  grantee = upper('&1.' ) )
   loop
      sql_txt := 'grant ' || buff.privilege ||
                 ' on ' || buff.table_name ||
                 ' to &2. with grant option';
      dbms_output.put_line(sql_txt);
      execute immediate sql_txt;
   end loop;
end;
/
