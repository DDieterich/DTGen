
-- SPOOL script to create PL/SQL component script files
-- &1. is the DTGEN application abbreviation
set define '&'
set feedback off
set linesize 4000
set pagesize 0
set serveroutput on format wrapped
set trimspool on
set verify off
spool comp.sql

prompt
prompt prompt
prompt prompt === Compile Stored Program Units ===
prompt
prompt set define off
prompt

begin
   dbms_output.put_line('');
   dbms_output.put_line('-- Package Specs');
   for buff in (
      select * from programs_act
       where APPLICATIONS_NK1 = '&1.'
        and  type = 'PACKAGE'
	    order by name )
   loop
      dbms_output.put_line('prompt');
      dbms_output.put_line('prompt '||buff.name||'.pks');
      dbms_output.put_line('@'||buff.name||'.pks');
      dbms_output.put_line('/');
      dbms_output.put_line('show errors PACKAGE '||buff.type||' '||buff.name);
      dbms_output.put_line('');
   end loop;
   dbms_output.put_line('');
   dbms_output.put_line('-- Functions');
   for buff in (
      select * from programs_act
       where APPLICATIONS_NK1 = '&1.'
        and  type = 'FUNCTION'
	    order by name )
   loop
      dbms_output.put_line('prompt');
      dbms_output.put_line('prompt '||buff.name||'.fnc');
      dbms_output.put_line('@'||buff.name||'.fnc');
      dbms_output.put_line('/');
      dbms_output.put_line('show errors FUNCTION '||buff.type||' '||buff.name);
      dbms_output.put_line('');
   end loop;
   dbms_output.put_line('');
   dbms_output.put_line('-- Procedures');
   for buff in (
      select * from programs_act
       where APPLICATIONS_NK1 = '&1.'
        and  type = 'PROCEDURE'
	    order by name )
   loop
      dbms_output.put_line('prompt');
      dbms_output.put_line('prompt '||buff.name||'.prc');
      dbms_output.put_line('@'||buff.name||'.prc');
      dbms_output.put_line('/');
      dbms_output.put_line('show errors PROCEDURE '||buff.type||' '||buff.name);
      dbms_output.put_line('');
   end loop;
   dbms_output.put_line('');
   dbms_output.put_line('-- Package Bodies');
   for buff in (
      select * from programs_act
       where APPLICATIONS_NK1 = '&1.'
        and  type = 'PACKAGE'
	    order by name )
   loop
      dbms_output.put_line('prompt');
      dbms_output.put_line('prompt '||buff.name||'.pkb');
      dbms_output.put_line('@'||buff.name||'.pkb');
      dbms_output.put_line('/');
      dbms_output.put_line('show errors PACKAGE BODY '||buff.name);
      dbms_output.put_line('');
   end loop;
end;
/

prompt
prompt prompt
prompt set define on
prompt

spool off
set verify on
set pagesize 20
set linesize 80
set feedback on
