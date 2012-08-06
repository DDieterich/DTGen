#!/bin/bash

#
#  test.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

echo "$0: TNS_ALIAS = ${TNS_ALIAS}"
exit

sqlplus /nolog @test > ${logfile} 2>&1 <<EOF
   WHENEVER SQLERROR EXIT SQL.SQLCODE
   WHENEVER OSERROR EXIT -1
   set define '&'
   set trimspool on
   set serveroutput on format wrapped
   set verify off
   connect ${GENNAME}/${GENPASS}@${TNS_ALIAS}
   prompt
   prompt Generating DTGEN ...
   @../../supp/fullgen DTGEN
   @../../supp/fullasm DTGEN
   connect ${OWNERNAME}/${OWNERPASS}@${TNS_ALIAS}
   prompt
   prompt Running installation ...
   @install_db
   @comp
EOF
if [ ${?} != 0 ]
then
   tail -20 ${logfile}
   exit ${?}
fi
if [ `fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} |
         tee /dev/tty | wc -l` != 0 ]
then
   tail -20 ${logfile}
   exit -1
fi

sqlldr ${OWNERNAME}/${OWNERPASS}@${TNS_ALIAS} CONTROL=dtgen_dataload.ctl >> ${logfile} 2>&1
if [ ${?} != 0 ]
then
   tail -20 dtgen_dataload.log
   exit ${?}
fi
if [ `fgrep -e " 0 Rows successfully loaded" 2>&1 |
         tee /dev/tty | wc -l` != 0 ]
then
   tail -20 dtgen_dataload.log
   exit -1
fi
if [ `fgrep -e "Rows not loaded due to data errors" \
            -e "Rows not loaded because all fields were null" \
            dtgen_dataload.log 2>&1 |
         fgrep -v '0 ' 2>&1 | tee /dev/tty | wc -l` != 0 ]
then
   tail -20 dtgen_dataload.log
   exit -1
fi

echo "$0 Complete"
