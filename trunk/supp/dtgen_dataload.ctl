--
-- DTGen SQL*Loader Control File Header
--    Full data dump of the DTGEN application
--    
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    October   04, 2012  08:19:40 PM
--
-- 1) Copy this Header to a file named "dtgen_dataload.ctl"
--    (The split is necessary to for the "STR" record terminator)
--    (The "STR" record terminator is necessary for records with embedded LineFeeds)
--    (1E = Record Separator, 0D = Carriage Return, 0A = LineFeed)
-- 2) sqlldr username/password CONTROL=dtgen_dataload.ctl
--    (This header is included in each datafile and skipped via the "skip = 1")
--
-- NOTE: CLOBs won't load into _ACT views due to
--      "ORA-22816: unsupported feature with RETURNING clause"
--
options (skip = 1)
load data infile dtgen_dataload.dat  "STR x'1E0D0A'"
into table APPLICATIONS APPEND when key = 'APPLICATIONS                  ' fields terminated by ''
   (key FILLER position(1:31), abbr CHAR(5), name CHAR(30), db_schema CHAR(30), apex_schema CHAR(30), apex_ws_name CHAR(30), apex_app_name CHAR(30), dbid CHAR(2000), db_auth CHAR(200), description CHAR(1000), ts_null_override CHAR(1), ts_onln_data CHAR(30), ts_onln_indx CHAR(30), ts_hist_data CHAR(30), ts_hist_indx CHAR(30), usr_datatype CHAR(20), usr_frgn_key CHAR(100), copyright CHAR(4000))
into table DOMAINS_ACT APPEND when key = 'DOMAINS                       ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR(5), abbr CHAR(5), name CHAR(20), fold CHAR(1), len FLOAT EXTERNAL, description CHAR(1000))
into table EXCEPTIONS_ACT APPEND when key = 'EXCEPTIONS                    ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR(5), code FLOAT EXTERNAL, name CHAR(30), message CHAR(2048), cause CHAR(2048), action CHAR(2048))
into table PROGRAMS_ACT APPEND when key = 'PROGRAMS                      ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR(5), name CHAR(30), type CHAR(30), description CHAR(1000))
into table TABLES_ACT APPEND when key = 'TABLES                        ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR(5), abbr CHAR(5), name CHAR(15), seq FLOAT EXTERNAL, type CHAR(3), group_name CHAR(30), mv_refresh_hr FLOAT EXTERNAL, ts_onln_data CHAR(30), ts_onln_indx CHAR(30), ts_hist_data CHAR(30), ts_hist_indx CHAR(30), description CHAR(1000))
into table CHECK_CONS_ACT APPEND when key = 'CHECK_CONS                    ' fields terminated by ''
   (key FILLER position(1:31), tables_nk1 CHAR(5), tables_nk2 CHAR(5), seq FLOAT EXTERNAL, text CHAR(1000), description CHAR(1000))
into table DOMAIN_VALUES_ACT APPEND when key = 'DOMAIN_VALUES                 ' fields terminated by ''
   (key FILLER position(1:31), domains_nk1 CHAR(5), domains_nk2 CHAR(5), value CHAR(100), seq FLOAT EXTERNAL, description CHAR(1000))
into table TAB_COLS_ACT APPEND when key = 'TAB_COLS                      ' fields terminated by ''
   (key FILLER position(1:31), tables_nk1 CHAR(5), tables_nk2 CHAR(5), name CHAR(25), seq FLOAT EXTERNAL, nk FLOAT EXTERNAL, req CHAR(1), fk_prefix CHAR(4), fk_tables_nk1 CHAR(5), fk_tables_nk2 CHAR(5), d_domains_nk1 CHAR(5), d_domains_nk2 CHAR(5), type CHAR(30), len FLOAT EXTERNAL, scale FLOAT EXTERNAL, fold CHAR(1), default_value CHAR(1000), upd_res_pct FLOAT EXTERNAL, description CHAR(1000))
into table TAB_INDS_ACT APPEND when key = 'TAB_INDS                      ' fields terminated by ''
   (key FILLER position(1:31), tab_cols_nk1 CHAR(5), tab_cols_nk2 CHAR(5), tab_cols_nk3 CHAR(25), tag CHAR(4), seq FLOAT EXTERNAL)
----------   End of Control File Header   ----------
