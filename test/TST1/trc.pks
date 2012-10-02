create or replace package trc
is

   -- Test Rig Common Utilties

   current_global_set  global_parms.global_set%TYPE := null;
   tparms              test_parms%ROWTYPE;
   key_txt             varchar2(60);
   sql_txt             varchar2(1994);

   procedure get_tparms
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number);

   function basic_test
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function tablespace_test
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function bool_to_str
      (bool_in in boolean)
   return varchar2;

   procedure set_global_parms
      (global_set_in  in  varchar2);

   procedure run_test
      (test_name_in   in  varchar2);

   procedure run_global_set
      (global_set_in  in  varchar2);

   procedure run_all;

end trc;
/
