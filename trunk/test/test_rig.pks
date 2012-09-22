create or replace package test_rig
is

   procedure basic_test;

   function BTT_SQLTAB_NON_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_SQLTAB_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_SQLTAB_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_SQLACT_NON_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_SQLACT_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_SQLACT_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_APITAB_NON_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_APITAB_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function BTT_APITAB_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function bool_to_str
      (bool_in in boolean)
   return varchar2;

   procedure set_global_parms
      (global_set_in  in  varchar2);

--   function run_test_instance
--      (test_name_in   in  varchar2
--      ,table_type_in  in  varchar2
--      ,parm_set_in    in  number)
--   return varchar2;

   procedure run_test
      (test_name_in   in  varchar2);

   procedure run_global_set
      (global_set_in  in  varchar2);

   procedure run_all;

end test_rig;
/
