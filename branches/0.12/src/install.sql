
--
-- DTGen Database Installation Script
-- (Must be run as the "sys as sysdba" user)
--

spool install

-- Configure SQL*Plus
--
set define '&'
set trimspool on
set feedback off
set serveroutput on format wrapped
set verify off

-- Initialize Variables
--
-- create_owner.sql defines variables OWNERNAME, OWNERPASS, and DEF_SPACE
--
define NAME = DTGEN   -- New Schema Owner Name
define PASS = dtgen   -- New Schema Owner Password
define TNS  = @XE2    -- TNS Alias Name for Remote Database
                      -- (must include the @ sign)
define APP  = dtgen   -- Application Abbreviation

-- Create New Schema Owner
--
-- New Schema Owner Default Tablespace: users
--
@../supp/create_owner &NAME. &PASS. users
@../supp/create_app_role &APP.

-- Create DTGen Schema Objects
--
connect &NAME./&PASS.&TNS.
set serveroutput on format wrapped
@install_db
@comp

set feedback on
set verify on

spool off
