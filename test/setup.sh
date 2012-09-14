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
   alter system set global_names=TRUE comment='Required for DTGen Mutli-Tier Testing' scope=BOTH;
   @../../supp/create_owner ${OWNERNAME} ${OWNERPASS} users
   @../create_ut_syns ${OWNERNAME} ${TESTNAME}
   grant select on ${TESTNAME}.global_parms to ${OWNERNAME} with grant option;
   grant select on ${TESTNAME}.table_types to ${OWNERNAME} with grant option;
   grant select on ${TESTNAME}.parm_types to ${OWNERNAME} with grant option;
   grant select on ${TESTNAME}.test_parms to ${OWNERNAME} with grant option;
   grant select on ${TESTNAME}.test_sets to ${OWNERNAME} with grant option;
   grant select on ${TESTNAME}.all_tests to ${OWNERNAME} with grant option;
   @../../supp/create_user ${USERNAME} ${USERPASS} ${OWNERNAME}
   @../grant_app_roles ${USERNAME};
   @../create_ut_syns ${USERNAME} ${TESTNAME}
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"
