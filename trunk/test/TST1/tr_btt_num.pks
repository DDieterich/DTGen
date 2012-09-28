create or replace package tr_btt_num
is

   -- Basic Table Test for Number Datatype

   procedure plain_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure plain_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure plain_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_num;
/
