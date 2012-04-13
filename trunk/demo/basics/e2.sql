
REM
REM Basic Demonstration, Exercise #2, Sequences and Surrogate Keys
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
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set feedback off
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

select sequence_name from user_sequences;

column table_name      format A20
column constraint_name format A20
column column_name     format A20

select uc.table_name, uc.constraint_name, ucc.column_name, ucc.position
 from  user_constraints uc
  left outer join user_cons_columns ucc on uc.constraint_name = ucc.constraint_name
 where uc.constraint_type = 'P'
  and  uc.view_related   is null
 order by uc.table_name
      ,ucc.column_name;

column table_name      clear
column constraint_name clear
column column_name     clear

select id, deptno, dname, loc from dept;

select id, empno, ename, mgr_emp_id, dept_id from emp;

spool off
