#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus ${OWNERNAME}/${OWNERPASS}@${TNS_ALIAS} > ${logfile} 2>&1 <<EOF
   @uninstall_db
EOF

# for SQLFILE in install_db_sec \
#                install_gui \
#                install_mt \
#                install_mt_sec \
#                install_usr \
#                uninstall_mt \
#                uninstall_usr \
# do
#    rm ${SQLFILE}.sql
# done >> ${logfile} 2>&1

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
