create or replace package test_gen
is

type applist_nt_type is table
     of file_lines_act.files_nk1%TYPE;
applist_nt  applist_nt_type;

type fileapp_rec_type is record
     (file_name    file_lines_act.files_nk2%TYPE
     ,applist_key  varchar2(2));
type fileapp_aa_type is table
     of fileapp_rec_type
     index by PLS_INTEGER;
type action_aa_type is table
     of fileapp_aa_type
     index by varchar2(15);
type user_rec_type is record
    (db_schema  applications_act.db_schema%TYPE
    ,dbid       applications_act.dbid%TYPE
    ,db_auth    applications_act.db_auth%TYPE
    ,action_aa  action_aa_type);
type user_aa_type is table
     of user_rec_type
     index by applications_act.db_schema%TYPE;
fileapp_rec  fileapp_rec_type;
user_aa      user_aa_type;

------------------------------------------------------------
/*
function gen_load
      (app_abbr_in   in  varchar2
      ,db_schema_in  in  varchar2)
   return clob;

function cleanup
      (app_abbr_in     in  varchar2
      ,db_schema_in    in  varchar2
      ,file_suffix_in  in  varchar2 default null)
   return clob;
*/
------------------------------------------------------------
procedure gen_all
      (action_in     in  varchar2
      ,db_schema_in  in  varchar2);

procedure output_file
      (app_abbr_in   in  varchar2
      ,file_name_in  in  varchar2);

procedure output_all
      (action_in     in  varchar2
      ,db_schema_in  in  varchar2);

end test_gen;
/
