create or replace package tr_btt_dtm_owner
is

   -- Basic Table Test for Number Datatype
   --   Running as owner privileges

   function SQLTAB_NON_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

------------------------------------------------------------

   function SQLTAB_NON_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_LOG_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLTAB_EFF_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_dtm_owner;
/
