create or replace package assemble as

   type vc2_list_type
      is table of varchar2(30);
   vc2_list  vc2_list_type;
   type aa_vc2_type
      is table of vc2_list_type
      index by varchar2(6);
   aa_vc2  aa_vc2_type;
   
   rclob   clob;

   function install_script
         (app_abbr_in  in  varchar2
         ,aa_key_in    in  varchar2
         ,suffix_in    in  varchar2 default '')
      return clob;
   procedure install_script
         (app_abbr_in  in  varchar2
         ,aa_key_in    in  varchar2
         ,suffix_in    in  varchar2 default '');

   function uninstall_script
         (app_abbr_in  in  varchar2
         ,aa_key_in    in  varchar2
         ,suffix_in    in  varchar2 default '')
      return clob;
   procedure uninstall_script
         (app_abbr_in  in  varchar2
         ,aa_key_in    in  varchar2
         ,suffix_in    in  varchar2 default '');

   procedure data_script
         (app_abbr_in  in  varchar2);
   function data_script
         (app_abbr_in  in  varchar2)
      return clob;

end assemble;