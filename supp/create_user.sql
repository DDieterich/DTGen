
set define '&'

set trimspool on
set serveroutput on
set feedback off
set verify off

spool create_user_&1._&2.

create user &2. identified by &2.
   default tablespace users
   temporary tablespace temp;

grant connect to &2.;
grant create synonym to &2.;
grant &1._app to &2.;

connect &2./&2.
@create_usyn &1.

spool off

set verify on
set feedback on
