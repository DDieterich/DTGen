create or replace package tr_btt_num_owner
is

   -- Basic Table Test for Number Datatype
   --   Running as owner privileges

   function SQLTAB_NON_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_num_owner;
/
