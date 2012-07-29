
REM
REM GUI Demonstration, Exercise #1, Default Maintenance Forms
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
set serveroutput on format wrapped
set define off

prompt Remove old DEMO4 Schema from DTGEN
delete from exceptions_act where applications_nk1 = 'DEMO4';
delete from programs_act where applications_nk1 = 'DEMO4';
delete from check_cons_act where tables_nk1 = 'DEMO4';
delete from indexes_act where tab_cols_nk1 = 'DEMO4';
delete from tab_cols_act where tables_nk1 = 'DEMO4';
delete from tables_act where applications_nk1 = 'DEMO4';
delete from domain_values_act where domains_nk1 = 'DEMO4';
delete from domains_act where applications_nk1 = 'DEMO4';
delete from file_lines_act where files_nk1 = 'DEMO4';
delete from files_act where applications_nk1 = 'DEMO4';
delete from applications_act where abbr = 'DEMO4';

prompt create a DEMO4 Schema in DTGEN
insert into applications_act (abbr, name, apex_schema, apex_ws_name, apex_app_name, description) values ('DEMO4', 'DTGen GUI Demonstration', 'dtgen_db_demo', 'dtgen_db_demo', 'GUI_DEMO', 'Based on the ASOF Demonstration, adds Graphical User Interface capabilities');

insert into domains_act (applications_nk1, abbr, name, fold, len, description) values ('DEMO4', 'JOB', 'Job Name', 'U', 9, 'Job Names');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO4', 'JOB', 10, 'PRESIDENT', 'Company President');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO4', 'JOB', 20, 'MANAGER', 'Department Manager');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO4', 'JOB', 30, 'ANALYST', 'Systems Analyst');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO4', 'JOB', 40, 'SALESMAN', 'Company Salesman');
insert into domain_values_act (domains_nk1, domains_nk2, seq, value, description) values ('DEMO4', 'JOB', 50, 'CLERK', 'Department Clerk');

insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('DEMO4', 'DEPT', 10, 'dept', 'LOG', 'Department Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('DEMO4', 'DEPT', 'deptno', 10, 1, 'NUMBER', 2, 'Department Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('DEMO4', 'DEPT', 'dname', 20, 'X', 'VARCHAR2', 14, 'Name of the Department');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, description) values ('DEMO4', 'DEPT', 'loc', 30, 'X', 'VARCHAR2', 13, 'Location for the Department');

insert into tables_act (applications_nk1, abbr, seq, name, type, description) values ('DEMO4', 'EMP', 20, 'emp', 'EFF', 'Employee Information');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description) values ('DEMO4', 'EMP', 'empno', 10, 1, 'NUMBER', 4, 'Employee Number');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, fold, description) values ('DEMO4', 'EMP', 'ename', 20, 'X', 'VARCHAR2', 16, 'U', 'Employee Name');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, d_domains_nk1, d_domains_nk2, description) values ('DEMO4', 'EMP', 'job', 30, 'X', 'DEMO4', 'JOB', 'Job Title');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, fk_prefix, fk_tables_nk1, fk_tables_nk2, description) values ('DEMO4', 'EMP', 'mgr_emp_id', 40, 'mgr_', 'DEMO4', 'EMP', 'Surrogate Key of Employee''s Manager');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, description) values ('DEMO4', 'EMP', 'hiredate', 50, 'X', 'DATE', 'Date the Employee was hired');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, type, len, scale, description) values ('DEMO4', 'EMP', 'sal', 60, 'X', 'NUMBER', 7, 2, 'Employee''s Salary');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, type, len, scale, description) values ('DEMO4', 'EMP', 'comm', 70, 'NUMBER', 7, 2, 'Employee''s Commission');
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, req, fk_tables_nk1, fk_tables_nk2, description) values ('DEMO4', 'EMP', 'dept_id', 80, 'X', 'DEMO4', 'DEPT', 'Surrogate Key of Employee''s Department');
insert into check_cons_act (tables_nk1, tables_nk2, seq, text, description) values ('DEMO4', 'EMP', 10, '(comm is null) or (comm is not null and job = ''SALESMAN'')', 'Only SALESMAN can be on commission');

prompt Generate DEMO4 Application
begin
   util.set_usr('DEMO4');
   generate.init('DEMO4');
   generate.create_glob;
   generate.create_ods;
   generate.create_integ;
   generate.create_oltp;
   generate.create_aa;
   generate.create_mods;
   generate.create_flow;
   commit;
end;
/

prompt Capture SQL Scripts
set termout off
set linesize 5000
spool install_db.sql
execute assemble.install_script('DEMO4', 'DB');
spool install_gui.sql
execute assemble.install_script('DEMO4', 'GUI');

------------------------------------------------------------

