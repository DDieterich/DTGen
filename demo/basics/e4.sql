
REM
REM Basic Demonstration, Exercise #4, Natural Key Updatable Views
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
set feedback 1
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT ROLLBACK
set serveroutput on format wrapped

column sal format 99999
set echo on

select deptno, dname, loc from dept_act
 where dname = 'OPERATIONS';

select empno, ename, job, mgr_emp_nk1, hiredate,
 sal, dept_nk1 from emp_act
 where dept_nk1 = 40;

-- Add a new manager to the Operations Department
--   using the surrogate key for the department
--   in the active view
insert into emp_act (empno, ename, job,
    mgr_emp_nk1, hiredate, sal, dept_id)
 values (8156, 'MCMURRY', 'MANAGER',
    7839, sysdate, 2975, 4);

-- Add a new analyst to the Operations Department
--   using the natural key for the department
--   in the active view
insert into emp_act (empno, ename, job,
    mgr_emp_nk1, hiredate, sal, dept_nk1)
 values (8157, 'WALKER', 'ANALYST',
    8156, sysdate, 3000, 40);

-- Transfer an analyst to the Operations Department
-- using the surrogate key for the department
-- in the active view
update emp_act
  set  dept_id     = 4
      ,mgr_emp_nk1 = 8156
 where empno = 7788;

-- Transfer a clerk to the Operations Department
--   using the natural key for the department
--   in the active view
update emp_act
  set  dept_nk1    = 40
      ,mgr_emp_nk1 = 8156
 where empno = 7900;

select empno, ename, job, mgr_emp_nk1, hiredate,
 sal, dept_nk1 from emp_act
 where dept_nk1 = 40
 order by empno;

set echo off
column sal clear

commit;

spool off
exit
