#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"
exit

. ./t.env

sqlplus ${OWNERNAME}/${OWNERPASS}@${TNS_ALIAS} @uninstall_db > ${logfile} 2>&1

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile}

echo "$0 Complete"
