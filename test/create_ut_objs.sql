
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
      (global_set        varchar2(1)  -- Primary Key
      ,db_constraints    varchar2(1) not null
      ,fold_strings      varchar2(1) not null
      ,ignore_no_change  varchar2(1) not null
      ,description       varchar2(2000)
      ,constraint global_parms_pk primary key (global_set)
      ,constraint global_parms_uk1 unique (db_constraints, fold_strings, ignore_no_change)
      ,constraint global_parms_ck1 check (db_constraints in ('T','F'))
      ,constraint global_parms_ck2 check (fold_strings in ('T','F'))
      ,constraint global_parms_ck3 check (ignore_no_change in ('T','F')));
grant select
   on global_parms to dtgen_ut_test;

create table parm_sets
      (parm_set     varchar2(30)  -- Primary Key
      ,description  varchar2(2000)
      ,constraint parm_sets_pk primary key (parm_set))
   organization index;
grant select
   on parm_sets to dtgen_ut_test;

create table test_parms
      (parm_set     varchar2(30)  -- Primary Key
      ,parm_seq     number        -- Primary Key
      ,result_txt   varchar2(4000)
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
      ,description  varchar2(2000)
      ,constraint test_parms_pk primary key (parm_set, parm_seq)
      ,constraint test_parms_fk1 foreign key (parm_set)
                       references parm_sets (parm_set));
grant select
   on test_parms to dtgen_ut_test;

create table test_sets
      (user_name    varchar2(30) -- Primary Key
      ,global_set   varchar2(1)  -- Primary Key
      ,test_name    varchar2(30) -- Primary Key
      ,parm_set     varchar2(30) -- Primary Key
      ,description  varchar2(2000)
      ,constraint  test_sets_pk primary key (user_name, global_set, test_name, parm_set)
      ,constraint  test_sets_fk1 foreign key (global_set)
                      references global_parms (global_set)
      ,constraint  test_sets_fk2 foreign key (parm_set)
                      references parm_sets (parm_set))
   organization index;
create index test_sets_fk1 on test_sets (parm_set);
grant select
   on test_sets to dtgen_ut_test;

@test_gen.pkb
