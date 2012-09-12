create or replace package test_rig
is

   procedure basic_test;

   function run
      (test_set_in  in  varchar2
      ,test_seq_in  in  number)
   return varchar2;

end test_rig;
/
