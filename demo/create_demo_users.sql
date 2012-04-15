
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
set serveroutput on
set define on

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

create role &DB_NAME._dml;
create role &DB_NAME._app;
grant &DB_NAME._app to &DB_NAME._dml;

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

create role &MT_NAME._dml;
create role &MT_NAME._app;
grant &MT_NAME._app to &MT_NAME._dml;

prompt Create User

create user &USR_NAME. identified by &USR_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;
grant connect to &USR_NAME.;
grant create synonym to &USR_NAME.;
grant &DB_NAME._app to &USR_NAME.;
grant &MT_NAME._app to &USR_NAME.;

prompt Create MT2 Schema Owner

create user &MT2_NAME. identified by &MT2_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;

alter user &MT2_NAME.
   quota unlimited on &TSPACE.;

grant connect to &MT2_NAME.;
grant resource to &MT2_NAME.;
grant create view to &MT2_NAME.;
grant create database link to &MT2_NAME.;
grant create materialized view to &MT2_NAME.;
grant create synonym to &MT2_NAME.;
grant DEBUG CONNECT SESSION to &MT2_NAME.;
grant DEBUG ANY PROCEDURE to &MT2_NAME.;
grant execute on DBMS_LOCK to &MT2_NAME.;

create role &MT2_NAME._dml;
create role &MT2_NAME._app;
grant &MT2_NAME._app to &MT2_NAME._dml;

prompt Create User2

create user &USR2_NAME. identified by &USR2_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;
grant connect to &USR2_NAME.;
grant create synonym to &USR2_NAME.;
grant &DB_NAME._app to &USR2_NAME.;
grant &MT_NAME._app to &USR2_NAME.;

spool off

exit
