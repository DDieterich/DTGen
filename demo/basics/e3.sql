
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

spool e3
set define '&'

REM Initialize Variables
REM
@vars

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set feedback off
set trimspool on
set serveroutput on size 1000000 format wrapped
set define on

prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.

select substr(uc.constraint_name,1,15)  constraint_name
	  ,substr(uc.table_name,1,15)       table_name
      ,substr(ucc.column_name,1,15)     column_name
	  ,ucc.position
      ,substr(uic.index_name,1,15)      index_name
 from  user_constraints uc
  left outer join user_cons_columns ucc on uc.constraint_name = ucc.constraint_name
  left outer join user_ind_columns uic on uc.table_name   = uic.table_name
                                      and ucc.column_name = uic.column_name
                                      and ucc.position    = uic.column_position
 where uc.constraint_type in ('R','U')
  and  uc.view_related    is null
 order by uc.constraint_name
      ,ucc.position;

spool off
