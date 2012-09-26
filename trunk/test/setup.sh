#!/bin/bash

#
#  setup.sh - Linux (or Cygwin for Windows) script to setup the
#     DTGen application testing logins
#

. ./t.env

if [ ${SYS_CONNECT_STRING-NULL} = "NULL" -o \
     ${TESTNAME-NULL}           = "NULL" -o \
     ${DB_SCHEMA-NULL}          = "NULL" -o \
     ${DB_SPASS-NULL}           = "NULL" -o \
     ${DB_USER-NULL}            = "NULL" -o \
     ${DB_UPASS-NULL}           = "NULL" -o \
     ${MT_SCHEMA-NULL}          = "NULL" -o \
     ${MT_SPASS-NULL}           = "NULL" -o \
     ${MT_USER-NULL}            = "NULL" -o \
     ${MT_UPASS-NULL}           = "NULL" -o \
     ${APP_ABBR-NULL}           = "NULL" -o \
     ${logfile-NULL}            = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

# Must be run as the "sys as sysdba" user
sqlplus ${SYS_CONNECT_STRING-NULL} as sysdba > ${logfile} 2>&1 <<EOF
   alter system set global_names=TRUE comment='Required for DTGen Mutli-Tier Testing' scope=BOTH;
   @../../supp/create_owner ${DB_SCHEMA} ${DB_SPASS} users
   @../create_ut_syns ${DB_SCHEMA} ${TESTNAME}
   @../tspace_quotas ${DB_SCHEMA}
   @../../supp/create_user ${DB_USER} ${DB_UPASS} ${DB_SCHEMA}
   @../../supp/grant_app_role ${APP_ABBR} ${DB_USER};
   @../create_ut_syns ${DB_USER} ${TESTNAME}
   @../../supp/create_owner ${MT_SCHEMA} ${MT_SPASS} users
   @../create_ut_syns ${MT_SCHEMA} ${TESTNAME}
   @../tspace_quotas ${MT_SCHEMA}
   @../../supp/create_user ${MT_USER} ${MT_UPASS} ${MT_SCHEMA}
   @../../supp/grant_app_role ${APP_ABBR} ${MT_USER};
   @../create_ut_syns ${MT_USER} ${TESTNAME}
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
