create or replace package test_rig
is

   procedure basic_test;

   procedure set_global_parms
      (global_set_in  in  varchar2);

   function run_test_instance
      (test_name_in   in  varchar2
      ,table_type_in  in  varchar2
      ,parm_set_in    in  number)
   return varchar2;

   procedure run_test
      (test_name_in   in  varchar2
      ,table_type_in  in  varchar2);

   procedure run_all;

end test_rig;
/
