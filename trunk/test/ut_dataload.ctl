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
      ,test_set          CHAR(1)
      ,db_constraints    CHAR(1)
      ,fold_strings      CHAR(1)
      ,ignore_no_change  CHAR(1))
into table TEST_PARMS append
   when key = 'TEST_PARMS                    '
   fields terminated by ''
   trailing nullcols
      (key FILLER position(1:31)
      ,test_seq   FLOAT EXTERNAL
      ,test_name  CHAR(30)
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
into table TEST_SCHEMAS append
   when key = 'TEST_SCHEMAS                  '
   fields terminated by ''
   trailing nullcols
      (key FILLER position(1:31)
      ,db_schema    CHAR(4000)
      ,test_set     CHAR(1)
      ,test_seq     FLOAT EXTERNAL
      ,success      CHAR(4000))
BEGINDATA
GLOBAL_PARMS                  AFFF
GLOBAL_PARMS                  BTFF
GLOBAL_PARMS                  CFTF
GLOBAL_PARMS                  DTTF
GLOBAL_PARMS                  EFFT
GLOBAL_PARMS                  FTFT
GLOBAL_PARMS                  GFTT
GLOBAL_PARMS                  HTTT
TEST_PARMS                    1111DTC_INSERTSQLTABT1A_NON11NUM_PLAINNULL
TEST_PARMS                    1112DTC_INSERTSQLTABT1A_NON12NUM_PLAIN'123.89'
TEST_PARMS                    1113DTC_INSERTSQLTABT1A_NON13NUM_PLAIN'-1.2e-4'
TEST_PARMS                    1114DTC_INSERTSQLTABT1A_NON14NUM_PLAIN'1.2e5'
TEST_PARMS                    1121DTC_UPDATESQLTABT1A_NON11NUM_PLAIN'456.78'
TEST_PARMS                    1122DTC_UPDATESQLTABT1A_NON12NUM_PLAIN'-5.6e-7'
TEST_PARMS                    1123DTC_UPDATESQLTABT1A_NON13NUM_PLAIN'3.4e5'
TEST_PARMS                    1124DTC_UPDATESQLTABT1A_NON14NUM_PLAINNULL
TEST_PARMS                    1131DTC_DELETESQLTABT1A_NON11
TEST_PARMS                    1132DTC_DELETESQLTABT1A_NON12
TEST_PARMS                    1133DTC_DELETESQLTABT1A_NON13
TEST_PARMS                    1134DTC_DELETESQLTABT1A_NON14
TEST_PARMS                    1211DTC_INSERTSQLACTT1A_NON11NUM_PLAINNULL
TEST_PARMS                    1212DTC_INSERTSQLACTT1A_NON12NUM_PLAIN'123.89'
TEST_PARMS                    1213DTC_INSERTSQLACTT1A_NON13NUM_PLAIN'-1.2e-4'
TEST_PARMS                    1214DTC_INSERTSQLACTT1A_NON14NUM_PLAIN'1.2e5'
TEST_PARMS                    1221DTC_UPDATESQLACTT1A_NON11NUM_PLAIN'456.78'
TEST_PARMS                    1222DTC_UPDATESQLACTT1A_NON12NUM_PLAIN'-5.6e-7'
TEST_PARMS                    1223DTC_UPDATESQLACTT1A_NON13NUM_PLAIN'3.4e5'
TEST_PARMS                    1224DTC_UPDATESQLACTT1A_NON14NUM_PLAINNULL
TEST_PARMS                    1231DTC_DELETESQLACTT1A_NON11
TEST_PARMS                    1232DTC_DELETESQLACTT1A_NON12
TEST_PARMS                    1233DTC_DELETESQLACTT1A_NON13
TEST_PARMS                    1234DTC_DELETESQLACTT1A_NON14
TEST_PARMS                    1311DTC_INSERTDMLTABT1A_NON11NUM_PLAINNULL
TEST_PARMS                    1312DTC_INSERTDMLTABT1A_NON12NUM_PLAIN'123.89'
TEST_PARMS                    1313DTC_INSERTDMLTABT1A_NON13NUM_PLAIN'-1.2e-4'
TEST_PARMS                    1314DTC_INSERTDMLTABT1A_NON14NUM_PLAIN'1.2e5'
TEST_PARMS                    1321DTC_UPDATEDMLTABT1A_NON11NUM_PLAIN'456.78'
TEST_PARMS                    1322DTC_UPDATEDMLTABT1A_NON12NUM_PLAIN'-5.6e-7'
TEST_PARMS                    1323DTC_UPDATEDMLTABT1A_NON13NUM_PLAIN'3.4e5'
TEST_PARMS                    1324DTC_UPDATEDMLTABT1A_NON14NUM_PLAINNULL
TEST_PARMS                    1331DTC_DELETEDMLT1A_NON11
TEST_PARMS                    1332DTC_DELETEDMLT1A_NON12
TEST_PARMS                    1333DTC_DELETEDMLT1A_NON13
TEST_PARMS                    1334DTC_DELETEDMLT1A_NON14
TEST_PARMS                    1411DTC_INSERTDMLACTT1A_NON11NUM_PLAINNULL
TEST_PARMS                    1412DTC_INSERTDMLACTT1A_NON12NUM_PLAIN'123.89'
TEST_PARMS                    1413DTC_INSERTDMLACTT1A_NON13NUM_PLAIN'-1.2e-4'
TEST_PARMS                    1414DTC_INSERTDMLACTT1A_NON14NUM_PLAIN'1.2e5'
TEST_PARMS                    1421DTC_UPDATEDMLACTT1A_NON11NUM_PLAIN'456.78'
TEST_PARMS                    1422DTC_UPDATEDMLACTT1A_NON12NUM_PLAIN'-5.6e-7'
TEST_PARMS                    1423DTC_UPDATEDMLACTT1A_NON13NUM_PLAIN'3.4e5'
TEST_PARMS                    1424DTC_UPDATEDMLACTT1A_NON14NUM_PLAINNULL
TEST_PARMS                    1431DTC_DELETEDMLT1A_NON11
TEST_PARMS                    1432DTC_DELETEDMLT1A_NON12
TEST_PARMS                    1433DTC_DELETEDMLT1A_NON13
TEST_PARMS                    1434DTC_DELETEDMLT1A_NON14
TEST_SCHEMAS                  TDBSTA1111SUCCESS
TEST_SCHEMAS                  TDBSTA1112SUCCESS
TEST_SCHEMAS                  TDBSTA1113SUCCESS
TEST_SCHEMAS                  TDBSTA1114SUCCESS
TEST_SCHEMAS                  TDBSTA1121SUCCESS
TEST_SCHEMAS                  TDBSTA1122SUCCESS
TEST_SCHEMAS                  TDBSTA1123SUCCESS
TEST_SCHEMAS                  TDBSTA1124SUCCESS
TEST_SCHEMAS                  TDBSTA1131SUCCESS
TEST_SCHEMAS                  TDBSTA1132SUCCESS
TEST_SCHEMAS                  TDBSTA1133SUCCESS
TEST_SCHEMAS                  TDBSTA1134SUCCESS
TEST_SCHEMAS                  TDBSTA1211SUCCESS
TEST_SCHEMAS                  TDBSTA1212SUCCESS
TEST_SCHEMAS                  TDBSTA1213SUCCESS
TEST_SCHEMAS                  TDBSTA1214SUCCESS
TEST_SCHEMAS                  TDBSTA1221SUCCESS
TEST_SCHEMAS                  TDBSTA1222SUCCESS
TEST_SCHEMAS                  TDBSTA1223SUCCESS
TEST_SCHEMAS                  TDBSTA1224SUCCESS
TEST_SCHEMAS                  TDBSTA1231SUCCESS
TEST_SCHEMAS                  TDBSTA1232SUCCESS
TEST_SCHEMAS                  TDBSTA1233SUCCESS
TEST_SCHEMAS                  TDBSTA1234SUCCESS
TEST_SCHEMAS                  TDBSTA1311SUCCESS
TEST_SCHEMAS                  TDBSTA1312SUCCESS
TEST_SCHEMAS                  TDBSTA1313SUCCESS
TEST_SCHEMAS                  TDBSTA1314SUCCESS
TEST_SCHEMAS                  TDBSTA1321SUCCESS
TEST_SCHEMAS                  TDBSTA1322SUCCESS
TEST_SCHEMAS                  TDBSTA1323SUCCESS
TEST_SCHEMAS                  TDBSTA1324SUCCESS
TEST_SCHEMAS                  TDBSTA1331SUCCESS
TEST_SCHEMAS                  TDBSTA1332SUCCESS
TEST_SCHEMAS                  TDBSTA1333SUCCESS
TEST_SCHEMAS                  TDBSTA1334SUCCESS
TEST_SCHEMAS                  TDBSTA1411SUCCESS
TEST_SCHEMAS                  TDBSTA1412SUCCESS
TEST_SCHEMAS                  TDBSTA1413SUCCESS
TEST_SCHEMAS                  TDBSTA1414SUCCESS
TEST_SCHEMAS                  TDBSTA1421SUCCESS
TEST_SCHEMAS                  TDBSTA1422SUCCESS
TEST_SCHEMAS                  TDBSTA1423SUCCESS
TEST_SCHEMAS                  TDBSTA1424SUCCESS
TEST_SCHEMAS                  TDBSTA1431SUCCESS
TEST_SCHEMAS                  TDBSTA1432SUCCESS
TEST_SCHEMAS                  TDBSTA1433SUCCESS
TEST_SCHEMAS                  TDBSTA1434SUCCESS
