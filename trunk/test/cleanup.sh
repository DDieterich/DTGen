#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

. ./t.env

if [ ${MT_USER_CONNECT-NULL}   = "NULL" -o \
     ${MT_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${DB_LINK_NAME-NULL}      = "NULL" -o \
     ${DB_USER_CONNECT-NULL}   = "NULL" -o \
     ${DB_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${GUI_DIR-NULL}           = "NULL" -o \
     ${DB_LINK_NAME-NULL}      = "NULL" -o \
     ${logfile-NULL}           = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   @uninstall_user ${MT_USER_CONNECT} mt
   @uninstall_mt_schema ${MT_SCHEMA_CONNECT} ${DB_LINK_NAME}
   @uninstall_user ${DB_USER_CONNECT} db
   @uninstall_db_schema ${DB_SCHEMA_CONNECT}
   exit

EOF

echo "*** uninstall_mt_user.gold comparison ..."
sdiff -s -w 80 uninstall_mt_user.gold uninstall_mt_user.log | ${SORT} -u | head

echo "*** uninstall_mt_schema.gold comparison ..."
sdiff -s -w 80 uninstall_mt_schema.gold uninstall_mt_schema.log | ${SORT} -u | head

echo "*** uninstall_db_user.gold comparison ..."
sdiff -s -w 80 uninstall_db_user.gold uninstall_db_user.log | ${SORT} -u | head

echo "*** uninstall_db_schema.gold comparison ..."
sdiff -s -w 80 uninstall_db_schema.gold uninstall_db_schema.log | ${SORT} -u | head

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
#   @gui_uncomp
#EOF
#fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head
#cd ${OLDPWD}

echo "$0 Complete"
