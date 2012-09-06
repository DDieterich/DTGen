
--
-- Create Schema Owner Script
-- (Must be run as the "sys as sysdba" user)
--
-- &1. - New Schema Owner Name
-- &2. - New Schema Owner Password
-- &3. - New Schema Owner Default Tablespace
--

set define '&'
set serveroutput on format wrapped

-- Create New Schema Owner
--
create user &1. identified by &2.
   default tablespace &3.;

alter user &1.
   quota unlimited on &3.;

-- Create New Schema Roles
--
create role &1._dml;
create role &1._app;
grant &1._app to &1._dml;

-- Common to both DB and MT
--
grant connect to &1.;
grant resource to &1.;
grant create view to &1.;
grant DEBUG CONNECT SESSION to &1.;
grant DEBUG ANY PROCEDURE to &1.;

-- Only used by DB (Un-tested)
--
grant execute on DBMS_LOCK to &1.;

-- Only used by MT (Un-tested)
--
grant create database link to &1.;
grant create materialized view to &1.;
grant create synonym to &1.;
