
REM
REM ASOF Demonstration, Exercise #4, Audited POP Functions
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
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set feedback 1
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

column eid               format 99
column empno             format 9999
column ename             format A8
column did               format 99
column dept              format 999
column aud_beg_usr       format A7
column aud_beg_dtm       format A9   truncate
column aud_end_usr       format A7
column aud_end_dtm       format A9   truncate
column aud_prev_beg_usr  format A7
column aud_prev_beg_dtm  format A9   truncate
column pop_dml           format A6
column pop_usr           format A7
column pop_dtm           format A9   truncate
set echo on

select id did, deptno, dname, loc from dept_act;

select empno, ename, job, dept_id did, dept_nk1 dept, aud_beg_usr, aud_beg_dtm
 from emp_act where dept_nk1 = 40;

execute util.set_usr('SMITH');

-- Add a new manager MCMURRY to the Operations Department
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_id)
 values (8156, 'MCMURRY', 'MANAGER', 7839, sysdate, 2975, 4);

-- Add a new analyst WALKER to the Operations Department
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1)
 values (8157, 'WALKER', 'ANALYST', 8156, sysdate, 3000, 40);

-- Transfer an analyst SCOTT to the Operations Department
update emp_act
  set  dept_id     = 4
      ,mgr_emp_nk1 = 8156
 where empno = 7788;

-- Transfer a clerk JAMES to the Operations Department
update emp_act
  set  dept_nk1    = 40
      ,mgr_emp_nk1 = 8156
 where empno = 7902;

commit;

select id eid, empno, ename, job, dept_id did, dept_nk1 dept,
       aud_beg_usr, aud_beg_dtm
 from emp_act where dept_nk1 = 40;

execute util.set_usr('MILLER');

select emp_id eid, empno, ename, dept_id did,
       aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
 from emp_hist where empno = 7902;

-- Undo the transfer of FORD to the Operations Department
declare
   emp_id  number;
begin
   select id into emp_id from emp_act where empno = 7902;
   emp_dml.pop(emp_id);
end;
/

-- Transfer a clerk JAMES to the Operations Department
update emp_act
  set  dept_nk1    = 40
      ,mgr_emp_nk1 = 8156
 where empno = 7900;

select id eid, empno, ename, job, dept_id did, dept_nk1 dept,
       aud_beg_usr, aud_beg_dtm
 from emp_act where dept_nk1 = 40 or empno = 7902;

select emp_id eid, empno, ename, dept_id did,
       aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
 from emp_hist where empno = 7902;

commit;

select emp_id eid, pop_dml, pop_usr, pop_dtm, empno, ename,
       aud_beg_usr, aud_beg_dtm, aud_prev_beg_usr, aud_prev_beg_dtm
 from emp_pdat;

set echo off

column eid               clear
column empno             clear
column ename             clear
column did               clear
column dept              clear
column aud_beg_usr       clear
column aud_beg_dtm       clear
column aud_end_usr       clear
column aud_end_dtm       clear
column aud_prev_beg_usr  clear
column aud_prev_beg_dtm  clear
column pop_dml           clear
column pop_usr           clear
column pop_dtm           clear

spool off
