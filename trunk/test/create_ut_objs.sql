
--
-- Create SQL*Developer Unit Test Owner Database Objects Script
--
-- &1. - Name of the Generator Schema Object Owner
--

-- Create Synonyms back to the Generator Schema Object Owner
create synonym applications_act for &1..applications_act;
create synonym file_lines_act   for &1..file_lines_act;
create synonym file_lines_asof  for &1..file_lines_asof;
create synonym util             for &1..util;
create synonym glob             for &1..glob;
create synonym generate         for &1..generate;
create synonym dtgen_util       for &1..dtgen_util;

@test_gen.pks
grant execute on test_gen to dtgen_ut_test;

/*
create table test_run as
   select abbr          app_abbr
         ,db_schema     db_schema
         ,systimestamp  gen_tstamp
   from applications_act where 0 = 1;
alter table test_run
   add (constraint test_run_pk
   primary key (app_abbr, db_schema));
grant select, insert, update, delete
   on test_run to dtgen_ut_test;
*/

create table global_parms
      (test_set          varchar2(1)
      ,db_constraints    varchar2(1) not null
      ,fold_strings      varchar2(1) not null
      ,ignore_no_change  varchar2(1) not null
      ,constraint global_parms_pk primary key (test_set));
grant select
   on global_parms to dtgen_ut_test;

create table test_parms
      (test_seq     number
      ,test_name    varchar2(30)   not null
      ,val0         varchar2(4000)
      ,val1         varchar2(4000)
      ,val2         varchar2(4000)
      ,val3         varchar2(4000)
      ,val4         varchar2(4000)
      ,val5         varchar2(4000)
      ,val6         varchar2(4000)
      ,val7         varchar2(4000)
      ,val8         varchar2(4000)
      ,val9         varchar2(4000)
      ,constraint test_parms_pk primary key (test_seq));
grant select
   on test_parms to dtgen_ut_test;

create table test_schemas as
   select db_schema from applications_act
    where 0 = 1;
alter table test_schemas
  add (test_set   varchar2(1)
      ,test_seq   number
      ,success    varchar2(4000) not null
      ,constraint test_schemas_pk primary key (db_schema, test_set, test_seq)
      ,constraint test_schemas_fk1 foreign key (test_set)
                         references global_parms (test_set));
      ,constraint test_schemas_fk2 foreign key (test_seq)
                         references test_parms (test_seq));
grant select
   on test_schemas to dtgen_ut_test;

@test_gen.pkb
