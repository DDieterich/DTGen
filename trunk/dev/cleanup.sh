#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

if [ ${TESTNAME-NULL} = "NULL" -o \
     ${TESTPASS-NULL} = "NULL" -o \
     ${logfile-NULL}  = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run d.sh instead."
  exit -1
fi

TEST_CONNECT_STRING=${TESTNAME}/${TESTPASS}
if [ ${TNS_ALIAS-NULL} != "NULL" ]
then
   TEST_CONNECT_STRING=${TEST_CONNECT_STRING}@${TNS_ALIAS}
fi

sqlplus ${TEST_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
   @uninstall_db
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

cd gui
sqlplus ${TEST_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
   @gui_uncomp
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
