
REM
REM ASOF Demonstration, Exercise #2, EFF vs. LOG Table Types
REM   (sqlplus /nolog @e2)
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

spool e2
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
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set serveroutput on format wrapped

column value        format A5
column description  format A74 word_wrapped

select value, description from domain_values_act
 where domains_nk1 = 'DTGEN' and domains_nk2 = 'TTYPE'
 order by seq;

column value        clear
column description  clear

select seq, name, type from tables_act
 where applications_nk1 = 'DEMO2' order by seq;

prompt
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.&TNS_ALIAS.
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set serveroutput on format wrapped

column systimestamp  format A18   truncate
column id            format 99
column dept          format 999
column loc           format A3    truncate
column aud_beg_usr   format A11
column aud_beg_dtm   format A18   truncate
column aud_end_usr   format A11
column aud_end_dtm   format A18   truncate

set feedback 1
set echo on

select id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm
  from dept_act where deptno = 50;
select dept_id id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from dept_aud where deptno = 50;

execute glob.set_usr('USER1');
select systimestamp from dual;
insert into dept_act (deptno, dname, loc)
  values (50, 'NEW_DEPT', 'LZ');

select id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm
  from dept_act where deptno = 50;
select dept_id id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from dept_aud where deptno = 50;

execute dbms_lock.sleep(1);
execute glob.set_usr('USER2');
select systimestamp from dual;
update dept_act
  set  loc = 'LA'
 where deptno = 50;

select id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm
  from dept_act where deptno = 50;
select dept_id id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from dept_aud where deptno = 50;

execute dbms_lock.sleep(1);
execute glob.set_usr('USER3');
select systimestamp from dual;
delete from dept_act where deptno = 50;

select id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm
  from dept_act where deptno = 50;
select dept_id id, deptno dept, loc,
  aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from dept_aud where deptno = 50;

rollback;

set echo off

column systimestamp  clear
column id            clear
column dept          clear
column loc           clear
column aud_beg_usr   clear
column aud_beg_dtm   clear
column aud_end_usr   clear
column aud_end_dtm   clear

prompt
prompt ============================================================

column systimestamp  format A18   truncate
column id            format 99
column empno         format 9999
column ename         format A9
column eff_beg_dtm   format A11   truncate
column aud_beg_usr   format A5
column aud_beg_dtm   format A11   truncate
column eff_end_dtm   format A11   truncate
column aud_end_usr   format A5
column aud_end_dtm   format A11   truncate

set feedback 1
set echo on

select id, empno, ename, to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm
  from emp_act where empno = 9999;
select emp_id id, empno, ename,
  to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm,
  to_char(eff_end_dtm,'DD HH24:MI:SS') eff_end_dtm,
  aud_end_usr, to_char(aud_end_dtm,'DD HH24:MI:SS') aud_end_dtm
  from emp_hist where empno = 9999;

execute glob.set_usr('USER1');
select systimestamp from dual;
insert into emp_act (empno, ename, job, hiredate, sal, dept_nk1,
     eff_beg_dtm)
  values (9999, 'NEW_EMP', 'CLERK', sysdate, 100, 40,
     to_timestamp('1983-6-1 11', 'YYYY-MM-DD HH24'));

select id, empno, ename, to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm
  from emp_act where empno = 9999;
select emp_id id, empno, ename,
  to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm,
  to_char(eff_end_dtm,'DD HH24:MI:SS') eff_end_dtm,
  aud_end_usr, to_char(aud_end_dtm,'DD HH24:MI:SS') aud_end_dtm
  from emp_hist where empno = 9999;

execute dbms_lock.sleep(1);
execute glob.set_usr('USER2');
select systimestamp from dual;
update emp_act
  set  ename = 'UPD_EMP',
       eff_beg_dtm = to_timestamp('1983-6-2 12', 'YYYY-MM-DD HH24')
 where empno = 9999;

select id, empno, ename, to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm
  from emp_act where empno = 9999;
select emp_id id, empno, ename,
  to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm,
  to_char(eff_end_dtm,'DD HH24:MI:SS') eff_end_dtm,
  aud_end_usr, to_char(aud_end_dtm,'DD HH24:MI:SS') aud_end_dtm
  from emp_hist where empno = 9999;

execute dbms_lock.sleep(1);
select systimestamp from dual;
declare
   eff_end_dtm  timestamp with local time zone;
   emp_id       number;
begin
   glob.set_usr('USER3');
   select id into emp_id
     from emp_act where empno = 9999;
   eff_end_dtm := to_timestamp('1983-6-3 13', 'YYYY-MM-DD HH24');
   emp_dml.del(emp_id, eff_end_dtm);
end;
/

select id, empno, ename, to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm
  from emp_act where empno = 9999;
select emp_id id, empno, ename,
  to_char(eff_beg_dtm,'DD HH24:MI:SS') eff_beg_dtm,
  aud_beg_usr, to_char(aud_beg_dtm,'DD HH24:MI:SS') aud_beg_dtm,
  to_char(eff_end_dtm,'DD HH24:MI:SS') eff_end_dtm,
  aud_end_usr, to_char(aud_end_dtm,'DD HH24:MI:SS') aud_end_dtm
  from emp_hist where empno = 9999;

rollback;

set echo off

column systimestamp  clear
column id            clear
column empno         clear
column ename         clear
column eff_beg_dtm   clear
column aud_beg_usr   clear
column aud_beg_dtm   clear
column eff_end_dtm   clear
column aud_end_usr   clear
column aud_end_dtm   clear

spool off
exit
