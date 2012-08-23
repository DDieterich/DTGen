#!/bin/bash

#
#  setup.sh - Linux (or Cygwin for Windows) script to setup the
#     DTGen application testing logins
#

if [ ${SYSNAME-NULL}  = "NULL" -o \
     ${SYSPASS-NULL}  = "NULL" -o \
     ${TESTNAME-NULL} = "NULL" -o \
     ${TESTPASS-NULL} = "NULL" -o \
     ${logfile-NULL}  = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run d.sh instead."
fi

SYS_CONNECT_STRING=${SYSNAME}/${SYSPASS}
if [ ${TNS_ALIAS-NULL} != "NULL" ]
then
   SYS_CONNECT_STRING=${SYS_CONNECT_STRING}@${TNS_ALIAS}
fi

# Must be run as the "sys as sysdba" user
sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${SYS_CONNECT_STRING} as sysdba
   @../supp/create_owner ${TESTNAME} ${TESTPASS} users
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
