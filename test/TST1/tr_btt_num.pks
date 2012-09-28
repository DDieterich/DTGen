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

--------------------------------------------------

   procedure min_len_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure min_len_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure min_len_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure min_min_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure min_min_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure min_min_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure min_max_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure min_max_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure min_max_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure max_len_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure max_len_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure max_len_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure max_min_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure max_min_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure max_min_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure max_max_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null);

   procedure max_max_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   procedure max_max_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null);

   function SQLACT_NON_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_num;
/
