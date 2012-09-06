#!/bin/bash

#
#  setup.sh - Linux (or Cygwin for Windows) script to setup the
#     DTGen application testing logins
#

. ./t.env

if [ ${SYS_CONNECT_STRING-NULL} = "NULL" -o \
     ${TESTNAME-NULL}           = "NULL" -o \
     ${OWNERNAME-NULL}          = "NULL" -o \
     ${OWNERPASS-NULL}          = "NULL" -o \
     ${USERNAME-NULL}           = "NULL" -o \
     ${USERPASS-NULL}           = "NULL" -o \
     ${logfile-NULL}            = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

# Must be run as the "sys as sysdba" user
sqlplus ${SYS_CONNECT_STRING-NULL} as sysdba > ${logfile} 2>&1 <<EOF
   @../../supp/create_owner ${OWNERNAME} ${OWNERPASS} users
   @../create_ut_syns ${OWNERNAME} ${TESTNAME}
   @../../supp/create_user ${USERNAME} ${USERPASS} ${OWNERNAME}
   @../create_ut_syns ${USERNAME} ${TESTNAME}
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
