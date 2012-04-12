
REM
REM Basic Demonstration, Exercise #1, Basic Generation
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
define OWNERNAME = dtgen         -- DTGen Schema Name
define OWNERPASS = dtgen         -- DTGen Schema Password
define DB_NAME = dtgen_db_demo   -- Database DEMO Schema Username
define DB_PASS = dtgen           -- Database DEMO Schema Password

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set feedback off
set trimspool on
set serveroutput on size 1000000 format wrapped
set define on

prompt Login to &OWNERNAME.
connect &OWNERNAME./&OWNERPASS.

prompt Remove old DEMO Schema from DTGEN
delete from exceptions_act where applications_nk1 = 'D1';
delete from programs_act where applications_nk1 = 'D1';
delete from check_cons_act where tables_nk1 = 'D1';
delete from indexes_act where tab_cols_nk1 = 'D1';
delete from tab_cols_act where tables_nk1 = 'D1';
delete from tables_act where applications_nk1 = 'D1';
delete from domain_values_act where domains_nk1 = 'D1';
delete from domains_act where applications_nk1 = 'D1';
delete from file_lines_act where files_nk1 = 'D1';
delete from files_act where applications_nk1 = 'D1';
delete from applications_act where abbr = 'D1';

prompt create a DEMO Schema in DTGEN
insert into applications_act (abbr, name, description) values ('D1', 'Demo1', 'Demo 1 is from Oracle''s Scott/Tiger demobld.sql');
insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('D1', 'DEPT', 10, 'dept', 'NON', 'Department Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('D1', 'DEPT', 'deptno', 10, 1, 'NUMBER', 2, 'Department Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('D1', 'DEPT', 'dname', 20, 'X', 'VARCHAR2', 14, 'Name of the Department');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('D1', 'DEPT', 'loc', 30, 'X', 'VARCHAR2', 13, 'Location for the Department');
insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('D1', 'EMP', 20, 'emp', 'NON', 'Employee Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('D1', 'EMP', 'empno', 10, 1, 'NUMBER', 4, 'Employee Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('D1', 'EMP', 'ename', 20, 'X', 'VARCHAR2', 16, 'Employee Name');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('D1', 'EMP', 'job', 30, 'X', 'VARCHAR2', 9, 'Job Title');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, fk_prefix, fk_tables_nk1, fk_tables_nk2, description) values ('D1', 'EMP', 'm_mgr_id', 40, 'm_', 'D1', 'EMP', 'Surrogate Key of Employee''s Manager');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, description) values ('D1', 'EMP', 'hiredate', 50, 'X', 'DATE', 'Date the Employee was hired');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, scale, description) values ('D1', 'EMP', 'sal', 60, 'X', 'NUMBER', 7, 2, 'Employee''s Salary');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, type, len, scale, description) values ('D1', 'EMP', 'comm', 70, 'NUMBER', 7, 2, 'Employee''s Commission');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, fk_prefix, fk_tables_nk1, fk_tables_nk2, description) values ('D1', 'EMP', 'd_dept_id', 80, 'X', 'd_', 'D1', 'DEPT', 'Surrogate Key of Employee''s Department');

prompt Generate Demo1 Application
begin
   util.set_usr('Demo1');
   generate.init('D1');
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
execute assemble.install_script('D1', 'DB');

spool install
set termout on
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
@install_db

insert into dept_act (deptno, dname, loc) values (10, 'ACCOUNTING', 'NEW YORK');
insert into dept_act (deptno, dname, loc) values (20, 'RESEARCH', 'DALLAS');
insert into dept_act (deptno, dname, loc) values (30, 'SALES', 'CHICAGO');
insert into dept_act (deptno, dname, loc) values (40, 'OPERATIONS', 'BOSTON');

select deptno, dname, loc from dept_act;

insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7839, 'KING', 'PRESIDENT', NULL, TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);

insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7566, 'JONES', 'MANAGER', 7839, TO_DATE('2-APR-1981', 'DD-MON-YYYY'), 2975, NULL, 20);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7788, 'SCOTT', 'ANALYST', 7566, TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7876, 'ADAMS', 'CLERK', 7788, TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7902, 'FORD', 'ANALYST', 7566, TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 3000, NULL, 20);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7369, 'SMITH', 'CLERK', 7902, TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, NULL, 20);

insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7698, 'BLAKE', 'MANAGER', 7839, TO_DATE('1-MAY-1981', 'DD-MON-YYYY'), 2850, NULL, 30);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7521, 'WARD', 'SALESMAN', 7698, TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7654, 'MARTIN', 'SALESMAN', 7698, TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7844, 'TURNER', 'SALESMAN', 7698, TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 1500, 0, 30);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7900, 'JAMES', 'CLERK', 7698, TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 950, NULL, 30);

insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7782, 'CLARK', 'MANAGER', 7839, TO_DATE('9-JUN-1981', 'DD-MON-YYYY'), 2450, NULL, 10);
insert into emp_act (empno, ename, job, m_emp_nk1, hiredate, sal, comm, d_dept_nk1) values (7934, 'MILLER', 'CLERK', 7782, TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);

select empno, ename, job, m_emp_nk1, hiredate, sal, d_dept_nk1 from emp_act;

spool off
