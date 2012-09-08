#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
#     DTGen application testing logins
#

. ./t.env

if [ ${SYS_CONNECT_STRING-NULL} = "NULL" -o \
     ${OWNERNAME-NULL}          = "NULL" -o \
     ${USERNAME-NULL}           = "NULL" -o \
     ${logfile-NULL}            = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus ${SYS_CONNECT_STRING} as sysdba > ${logfile} 2>&1 <<EOF
   @../../supp/drop_user ${USERNAME}
   @../../supp/drop_owner ${OWNERNAME}
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
