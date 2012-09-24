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
     ${DB_LINK_NAME-NULL}         = "NULL" -o \
     ${DB_USING_STR-NULL}         = "NULL" -o \
     ${logfile-NULL}              = "NULL" ]
then
  echo "This script should not be run stand-alone.  Run t.sh instead."
  exit -1
fi

# NOTE: There is a DROP_DBLINK in cleanup.sh
CREATE_DBLINK=""
if [ ${OWNERNAME} = 'TMTST' ]
then
   CREATE_DBLINK="create database link ${DB_LINK_NAME} connect to TDBST identified by \"TDBST\" using ${DB_USING_STR};"
fi
if [ ${OWNERNAME} = 'TMTSTDOD' ]
then
   CREATE_DBLINK="create database link ${DB_LINK_NAME} connect to TDBUT identified by \"TDBUT\" using ${DB_USING_STR};"
fi
if [ ${OWNERNAME} = 'TMTSN' ]
then
   CREATE_DBLINK="create database link ${DB_LINK_NAME} connect to TDBSN identified by \"TDBSN\" using ${DB_USING_STR};"
fi
if [ ${OWNERNAME} = 'TMTSNDOD' ]
then
   CREATE_DBLINK="create database link ${DB_LINK_NAME} connect to TDBUN identified by \"TDBUN\" using ${DB_USING_STR};"
fi

# This may be a bug in Oracle11g Express Edition...
#   These grants should not be necessary when using private fixed
#   user database links.  The bug appears to be dependent on the
#   use of "loopback" in that permissions over the database link
#   are confused with permissions not over the database link for
#   database objects with the same name.  This is particularly
#   true to SQL submitted to the database, as opposed to PL/SQL
#   submitted to the database.
function setup_grant_execute () {
   GRANT_EXECUTE="${GRANT_EXECUTE}
grant execute on glob to ${1};
begin
   FOR buff in (
      select table_name from user_tab_privs
       where grantor    = USER
        and  privilege  = 'EXECUTE'
        and  table_name like '%_POP' )
   loop
      execute immediate 'grant execute on ' ||
         buff.table_name || ' to ${1}';
   end loop;
end;
/
begin
   FOR buff in (
      select table_name from user_tab_privs
       where grantor    = USER
        and  privilege  = 'UPDATE'
        and  table_name not like '%~_ACT' escape '~' )
   loop
      execute immediate 'grant select, insert, update, delete on ' ||
         buff.table_name || ' to ${1}';
   end loop;
end;
/"
   }
# This explicit grant is required to allow the application user to
#   create packages on owner objects
function setup_grant_option () {
   GRANT_OPTION="${GRANT_OPTION}
begin
   FOR buff in (
      select * from user_tab_privs
       where grantor    = USER
        and  grantee    = 'TST1_APP' )
   loop
      execute immediate 'grant ' || buff.privilege ||
                          ' on ' || buff.table_name ||
                          ' to ${1} with grant option';
   end loop;
end;
/"
   }
GRANT_EXECUTE=""
GRANT_OPTION=""
if [ ${OWNERNAME} = 'TDBST' ]
then
   setup_grant_execute 'TMTST'
   setup_grant_execute 'TMTSTDOD' 
   setup_grant_option 'TDBUT'
fi
if [ ${OWNERNAME} = 'TDBSN' ]
then
   setup_grant_execute 'TMTSN'
   setup_grant_execute 'TMTSNDOD'
   setup_grant_option 'TDBUN'
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
   ${CREATE_DBLINK}
   @install_owner
   @../comp
   @../install_test_rig
   ${GRANT_EXECUTE}
   spool install_user.log
   connect ${USER_CONNECT_STRING}
   @install_user
   @../install_test_rig
   spool off
   exit
EOF

echo "*** install_owner.gold comparison ..."
sdiff -s -w 80 install_owner.gold install_owner.log | ${SORT} -u | head

echo "*** install_user.gold comparison ..."
sdiff -s -w 80 install_user.gold install_user.log | ${SORT} -u | head

#cd ${GUI_DIR}
#sqlplus ${OWNER_CONNECT_STRING} >> ${logfile} 2>&1 <<EOF
#   @gui_comp
#EOF

echo "*** Errors and Warnings ..."
fgrep -i -e fail -e warn -e ora- -e sp2- -e pls- ${logfile} | ${SORT} -u | head

echo "$0 Complete"

