#!/bin/bash

#
#  load.sh - Linux (or Cygwin for Windows) script to load the DTGen test
#

. ./t.env

if [ ${DB_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${DB_SCHEMA-NULL}         = "NULL" -o \
     ${DB_SPASS-NULL}          = "NULL" -o \
     ${DB_USER_CONNECT-NULL}   = "NULL" -o \
     ${DB_USER-NULL}           = "NULL" -o \
     ${MT_SCHEMA_CONNECT-NULL} = "NULL" -o \
     ${MT_SCHEMA-NULL}         = "NULL" -o \
     ${MT_USER_CONNECT-NULL}   = "NULL" -o \
     ${MT_USER-NULL}           = "NULL" -o \
     ${GUI_DIR-NULL}           = "NULL" -o \
     ${DB_LINK_NAME-NULL}      = "NULL" -o \
     ${DB_USING_STR-NULL}      = "NULL" -o \
     ${APP_ABBR-NULL}          = "NULL" -o \
     ${logfile-NULL}           = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   @load ${APP_ABBR} ${DEV_CONNECT_STRING}
   @install_db_schema ${DB_SCHEMA_CONNECT} ${MT_SCHEMA} ${APP_ABBR} ${DB_USER}
   @install_user ${DB_USER_CONNECT} db ${DB_SCHEMA}
   @install_mt_schema ${MT_SCHEMA_CONNECT} ${DB_LINK_NAME} ${DB_SCHEMA} ${DB_SPASS} ${DB_USING_STR} ${APP_ABBR} ${MT_USER}
   @install_user ${MT_USER_CONNECT} mt ${MT_SCHEMA}
   exit
EOF

echo "*** install_db_schema.gold comparison ..."
sdiff -s -w 80 install_db_schema.gold install_db_schema.log | ${SORT} -u | head

echo "*** install_db_user.gold comparison ..."
sdiff -s -w 80 install_db_user.gold install_db_user.log | ${SORT} -u | head

echo "*** install_mt_schema.gold comparison ..."
sdiff -s -w 80 install_mt_schema.gold install_mt_schema.log | ${SORT} -u | head

echo "*** install_mt_user.gold comparison ..."
sdiff -s -w 80 install_mt_user.gold install_mt_user.log | ${SORT} -u | head

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} >> ${logfile} 2>&1 <<EOF
#   @gui_comp
#EOF
#fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head
#cd ${OLDPWD}

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
