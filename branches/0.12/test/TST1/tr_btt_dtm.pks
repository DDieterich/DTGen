create or replace package tr_btt_dtm
is

   -- Basic Table Test for Number Datatype

   procedure date_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  date default null);

   procedure date_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  date default null);

   procedure date_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  date default null);

   function SQLACT_NON_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure tst_tz_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  timestamp with time zone default null);

   procedure tst_tz_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with time zone default null);

   procedure tst_tz_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with time zone default null);

   function SQLACT_NON_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

--------------------------------------------------

   procedure tst_ltz_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  timestamp with local time zone default null);

   procedure tst_ltz_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with local time zone default null);

   procedure tst_ltz_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with local time zone default null);

   function SQLACT_NON_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_LOG_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function SQLACT_EFF_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_NON_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_LOG_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

   function APITAB_EFF_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2;

end tr_btt_dtm;
/
