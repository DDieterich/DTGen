#!/bin/bash

#
#  test.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"

. ./t.env

sqlplus /nolog > ${logfile} 2>&1 <<EOF
   set define '&'
   set trimspool on
   set verify off
   connect ${OLDNAME}/${OLDPASS}@${TNS_ALIAS}
   WHENEVER SQLERROR EXIT SQL.SQLCODE
   WHENEVER OSERROR EXIT -1
   set serveroutput on format wrapped
   prompt
   prompt Generating DTGEN ...
   @../../supp/fullgen DTGEN
   @../../supp/fullasm DTGEN
   connect ${TESTNAME}/${TESTPASS}@${TNS_ALIAS}
   WHENEVER SQLERROR EXIT SQL.SQLCODE
   WHENEVER OSERROR EXIT -1
   set serveroutput on format wrapped
   prompt
   prompt Running installation ...
   @install_db
   @comp
EOF
if [ ${?} != 0 ]
then
   echo "SQL*Plus did not return a 0: ${?}"
   tail -20 ${logfile}
   exit ${?}
fi
if [ `fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} |
         fgrep -v "The letter case of a string has failed to meet the requirement listed." |
         tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${logfile}
   exit -1
fi

if [ -r dtgen_dataload2.ctl ]
then
   LDRCTLNAME="dtgen_dataload2"
else
   LDRCTLNAME="dtgen_dataload"
fi
sqlldr ${TESTNAME}/${TESTPASS}@${TNS_ALIAS} CONTROL=${LDRCTLNAME}.ctl >> ${logfile} 2>&1
if [ ${?} != 0 ]
then
   tail -20 ${LDRCTLNAME}.log
   exit ${?}
fi
if [ `fgrep -e " 0 Rows successfully loaded" ${LDRCTLNAME}.log 2>&1 |
         tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${LDRCTLNAME}.log
   exit -1
fi
if [ `fgrep -e "Rows not loaded due to data errors" \
            -e "Rows not loaded because all fields were null" \
            ${LDRCTLNAME}.log 2>&1 |
         fgrep -v '0 ' 2>&1 | tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${LDRCTLNAME}.log
   exit -1
fi
if [ `grep -e "^Total logical records skipped:" \
           -e "^Total logical records rejected:" \
           -e "^Total logical records discarded:" \
            ${LDRCTLNAME}.log 2>&1 |
         grep -v '        0$' 2>&1 | tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${LDRCTLNAME}.log
   exit -1
fi

echo "$0 Complete"
