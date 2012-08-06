#!/bin/bash

#
#  t.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

# Set the Oracle environment for the database connection
#export oracle_home=
#export oracle_sid=
export TNS_ALIAS="XE2"
export GENNAME=dtgen
export GENPASS=dtgen

# Set directory list
DIR_LIST="dtgen"

function show_usage () {
   echo "Use the form: t.sh (setup|test|cleanup|remove) {test directory}"
   }

function run_script () {
   echo
   echo "${2} ..."
   cd "${2}"
   # Some scripts need the sys login
   ./${1}.sh sys oracle7
   cd ..
   }
# Check Parameters
#
if [ ${#} -ne 1 -a ${#} -ne 2 ]
then
   show_usage;
   exit -1
fi
if [ ${1} != "setup" -a ${1} != "test" -a ${1} != "cleanup" -a ${1} != "remove" ]
then
   show_usage;
   exit -2
fi
if [ ${#} -eq 1 ]
then
   for TDIR in ${DIR_LIST}
   do
      run_script ${1} ${TDIR}
   done
else
   if [ ! -d ${2} ]
   then
      show_usage;
      exit -3
   else
      run_script ${1} ${2}
   fi
fi
