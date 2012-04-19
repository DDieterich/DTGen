
REM
REM Basic Demonstration, Exercise #5, All Instances View
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
WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE
set feedback 1
set trimspool on
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on size 1000000 format wrapped

column stat              format A4
column eid               format 99
column empno             format 9999
column ename             format A8
column did               format 99
column deptno            format 99
column aud_beg_usr       format A8
column aud_beg_dtm       format A9   truncate
column aud_end_usr       format A8
column aud_end_dtm       format A9   truncate
column aud_prev_beg_usr  format A8
column aud_prev_beg_dtm  format A9   truncate
column pop_dml           format A3   truncate
column pop_usr           format A8
column pop_dtm           format A9   truncate
set echo on

select empno, ename, id eid, stat, dept_id did,
       aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from emp_all order by empno, id;

execute util.set_usr('MILLER');

-- SMITH retires today
delete from emp_act
 where empno = 7369;

select empno, ename, id eid, stat, dept_id did,
       aud_beg_usr, aud_beg_dtm, aud_end_usr, aud_end_dtm
  from emp_all order by empno, id;

select empno, ename, id eid, dept_id did, aud_beg_usr, aud_beg_dtm
  from emp_act where empno = 7369;

rollback;

set echo off

column stat              clear
column eid               clear
column empno             clear
column ename             clear
column did               clear
column deptno            clear
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
