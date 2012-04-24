
REM
REM Basic Demonstration, Exercise #8, Full Procedural APIs
REM   (sqlplus /nolog @e8)
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

spool e8
set define '&'
set tab off

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

column id          format 999
column empno       format 99999
column mgr_id_path format A20
column mgr_nk_path format A30

set echo on

select ename, id, empno, mgr_id_path, mgr_nk_path
  from emp_act where empno = 7369;

select emp_dml.get_id(7369) id, emp_dml.get_nk(6) empno,
       emp_dml.get_mgr_id_path(6) mgr_id_path,
       emp_dml.get_mgr_nk_path(6) mgr_nk_path
  from dual;

select emp_dml.get_mgr_id_by_id_path('1:2:5') id
 from  dual;

select emp_dml.get_mgr_id_by_nk_path('7839:7566:7902') id
 from  dual;

declare
   id          emp_act.id%TYPE;
   empno       emp_act.empno%TYPE        := 21;
   ename       emp_act.ename%TYPE        := 'BOGUS';
   job         emp_act.job%TYPE          := 'CLERK';
   mgr_emp_id  emp_act.mgr_emp_id%TYPE;
   hiredate    emp_act.hiredate%TYPE     := sysdate;
   sal         emp_act.sal%TYPE          := 1;
   comm        emp_act.comm%TYPE;
   dept_id     emp_act.dept_id%TYPE      := 4;
begin
   dbms_output.enable;
   dbms_output.put_line('id before emp_dml.ins is "' || id || '"');
   emp_dml.ins
      (n_id          => id
      ,n_empno       => empno
      ,n_ename       => ename
      ,n_job         => job
      ,n_mgr_emp_id  => mgr_emp_id
      ,n_hiredate    => hiredate
      ,n_sal         => sal
      ,n_comm        => comm
      ,n_dept_id     => dept_id
      );
   dbms_output.put_line('id after emp_dml.ins is "' || id || '"');
end;
/

select id, empno, ename, job, sal, mgr_emp_nk1, dept_nk1
  from emp_act where ename = 'BOGUS';

describe emp_dml

begin
   dbms_output.enable;
   glob.fold_strings := TRUE;
   for buff in (
      select * from emp
       where ename = 'BOGUS' )
   loop
      buff.job   := 'SALESMAN';
      buff.ename := 'Bogus';
      dbms_output.put_line('buff.ename before emp_dml.up is "' ||
                            buff.ename || '"');
      emp_dml.upd
         (o_id_in       => buff.id
         ,n_empno       => buff.empno
         ,n_ename       => buff.ename
         ,n_job         => buff.job
         ,n_mgr_emp_id  => buff.mgr_emp_id
         ,n_hiredate    => buff.hiredate
         ,n_sal         => buff.sal
         ,n_comm        => buff.comm
         ,n_dept_id     => buff.dept_id
         );
      dbms_output.put_line('buff.ename after emp_dml.up is "' ||
                            buff.ename || '"');
   end loop;
end;
/

select id, empno, ename, job, sal, mgr_emp_nk1, dept_nk1
  from emp_act where ename = 'BOGUS';

declare
   rec  emp%ROWTYPE;
begin
   dbms_output.enable;
   rec.id            := null;
   rec.empno         := 22;
   rec.ename         := 'BOGUS';
   rec.job           := 'CLERK';
   rec.mgr_emp_id    := null;
   rec.hiredate      := sysdate;
   rec.sal           := 1;
   rec.comm          := null;
   rec.dept_id       := null;
   dbms_output.put_line('rec.mgr_emp_id before emp_dml.ins is "' ||
                         rec.mgr_emp_id || '"');
   dbms_output.put_line('rec.dept_id before emp_dml.ins is "' ||
                         rec.dept_id || '"');
   emp_dml.ins
      (n_id              => rec.id
      ,n_empno           => rec.empno
      ,n_ename           => rec.ename
      ,n_job             => rec.job
      ,n_mgr_emp_id      => rec.mgr_emp_id
      ,n_mgr_nk_path_in  => '7839:7566:7902'
      ,n_hiredate        => rec.hiredate
      ,n_sal             => rec.sal
      ,n_comm            => rec.comm
      ,n_dept_id         => rec.dept_id
      ,n_dept_nk1_in     => 40
      );
   dbms_output.put_line('rec.mgr_emp_id after emp_dml.ins is "' ||
                         rec.mgr_emp_id || '"');
   dbms_output.put_line('rec.dept_id after emp_dml.ins is "' ||
                         rec.dept_id || '"');
end;
/

select id, empno, ename, job, sal, mgr_emp_nk1, dept_nk1
  from emp_act where ename = 'BOGUS';

declare
   type empcurtype is ref cursor return emp%ROWTYPE;
   c1   empcurtype;
   buff emp%rowtype;
begin
   dbms_output.enable;
   glob.fold_strings := TRUE;
   open c1 for
      select * from emp
       where empno = 21;
   fetch c1 into buff;
   close c1;
   dbms_output.put_line('buff.mgr_emp_id after emp_dml.ins is "' ||
                         buff.mgr_emp_id || '"');
   emp_dml.upd
      (o_id_in             => buff.id
      ,n_empno             => buff.empno
      ,n_ename             => buff.ename
      ,n_job               => buff.job
      ,n_mgr_emp_id        => buff.mgr_emp_id
      ,n_mgr_nk_path_in    => '7839:7566:7902'
      ,n_hiredate          => buff.hiredate
      ,n_sal               => buff.sal
      ,n_comm              => buff.comm
      ,n_dept_id           => buff.dept_id
      ,nkdata_provided_in  => 'T'
      );
   dbms_output.put_line('buff.mgr_emp_id after emp_dml.ins is "' ||
                         buff.mgr_emp_id || '"');
end;
/

select id, empno, ename, job, sal, mgr_emp_nk1, dept_nk1
  from emp_act where ename = 'BOGUS';

set echo off

column id          clear
column empno       clear
column mgr_id_path clear
column mgr_nk_path clear

spool off
