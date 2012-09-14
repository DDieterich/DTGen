#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

. ./t.env

if [ ${USER_CONNECT_STRING-NULL}  = "NULL" -o \
     ${OWNER_CONNECT_STRING-NULL} = "NULL" -o \
     ${GUI_DIR-NULL}              = "NULL" -o \
     ${DB_LINK_NAME-NULL}         = "NULL" -o \
     ${logfile-NULL}              = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

# NOTE: There is a CREATE_DBLINK in load.sh
DROP_DBLINK=""
if [ ${OWNERNAME} = 'TMTST' ]
then
   DROP_DBLINK="drop database link ${DB_LINK_NAME};"
fi
if [ ${OWNERNAME} = 'TMTSTDOD' ]
then
   DROP_DBLINK="drop database link ${DB_LINK_NAME};"
fi
if [ ${OWNERNAME} = 'TMTSN' ]
then
   DROP_DBLINK="drop database link ${DB_LINK_NAME};"
fi
if [ ${OWNERNAME} = 'TMTSNDOD' ]
then
   DROP_DBLINK="drop database link ${DB_LINK_NAME};"
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   spool uninstall_user.log
   connect ${USER_CONNECT_STRING}
   ALTER SESSION SET recyclebin = OFF;
   @uninstall_user
   spool uninstall_owner.log
   connect ${OWNER_CONNECT_STRING}
   ALTER SESSION SET recyclebin = OFF;
   @uninstall_owner
   ${DROP_DBLINK}
EOF

echo "*** uninstall_user.gold comparison ..."
sdiff -s -w 80 uninstall_user.gold uninstall_user.log | ${SORT} -u | head

echo "*** uninstall_owner.gold comparison ..."
sdiff -s -w 80 uninstall_owner.gold uninstall_owner.log | ${SORT} -u | head

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
#   @gui_uncomp
#EOF
#
#fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
