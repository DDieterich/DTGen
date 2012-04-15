
REM
REM Basic Demonstration, Exercise #1, Entity Based History and Audit
REM   (sqlplus /nolog @e1)
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

spool e1
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

prompt Remove old DEMO2 Schema from DTGEN
delete from exceptions_act where applications_nk1 = 'DEMO2';
delete from programs_act where applications_nk1 = 'DEMO2';
delete from check_cons_act where tables_nk1 = 'DEMO2';
delete from indexes_act where tab_cols_nk1 = 'DEMO2';
delete from tab_cols_act where tables_nk1 = 'DEMO2';
delete from tables_act where applications_nk1 = 'DEMO2';
delete from domain_values_act where domains_nk1 = 'DEMO2';
delete from domains_act where applications_nk1 = 'DEMO2';
delete from file_lines_act where files_nk1 = 'DEMO2';
delete from files_act where applications_nk1 = 'DEMO2';
delete from applications_act where abbr = 'DEMO2';

prompt create a DEMO2 Schema in DTGEN
insert into applications_act (abbr, name, description) values ('DEMO2', 'DTGen ASOF Demonstration', 'Demonstrates history and audit capabilities of DTGen');

insert into domains_act (applications_nk1, abbr, name, fold, len, description) values ('DEMO2', 'JOB', 'Job Name', 'U', 9, 'Job Names');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO2', 'JOB', 10, 'PRESIDENT', 'Company President');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO2', 'JOB', 20, 'MANAGER', 'Department Manager');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO2', 'JOB', 30, 'ANALYST', 'Systems Analyst');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO2', 'JOB', 40, 'SALESMAN', 'Company Salesman');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO2', 'JOB', 50, 'CLERK', 'Department Clerk');

insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('DEMO2', 'DEPT', 10, 'dept', 'LOG', 'Department Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('DEMO2', 'DEPT', 'deptno', 10, 1, 'NUMBER', 2, 'Department Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('DEMO2', 'DEPT', 'dname', 20, 'X', 'VARCHAR2', 14, 'Name of the Department');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('DEMO2', 'DEPT', 'loc', 30, 'X', 'VARCHAR2', 13, 'Location for the Department');

insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('DEMO2', 'EMP', 20, 'emp', 'EFF', 'Employee Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('DEMO2', 'EMP', 'empno', 10, 1, 'NUMBER', 4, 'Employee Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, fold, description) values ('DEMO2', 'EMP', 'ename', 20, 'X', 'VARCHAR2', 16, 'U', 'Employee Name');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, d_domains_nk1, d_domains_nk2, description) values ('DEMO2', 'EMP', 'job', 30, 'X', 'DEMO2', 'JOB', 'Job Title');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, fk_prefix, fk_tables_nk1, fk_tables_nk2, description) values ('DEMO2', 'EMP', 'mgr_emp_id', 40, 'mgr_', 'DEMO2', 'EMP', 'Surrogate Key of Employee''s Manager');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, description) values ('DEMO2', 'EMP', 'hiredate', 50, 'X', 'DATE', 'Date the Employee was hired');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, scale, description) values ('DEMO2', 'EMP', 'sal', 60, 'X', 'NUMBER', 7, 2, 'Employee''s Salary');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, type, len, scale, description) values ('DEMO2', 'EMP', 'comm', 70, 'NUMBER', 7, 2, 'Employee''s Commission');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, fk_tables_nk1, fk_tables_nk2, description) values ('DEMO2', 'EMP', 'dept_id', 80, 'X', 'DEMO2', 'DEPT', 'Surrogate Key of Employee''s Department');
insert into check_cons_act (tables_nk1, tables_nk2, seq, text, description) values ('DEMO2', 'EMP', 10, '(comm is null) or (comm is not null and job = ''SALESMAN'')', 'Only SALESMAN can be on commission');

prompt Generate Demo2 Application
begin
   util.set_usr('Demo2');
   generate.init('DEMO2');
   generate.create_glob;
   generate.create_ods;
   generate.create_integ;
   generate.create_oltp;
   generate.create_mods;
   commit;
end;
/

prompt Capture install_db.sql Script
set termout off
spool install_db.sql
execute assemble.install_script('DEMO2', 'DB');

spool install
set termout on
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped
@install_db

execute util.set_usr('Demo2');

prompt
prompt ============================================================

insert into dept_act (deptno, dname, loc) values (10, 'ACCOUNTING', 'NEW YORK');
insert into dept_act (deptno, dname, loc) values (20, 'RESEARCH', 'DALLAS');
insert into dept_act (deptno, dname, loc) values (30, 'SALES', 'CHICAGO');

