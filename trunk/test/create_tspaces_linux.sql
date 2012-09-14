
--
-- Create Tablespaces in MS-Windows Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - Generator Schema Object Owner Name
--

-- Create Test Tablespaces;
create tablespace test_onln_data_default datafile
   '/u01/oradata/DEMO1/TEST_ONLN_DATA_DEFAULT.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_onln_indx_default datafile
   '/u01/oradata/DEMO1/TEST_ONLN_INDX_DEFAULT.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_hist_data_default datafile
   '/u01/oradata/DEMO1/TEST_HIST_DATA_DEFAULT.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_hist_indx_default datafile
   '/u01/oradata/DEMO1/TEST_HIST_INDX_DEFAULT.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_onln_data_special datafile
   '/u01/oradata/DEMO1/TEST_ONLN_DATA_SPECIAL.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_onln_indx_special datafile
   '/u01/oradata/DEMO1/TEST_ONLN_INDX_SPECIAL.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_hist_data_special datafile
   '/u01/oradata/DEMO1/TEST_HIST_DATA_SPECIAL.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
create tablespace test_hist_indx_special datafile
   '/u01/oradata/DEMO1/TEST_HIST_INDX_SPECIAL.DBF'
   size 1M reuse autoextend on next 1M maxsize 1024M online;
