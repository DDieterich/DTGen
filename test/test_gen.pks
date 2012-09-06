create or replace package test_gen
is

type file_nt_type is table
   of file_lines_asof.files_nk2%TYPE;
type app_file_aa_type is table
    of file_nt_type
    index by file_lines_asof.files_nk1%TYPE;
type user_rec_type is record
   (db_schema    applications_act.db_schema%TYPE
   ,dbid         applications_act.dbid%TYPE
   ,db_auth      applications_act.db_auth%TYPE
   ,app_file_aa  app_file_aa_type);
type user_aa_type is table
   of user_rec_type
   index by applications_act.db_schema%TYPE;
user_aa  user_aa_type;

------------------------------------------------------------
function gen_load
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2)
   return clob;

function cleanup
      (app_abbr_in     in  varchar2
      ,db_schema_in    in  varchar2
      ,file_suffix_in  in  varchar2 default null)
   return clob;

------------------------------------------------------------
procedure gen_all
      (vector_in     in  varchar2
      ,db_schema_in  in  varchar2);

procedure output_file
      (app_abbr_in   in  varchar2
      ,file_name_in  in  varchar2);

procedure output_all
      (vector_in     in  varchar2
      ,db_schema_in  in  varchar2);

end test_gen;
/
