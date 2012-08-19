
--
--  rebuild.sql - Script to generate the DTGen application using DTGen
--
--  Note: This will only rebuild the database tier.
--        It does not (re)build:
--          -) User Synonyms
--          -) Mid-Tier
--          -) Mid-Tier Security
--          -) Database Security
--          -) APEX GUI Maintenance Forms
--

spool test_gen

-- Configure SQL*Plus
--
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT
set define '&'
set trimspool on
set serveroutput on format wrapped
set verify off

define APP_ID = DTGEN   -- APPLICATIONS.ABBR for the Application

prompt
prompt Running generation ...

BEGIN

   /*  Initialize  */
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&APP_ID.');

   /*  Drop/Delete Scripts  */
   generate.drop_mods;
   generate.drop_oltp;
   generate.drop_integ;
   generate.drop_ods;
   generate.drop_glob;

   /*  Create Scripts  */
   generate.create_glob;
   generate.create_ods;
   generate.create_integ;
   generate.create_oltp;
   generate.create_mods;

END;
/

commit;

spool test_load

connect dtgen_test/dtgen_test@XE2
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT

@install_db
@comp

spool off

exit
