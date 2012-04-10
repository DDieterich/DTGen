
set define '&'

set trimspool on
set serveroutput on
spool create_owner_&1.

create user &1. identified by &1.
   default tablespace users
   temporary tablespace temp;

alter user &1.
   quota unlimited on users;

grant connect to &1.;
grant resource to &1.;
grant create view to &1.;
grant create database link to &1.;
grant create materialized view to &1.;
grant create synonym to &1.;
grant DEBUG CONNECT SESSION to &1.;
grant DEBUG ANY PROCEDURE to &1.;
create role &1._dml;
create role &1._app;
grant &1._app to &1._dml;

spool off
