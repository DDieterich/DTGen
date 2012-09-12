--
-- Unit Test SQL*Loader Control File
--
-- sqlldr username/password CONTROL=FILENAME
--
load data infile *
into table GLOBAL_PARMS append
   when key = 'GLOBAL_PARMS                  '
   fields terminated by ''
      (key FILLER position(1:31)
      ,global_set        CHAR(1)
      ,db_constraints    CHAR(1)
      ,fold_strings      CHAR(1)
      ,ignore_no_change  CHAR(1))
into table TABLE_TYPES append
   when key = 'TABLE_TYPES                   '
   fields terminated by ''
      (key FILLER position(1:31)
      ,table_type  CHAR(30))
into table PARM_TYPES append
   when key = 'PARM_TYPES                    '
   fields terminated by ''
      (key FILLER position(1:31)
      ,parm_type  CHAR(30))
into table TEST_PARMS append
   when key = 'TEST_PARMS                    '
   fields terminated by ''
   trailing nullcols
      (key FILLER position(1:31)
      ,parm_set   FLOAT EXTERNAL
      ,parm_type  CHAR(30)
      ,val0       CHAR(4000)
      ,val1       CHAR(4000)
      ,val2       CHAR(4000)
      ,val3       CHAR(4000)
      ,val4       CHAR(4000)
      ,val5       CHAR(4000)
      ,val6       CHAR(4000)
      ,val7       CHAR(4000)
      ,val8       CHAR(4000)
      ,val9       CHAR(4000) )
into table TEST_SETS append
   when key = 'TEST_SETS                     '
   fields terminated by ''
      (key FILLER position(1:31)
      ,test_name    CHAR(30)
      ,parm_type    CHAR(30))
BEGINDATA
GLOBAL_PARMS                  AFFF
GLOBAL_PARMS                  BTFF
GLOBAL_PARMS                  CFTF
GLOBAL_PARMS                  DTTF
GLOBAL_PARMS                  EFFT
GLOBAL_PARMS                  FTFT
GLOBAL_PARMS                  GFTT
GLOBAL_PARMS                  HTTT
TABLE_TYPES                   NON
TABLE_TYPES                   LOG
TABLE_TYPES                   EFF
PARM_TYPES                    DTC
TEST_PARMS                    111DTCINSERT11NUM_PLAINNULL
TEST_PARMS                    112DTCINSERT12NUM_PLAIN'123.89'
TEST_PARMS                    113DTCINSERT13NUM_PLAIN'-1.2e-4'
TEST_PARMS                    114DTCINSERT14NUM_PLAIN'1.2e5'
TEST_PARMS                    121DTCUPDATE11NUM_PLAIN'456.78'
TEST_PARMS                    122DTCUPDATE12NUM_PLAIN'-5.6e-7'
TEST_PARMS                    123DTCUPDATE13NUM_PLAIN'3.4e5'
TEST_PARMS                    124DTCUPDATE14NUM_PLAINNULL
TEST_PARMS                    131DTCDELETE11
TEST_PARMS                    132DTCDELETE12
TEST_PARMS                    133DTCDELETE13
TEST_PARMS                    134DTCDELETE14
TEST_SETS                     DTC_SQLTABDTC
TEST_SETS                     DTC_SQLACTDTC
TEST_SETS                     DTC_DMLTABDTC
TEST_SETS                     DTC_DMLACTDTC
