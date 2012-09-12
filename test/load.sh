#!/bin/bash

#
#  load.sh - Linux (or Cygwin for Windows) script to load the DTGen test
#

. ./t.env

if [ ${OWNER_CONNECT_STRING-NULL} = "NULL" -o \
     ${OWNERNAME-NULL}            = "NULL" -o \
     ${USER_CONNECT_STRING-NULL}  = "NULL" -o \
     ${USERNAME-NULL}             = "NULL" -o \
     ${GUI_DIR-NULL}              = "NULL" -o \
     ${logfile-NULL}              = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   connect ${OWNER_CONNECT_STRING}
   set serveroutput on format wrapped
   set feedback off
   set linesize 4000
   set pagesize 0
   set trimspool on
   set verify off
   -- set termout off - This doesn't work with redirected output
   set sqlprompt "-- "
   set sqlcontinue "-- "
   spool install_owner.sql
   execute test_gen.output_all('install', '${OWNERNAME}');
   spool uninstall_owner.sql
   execute test_gen.output_all('uninstall', '${OWNERNAME}');
   spool install_user.sql
   execute test_gen.output_all('install', '${USERNAME}');
   spool uninstall_user.sql
   execute test_gen.output_all('uninstall', '${USERNAME}');
   spool off
   set sqlprompt "SQL> "
   set sqlcontinue "> "
   -- set termout on
   set verify on
   set pagesize 20
   set linesize 80
   set feedback 6
   spool install_owner.log
   connect ${OWNER_CONNECT_STRING}
   @install_owner
   @../comp
   spool install_user.log
   connect ${USER_CONNECT_STRING}
   @install_user
   spool off
   exit
EOF

echo "*** install_owner.gold comparison ..."
sdiff -s -w 80 install_owner.gold install_owner.log | ${SORT} -u | head

echo "*** install_user.gold comparison ..."
sdiff -s -w 80 install_user.gold install_user.log | ${SORT} -u | head

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} > ${logfile} 2>&1 <<EOF
#   @gui_comp
#EOF
#
#fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"

