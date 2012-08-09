#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
#     DTGen application testing logins
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${SYSNAME}/${SYSPASS}@${TNS_ALIAS} as sysdba
   drop role ${TESTNAME}_app;
   drop role ${TESTNAME}_dml;
   drop user ${TESTNAME} cascade;
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

for SQLFILE in install_db_sec \
               install_gui \
               install_mt \
               install_mt_sec \
               install_usr \
               uninstall_mt \
               uninstall_usr \
do
   rm ${SQLFILE}.sql
done >> ${logfile} 2>&1

echo "$0 Complete"
