#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus ${TESTNAME}/${TESTPASS}@${TNS_ALIAS} > ${logfile} 2>&1 <<EOF
   @uninstall_db
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
