#!/bin/bash

#
#  setup.sh - Linux (or Cygwin for Windows) script to setup the
#     DTGen application testing logins
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"
exit

# Must be run as the "sys as sysdba" user
sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${1}/${2}@${TNS_ALIAS} as sysdba
   @../supp/create_owner ${OWNERNAME} ${OWNERPASS} users
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
