
REM
REM DTGEN Un-Installation Script
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

spool uninstall

REM Initialize Variables
REM
define OWNERNAME = GEN     -- New DTGen Schema Name

REM Configure SQL*Plus
REM
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set trimspool on
set serveroutput on
set feedback off
set define on

prompt
prompt This will remove the following user from the database:
prompt
prompt   -) &OWNERNAME.
prompt
prompt Note: APEX Applications must be dropped manually
prompt Note: DTGen users must be dropped manually
prompt
prompt Press ENTER to continue
accept junk

drop role &OWNERNAME._app;
drop role &OWNERNAME._dml;
drop user &OWNERNAME. cascade;

spool off
