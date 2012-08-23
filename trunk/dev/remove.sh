#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
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

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${SYS_CONNECT_STRING} as sysdba
   drop role ${TESTNAME}_app;
   drop role ${TESTNAME}_dml;
   drop user ${TESTNAME} cascade;
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

for FILE in setup.log \
            test.log \
            install_db_sec.sql \
            install_gui.sql \
            install_mt.sql \
            install_mt_sec.sql \
            install_usr.sql \
            uninstall_mt.sql \
            uninstall_usr.sql \
            comp.LST \
            dtgen_dataload.log \
            dtgen_dataload.bad \
            dtgen_dataload2.ctl \
            dtgen_dataload2.log \
            dtgen_dataload2.bad \
            install_gui.LST \
            cleanup.log \
do
   echo "Removing ${FILE} ..."
   rm ${FILE}
done >> ${logfile} 2>&1

echo "$0 Complete"
