create package test_rig
is

   function DTC_INSERT_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_INSERT_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_INSERT_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

   function DTC_UPDATE_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2;

end test_rig;
/
