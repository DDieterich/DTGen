#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
#     DTGen application testing logins
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${SYSNAME}/${SYSPASS}@${TNS_ALIAS} as sysdba
   drop role ${DEMONAME}_app;
   drop role ${DEMONAME}_dml;
   drop user ${DEMONAME} cascade;
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
