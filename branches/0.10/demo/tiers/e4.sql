
REM
REM Tiers Demonstration, Exercise #4, Global Locks
REM   (sqlplus /nolog @e4)
REM
REM Copyright (c) 2012, Duane.Dieterich@gmail.com
REM All rights reserved.
REM
REM Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
REM
REM Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
REM Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
REM THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
REM

spool e4
set define '&'

REM Initialize Variables
REM
@../vars

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set feedback off
set trimspool on
set define on

prompt Login to &USR_NAME.
connect &USR_NAME./&USR_PASS.
set serveroutput on size 1000000 format wrapped

set echo on

describe glob

execute util.set_usr('DEMO3');
execute dbms_output.put_line(glob.request_lock('DEMO3'));

set echo off

prompt
prompt  Open another window to run "e4a.sql"
prompt     Ex: sqlplus /nolog @e4a
prompt
prompt  Press Enter when prompted from other window
accept junk

set echo on
execute dbms_output.put_line(glob.request_lock('DEMO2'));
execute dbms_output.put_line(glob.request_lock('DEMO3'));
execute dbms_output.put_line(glob.release_lock);
execute dbms_output.put_line(glob.release_lock);
set echo off

spool off
exit
