--
-- Unit Test SQL*Loader Control File
--
-- sqlldr username/password CONTROL=FILENAME
--
load data infile *
into table GLOBAL_PARMS append
   when key = 'GLOBAL_PARMS                  '
   fields terminated by ''
   trailing nullcols
      (key FILLER position(1:31)
      ,global_set        CHAR(1)
      ,db_constraints    CHAR(1)
      ,fold_strings      CHAR(1)
      ,ignore_no_change  CHAR(1)
      ,description       CHAR(2000) )
into table PARM_SETS append
   when key = 'PARM_SETS                     '
   fields terminated by ''
   trailing nullcols
      (key FILLER   position(1:31)
      ,parm_set     CHAR(30)
      ,description  CHAR(2000) )
into table TEST_PARMS append
   when key = 'TEST_PARMS                    '
   fields terminated by ''
   trailing nullcols
      (key FILLER   position(1:31)
      ,parm_set     CHAR(30)
      ,parm_seq     FLOAT EXTERNAL
      ,result_txt   CHAR(4000)
      ,val0         CHAR(4000)
      ,val1         CHAR(4000)
      ,val2         CHAR(4000)
      ,val3         CHAR(4000)
      ,val4         CHAR(4000)
      ,val5         CHAR(4000)
      ,val6         CHAR(4000)
      ,val7         CHAR(4000)
      ,val8         CHAR(4000)
      ,val9         CHAR(4000)
      ,description  CHAR(2000) )
into table TEST_SETS append
   when key = 'TEST_SETS                     '
   fields terminated by ''
   trailing nullcols
      (key FILLER position(1:31)
      ,user_name    CHAR(30)
      ,global_set   CHAR(1)
      ,test_name    CHAR(60)
      ,parm_set     CHAR(30)
      ,description  CHAR(2000) )
