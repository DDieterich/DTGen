
REM
REM Tiers Demonstration, Exercise #3, User Security
REM   (sqlplus /nolog @e3)
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

spool e3
set define '&'

REM Initialize Variables
REM
@../vars

REM Configure SQL*Plus
REM
set feedback off
set trimspool on
set define on

prompt Login to &OWNERNAME.
connect &OWNERNAME./&OWNERPASS.&TNS_ALIAS.
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set serveroutput on format wrapped
set echo on
select name, db_schema from applications where abbr = 'DEMO3';
set echo off

prompt Login to &USR_NAME.
connect &USR_NAME./&USR_PASS.&TNS_ALIAS.
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set serveroutput on format wrapped
@install_usr &MT_NAME.

set linesize 120
set pagesize 5000
set echo on

explain plan set statement_id = 'D3_E3_Q1'
   into plan_table for select * from emp where empno = 7900;

select plan_table_output from table (
  dbms_xplan.display('PLAN_TABLE', 'D3_E3_Q1') );

set echo off
set linesize 80
set pagesize 24

column empno        format 9999
column ename        format A8
column job          format A9
column mgr_emp_nk1  format 9999
column hiredate     format A9
column sal          format 9999
column deptno       format 99999
column dname        format A10
column loc          format A8

set echo on

execute glob.set_asof_dtm(to_timestamp('1981-06-01', 'YYYY-MM-DD'))

select empno, ename, job, mgr_emp_nk1, hiredate, sal, deptno, dname, loc
 from  emp_asof e, dept_asof d where e.dept_id = d.id
 order by empno;

set echo off

column empno        clear
column ename        clear
column job          clear
column mgr_emp_nk1  clear
column hiredate     clear
column sal          clear
column deptno       clear
column dname        clear
column loc          clear

spool off
exit
