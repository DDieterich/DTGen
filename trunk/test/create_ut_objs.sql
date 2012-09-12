
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
      (global_set        varchar2(1)
      ,db_constraints    varchar2(1) not null
      ,fold_strings      varchar2(1) not null
      ,ignore_no_change  varchar2(1) not null
      ,constraint global_parms_pk primary key (global_set)
      ,constraint global_parms_uk1 unique (db_constraints, fold_strings, ignore_no_change));
grant select
   on global_parms to dtgen_ut_test;

create table table_types
      (table_type  varchar2(30)
      ,constraint table_types_pk primary key (table_type));
grant select
   on table_types to dtgen_ut_test;

create table parm_types
      (parm_type  varchar2(30)
      ,constraint parm_types_pk primary key (parm_type));
grant select
   on parm_types to dtgen_ut_test;

create table test_parms
      (parm_set     number
      ,parm_type    varchar2(30)   not null
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
      ,constraint test_parms_pk primary key (parm_set)
      ,constraint test_parms_fk1 foreign key (parm_type)
                       references parm_types (parm_type));
create index test_parms_fk1 on test_parms (parm_type);
grant select
   on test_parms to dtgen_ut_test;

create table test_sets
      (test_name  varchar2(30)
      ,parm_type  varchar2(30)
      ,constraint test_sets_pk primary key (test_name, parm_type)
      ,constraint test_sets_fk1 foreign key (parm_type)
                      references parm_types (parm_type));
create index test_sets_fk1 on test_sets (parm_type);
grant select
   on test_sets to dtgen_ut_test;

create view all_tests as
   select global_set
         ,table_type
         ,test_name
         ,parm_set
         ,'SUCCESS'  return$
    from test_sets
         inner join test_parms using (parm_type)
         cross join global_parms
         cross join table_types;

@test_gen.pkb
