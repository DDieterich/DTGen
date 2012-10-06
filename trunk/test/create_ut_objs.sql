
--
-- Create SQL*Developer Unit Test Owner Database Objects Script
--
-- &1. - Name of the Generator Schema Object Owner
--

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
   on global_parms to UTP_app;

create table parm_sets
      (parm_set     varchar2(30)  -- Primary Key
      ,description  varchar2(2000)
      ,constraint parm_sets_pk primary key (parm_set))
   organization index;
grant select
   on parm_sets to UTP_app;

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
   on test_parms to UTP_app;

create table test_sets
      (user_name    varchar2(30) -- Primary Key
      ,global_set   varchar2(1)  -- Primary Key
      ,test_name    varchar2(60) -- Primary Key
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
   on test_sets to UTP_app;
