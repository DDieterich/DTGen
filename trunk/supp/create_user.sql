
REM
REM Create User Sample Script
REM (Must be run as the "system" or "sys as sysdba" user)
REM

set define '&'
set verify off
set trimspool on
set feedback on

REM Initialize Variables
REM
define OWNERNAME = &1.   -- New Schema Owner Name
define OWNERPASS = &2.   -- New Schema Owner Password
define USERNAME  = &3.   -- New Application User Name
define USERPASS  = &4.   -- New Application User Password

spool create_&OWNERNAME._user_&USERNAME.

create user &USERNAME. identified by &USERPASS.
   default tablespace users
   temporary tablespace temp;

grant connect to &USERNAME.;
grant create synonym to &USERNAME.;
grant &OWNERNAME._app to &USERNAME.;

connect &OWNERNAME./&OWNERPASS.
@create_usyn &OWNERNAME.

spool off

set verify on
