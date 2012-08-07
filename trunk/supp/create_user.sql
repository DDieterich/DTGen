
--
-- Create User Sample Script
-- (Must be run as the "system" or "sys as sysdba" user)
--
define OWNERNAME = &1.   -- New Schema Owner Name
define OWNERPASS = &2.   -- New Schema Owner Password
define USERNAME  = &3.   -- New Application User Name
define USERPASS  = &4.   -- New Application User Password
--

set define '&'
set serveroutput on format wrapped

-- Initialize Variables
--

create user &3. identified by &4.
   default tablespace users;

grant connect to &3.;
grant create synonym to &3.;
grant &1._app to &3.;

connect &3./&4.
set serveroutput on format wrapped
@install_usyn
