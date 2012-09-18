
-- Multi-Tier Global Package Settings won't work
--   across distributed connections
set echo on
spool multi_tier_global_pkg_test
drop user TEST_MTS cascade;
drop user TEST_DBS cascade;

alter system set global_names=TRUE
   comment='Required for Mutli-Tier Distributed Testing'
   scope=MEMORY;

-- Simulated Database Server User
create user TEST_DBS identified by TEST_DBS
   default tablespace users;
grant connect, resource to TEST_DBS;
-- Simulated Mid-Tier Server User
create user TEST_MTS identified by TEST_MTS
   default tablespace users;
grant connect, resource to TEST_MTS;
grant create database link to TEST_MTS;
grant create synonym to TEST_MTS;

-- Simulated Database Server User
connect TEST_DBS@XE2/TEST_DBS
create table test_globals
   (seq  number
   ,gval varchar2(30));
create package test_global_pkg
is
   procedure set_gval(gval_in in varchar2);
   function get_gval return varchar2;
end test_global_pkg;
/
show errors
create package body test_global_pkg
is
   gval varchar2(30) := 'DBS_DEFAULT';
procedure set_gval(gval_in in varchar2)
is
begin
   gval := gval_in;
end set_gval;
function get_gval return varchar2
is
begin
   return gval;
end get_gval;
begin
   gval := 'DBS_INIT';
end test_global_pkg;
/
show errors
insert into test_globals (seq, gval)
  values (0, test_global_pkg.get_gval);
execute test_global_pkg.set_gval('DBS_Val1');
insert into test_globals (seq, gval)
  values (1, test_global_pkg.get_gval);
commit;
-- This should not be necessary
grant execute on test_global_pkg to TEST_MTS;

-- Simulated Mid-Tier Server User
connect TEST_MTS@XE2/TEST_MTS
create database link XE@loopback
   connect to TEST_DBS identified by TEST_DBS
   using 'loopback';
create synonym test_globals for test_globals@XE@loopback;
create package test_global_pkg
is
   procedure set_gval(gval_in in varchar2);
   function get_gval return varchar2;
end test_global_pkg;
/
show errors
create package body test_global_pkg
is
procedure set_gval(gval_in in varchar2)
is
begin
   test_global_pkg.set_gval@XE@loopback(gval_in);
end set_gval;
function get_gval return varchar2
is
begin
   return test_global_pkg.get_gval@XE@loopback;
end get_gval;
end test_global_pkg;
/
show errors
insert into test_globals (seq, gval)
  values (2, TEST_DBS.test_global_pkg.get_gval);
execute test_global_pkg.set_gval('MTS_Val1');
insert into test_globals (seq, gval)
  values (3, TEST_DBS.test_global_pkg.get_gval);
execute execute immediate 'insert into test_globals (seq, gval) values (4, TEST_DBS.test_global_pkg.get_gval)';
begin
   insert into test_globals@XE@loopback (seq, gval)
     values (5, TEST_DBS.test_global_pkg.get_gval);
end;
/
begin
   execute immediate 'insert into test_globals@XE@loopback (seq, gval) values (6, TEST_DBS.test_global_pkg.get_gval)';
end;
/
select test_global_pkg.get_gval from dual;
select test_global_pkg.get_gval from dual@XE@loopback;
select TEST_DBS.test_global_pkg.get_gval from dual@XE@loopback;
select * From test_globals;
-- This fails:
insert into test_globals@XE@loopback (seq, gval)
  values (21, test_global_pkg.get_gval);
-- This fails:
insert into test_globals (seq, gval)
  values (22, test_global_pkg.get_gval);
-- This fails:
insert into test_globals (seq, gval)
  values (23, TEST_MTS.test_global_pkg.get_gval);
commit;

spool off
exit
