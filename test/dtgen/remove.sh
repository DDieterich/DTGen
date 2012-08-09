#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
#     DTGen application testing logins
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${SYSNAME}/${SYSPASS}@${TNS_ALIAS} as sysdba
   drop role ${OWNERNAME}_app;
   drop role ${OWNERNAME}_dml;
   drop user ${OWNERNAME} cascade;
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
