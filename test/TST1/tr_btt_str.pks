create or replace package tr_btt_str
is

   -- Basic Table Test for Number Datatype

   procedure char_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  varchar2 default null);

   procedure char_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  varchar2 default null);

   procedure char_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  varchar2 default null);

   function SQLACT_NON_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_str;
/
