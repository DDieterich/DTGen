#!/bin/bash

#
#  t.sh - Linux (or Cygwin for Windows) script to test the DTGen application
#

# Set the Oracle environment for the database connection
#export oracle_home=
#export oracle_sid=
export TNS_ALIAS="XE2"

# Set directory list
DIR_LIST="dtgen"

function show_usage () {
   echo "Use the form: t.sh (setup|test|cleanup|remove)"
   }

# Check Parameters
#
if [ ${#} != 1 ]
then
   show_usage;
   exit -1
fi
if [ ${1} != "setup" -a ${1} != "test" -a ${1} != "cleanup" -a ${1} != "remove" ]
then
   show_usage;
   exit -1
fi

for TDIR in ${DIR_LIST}
do
   echo
   echo "${TDIR} ..."
   cd "${TDIR}"
   # Some scripts need the sys login
   ./${1}.sh sys oracle7
   cd ..
done
