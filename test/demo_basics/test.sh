#!/bin/bash

#
#  test.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

cd ../../demo/basics
sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${DEMONAME}/${DEMOPASS}@${TNS_ALIAS}
   @e1
   @e2
   @e3
   @e4
   @e5
   @e6
   @e7
   @e8
   @e9
EOF
if [ ${?} != 0 ]
then
   echo "SQL*Plus did not return a 0: ${?}"
   tail -20 ${logfile}
   exit ${?}
fi
if [ `fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} |
         fgrep -v "The letter case of a string has failed to meet the requirement listed." |
         tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${logfile}
   exit -1
fi

echo "$0 Complete"
