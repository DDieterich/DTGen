
--
--  fullgen.sql - Script used to generate scripts for an application
--
-- &1. is the DTGEN application abbreviation
--

set define '&'
set serveroutput on format wrapped

prompt
prompt Running fullgen ...

BEGIN

   /*  Initialize  */
   util.set_usr('Initial Load');  -- Any string will work for this parameter
   generate.init('&1.');

   /*  Drop/Delete Scripts  */
   generate.drop_usyn;
   generate.drop_mods;
   generate.drop_oltp;
   generate.drop_dist;
   generate.drop_aa;
   generate.drop_integ;
   generate.delete_ods;
   generate.drop_ods;
   generate.drop_gusr;
   generate.drop_gdst;
   generate.drop_glob;

   /*  Create Scripts  */
   generate.create_glob;
   generate.create_gdst;
   generate.create_gusr;
   generate.create_ods;
   generate.create_integ;
   generate.create_aa;
   generate.create_dist;
   generate.create_oltp;
   generate.create_mods;
   generate.create_usyn;

   /*  Create GUI Script  */
   generate.create_flow;

END;
/

commit;
