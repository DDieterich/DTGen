
REM
REM Basic Demonstration, Exercise #5, Full Path Hierarchy Data
REM   (sqlplus /nolog @e5)
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

spool e5
set define '&'

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
set serveroutput on format wrapped

column column_name     format A19
column comments        format A60
column empno           format 999999
column mgr_id_path     format A20
column get_mgr_id_path format A20
column mgr_nk_path     format A20
column get_mgr_nk_path format A20

select column_name, comments
 from  user_col_comments
 where table_name  = 'EMP_ACT'
  and  column_name in ('MGR_ID_PATH', 'MGR_EMP_ID', 'ID', 'ENAME');

set echo on

select mgr_id_path, mgr_emp_id, id, ename,
       emp_dml.get_mgr_id_path(id) get_mgr_id_path
 from  emp_act where ename = 'SMITH';

set echo off

select column_name, comments
 from  user_col_comments
 where table_name  = 'EMP_ACT'
  and  column_name in ('MGR_NK_PATH', 'MGR_EMP_NK1', 'EMPNO', 'ENAME');

set echo on

select mgr_nk_path, mgr_emp_nk1, empno, ename,
       emp_dml.get_mgr_nk_path(emp_dml.get_id(empno)) get_mgr_nk_path
 from  emp_act where ename = 'SMITH';

set echo off

column column_name     clear
column comments        clear
column empno           clear
column mgr_id_path     clear
column get_mgr_id_path clear
column mgr_nk_path     clear
column get_mgr_nk_path clear

spool off
exit
