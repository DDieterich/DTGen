
--
-- Create SQL*Developer Unit Test Owner Database Objects Script
--
-- &1. - Name of the Generator Schema Object Owner
--

-- Create Synonyms back to the Generator Schema Object Owner
create synonym applications_act for &1..applications_act;
create synonym file_lines_asof  for &1..file_lines_asof;
create synonym glob             for &1..glob;
create synonym generate         for &1..generate;

@test_gen.pks
grant execute on test_gen to dtgen_ut_test;
@test_rig.pks
grant execute on test_rig to dtgen_ut_test;

create table test_run as
   select abbr          app_abbr
         ,db_schema     schema_name
         ,systimestamp  gen_tstamp
   from applications_act where 0 = 1;
alter table test_run
   add (constraint test_run_pk
   primary key (app_abbr, schema_name));
grant select, insert, update, delete
   on test_run to dtgen_ut_test;

create sequence test_parms_seq;
create table test_parms
   (schema_name  applications.db_schema%TYPE -- Primary Key
   ,seq          number       -- Primary Key
   ,test_name    varchar2(30)   not null
   ,success      varchar2(4000) not null
   ,val1         varchar2(4000)
   ,val2         varchar2(4000)
   ,constraint test_parms_pk primary key (schema_name, seq));
grant select
   on test_parms to dtgen_ut_test;
create trigger test_parms_bi
  before insert on test_parms
  for each row
begin
   select test_parms_seq.nextval into :new.seq from dual;
end test_parms_bi;
/

@test_gen.pkb
@test_rig.pkb

insert into test_parms (schema_name, test_name, success, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 1, null);
insert into test_parms (schema_name, test_name, success, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 2, '123.89');
insert into test_parms (schema_name, test_name, success, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 3, '-1.2e-4');
insert into test_parms (schema_name, test_name, success, val1, val2, val3) values ('TDBST', 'DTC_INSERT', 'SUCCESS', 'SUCCESS', 'SUCCESS', 'NUM_PLAIN_PLAIN', 4, '1.2e5');
