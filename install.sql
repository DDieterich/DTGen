
--
-- DTGen Database Installation Script
-- (Must be run as the "sys as sysdba" user)
--

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'

-- Initialize Variables
--
define NAME = dtgen   -- New Schema Owner Name
define PASS = dtgen   -- New Schema Owner Password

-- Create New Schema Owner
--
-- New Schema Owner Default Tablespace:   users
-- New Schema Owner Temporary Tablespace: temp
--
@supp/create_owner &NAME. &PASS. users

set trimspool on
set serveroutput on
set feedback off
set verify off

spool install

-- Create DTGen Schema Objects
--
connect &NAME./&PASS.
@src/install_db
@src/comp

spool off

set feedback on
set verify on