column column_name format A19
column comments    format A60 word_wrapped

select column_name, comments
 from  user_col_comments
 where table_name  = 'DEPT_ACT'
  and  column_name in ('DEPTNO', 'DNAME', 'LOC', 'AUD_BEG_USR', 'AUD_BEG_DTM');

column column_name clear
column comments    clear

column id           format 99
column deptno       format 99999
column dname        format A10
column loc          format A10
column aud_beg_usr  format A11
column aud_beg_dtm  format A15   truncate

select deptno, dname, loc, aud_beg_usr, aud_beg_dtm from dept_act;

column id           clear
column deptno       clear
column dname        clear
column loc          clear
column aud_beg_usr  clear
column aud_beg_dtm  clear

prompt
prompt ============================================================

insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7839, 'KING', 'PRESIDENT', NULL, TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, 10, TO_TIMESTAMP('17-NOV-1981', 'DD-MON-YYYY'));

insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7566, 'JONES', 'MANAGER', 7839, TO_DATE('02-APR-1981', 'DD-MON-YYYY'), 2975, 20, TO_TIMESTAMP('02-APR-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7788, 'SCOTT', 'ANALYST', 7566, TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, 20, TO_TIMESTAMP('09-DEC-1982', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7876, 'ADAMS', 'CLERK', 7788, TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, 20, TO_TIMESTAMP('12-JAN-1983', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7902, 'FORD', 'ANALYST', 7566, TO_DATE('03-DEC-1981', 'DD-MON-YYYY'), 3000, 20, TO_TIMESTAMP('03-DEC-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7369, 'SMITH', 'CLERK', 7902, TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, 20, TO_TIMESTAMP('17-DEC-1980', 'DD-MON-YYYY'));

insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7698, 'BLAKE', 'MANAGER', 7839, TO_DATE('1-MAY-1981', 'DD-MON-YYYY'), 2850, NULL, 30, TO_TIMESTAMP('1-MAY-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30, TO_TIMESTAMP('20-FEB-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7521, 'WARD', 'SALESMAN', 7698, TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30, TO_TIMESTAMP('22-FEB-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7654, 'MARTIN', 'SALESMAN', 7698, TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30, TO_TIMESTAMP('28-SEP-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7844, 'TURNER', 'SALESMAN', 7698, TO_DATE('08-SEP-1981', 'DD-MON-YYYY'), 1500, 0, 30, TO_TIMESTAMP('08-SEP-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, comm, dept_nk1, eff_beg_dtm) values (7900, 'JAMES', 'CLERK', 7698, TO_DATE('03-DEC-1981', 'DD-MON-YYYY'), 950, NULL, 30, TO_TIMESTAMP('03-DEC-1981', 'DD-MON-YYYY'));

insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7782, 'CLARK', 'MANAGER', 7839, TO_DATE('09-JUN-1981', 'DD-MON-YYYY'), 2450, 10, TO_TIMESTAMP('09-JUN-1981', 'DD-MON-YYYY'));
insert into emp_act (empno, ename, job, mgr_emp_nk1, hiredate, sal, dept_nk1, eff_beg_dtm) values (7934, 'MILLER', 'CLERK', 7782, TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, 10, TO_TIMESTAMP('23-JAN-1982', 'DD-MON-YYYY'));

column column_name format A19
column comments    format A60 word_wrapped

select column_name, comments
 from  user_col_comments
 where table_name  = 'EMP_ACT'
  and  column_name in ('EMPNO', 'ENAME', 'JOB', 'MGR_EMP_NK1',
       'HIREDATE', 'SAL', 'DEPT_NK1', 'EFF_BEG_DTM', 'AUD_BEG_USR');

column column_name clear
column comments    clear

column empno        format 9999
column ename        format A6
column job          format A9
column mgr_emp_nk1  format 9999  heading MGR_
column hiredate     format A9
column sal          format 9999
column dept_nk1     format 99999 heading DEPT_
column eff_beg_dtm  format A15   truncate
column aud_beg_usr  format A11

select empno, ename, job, mgr_emp_nk1, hiredate,
       sal, dept_nk1, eff_beg_dtm, aud_beg_usr
 from  emp_act;

column empno        clear
column ename        clear
column job          clear
column mgr_emp_nk1  clear
column hiredate     clear
column sal          clear
column dept_nk1     clear
column eff_beg_dtm  clear
column aud_beg_usr  clear

spool off
