#!/bin/bash

#
#  t.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

# Check Parameters
#
function show_usage () {
   echo "Use the form: t.sh (setup|test|cleanup|remove) {test directory}"
   }
if [ ${#} -ne 1 -a ${#} -ne 2 ]
then
   show_usage;
   exit -1
fi
if [ "${1}" != "setup" -a "${1}" != "test" -a "${1}" != "cleanup" -a "${1}" != "remove" ]
then
   show_usage;
   exit -2
fi
if [ ${#} -eq 2 ]
then
   if [ ! -x "${2}/${1}.sh" ]
   then
      show_usage;
      exit -3
   fi
fi

# Set the Oracle environment for the database connection
#export oracle_home=
#export oracle_sid=
export TNS_ALIAS="XE2"
export GENNAME=dtgen
export GENPASS=dtgen
export SYSPASS=""
if [ ${1} = "setup" -o ${1} = "remove" ]
then
   export SYSNAME=sys
   if [ "${SYSPASS:-"NULL"}" = "NULL" ]
   then
      read -sp "Enter the '${SYSNAME}' password:" SYSPASS
      echo
   fi
   if [ `echo "exit" | sqlplus ${SYSNAME}/${SYSPASS}@${TNS_ALIAS} as sysdba |
         grep "^Connected to:" | wc -l` -ne 1 ]
   then
      echo "Invalid '${SYSNAME}' password"
      exit -4
   fi
fi

# Set directory list
DIR_LIST="dtgen demo/basics"

function run_script () {
   echo
   echo "${2} ..."
   cd "${2}"
   # Some scripts need the sys login
   ./${1}.sh
   cd "${OLDPWD}"
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
