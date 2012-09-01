create or replace package test_gen
is

type file_list_nt_type is table
   of file_lines_asof.files_nk2%TYPE;
type user_parms_rec_type is record
   (db_schema  applications_act.db_schema%TYPE
   ,dbid       applications_act.dbid%TYPE
   ,db_auth    applications_act.db_auth%TYPE
   ,file_list_nt  file_list_nt_type);
type user_parms_aa_type is table
   of user_parms_rec_type
   index by applications_act.db_schema%TYPE;
user_parms_aa  user_parms_aa_type;

procedure gen_load
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2);

procedure cleanup
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2);

end test_gen;
/
