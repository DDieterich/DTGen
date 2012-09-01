
--
-- Create SQL*Developer Unit Test Owner Database Objects Script
--
-- &1. - Name of the Generator Schema Object Owner
--

-- Create Synonyms back to the Generator Schema Object Owner
create synonym applications_act for &1..applications_act;
create synonym file_lines_asof  for &1..file_lines_asof;
create synonym util             for &1..util;
create synonym glob             for &1..glob;
create synonym generate         for &1..generate;

@test_gen.pks
grant execute on test_gen to dtgen_ut_test;
@test_rig.pks
grant execute on test_rig to dtgen_ut_test;

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

drop table test_parms;
create table test_parms as
   select db_schema from applications_act
    where 0 = 1;
alter table test_parms
  add (seq          number
      ,test_name    varchar2(30)   not null
      ,success      varchar2(4000) not null
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
      ,constraint test_parms_pk primary key (db_schema, seq));
grant select
   on test_parms to dtgen_ut_test;
/

@test_gen.pkb
@test_rig.pkb

insert into test_parms (db_schema, seq, test_name, success, val0, val1, val2) values ('TDBST', 1, 'DTC_INSERT', 'SUCCESS', 'NUM_PLAIN', 1, null);
insert into test_parms (db_schema, seq, test_name, success, val0, val1, val2) values ('TDBST', 2, 'DTC_INSERT', 'SUCCESS', 'NUM_PLAIN', 2, '123.89');
insert into test_parms (db_schema, seq, test_name, success, val0, val1, val2) values ('TDBST', 3, 'DTC_INSERT', 'SUCCESS', 'NUM_PLAIN', 3, '-1.2e-4');
insert into test_parms (db_schema, seq, test_name, success, val0, val1, val2) values ('TDBST', 4, 'DTC_INSERT', 'SUCCESS', 'NUM_PLAIN', 4, '1.2e5');
