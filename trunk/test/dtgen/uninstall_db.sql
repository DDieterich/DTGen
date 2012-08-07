
--
--  Uninstall Database Scripts for DTGEN
--
--  The 6 scripts included are:
--    -) drop_mods
--    -) drop_aa
--    -) drop_oltp
--    -) drop_integ
--    -) drop_ods
--    -) drop_glob
--


select ' -) drop_mods  ' as FILE_NAME from dual;


-- Script File "drop_mods"
--    Drop Program Modules
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    06, 2012  10:02:10 PM


drop PACKAGE generate;
drop PACKAGE assemble;


select ' -) drop_aa  ' as FILE_NAME from dual;



select ' -) drop_oltp  ' as FILE_NAME from dual;


-- Script File "drop_oltp"
--    Drop Online Data Store using generated code
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    06, 2012  10:02:10 PM


----------------------------------------
select '***  reserved_words  ***' as TABLE_NAME from dual;
----------------------------------------
drop view reserved_words_act;
drop package reserved_words_view;
drop package reserved_words_dml;

----------------------------------------
select '***  exceptions  ***' as TABLE_NAME from dual;
----------------------------------------
drop view exceptions_act;
drop package exceptions_view;
drop package exceptions_dml;

----------------------------------------
select '***  programs  ***' as TABLE_NAME from dual;
----------------------------------------
drop view programs_act;
drop package programs_view;
drop package programs_dml;

----------------------------------------
select '***  check_cons  ***' as TABLE_NAME from dual;
----------------------------------------
drop view check_cons_act;
drop package check_cons_view;
drop package check_cons_dml;

----------------------------------------
select '***  indexes  ***' as TABLE_NAME from dual;
----------------------------------------
drop view indexes_act;
drop package indexes_view;
drop package indexes_dml;

----------------------------------------
select '***  tab_cols  ***' as TABLE_NAME from dual;
----------------------------------------
drop view tab_cols_act;
drop package tab_cols_view;
drop package tab_cols_dml;

----------------------------------------
select '***  tables  ***' as TABLE_NAME from dual;
----------------------------------------
drop view tables_act;
drop package tables_view;
drop package tables_dml;

----------------------------------------
select '***  domain_values  ***' as TABLE_NAME from dual;
----------------------------------------
drop view domain_values_act;
drop package domain_values_view;
drop package domain_values_dml;

----------------------------------------
select '***  domains  ***' as TABLE_NAME from dual;
----------------------------------------
drop view domains_act;
drop package domains_view;
drop package domains_dml;

----------------------------------------
select '***  file_lines  ***' as TABLE_NAME from dual;
----------------------------------------
drop view file_lines_act;
drop package file_lines_view;
drop package file_lines_dml;

----------------------------------------
select '***  files  ***' as TABLE_NAME from dual;
----------------------------------------
drop view files_act;
drop package files_view;
drop package files_dml;

----------------------------------------
select '***  applications  ***' as TABLE_NAME from dual;
----------------------------------------
drop view applications_act;
drop package applications_view;
drop package applications_dml;

select view_name, text_length, view_type_owner
 from  user_views;
select substr(object_name,1,30), object_type, status
 from  user_objects
 where object_type = 'PACKAGE BODY'
  and  object_name not like '%_POP';


select ' -) drop_integ  ' as FILE_NAME from dual;


-- Script File "drop_integ"
--    Drop ODS integrity using generated code
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    06, 2012  10:02:11 PM


----------------------------------------
select '***  reserved_words  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER reserved_words_bi;
drop TRIGGER reserved_words_bu;
drop TRIGGER reserved_words_bd;
alter table reserved_words drop constraint reserved_words_dm1;
alter table reserved_words drop constraint reserved_words_fld1;
alter table reserved_words drop constraint reserved_words_nn2;
alter table reserved_words drop constraint reserved_words_nn1;

----------------------------------------
select '***  exceptions  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER exceptions_bi;
drop TRIGGER exceptions_bu;
drop TRIGGER exceptions_bd;
alter table exceptions drop constraint exceptions_fld1;
alter table exceptions drop constraint exceptions_ck2;
alter table exceptions drop constraint exceptions_ck1;
alter table exceptions drop constraint exceptions_nn3;
alter table exceptions drop constraint exceptions_nn2;
alter table exceptions drop constraint exceptions_nn1;

----------------------------------------
select '***  programs  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER programs_bi;
drop TRIGGER programs_bu;
drop TRIGGER programs_bd;
alter table programs drop constraint programs_dm1;
alter table programs drop constraint programs_fld1;
alter table programs drop constraint programs_ck1;
alter table programs drop constraint programs_nn3;
alter table programs drop constraint programs_nn2;
alter table programs drop constraint programs_nn1;

----------------------------------------
select '***  check_cons  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER check_cons_bi;
drop TRIGGER check_cons_bu;
drop TRIGGER check_cons_bd;
alter table check_cons drop constraint check_cons_ck1;
alter table check_cons drop constraint check_cons_nn3;
alter table check_cons drop constraint check_cons_nn2;
alter table check_cons drop constraint check_cons_nn1;

