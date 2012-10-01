create or replace package tr_btt_str_owner
is

   -- Basic Table Test for Number Datatype
   --   Running as owner privileges

   function SQLTAB_NON_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_str_owner;
/
