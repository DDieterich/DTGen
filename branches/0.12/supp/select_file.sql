
-- SPOOL script to create DTGEN SQL script files
-- &1. is the DTGEN application abbreviation
-- &2. is the name of the DTGEN SQL script file
spool &2..sql
set define '&'
set feedback off
set linesize 4000
set pagesize 0
set trimspool on
set verify off

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

set verify on
set pagesize 20
set linesize 80
set feedback 6
spool off
