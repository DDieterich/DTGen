
--
--  test_ins.sql - Script to install the DTGen application
--

spool test_ins

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set trimspool on
set serveroutput on format wrapped
set verify off

prompt
prompt Running installation ...

@install_db
@comp

exit
