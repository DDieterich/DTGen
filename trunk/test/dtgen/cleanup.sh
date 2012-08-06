#!/bin/bash

#
#  cleanup.sh - Linux (or Cygwin for Windows) script to cleanup the
#     DTGen application after testing
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"
exit

sqlplus dtgen/dtgen@${TNS_ALIAS} @uninstall_db > cleanup.log 2>&1

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- cleanup.log

echo "$0 Complete"
