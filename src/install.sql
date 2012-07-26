
REM
REM DTGen Database Installation Script
REM (Must be run as the "sys as sysdba" user)
REM

spool install

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'
set trimspool on
set serveroutput on
set feedback off
set verify off

REM Initialize Variables
REM
define NAME = dtgen   -- New Schema Owner Name
define PASS = dtgen   -- New Schema Owner Password

REM Create New Schema Owner
REM
-- New Schema Owner Default Tablespace:   users
-- New Schema Owner Temporary Tablespace: temp
@create_owner &NAME. &PASS. users temp

REM Create DTGen Schema Objects
REM
connect &NAME./&PASS.
@install_db
@comp

set feedback on
set verify on

spool off
