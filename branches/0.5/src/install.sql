
REM
REM DTGen Database Installation Script
REM (Must be run as the "system" user)
REM
REM Copyright (c) 2011, Duane.Dieterich@gmail.com
REM All rights reserved.
REM
REM Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
REM
REM Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
REM Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
REM THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

prompt generate.pkb
@assemble.pkb
/

set define on
set verify on

spool off
