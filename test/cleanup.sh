#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

. ./t.env

if [ ${USER_CONNECT_STRING-NULL}  = "NULL" -o \
     ${OWNER_CONNECT_STRING-NULL} = "NULL" -o \
     ${GUI_DIR-NULL}              = "NULL" -o \
     ${logfile-NULL}              = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${USER_CONNECT_STRING}
   ALTER SESSION SET recyclebin = OFF;
   @uninstall_user
   connect ${OWNER_CONNECT_STRING}
   ALTER SESSION SET recyclebin = OFF;
   @uninstall_owner
EOF

echo "cleanup.gold comparison ..."
sdiff -s -w 80 cleanup.gold cleanup.log | fgrep -v 'SQL*Plus: Release '

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
#   @gui_uncomp
#EOF
#
#fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
