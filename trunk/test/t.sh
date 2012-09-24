#!/bin/bash

#
#  t.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

# Set the Oracle environment for the database connection
export TNS_ALIAS=DEMO1
export TNS_ALIAS=XE2
DEV_PROD="DEV"
if [ ${DEV_PROD} = "PROD" ]
then
   export GUI_DIR=../../gui
   export DEVNAME=dtgen
   export DEVPASS=dtgen
else
   export GUI_DIR=../../dev/gui
   export DEVNAME=dtgen_dev
   export DEVPASS=dtgen_dev
fi
export TESTNAME=dtgen_test
export TESTPASS=dtgen_test
export DB_LINK_NAME="XE@loopback"
export DB_USING_STR="'loopback'"
export logfile="${1}.log"

# Pickup the CygWin sort instead of the Windows sort
export SORT="/usr/bin/sort"

# Set directory list
DIR_LIST="DB_Integ MT_Integ DODMT_Integ DB_NoInteg MT_NoInteg DODMT_NoInteg"

# Set Connect Strings
export DEV_CONNECT_STRING=${DEVNAME}/${DEVPASS}
if [ ${TNS_ALIAS-NULL} != "NULL" ]
then
   DEV_CONNECT_STRING=${DEV_CONNECT_STRING}@${TNS_ALIAS}
fi
export TEST_CONNECT_STRING=${TESTNAME}/${TESTPASS}
if [ ${TNS_ALIAS-NULL} != "NULL" ]
then
   TEST_CONNECT_STRING=${CONNECT_STRING}@${TNS_ALIAS}
fi

function show_usage () {
   echo "Use the form: t.sh (setup|load|test|cleanup|remove|-p) {test directory}"
   }

# Check Number of Parameters
if [ ${#} -ne 1 -a ${#} -ne 2 ]
then
   echo "Incorrect number of parameters: ${#}"
   show_usage;
   exit -1
fi

# Check First Parameter
if [ "${1}" != "setup" -a "${1}" != "load" -a "${1}" != "test" -a "${1}" != "cleanup" -a "${1}" != "remove" -a "${1}" != "-p" ]
then
   echo "Incorrect first parameter: ${1}"
   show_usage;
   exit -2
fi

# Check Environment Files
if [ ${#} -eq 1 ]
then
   for TDIR in ${DIR_LIST}
   do
      if [ ! -r "${TDIR}/t.env" ]
      then
         echo "Script is not readable: ${TDIR}/t.env"
         show_usage;
         exit -3
      fi
   done
else
   if [ ! -r "${2}/t.env" ]
   then
      echo "Script is not readable: ${2}/t.env"
      show_usage;
      exit -3
   fi
fi

#  Print the Environment Files
if [ ${1} = "-p" ]
then
   echo ""
   echo "Common Environment for ${0}:"
   echo "TNS_ALIAS = ${TNS_ALIAS}"
   echo "TNS_ALIAS = ${TNS_ALIAS}"
   echo "SYSNAME   = ${SYSNAME}"
   echo "SYSPASS   = ${SYSPASS}"
   echo "GUI_DIR   = ${GUI_DIR}"
   echo "DEVNAME   = ${DEVNAME}"
   echo "DEVPASS   = ${DEVPASS}"
   echo "TESTNAME  = ${TESTNAME}"
   echo "TESTPASS  = ${TESTPASS}"
   echo "logfile   = ${logfile}"
   echo "SYS_CONNECT_STRING  = ${SYS_CONNECT_STRING}"
   echo "DEV_CONNECT_STRING  = ${DEV_CONNECT_STRING}"
   echo "TEST_CONNECT_STRING = ${TEST_CONNECT_STRING}"
   if [ ${#} -eq 1 ]
   then
      for TDIR in ${DIR_LIST}
      do
         echo ""
         echo "Environment for ${TDIR}:"
         . ${TDIR}/t.env -p
      done
   else
      echo ""
      echo "Environment for ${2}:"
      . ${2}/t.env -p
   fi
   exit 0
fi

# Check the script files
if [ ! -x "${1}.sh" ]
then
   echo "Script is not executable: ${TDIR}/${1}.sh"
   show_usage;
   exit -4
fi

# Capture the SYS Password and Set Connect String
if [ ${1} = "setup" -o ${1} = "remove" ]
then
   SYSNAME=sys
   read -sp "Enter the '${SYSNAME}' password:" SYSPASS
   echo
   export SYS_CONNECT_STRING=${SYSNAME}/${SYSPASS}
   if [ ${TNS_ALIAS-NULL} != "NULL" ]
   then
      SYS_CONNECT_STRING=${SYS_CONNECT_STRING}@${TNS_ALIAS}
   fi
   if [ `echo "exit" | sqlplus ${SYS_CONNECT_STRING} as sysdba |
         grep "^Connected to:" | wc -l` -ne 1 ]
   then
      echo "Invalid '${SYSNAME}' password"
      exit -5
   fi
fi

function run_script () {
   echo
   echo "${2} ..."
   cd "${2}"
   ../${1}.sh
   cd ..
   }

if [ ${#} -eq 1 ]
then
   for TDIR in ${DIR_LIST}
   do
      run_script ${1} "${TDIR}"
   done
else
   run_script ${1} "${2}"
fi
