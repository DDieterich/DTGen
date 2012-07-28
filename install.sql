
REM
REM DTGen Database Installation Script
REM (Must be run as the "sys as sysdba" user)
REM

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'

REM Initialize Variables
REM
define NAME = dtgen   -- New Schema Owner Name
define PASS = dtgen   -- New Schema Owner Password

REM Create New Schema Owner
REM
-- New Schema Owner Default Tablespace:   users
-- New Schema Owner Temporary Tablespace: temp
@src/create_owner &NAME. &PASS. users temp

set trimspool on
set serveroutput on
set feedback off
set verify off

spool install

REM Create DTGen Schema Objects
REM
connect &NAME./&PASS.
@src/dtgen/install_db
@src/dtgen/comp

spool off

set feedback on
set verify on
