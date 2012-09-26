#!/bin/bash

#
#  test.sh - Linux (or Cygwin for Windows) script to test the test application
#

. ./t.env

if [ ${DB_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${DB_SCHEMA-NULL}         = "NULL" -o \
     ${DB_USER_CONNECT-NULL}   = "NULL" -o \
     ${DB_USER-NULL}           = "NULL" -o \
     ${MT_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${MT_SCHEMA-NULL}         = "NULL" -o \
     ${MT_USER_CONNECT-NULL}   = "NULL" -o \
     ${MT_USER-NULL}           = "NULL" -o \
     ${APP_ABBR-NULL}          = "NULL" -o \
     ${logfile-NULL}           = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

RUN_TEST=""
function run_test {
   RUN_TEST="${RUN_TEST}
   spool test_${2}.log
   prompt ****************************************
   prompt ***  ${2}
   connect ${1}
   @test
   spool off
"
}

run_test ${DB_SCHEMA_CONNECT} ${DB_SCHEMA}
run_test ${DB_USER_CONNECT}   ${DB_USER}
run_test ${MT_SCHEMA_CONNECT} ${MT_SCHEMA}
run_test ${MT_USER_CONNECT}   ${MT_USER}

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   set echo on
   set trimspool on
   set linesize 4000
   ${RUN_TEST}
   exit
EOF

echo "*** test_${DB_SCHEMA}.gold comparison ..."
sdiff -s -w 80 test_${DB_SCHEMA}.gold test_${DB_SCHEMA}.log | ${SORT} -u | head

echo "*** test_${DB_USER}.gold comparison ..."
sdiff -s -w 80 test_${DB_USER}.gold test_${DB_USER}.log | ${SORT} -u | head

echo "*** test_${MT_SCHEMA}.gold comparison ..."
sdiff -s -w 80 test_${MT_SCHEMA}.gold test_${MT_SCHEMA}.log | ${SORT} -u | head

echo "*** test_${MT_USER}.gold comparison ..."
sdiff -s -w 80 test_${MT_USER}.gold test_${MT_USER}.log | ${SORT} -u | head

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
