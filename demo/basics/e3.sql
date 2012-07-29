
REM
REM Basic Demonstration, Exercise #3, Indexed Foreign Keys and Natural Keys
REM   (sqlplus /nolog @e3)
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

column column_name format A19
column comments    format A60 word_wrapped

select column_name, comments
 from  user_col_comments
 where table_name  = 'TAB_COLS_ACT'
  and  column_name in ('TABLES_NK2', 'NAME', 'SEQ',
       'NK', 'TYPE', 'LEN', 'FK_PREFIX', 'FK_TABLES_NK2');

column column_name clear
column comments    clear

column tables_nk2    format A18
column name          format A15
column nk            format 999
column type          format A15
column fk_prefix     format A10
column fk_tables_nk2 format A18

select tables_nk2, name, seq, nk, type, len
 from  tab_cols_act
 where tables_nk1 = 'DEMO1'
  and  nk            is not null;

select tables_nk2, name, seq, fk_prefix, fk_tables_nk2
 from  tab_cols_act
 where tables_nk1    = 'DEMO1'
  and  fk_tables_nk1 = 'DEMO1';

column tables_nk2    clear
column name          clear
column nk            clear
column type          clear
column fk_prefix     clear
column fk_tables_nk2 clear

prompt
prompt Login to &DB_NAME.
connect &DB_NAME./&DB_PASS.
set serveroutput on format wrapped

column constraint_name format A15
column table_name      format A15
column column_name     format A15
column index_name      format A15

select uc.constraint_name, uc.table_name, ucc.column_name, ucc.position, uic.index_name
 from  user_constraints uc
  left outer join user_cons_columns ucc on uc.constraint_name = ucc.constraint_name
  left outer join user_ind_columns uic on uc.table_name   = uic.table_name
                                      and ucc.column_name = uic.column_name
                                      and ucc.position    = uic.column_position
 where uc.constraint_type in ('R','U')
  and  uc.view_related    is null
 order by uc.constraint_name
      ,ucc.position;

column constraint_name clear
column table_name      clear
column column_name     clear
column index_name      clear

spool off
exit
