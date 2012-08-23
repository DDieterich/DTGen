#!/bin/bash

#
#  d.sh - Linux (or Cygwin for Windows) script to test generate the DTGen application
#

# Check Parameters
#
function show_usage () {
   echo "Use the form: d.sh (setup|test|cleanup|remove) {test directory}"
   }
if [ ${#} -ne 1 ]
then
   echo "Incorrect number of parameters: ${#}"
   show_usage;
   exit -1
fi
if [ "${1}" != "setup"   -a \
     "${1}" != "test"    -a \
     "${1}" != "cleanup" -a \
     "${1}" != "remove"  ]
then
   echo "Incorrect first parameter: ${1}"
   show_usage;
   exit -2
fi
if [ ! -r "./d.env" ]
then
   echo "Script is not readable: ./d.env"
   show_usage;
   exit -3
fi
if [ ! -x "./${1}.sh" ]
then
   echo "Script is not executable: ./${1}.sh"
   show_usage;
   exit -4
fi

# Set the environment for the database connection
. ./d.env

# Get SYS Password, if needed
if [ ${1} = "setup"  -o \
     ${1} = "remove" ]
then
   if [ "${SYSPASS:-"NULL"}" = "NULL" ]
   then
      read -sp "Enter the '${SYSNAME}' password:" SYSPASS
      echo
   fi
   if [ `echo "exit" | sqlplus ${SYSNAME}/${SYSPASS}@${TNS_ALIAS} as sysdba |
         grep "^Connected to:" | wc -l` -ne 1 ]
   then
      echo "Invalid '${SYSNAME}' password"
      exit -5
   fi
fi

./${1}.sh
