
REM
REM Create Demonstration Schema Users
REM (Must be run as the "sys as sysdba" user)
REM

spool create_demo_users
set define '&'
set verify off

REM Initialize Variables
REM
@vars

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set trimspool on
set feedback off
set serveroutput on format wrapped
set define on

prompt create_roles

create role DEMO3_dml;
create role DEMO3_app;
grant DEMO3_app to DEMO3_dml;

prompt Create DB Schema Owner

create user &DB_NAME. identified by &DB_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;

alter user &DB_NAME.
   quota unlimited on &TSPACE.;

grant connect to &DB_NAME.;
grant resource to &DB_NAME.;
grant create view to &DB_NAME.;
grant DEBUG CONNECT SESSION to &DB_NAME.;
grant DEBUG ANY PROCEDURE to &DB_NAME.;
grant execute on DBMS_LOCK to &DB_NAME.;
-- Required for Tiers Demonstration
grant select on v_$database to dtgen;

prompt Create MT Schema Owner

create user &MT_NAME. identified by &MT_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;

alter user &MT_NAME.
   quota unlimited on &TSPACE.;

grant connect to &MT_NAME.;
grant resource to &MT_NAME.;
grant create view to &MT_NAME.;
grant create database link to &MT_NAME.;
grant create materialized view to &MT_NAME.;
grant create synonym to &MT_NAME.;
grant DEBUG CONNECT SESSION to &MT_NAME.;
grant DEBUG ANY PROCEDURE to &MT_NAME.;
grant execute on DBMS_LOCK to &MT_NAME.;

prompt Create User

create user &USR_NAME. identified by &USR_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;
grant connect to &USR_NAME.;
grant create synonym to &USR_NAME.;
grant DEMO3_app to &USR_NAME.;

spool off

exit
