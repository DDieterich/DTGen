
--
-- DTGen Database Installation Script
-- (Must be run as the "sys as sysdba" user)
--

spool install

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'
set trimspool on
set feedback off
set serveroutput on format wrapped
set verify off

-- Initialize Variables
--
-- create_owner.sql defines variables OWNERNAME, OWNERPASS, and DEF_SPACE
--
define NAME = dtgen   -- New Schema Owner Name
define PASS = dtgen   -- New Schema Owner Password

-- Create New Schema Owner
--
-- New Schema Owner Default Tablespace: users
--
@supp/create_owner &NAME. &PASS. users

-- Create DTGen Schema Objects
--
connect &NAME./&PASS.
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
@src/install_db
@src/comp

set feedback on
set verify on

spool off
