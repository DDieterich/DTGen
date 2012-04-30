
REM
REM Basic Demonstration, Exercise #7, Enforced Case Folding
REM   (sqlplus /nolog @e7)
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

spool e7
set define '&'

REM Initialize Variables
REM
@../vars

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT ROLLBACK
set feedback 1
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

set echo on

select empno, ename
 from  emp
 where empno = 7369;

set echo off
set feedback off

prompt
begin
   dbms_output.enable(1000000);
   dbms_output.put_line('glob.fold_strings := TRUE;');
                         glob.fold_strings := TRUE;
end;
/
prompt

set feedback 1
set echo on

-- Change SMITH's name to mixed-case
update emp_act
  set  ename = 'Smith'
 where empno = 7369;

select empno, ename
 from  emp
 where empno = 7369;

set echo off
set feedback off

prompt
begin
   dbms_output.put_line('glob.fold_strings := FALSE;');
                         glob.fold_strings := FALSE;
end;
/
prompt

set feedback 1
set echo on

-- Change SMITH's name to mixed-case
update emp_act
  set  ename = 'Smith'
 where empno = 7369;

select empno, ename
 from  emp
 where empno = 7369;

set echo off

begin
   glob.fold_strings := TRUE;
   commit;
end;
/

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT ROLLBACK
spool off
exit
