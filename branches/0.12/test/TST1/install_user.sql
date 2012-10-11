--
-- Install Database User
--
--  &1 - ${DB_USER_CONNECT}
--  &2 - Type of User ("db" or "mt")
--  &3 - Destination Schema for Synonyms
--

spool install_&2._user.log
connect &1.
set serveroutput on format wrapped

@create_gusr &3.
@create_usyn &3.

@install_test_rig

spool off
