
set linesize 4000
set trimspool on
set pagesize 0
set feedback off
set termout off
set verify off
set define '&'

spool &2..sql

prompt
prompt select '=== &1. &2. ===' as SCRIPT_NAME from dual;;

select FL.value
 from  file_lines  FL
 where FL.file_id = (
       select F.id
        from  files  F
        where F.name = '&2.'
         and  F.application_id = (
              select APP.id
               from  applications  APP
               where APP.abbr = '&1.' ) )
 order by seq;

spool off

set verify on
set termout on
set feedback 6
set pagesize 20
set linesize 80
