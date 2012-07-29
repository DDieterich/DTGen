
REM
REM ASOF Demonstration, Exercise #6, Transportable ASOF Data
REM   (sqlplus /nolog @e6)
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

spool e6
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

column empno        format 9999
column ename        format A8
column job          format A9
column mgr_emp_nk1  format 9999
column hiredate     format A9
column sal          format 9999
column deptno       format 99999
column dname        format A10
column loc          format A8

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on format wrapped

set echo on

REM Export the 4 tables
REM 
host exp &DB_NAME./&DB_PASS. LOG=e6_exp.log FILE=e6.dmp TABLES=dept,dept_aud,emp,emp_hist

REM  These constraints are only used to assist Data Dictionary Queries
REM  Since they were created, these constraints were never enabled
REM
alter view emp_act  drop constraint emp_act_fk1;
alter view emp_act  drop constraint emp_act_fk2;
alter view emp_l    drop constraint emp_l_fk1;
alter view emp_l    drop constraint emp_l_fk2;
alter view emp_all  drop constraint emp_all_fk1;
alter view emp_all  drop constraint emp_all_fk2;
alter view emp_f    drop constraint emp_f_fk1;
alter view emp_f    drop constraint emp_f_fk2;
alter view emp_asof drop constraint emp_asof_fk1;
alter view emp_asof drop constraint emp_asof_fk2;

REM Drop the tables
REM
drop table emp_hist;
drop table emp;
drop table dept_aud;
drop table dept;

REM Import the 4 tables
REM 
host imp &DB_NAME./&DB_PASS. LOG=e6_imp.log FILE=e6.dmp

REM While not necessary in this exercise, it is important to demonstrate
REM   a possible method of transporting the sequence generators

drop   sequence dept_seq;
create sequence dept_seq;
declare
   max_id  number;
   junk    number;
begin
   dbms_output.enable;
   select max(id) into max_id
   from (select max(id) id from dept
         union
		 select max(dept_id) id from dept_aud
		 );
   for i in 1 .. max_id
   loop
      select dept_seq.nextval into junk from dual;
   end loop;
   dbms_output.put_line('DEPT_SEQ incremented to ' || max_id);
end;
/

drop   sequence emp_seq;
create sequence emp_seq;
declare
   max_id  number;
   junk    number;
begin
   dbms_output.enable;
   select max(id) into max_id
   from (select max(id) id from emp
         union
		 select max(emp_id) id from emp_hist
		 );
   for i in 1 .. max_id
   loop
      select emp_seq.nextval into junk from dual;
   end loop;
   dbms_output.put_line('EMP_SEQ incremented to ' || max_id);
end;
/

commit;

execute glob.set_asof_dtm(to_timestamp('1983-01-01', 'YYYY-MM-DD'))

select empno, ename, job, mgr_emp_nk1, hiredate, sal, deptno, dname, loc
 from  emp_asof e, dept_asof d where e.dept_id = d.id
 order by empno;

execute glob.set_asof_dtm(to_timestamp('1982-01-01', 'YYYY-MM-DD'))

select empno, ename, job, mgr_emp_nk1, hiredate, sal, deptno, dname, loc
 from  emp_asof e, dept_asof d where e.dept_id = d.id
 order by empno;

execute glob.set_asof_dtm(to_timestamp('1981-09-01', 'YYYY-MM-DD'))

select empno, ename, job, mgr_emp_nk1, hiredate, sal, deptno, dname, loc
 from  emp_asof e, dept_asof d where e.dept_id = d.id
 order by empno;

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
