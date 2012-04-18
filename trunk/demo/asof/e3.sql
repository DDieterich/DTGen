
REM
REM Basic Demonstration, Exercise #3, Point-in-Time ASOF Views
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
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set feedback off
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

column id           format 99
column empno        format 9999
column ename        format A8
column job          format A9
column mgr_emp_nk1  format 9999  heading MGR_
column hiredate     format A9
column sal          format 9999
column dept_nk1     format 999 heading DEPT
column aud_beg_usr  format A11
column aud_beg_dtm  format A12   truncate

set feedback 1
set echo on

execute util.set_asof_dtm(to_timestamp('1981-06-01', 'YYYY-MM-DD'))

select id, empno, ename, job, mgr_emp_nk1, hiredate,
       sal, dept_nk1, aud_beg_usr, aud_beg_dtm
 from  emp_asof
 order by empno;

execute util.set_asof_dtm(to_timestamp('1981-09-01', 'YYYY-MM-DD'))

select id, empno, ename, job, mgr_emp_nk1, hiredate,
       sal, dept_nk1, aud_beg_usr, aud_beg_dtm
 from  emp_asof
 order by empno;

execute util.set_asof_dtm(to_timestamp('1982-01-01', 'YYYY-MM-DD'))

select id, empno, ename, job, mgr_emp_nk1, hiredate,
       sal, dept_nk1, aud_beg_usr, aud_beg_dtm
 from  emp_asof
 order by empno;

set echo off

column id           clear
column empno        clear
column ename        clear
column job          clear
column mgr_emp_nk1  clear
column hiredate     clear
column sal          clear
column dept_nk1     clear
column aud_beg_usr  clear
column aud_beg_dtm  clear

spool off
