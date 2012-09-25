#!/bin/bash

#
#  test.sh - Linux (or Cygwin for Windows) script to test the test application
#

. ./t.env

if [ ${OWNER_CONNECT_STRING-NULL} = "NULL" -o \
     ${OWNERNAME-NULL}            = "NULL" -o \
     ${USER_CONNECT_STRING-NULL}  = "NULL" -o \
     ${USERNAME-NULL}             = "NULL" -o \
     ${logfile-NULL}              = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   set echo on
   set trimspool on
   set linesize 4000
   prompt ****************************************
   prompt ***  ${OWNERNAME}
   connect ${OWNER_CONNECT_STRING}
   @../test
   prompt ****************************************
   prompt ***  ${USERNAME}
   connect ${USER_CONNECT_STRING}
   @../test
   exit
EOF

echo "*** ${logfile}.gold comparison ..."
sdiff -s -w 80 ${logfile}.gold ${logfile} | fgrep -v 'SQL*Plus: Release' | ${SORT} -u | head

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
