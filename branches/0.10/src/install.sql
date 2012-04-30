
REM
REM DTGen Database Installation Script
REM (Must be run as the "sys as sysdba" user)
REM

set define '&'

set trimspool on
set serveroutput on
set feedback off
set verify off
spool install

REM Initialize Variables
REM
define OWNERNAME = dtgen   -- New DTGen Schema Name
define OWNERPASS = dtgen   -- New DTGen Schema Password
define TSPACE = users      -- Default Tablespace for DTGen Account

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set trimspool on
set serveroutput on
set feedback off
set define on

REM Create DTGEN Schema Owner
REM
create user &OWNERNAME. identified by &OWNERPASS.
   default tablespace &TSPACE.
   temporary tablespace temp;
alter user &OWNERNAME.
   quota unlimited on &TSPACE.;
grant connect to &OWNERNAME.;
grant resource to &OWNERNAME.;
grant create view to &OWNERNAME.;
grant create database link to &OWNERNAME.;
grant create materialized view to &OWNERNAME.;
grant create synonym to &OWNERNAME.;
grant DEBUG CONNECT SESSION to &OWNERNAME.;
grant DEBUG ANY PROCEDURE to &OWNERNAME.;
grant execute on dbms_lock to &OWNERNAME.;

REM Create DTGEN Roles
REM
create role &OWNERNAME._dml;
create role &OWNERNAME._app;
grant &OWNERNAME._app to &OWNERNAME._dml;

REM Create DTGen Schema Objects
REM
connect &OWNERNAME./&OWNERPASS.
@install_db

set feedback on
set define off
prompt

prompt generate.pks
@generate.pks
/

prompt assemble.pks
@assemble.pks
/

prompt generate.pkb
@generate.pkb
/

prompt assemble.pkb
@assemble.pkb
/

set define on
set verify on

spool off