spool install
set linesize 80
set termout on
set define on
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on format wrapped
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
@install_db
@install_gui
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define off
set feedback off

prompt
prompt Loading data into database

execute glob.set_db_constraints(FALSE);

alter trigger dept_bi disable;

insert into dept (id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm) values (1, 10, 'ACCOUNTING', 'NEW YORK', 'Dataload', to_timestamp('1980-11-1', 'YYYY-MM-DD'));
insert into dept (id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm) values (2, 20, 'RESEARCH', 'DALLAS', 'Dataload', to_timestamp('1980-11-1', 'YYYY-MM-DD'));
insert into dept_aud (dept_id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm) values (3, 30, 'SALES', 'ST LOUIS', 'Dataload', to_timestamp('1980-11-1', 'YYYY-MM-DD'), 'THOMPSON', to_timestamp('1982-8-17', 'YYYY-MM-DD'));
insert into dept (id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm) values (3, 30, 'SALES', 'CHICAGO', 'THOMPSON', to_timestamp('1982-8-17', 'YYYY-MM-DD'));
insert into dept_aud (dept_id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm) values (4, 40, 'OPERATIONS', 'BUFFALO', 'Dataload', to_timestamp('1980-11-1', 'YYYY-MM-DD'), 'JAMES', to_timestamp('1982-2-12', 'YYYY-MM-DD'));
insert into dept (id, deptno, dname, loc, aud_beg_usr, aud_beg_dtm) values (4, 40, 'OPERATIONS', 'BOSTON', 'JAMES', to_timestamp('1982-2-12', 'YYYY-MM-DD'));

declare
   junk number;
begin
   for i in 1 .. 4
   loop
      select dept_seq.nextval into junk from dual;
   end loop;
end;
/

alter trigger dept_bi enable;

alter trigger emp_bi disable;
alter table emp disable constraint emp_fk1;

REM  Note: Inserts into EMP_HIST can only be done by the schema owner.

insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (1,7301,'ELLISON','PRESIDENT',null,to_date('1980-11-2','YYYY-MM-DD'),4000,null,1,to_date('1980-11-2','YYYY-MM-DD'),to_date('1981-6-30','YYYY-MM-DD'),'Y',to_date('1980-11-4','YYYY-MM-DD'),'DAVIS',to_date('1981-6-28','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (2,7344,'DAVIS','CLERK',1,to_date('1980-11-16','YYYY-MM-DD'),1400,null,1,to_date('1980-11-16','YYYY-MM-DD'),to_date('1981-6-23','YYYY-MM-DD'),'',to_date('1980-11-14','YYYY-MM-DD'),'DAVIS',to_date('1981-6-25','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (2,7344,'DAVIS','CLERK',11,to_date('1980-11-16','YYYY-MM-DD'),1400,null,1,to_date('1981-6-23','YYYY-MM-DD'),to_date('1981-8-21','YYYY-MM-DD'),'',to_date('1981-6-25','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-20','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (2,7344,'DAVIS','CLERK',12,to_date('1980-11-16','YYYY-MM-DD'),1400,null,1,to_date('1981-8-21','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'',to_date('1981-8-20','YYYY-MM-DD'),'THOMPSON',to_date('1981-11-29','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (2,7344,'DAVIS','CLERK',15,to_date('1980-11-16','YYYY-MM-DD'),1400,null,1,to_date('1981-11-29','YYYY-MM-DD'),to_date('1981-12-8','YYYY-MM-DD'),'Y',to_date('1981-11-29','YYYY-MM-DD'),'SMITH',to_date('1981-12-6','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (3,7369,'THOMPSON','CLERK',1,to_date('1980-12-17','YYYY-MM-DD'),800,null,1,to_date('1980-12-17','YYYY-MM-DD'),to_date('1981-6-23','YYYY-MM-DD'),'',to_date('1980-12-15','YYYY-MM-DD'),'DAVIS',to_date('1981-6-25','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (3,7369,'THOMPSON','CLERK',11,to_date('1980-12-17','YYYY-MM-DD'),800,null,1,to_date('1981-6-23','YYYY-MM-DD'),to_date('1981-8-21','YYYY-MM-DD'),'',to_date('1981-6-25','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-21','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (3,7369,'SMITH','CLERK',12,to_date('1980-12-17','YYYY-MM-DD'),800,null,1,to_date('1981-8-21','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'',to_date('1981-8-21','YYYY-MM-DD'),'SMITH',to_date('1981-12-1','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (3,7369,'SMITH','CLERK',15,to_date('1980-12-17','YYYY-MM-DD'),800,null,1,to_date('1981-11-29','YYYY-MM-DD'),to_date('1983-2-26','YYYY-MM-DD'),'',to_date('1981-12-1','YYYY-MM-DD'),'SMITH',to_date('1983-2-26','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (3,7369,'SMITH','CLERK',18,to_date('1980-12-17','YYYY-MM-DD'),800,null,2,to_date('1983-2-26','YYYY-MM-DD'),to_date('1983-2-26','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (4,7499,'ALLEN','SALESMAN',1,to_date('1981-2-20','YYYY-MM-DD'),1600,300,1,to_date('1981-2-20','YYYY-MM-DD'),to_date('1981-5-15','YYYY-MM-DD'),'',to_date('1981-2-17','YYYY-MM-DD'),'THOMPSON',to_date('1981-5-12','YYYY-MM-DD'),'THOMPSON');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (4,7499,'ALLEN','SALESMAN',8,to_date('1981-2-20','YYYY-MM-DD'),1600,300,3,to_date('1981-5-15','YYYY-MM-DD'),to_date('1981-5-12','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (5,7521,'WARD','SALESMAN',1,to_date('1981-2-22','YYYY-MM-DD'),1250,500,1,to_date('1981-2-22','YYYY-MM-DD'),to_date('1981-5-15','YYYY-MM-DD'),'',to_date('1981-2-24','YYYY-MM-DD'),'THOMPSON',to_date('1981-5-14','YYYY-MM-DD'),'THOMPSON');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (5,7521,'WARD','SALESMAN',8,to_date('1981-2-22','YYYY-MM-DD'),1250,500,3,to_date('1981-5-15','YYYY-MM-DD'),to_date('1981-5-14','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (6,7566,'JONES','MANAGER',1,to_date('1981-4-2','YYYY-MM-DD'),2975,null,2,to_date('1981-4-2','YYYY-MM-DD'),to_date('1981-6-23','YYYY-MM-DD'),'',to_date('1981-4-3','YYYY-MM-DD'),'THOMPSON',to_date('1981-6-24','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (6,7566,'JONES','MANAGER',11,to_date('1981-4-2','YYYY-MM-DD'),2975,null,2,to_date('1981-6-23','YYYY-MM-DD'),to_date('1981-8-21','YYYY-MM-DD'),'',to_date('1981-6-24','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-22','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (6,7566,'JONES','MANAGER',12,to_date('1981-4-2','YYYY-MM-DD'),2975,null,2,to_date('1981-8-21','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'',to_date('1981-8-22','YYYY-MM-DD'),'SMITH',to_date('1981-11-29','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (6,7566,'JONES','MANAGER',15,to_date('1981-4-2','YYYY-MM-DD'),2975,null,2,to_date('1981-11-29','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (7,7654,'MARTIN','SALESMAN',1,to_date('1981-4-17','YYYY-MM-DD'),1250,1400,3,to_date('1981-4-17','YYYY-MM-DD'),to_date('1981-5-15','YYYY-MM-DD'),'Y',to_date('1981-4-16','YYYY-MM-DD'),'THOMPSON',to_date('1981-5-13','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (8,7698,'BLAKE','MANAGER',1,to_date('1981-5-1','YYYY-MM-DD'),2850,null,3,to_date('1981-5-1','YYYY-MM-DD'),to_date('1981-6-23','YYYY-MM-DD'),'',to_date('1981-5-2','YYYY-MM-DD'),'THOMPSON',to_date('1981-6-24','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (8,7698,'BLAKE','MANAGER',11,to_date('1981-5-1','YYYY-MM-DD'),2850,null,3,to_date('1981-6-23','YYYY-MM-DD'),to_date('1981-8-21','YYYY-MM-DD'),'',to_date('1981-6-24','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-19','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (8,7698,'BLAKE','MANAGER',12,to_date('1981-5-1','YYYY-MM-DD'),2850,null,3,to_date('1981-8-21','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'',to_date('1981-8-19','YYYY-MM-DD'),'THOMPSON',to_date('1981-11-30','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (8,7698,'BLAKE','MANAGER',15,to_date('1981-5-1','YYYY-MM-DD'),2850,null,3,to_date('1981-11-29','YYYY-MM-DD'),to_date('1981-11-30','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (9,7782,'CLARK','MANAGER',1,to_date('1981-6-9','YYYY-MM-DD'),2450,null,1,to_date('1981-6-9','YYYY-MM-DD'),to_date('1981-6-23','YYYY-MM-DD'),'',to_date('1981-6-7','YYYY-MM-DD'),'THOMPSON',to_date('1981-6-23','YYYY-MM-DD'),'THOMPSON');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (9,7782,'CLARK','MANAGER',11,to_date('1981-6-9','YYYY-MM-DD'),2450,null,1,to_date('1981-6-23','YYYY-MM-DD'),to_date('1981-8-21','YYYY-MM-DD'),'',to_date('1981-6-23','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-23','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (9,7782,'CLARK','MANAGER',12,to_date('1981-6-9','YYYY-MM-DD'),2450,null,1,to_date('1981-8-21','YYYY-MM-DD'),to_date('1981-11-29','YYYY-MM-DD'),'',to_date('1981-8-23','YYYY-MM-DD'),'SMITH',to_date('1981-11-26','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (9,7782,'CLARK','MANAGER',15,to_date('1981-6-9','YYYY-MM-DD'),2450,null,1,to_date('1981-11-29','YYYY-MM-DD'),to_date('1981-11-26','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (10,7788,'SCOTT','ANALYST',6,to_date('1981-6-12','YYYY-MM-DD'),3000,null,2,to_date('1981-6-12','YYYY-MM-DD'),to_date('1982-3-10','YYYY-MM-DD'),'Y',to_date('1981-6-10','YYYY-MM-DD'),'THOMPSON',to_date('1982-3-9','YYYY-MM-DD'),'JAMES');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (11,7839,'KING','PRESIDENT',null,to_date('1981-6-16','YYYY-MM-DD'),5000,null,1,to_date('1981-6-16','YYYY-MM-DD'),to_date('1981-8-28','YYYY-MM-DD'),'Y',to_date('1981-6-18','YYYY-MM-DD'),'THOMPSON',to_date('1981-8-30','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (12,7840,'LANE','PRESIDENT',null,to_date('1981-8-14','YYYY-MM-DD'),6000,null,1,to_date('1981-8-14','YYYY-MM-DD'),to_date('1981-12-1','YYYY-MM-DD'),'Y',to_date('1981-8-12','YYYY-MM-DD'),'THOMPSON',to_date('1981-11-29','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (13,7844,'TURNER','SALESMAN',8,to_date('1981-9-8','YYYY-MM-DD'),1500,0,3,to_date('1981-9-8','YYYY-MM-DD'),to_date('1981-9-6','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (14,7654,'MARTIN','SALESMAN',8,to_date('1981-9-28','YYYY-MM-DD'),1250,1400,3,to_date('1981-9-28','YYYY-MM-DD'),to_date('1981-9-26','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (15,7839,'KING','PRESIDENT',null,to_date('1981-11-17','YYYY-MM-DD'),5000,null,1,to_date('1981-11-17','YYYY-MM-DD'),to_date('1981-11-18','YYYY-MM-DD'),'SMITH');
insert into EMP_HIST (EMP_ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,EFF_END_DTM,LAST_ACTIVE,AUD_BEG_DTM,AUD_BEG_USR,AUD_END_DTM,AUD_END_USR) values (16,7876,'ADAMS','CLERK',6,to_date('1981-11-22','YYYY-MM-DD'),1100,null,2,to_date('1981-11-22','YYYY-MM-DD'),to_date('1982-6-15','YYYY-MM-DD'),'Y',to_date('1981-11-20','YYYY-MM-DD'),'SMITH',to_date('1982-6-13','YYYY-MM-DD'),'JAMES');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (17,7900,'JAMES','CLERK',8,to_date('1981-12-3','YYYY-MM-DD'),950,null,3,to_date('1981-12-3','YYYY-MM-DD'),to_date('1981-12-5','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (18,7902,'FORD','ANALYST',6,to_date('1981-12-3','YYYY-MM-DD'),3000,null,2,to_date('1981-12-3','YYYY-MM-DD'),to_date('1981-12-1','YYYY-MM-DD'),'SMITH');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (19,7934,'MILLER','CLERK',9,to_date('1982-1-23','YYYY-MM-DD'),1300,null,1,to_date('1982-1-23','YYYY-MM-DD'),to_date('1982-1-21','YYYY-MM-DD'),'JAMES');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (20,7788,'SCOTT','ANALYST',6,to_date('1982-12-9','YYYY-MM-DD'),3000,null,2,to_date('1982-12-9','YYYY-MM-DD'),to_date('1982-12-11','YYYY-MM-DD'),'JAMES');
insert into EMP (ID,EMPNO,ENAME,JOB,MGR_EMP_ID,HIREDATE,SAL,COMM,DEPT_ID,EFF_BEG_DTM,AUD_BEG_DTM,AUD_BEG_USR) values (21,7876,'ADAMS','CLERK',20,to_date('1983-1-12','YYYY-MM-DD'),1100,null,2,to_date('1983-1-12','YYYY-MM-DD'),to_date('1983-1-12','YYYY-MM-DD'),'SMITH');

declare
   junk number;
begin
   for i in 1 .. 21
   loop
      select emp_seq.nextval into junk from dual;
   end loop;
end;
/

alter table emp enable constraint emp_fk1;
alter trigger emp_bi enable;

set feedback on
spool off
exit