----------------------------------------
select '***  indexes  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER indexes_bi;
drop TRIGGER indexes_bu;
drop TRIGGER indexes_bd;
alter table indexes drop constraint indexes_fld1;
alter table indexes drop constraint indexes_ck1;
alter table indexes drop constraint indexes_nn3;
alter table indexes drop constraint indexes_nn2;
alter table indexes drop constraint indexes_nn1;

----------------------------------------
select '***  tab_cols  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER tab_cols_bi;
drop TRIGGER tab_cols_bu;
drop TRIGGER tab_cols_bd;
alter table tab_cols drop constraint tab_cols_dm1;
alter table tab_cols drop constraint tab_cols_dm2;
alter table tab_cols drop constraint tab_cols_dm3;
alter table tab_cols drop constraint tab_cols_fld1;
alter table tab_cols drop constraint tab_cols_fld2;
alter table tab_cols drop constraint tab_cols_ck17;
alter table tab_cols drop constraint tab_cols_ck16;
alter table tab_cols drop constraint tab_cols_ck15;
alter table tab_cols drop constraint tab_cols_ck14;
alter table tab_cols drop constraint tab_cols_ck13;
alter table tab_cols drop constraint tab_cols_ck12;
alter table tab_cols drop constraint tab_cols_ck11;
alter table tab_cols drop constraint tab_cols_ck10;
alter table tab_cols drop constraint tab_cols_ck9;
alter table tab_cols drop constraint tab_cols_ck8;
alter table tab_cols drop constraint tab_cols_ck7;
alter table tab_cols drop constraint tab_cols_ck6;
alter table tab_cols drop constraint tab_cols_ck5;
alter table tab_cols drop constraint tab_cols_ck4;
alter table tab_cols drop constraint tab_cols_ck3;
alter table tab_cols drop constraint tab_cols_ck2;
alter table tab_cols drop constraint tab_cols_ck1;
alter table tab_cols drop constraint tab_cols_nn3;
alter table tab_cols drop constraint tab_cols_nn2;
alter table tab_cols drop constraint tab_cols_nn1;

----------------------------------------
select '***  tables  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER tables_bi;
drop TRIGGER tables_bu;
drop TRIGGER tables_bd;
alter table tables drop constraint tables_dm1;
alter table tables drop constraint tables_fld1;
alter table tables drop constraint tables_fld2;
alter table tables drop constraint tables_fld3;
alter table tables drop constraint tables_fld4;
alter table tables drop constraint tables_fld5;
alter table tables drop constraint tables_fld6;
alter table tables drop constraint tables_fld7;
alter table tables drop constraint tables_ck9;
alter table tables drop constraint tables_ck8;
alter table tables drop constraint tables_ck7;
alter table tables drop constraint tables_ck6;
alter table tables drop constraint tables_ck5;
alter table tables drop constraint tables_ck4;
alter table tables drop constraint tables_ck3;
alter table tables drop constraint tables_ck2;
alter table tables drop constraint tables_ck1;
alter table tables drop constraint tables_nn5;
alter table tables drop constraint tables_nn4;
alter table tables drop constraint tables_nn3;
alter table tables drop constraint tables_nn2;
alter table tables drop constraint tables_nn1;

----------------------------------------
select '***  domain_values  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER domain_values_bi;
drop TRIGGER domain_values_bu;
drop TRIGGER domain_values_bd;
alter table domain_values drop constraint domain_values_ck1;
alter table domain_values drop constraint domain_values_nn3;
alter table domain_values drop constraint domain_values_nn2;
alter table domain_values drop constraint domain_values_nn1;

----------------------------------------
select '***  domains  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER domains_bi;
drop TRIGGER domains_bu;
drop TRIGGER domains_bd;
alter table domains drop constraint domains_dm1;
alter table domains drop constraint domains_fld1;
alter table domains drop constraint domains_fld2;
alter table domains drop constraint domains_ck1;
alter table domains drop constraint domains_nn5;
alter table domains drop constraint domains_nn4;
alter table domains drop constraint domains_nn3;
alter table domains drop constraint domains_nn2;
alter table domains drop constraint domains_nn1;

----------------------------------------
select '***  file_lines  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER file_lines_bi;
drop TRIGGER file_lines_bu;
drop TRIGGER file_lines_bd;
alter table file_lines drop constraint file_lines_nn2;
alter table file_lines drop constraint file_lines_nn1;

----------------------------------------
select '***  files  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER files_bi;
drop TRIGGER files_bu;
drop TRIGGER files_bd;
alter table files drop constraint files_dm1;
alter table files drop constraint files_nn4;
alter table files drop constraint files_nn3;
alter table files drop constraint files_nn2;
alter table files drop constraint files_nn1;

