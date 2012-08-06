#!/bin/bash

#
#  remove.sh - Linux (or Cygwin for Windows) script to remove the
#     DTGen application testing logins
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"
exit

sqlplus /nolog > remove.log 2>&1 <<EOF
   connect ${1}/${2}@${TNS_ALIAS} as sysdba
   drop role dtgen_test_app;
   drop role dtgen_test_dml;
   drop user dtgen_test cascade;
EOF

fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- remove.log

echo "$0 Complete"
