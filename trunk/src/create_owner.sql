
REM
REM Create Schema Owner Script
REM (Must be run as the "sys as sysdba" user)
REM

set define '&'
set verify off
set trimspool on

REM Initialize Variables
REM
define OWNERNAME = &1.   -- New Schema Owner Name
define OWNERPASS = &2.   -- New Schema Owner Password
define DEF_SPACE = &3.   -- New Schema Owner Default Tablespace
define TMP_SPACE = &4.   -- New Schema Owner Temporary Tablespace

REM Create New Schema Owner
REM
create user &OWNERNAME. identified by &OWNERPASS.
   default tablespace &DEF_SPACE.
   temporary tablespace &TMP_SPACE.;

alter user &OWNERNAME.
   quota unlimited on &DEF_SPACE.;

grant connect to &OWNERNAME.;
grant resource to &OWNERNAME.;
grant create view to &OWNERNAME.;
grant create database link to &OWNERNAME.;
grant create materialized view to &OWNERNAME.;
grant create synonym to &OWNERNAME.;
grant DEBUG CONNECT SESSION to &OWNERNAME.;
grant DEBUG ANY PROCEDURE to &OWNERNAME.;
grant execute on DBMS_LOCK to &OWNERNAME.;

REM Create New Schema Roles
REM
create role &OWNERNAME._dml;
create role &OWNERNAME._app;
grant &OWNERNAME._app to &OWNERNAME._dml;
