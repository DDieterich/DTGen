
REM
REM Basic Demonstration, Exercise #9, Custom Check Constraints
REM   (sqlplus /nolog @e9)
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

spool e9
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

prompt Login to &OWNERNAME.
connect &OWNERNAME./&OWNERPASS.
set serveroutput on size 1000000 format wrapped

column column_name format A19
column comments    format A60 word_wrapped

select column_name, comments
 from  user_col_comments
 where table_name  = 'CHECK_CONS_ACT'
  and  column_name in ('TABLES_NK2', 'SEQ', 'TEXT', 'DESCRIPTION');

column column_name clear
column comments    clear

column tables_nk2   format A10
column seq          format 99
column text         format A32 word_wrapped
column description  format A32 word_wrapped

select tables_nk2, seq, text, description
 from  check_cons_act
 where tables_nk1 = 'DEMO1';

column tables_nk2   clear
column seq          clear
column text         clear
column description  clear

prompt
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

column sal  format 99999
column comm format 99999

prompt
begin
   dbms_output.enable(1000000);
   dbms_output.put_line('glob.set_db_constraints(TRUE);');
                         glob.set_db_constraints(TRUE);
end;
/
prompt

set feedback 1
set echo on

select empno, ename, job, mgr_emp_nk1, sal, comm, dept_nk1
  from emp_act where ename = 'SMITH';

update emp_act
  set  comm  = 1000
 where empno = 7369;

set echo off
set feedback off

prompt
begin
   dbms_output.enable(1000000);
   dbms_output.put_line('glob.set_db_constraints(FALSE);');
                         glob.set_db_constraints(FALSE);
end;
/
prompt

set feedback 1
set echo on

update emp_act
  set  comm  = 1000
 where empno = 7369;

update emp
  set  comm  = 1000
 where empno = 7369;

set echo off
set feedback off

column sal  clear
column comm clear

WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT

spool off
exit