BEGINDATA
GLOBAL_PARMS                  ATTT
GLOBAL_PARMS                  BTTF
GLOBAL_PARMS                  CTFT
GLOBAL_PARMS                  DTFF
GLOBAL_PARMS                  EFTT
GLOBAL_PARMS                  FFTF
GLOBAL_PARMS                  GFFT
GLOBAL_PARMS                  HFFF
PARM_SETS                     BTT_NUM_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Plain Numbers
PARM_SETS                     BTT_NUM_LOG_NoIntDBFailed Basic Table Test for SQL LOG Table Insert with no Integrity (Triggers) at Database Server
PARM_SETS                     BTT_NUM_EFF_NoIntDBFailed Basic Table Test for SQL EFF Table Insert with no Integrity (Triggers) at Database Server
PARM_SETS                     BTT_NUM_USR_NULL_INSFailed Basic Table Test for SQL LOG/EFF ACT Views Insert DB_CONSTRAINTS = TRUE and no Integrity (Triggers)
PARM_SETS                     BTT_NUM_MIN_LEN_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Minimum Length Numbers
PARM_SETS                     BTT_NUM_MIN_MIN_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Minimum Length Numbers with Minimum Precision (Very Large Scalars)
PARM_SETS                     BTT_NUM_MIN_MAX_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Minimum Length Numbers with Maximum Precision (Very Small Scalars)
PARM_SETS                     BTT_NUM_MAX_LEN_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Maximum Length Numbers
PARM_SETS                     BTT_NUM_MAX_MIN_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Maximum Length Numbers with Minimum Precision (Very Large Scalars)
PARM_SETS                     BTT_NUM_MAX_MAX_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Maximum Length Numbers with Maximum Precision (Very Small Scalars)
PARM_SETS                     BTT_DTM_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for DATE/time Data
PARM_SETS                     BTT_TTZ_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Plain TIMESTAMP with Time Zone Data
PARM_SETS                     BTT_LTZ_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Plain TIMESTAMP with Local Time Zone Data
PARM_SETS                     BTT_CHAR_MAX_PASSHappy Path Basic Table Test (DTC, POPT, Partial HAT, Partial APIT, and Partial DMLIT) for Variable Character Data
TEST_PARMS                    BTT_NUM_PASS1SUCCESS11456.78
TEST_PARMS                    BTT_NUM_PASS2SUCCESS12123.89-5.6e-70
TEST_PARMS                    BTT_NUM_PASS3SUCCESS13-1.2e-403.4e50
TEST_PARMS                    BTT_NUM_PASS4SUCCESS141.2e50
TEST_PARMS                    BTT_NUM_PASS5SUCCESS151.0e-1300.9e126
TEST_PARMS                    BTT_NUM_PASS6SUCCESS16-1.0e-130-0.9e126
TEST_PARMS                    BTT_NUM_LOG_NoIntDB1FAILURE at UPDATE: ORA-20000: t1a_log_aud row_cnt is not 1:%1123.89-5.6e-70
TEST_PARMS                    BTT_NUM_EFF_NoIntDB1FAILURE at UPDATE: ORA-20000: t1a_eff_hist row_cnt is not 1:%1123.89-5.6e-70
TEST_PARMS                    BTT_NUM_USR_NULL_INS1FAILURE at INSERT: ORA-01400: cannot insert NULL into ("%"."AUD_BEG_USR")%1123.89-5.6e-70
TEST_PARMS                    BTT_NUM_MIN_LEN_PASS1SUCCESS111-2
TEST_PARMS                    BTT_NUM_MIN_MIN_PASS1SUCCESS113e84-4e84
TEST_PARMS                    BTT_NUM_MIN_MAX_PASS1SUCCESS115e-127-6e-127
TEST_PARMS                    BTT_NUM_MAX_LEN_PASS1SUCCESS1112345678901234567890123456789012345678-23456789012345678901234567890123456789
TEST_PARMS                    BTT_NUM_MAX_MIN_PASS1SUCCESS114.5678901234567890123456789012345678901e121-5.6789012345678901234567890123456789012e121
TEST_PARMS                    BTT_NUM_MAX_MAX_PASS1SUCCESS116.7890123456789012345678901234567890123e-90-7.8901234567890123456789012345678901234e-90
TEST_PARMS                    BTT_DTM_PASS1SUCCESS1111-SEP-2001 AD 08:46:01
TEST_PARMS                    BTT_DTM_PASS2SUCCESS1202-MAY-2011 AD 01:13:07
TEST_PARMS                    BTT_DTM_PASS3SUCCESS1301-JAN-4712 BC 00:00:0031-DEC-4713 AD 23:59:59
TEST_PARMS                    BTT_TTZ_PASS1SUCCESS1111-SEP-2001 AD 08:46:01.789 UTC
TEST_PARMS                    BTT_TTZ_PASS2SUCCESS1202-MAY-2011 AD 01:13:07.456 UTC
TEST_PARMS                    BTT_TTZ_PASS3SUCCESS1301-JAN-4712 BC 00:00:00.123 UTC31-DEC-9999 AD 23:59:59.999 UTC
TEST_PARMS                    BTT_LTZ_PASS1SUCCESS1111-SEP-2001 AD 08:46:01.789
TEST_PARMS                    BTT_LTZ_PASS2SUCCESS1202-MAY-2011 AD 01:13:07.456
TEST_PARMS                    BTT_LTZ_PASS3SUCCESS1301-JAN-4712 BC 00:00:00.12331-DEC-9999 AD 23:59:59.999
TEST_PARMS                    BTT_CHAR_MAX_PASS1SUCCESS11The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.
TEST_PARMS                    BTT_CHAR_MAX_PASS2SUCCESS12The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.  The length of this sentence, with the 2 (two) leading spaces, and the period, is a 100 characters.
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_STR_OWNER.SQLTAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.SQLACT_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.APITAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1DBSFTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1DBSGTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1DBSHTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_STR_OWNER.SQLTAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.SQLACT_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.APITAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1DBSFTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1DBSGTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1DBSHTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSBTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSCTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSDTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSETR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSFTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSGTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSHTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.SQLACT_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBSATR_BTT_NUM.APITAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM_OWNER.SQLTAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.SQLACT_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBSATR_BTT_DTM.APITAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBSATR_BTT_STR_OWNER.SQLTAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.SQLACT_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBSATR_BTT_STR.APITAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_STR.SQLACT_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_STR.APITAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_STR.SQLACT_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_STR.APITAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUBTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUCTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUDTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUETR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUFTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUGTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUHTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.SQLACT_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1DBUATR_BTT_NUM.APITAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.SQLACT_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1DBUATR_BTT_DTM.APITAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1DBUATR_BTT_STR.SQLACT_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1DBUATR_BTT_STR.APITAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM_OWNER.SQLTAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_STR_OWNER.SQLTAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.SQLACT_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.APITAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1MTSFTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1MTSGTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1MTSHTR_BTT_NUM_OWNER.SQLTAB_LOG_PLAINBTT_NUM_LOG_NoIntDB
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_STR_OWNER.SQLTAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.SQLACT_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.APITAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1MTSFTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1MTSGTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1MTSHTR_BTT_NUM_OWNER.SQLTAB_EFF_PLAINBTT_NUM_EFF_NoIntDB
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSBTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSCTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSDTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSETR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSFTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSGTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSHTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM_OWNER.SQLTAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.SQLACT_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTSATR_BTT_NUM.APITAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM_OWNER.SQLTAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.SQLACT_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTSATR_BTT_DTM.APITAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTSATR_BTT_STR_OWNER.SQLTAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.SQLACT_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTSATR_BTT_STR.APITAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.SQLACT_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.APITAB_NON_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_NON_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_NON_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_NON_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_NON_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_STR.SQLACT_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_STR.APITAB_NON_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.SQLACT_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.APITAB_LOG_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_LOG_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_LOG_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_LOG_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_LOG_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_STR.SQLACT_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_STR.APITAB_LOG_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.SQLACT_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUBTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUCTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUDTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUETR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUFTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUGTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUHTR_BTT_NUM.APITAB_EFF_PLAINBTT_NUM_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.SQLACT_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MIN_LENBTT_NUM_MIN_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MIN_MINBTT_NUM_MIN_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MIN_MAXBTT_NUM_MIN_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MAX_LENBTT_NUM_MAX_LEN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MAX_MINBTT_NUM_MAX_MIN_PASS
TEST_SETS                     T1MTUATR_BTT_NUM.APITAB_EFF_MAX_MAXBTT_NUM_MAX_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.SQLACT_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_EFF_DATEBTT_DTM_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_EFF_TST_TZBTT_TTZ_PASS
TEST_SETS                     T1MTUATR_BTT_DTM.APITAB_EFF_TST_LTZBTT_LTZ_PASS
TEST_SETS                     T1MTUATR_BTT_STR.SQLACT_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
TEST_SETS                     T1MTUATR_BTT_STR.APITAB_EFF_CHAR_MAXBTT_CHAR_MAX_PASS