----------------------------------------
select '***  applications  ***' as TABLE_NAME from dual;
----------------------------------------
drop TRIGGER applications_bi;
drop TRIGGER applications_bu;
drop TRIGGER applications_bd;
alter table applications drop constraint applications_dm1;
alter table applications drop constraint applications_dm2;
alter table applications drop constraint applications_fld1;
alter table applications drop constraint applications_fld2;
alter table applications drop constraint applications_fld3;
alter table applications drop constraint applications_fld4;
alter table applications drop constraint applications_fld5;
alter table applications drop constraint applications_fld6;
alter table applications drop constraint applications_fld7;
alter table applications drop constraint applications_fld8;
alter table applications drop constraint applications_fld9;
alter table applications drop constraint applications_fld10;
alter table applications drop constraint applications_fld11;
alter table applications drop constraint applications_ck5;
alter table applications drop constraint applications_ck4;
alter table applications drop constraint applications_ck3;
alter table applications drop constraint applications_ck2;
alter table applications drop constraint applications_ck1;
alter table applications drop constraint applications_nn2;
alter table applications drop constraint applications_nn1;

select trigger_name, trigger_type, table_name
 from  user_triggers where base_object_type = 'TABLE';
select substr(owner||'.'||constraint_name,1,40)
      ,constraint_type, table_name
 from  user_constraints
 where constraint_type not in ('P','U','R');


select ' -) drop_ods  ' as FILE_NAME from dual;


-- Script File "drop_ods"
--    Drop Online Data Store using generated code
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    06, 2012  10:02:11 PM


----------------------------------------
select '***  reserved_words  ***' as TABLE_NAME from dual;
----------------------------------------
drop package reserved_words_tab;
/***  ACTIVE Foreign Keys  ***/

drop table reserved_words;
drop sequence reserved_words_seq;

----------------------------------------
select '***  exceptions  ***' as TABLE_NAME from dual;
----------------------------------------
drop package exceptions_tab;
/***  ACTIVE Foreign Keys  ***/
alter table exceptions drop constraint exceptions_fk1;

drop table exceptions;
drop sequence exceptions_seq;

----------------------------------------
select '***  programs  ***' as TABLE_NAME from dual;
----------------------------------------
drop package programs_tab;
/***  ACTIVE Foreign Keys  ***/
alter table programs drop constraint programs_fk1;

drop table programs;
drop sequence programs_seq;

----------------------------------------
select '***  check_cons  ***' as TABLE_NAME from dual;
----------------------------------------
drop package check_cons_tab;
/***  ACTIVE Foreign Keys  ***/
alter table check_cons drop constraint check_cons_fk1;

drop table check_cons;
drop sequence check_cons_seq;

----------------------------------------
select '***  indexes  ***' as TABLE_NAME from dual;
----------------------------------------
drop package indexes_tab;
/***  ACTIVE Foreign Keys  ***/
alter table indexes drop constraint indexes_fk1;

drop table indexes;
drop sequence indexes_seq;

----------------------------------------
select '***  tab_cols  ***' as TABLE_NAME from dual;
----------------------------------------
drop package tab_cols_tab;
/***  ACTIVE Foreign Keys  ***/
alter table tab_cols drop constraint tab_cols_fk1;
alter table tab_cols drop constraint tab_cols_fk2;
alter table tab_cols drop constraint tab_cols_fk3;

drop table tab_cols;
drop sequence tab_cols_seq;

----------------------------------------
select '***  tables  ***' as TABLE_NAME from dual;
----------------------------------------
drop package tables_tab;
/***  ACTIVE Foreign Keys  ***/
alter table tables drop constraint tables_fk1;

drop table tables;
drop sequence tables_seq;

----------------------------------------
select '***  domain_values  ***' as TABLE_NAME from dual;
----------------------------------------
drop package domain_values_tab;
/***  ACTIVE Foreign Keys  ***/
alter table domain_values drop constraint domain_values_fk1;

drop table domain_values;
drop sequence domain_values_seq;

----------------------------------------
select '***  domains  ***' as TABLE_NAME from dual;
----------------------------------------
drop package domains_tab;
/***  ACTIVE Foreign Keys  ***/
alter table domains drop constraint domains_fk1;

drop table domains;
drop sequence domains_seq;

----------------------------------------
select '***  file_lines  ***' as TABLE_NAME from dual;
----------------------------------------
drop package file_lines_tab;
/***  ACTIVE Foreign Keys  ***/
alter table file_lines drop constraint file_lines_fk1;

drop table file_lines;
drop sequence file_lines_seq;

----------------------------------------
select '***  files  ***' as TABLE_NAME from dual;
----------------------------------------
drop package files_tab;
/***  ACTIVE Foreign Keys  ***/
alter table files drop constraint files_fk1;

drop table files;
drop sequence files_seq;

----------------------------------------
select '***  applications  ***' as TABLE_NAME from dual;
----------------------------------------
drop package applications_tab;
/***  ACTIVE Foreign Keys  ***/

drop table applications;
drop sequence applications_seq;

select substr(object_name,1,30), object_type, status
 from  user_objects where object_type = 'PACKAGE BODY';
select table_name, tablespace_name
 from  user_tables;
select sequence_name, min_value, max_value, last_number
 from  user_sequences;



select ' -) drop_glob  ' as FILE_NAME from dual;


-- Script File "drop_glob"
--    Drop Globals using generated code
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    06, 2012  10:02:11 PM


drop package util;
drop table util_log;
drop type col_type;
drop type pair_type;
drop package glob;

select substr(object_name,1,30), object_type, status
 from  user_objects;

