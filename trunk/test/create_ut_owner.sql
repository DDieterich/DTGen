
--
-- Create SQL*Developer Unit Test Repository Owner Script
-- (Must be run as the "sys as sysdba" user)
--

define UTO_NAME=dtgen_test
define UTO_PASS=dtgen_test

set define '&'
set serveroutput on format wrapped

-- Create New Schema Owner
--
create user &UTO_NAME. identified by &UTO_PASS.
   default tablespace users;

alter user &UTO_NAME.
   quota unlimited on users;

grant connect to &UTO_NAME.;
grant resource to &UTO_NAME.;
grant create view to &UTO_NAME.;
grant select on dba_roles to &UTO_NAME.;
grant select on dba_role_privs to &UTO_NAME.;

prompt NOTE: This grant may fail on a new database
grant UT_REPO_ADMINISTRATOR to &UTO_NAME. with admin option;

create role dtgen_ut_test;

create table &1..test_run
   (schema_name  varchar2(30) -- Primary Key
   ,gen_tstamp   timestamp    not null
   ,constraint test_run_pk primary key (schema_name));
grant select, insert, update, delete
   on &1..test_run to dtgen_ut_test;

create sequence &1..test_parms_seq;
create table &1..test_parms
   (schema_name  varchar2(30) -- Primary Key
   ,seq          number       -- Primary Key
   ,test_name    varchar2(30)   not null
   ,success      varchar2(2000) not null
   ,val1         varchar2(30)
   ,val2         varchar2(30)
   ,constraint test_col_parms_pk primary key (schema_name, seq));
grant select
   on &1..test_col_parms to dtgen_ut_test;
create trigger &1..test_col_parms_bi
  before insert on &1..test_col_parms
  for each row
begin
   select test_col_parms_seq.nextval into :new.seq from dual;
end &1..test_col_parms_bi;
/

insert into &1..test_col_parms (schema_name, test_name, success_non, success_log, success_eff, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 1, null);
insert into &1..test_col_parms (schema_name, test_name, success_non, success_log, success_eff, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 2, '123.89');
insert into &1..test_col_parms (schema_name, test_name, success_non, success_log, success_eff, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 3, '-1.2e-4');
insert into &1..test_col_parms (schema_name, test_name, success_non, success_log, success_eff, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 4, '1.2e5');

create package test_rig
is

   function DTC_INSERT_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_INSERT_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_INSERT_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

end test_rig;

create package body test_rig
is

function DTC_INSERT_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'insert into ' || table_name_in ||
               ' (seq, ' || column_name_in ||
            ') values (' || tab_seq_in ||
                    ', ' || value_in || ')';
end DTC_INSERT_SQL;

function DTC_UPDATE_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'update ' || table_name_in ||
            ' set ' || column_name_in ||
              ' = ' || value_in ||
    ' where seq = ' || tab_seq_in;
end DTC_UPDATE_SQL;

function DTC_INSERT_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
begin
   return 'declare buff ' || table_name_in || '%ROWTYPE; begin' ||
          ' buff.seq := ' || tab_seq_in ||
                '; buff.' || column_name_in ||
                   ' := ' || value_in
                     '; ' || table_name_in ||
           '.ins(buff)'
end DTC_INSERT_API;

function DTC_INSERT_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
begin
   return 'declare buff ' || table_name_in ||
   '_ACT%ROWTYPE; begin ' || table_name_in ||
           '.ins(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' || value_in || ')';
end DTC_INSERT_API2;

function DTC_UPDATE_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
begin
   return 'declare buff ' || table_name_in ||
       '%ROWTYPE; begin ' || table_name_in ||
           '.upd(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' ||value_in || ')';
end DTC_UPDATE_API;

function DTC_UPDATE_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
begin
   return 'declare buff ' || table_name_in ||
   '_ACT%ROWTYPE; begin ' || table_name_in ||
           '.upd(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' || value_in || ')';
end DTC_UPDATE_API2;

end test_rig;
