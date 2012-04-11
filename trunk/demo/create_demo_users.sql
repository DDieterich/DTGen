
REM
REM Create Demonstration Schema Users
REM (Must be run as the "sys as sysdba" user)
REM

spool create_demo_users
set define '&'

REM Initialize Variables
REM
define TSPACE = users            -- Default Tablespace
define DB_NAME = dtgen_db_demo   -- Database DEMO Schema Username
define DB_PASS = dtgen           -- Database DEMO Schema Password
define MT_NAME = dtgen_mt_demo   -- Mid-Tier DEMO Schema Username
define MT_PASS = dtgen           -- Mid-Tier DEMO Schema Password
define USR_NAME = dtgen_usr_demo -- DEMO User Username
define USR_PASS = dtgen          -- DEMO User Password

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set trimspool on
set serveroutput on
set feedback off
set define on

REM Create DB Schema User
REM
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

REM Create MT Schema User
REM
create user &MT_NAME. identified by &MT_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;

alter user &MT_NAME.
   quota unlimited on &TSPACE.;

grant connect to &MT_NAME.;
grant resource to &MT_NAME.;
grant create view to &MT_NAME.;
grant create database link to &OWNERNAME.;
grant create materialized view to &OWNERNAME.;
grant create synonym to &OWNERNAME.;
grant DEBUG CONNECT SESSION to &MT_NAME.;
grant DEBUG ANY PROCEDURE to &MT_NAME.;
grant execute on DBMS_LOCK to &MT_NAME.;

REM Create MT Schema User
REM
create user &USR_NAME. identified by &USR_PASS.
   default tablespace &TSPACE.
   temporary tablespace temp;
grant connect to &USR_NAME.;
grant create synonym to &USR_NAME.;
grant &DB_NAME._app to &USR_NAME.;
grant &MT_NAME._app to &USR_NAME.;

spool off

exit
