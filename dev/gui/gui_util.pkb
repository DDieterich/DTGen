create or replace
package body gui_util
as
/************************************************************
DTGEN "GUI_Util" Package Body
Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/
af_blob_content blob;            -- APEX_APPLICATION_FILES
af_description  varchar2(4000);  -- APEX_APPLICATION_FILES
af_doc_size     number;          -- APEX_APPLICATION_FILES
af_flow_id      number;          -- APEX_APPLICATION_FILES
af_title        varchar2(255);   -- APEX_APPLICATION_FILES
----------------------------------------
function is_number
      (str_in  in  varchar2)
   return number
as
begin
   case to_number(str_in)
      when 1 then return 1; else return 1;
      end case;
exception
   when VALUE_ERROR then
      return 0;
   when others then
      raise;
end is_number;
----------------------------------------
function get_lockname
      (app_abbr_in  in  varchar2)
   return varchar2
is
begin
   return 'DTGen ' || app_abbr_in;
end get_lockname;
----------------------------------------
function get_column_length
      (tab_name_in  in  varchar2
      ,col_name_in  in  varchar2)
   return number
is
   col_len  number;
begin
   select char_length
    into  col_len
    from  user_tab_columns
    where table_name  = tab_name_in
     and  column_name = col_name_in;
   return col_len;
end get_column_length;
----------------------------------------
procedure update_apex_app_files
      (app_abbr_in  in  varchar2
      ,action_in    in  varchar2
      ,own_key_in   in  varchar2 default null
      ,suffix_in    in  varchar2 default null)
is
   dest_offset   number  := 1;
   src_offset    number  := 1;
   lang_context  number  := DBMS_LOB.DEFAULT_LANG_CTX;
   warning       number;
   af_id  number;
   cnt   number;
begin
   dbms_lob.trim(af_blob_content, 0);
   if lower(action_in) = 'data'
   then
      dbms_lob.converttoblob
         (af_blob_content
         ,dtgen_util.data_script(app_abbr_in)
         ,dbms_lob.lobmaxsize
         ,dest_offset
         ,src_offset
         ,dbms_lob.default_csid
         ,lang_context
         ,warning
         );
   else
      dbms_lob.converttoblob
         (af_blob_content
         ,dtgen_util.assemble_script(app_abbr_in, action_in, own_key_in, suffix_in)
         ,dbms_lob.lobmaxsize
         ,dest_offset
         ,src_offset
         ,dbms_lob.default_csid
         ,lang_context
         ,warning
         );
   end if;
   if warning != DBMS_LOB.NO_WARNING
   then
      DBMS_OUTPUT.PUT_LINE('gui_util.update_apex_app_files() ' ||
             'had problems with dbms_lob.converttoblob.');
   end if;
   af_doc_size := dbms_lob.getlength(af_blob_content);
   af_id       := wwv_flow_id.next_val;
   delete from apex_application_files
    where flow_id = af_flow_id
     and  title   = af_title;
   insert into apex_application_files
         (id
         ,flow_id
         ,name
         ,title
         ,mime_type
         ,doc_size
         ,dad_charset
         ,content_type
         ,blob_content
         ,description
         ,file_type
         ,file_charset)
      values
         (af_id
         ,af_flow_id
         ,af_id || '/' || af_title
         ,af_title
         ,'text/plain'
         ,af_doc_size
         ,'ascii'
         ,'BLOB'
         ,af_blob_content
         ,af_description
         ,'SCRIPT'
         ,'utf-8');
end update_apex_app_files;
----------------------------------------
function gen_ind_tag
      (tables_nk1_in     in  varchar2
      ,tables_nk2_in     in  varchar2
      ,uniq_in           in  varchar2)
   return varchar2
as
   maxnum     number;
begin
   select max(to_number(substr(tag,3)))
     into maxnum
    from  tab_inds_act
    where tab_cols_nk1 = tables_nk1_in
     and  tab_cols_nk2 = tables_nk2_in
     and  lower(substr(tag,2,1)) = 'x'
     and  gui_util.is_number(substr(tag,3)) = 1;
   return case upper(uniq_in)
          when 'Y' then 'u' else 'i'
          end || 'x' || (nvl(maxnum,0) + 1);
end gen_ind_tag;
----------------------------------------
function index_desc
      (app_abbr_in  in  varchar2
      ,tab_abbr_in  in  varchar2
      ,ind_tag_in   in  varchar2)
   return varchar2
as
   l_vc_arr2   apex_application_global.vc_arr2; 
begin 
   select tab_cols_nk3
     bulk collect 
     into l_vc_arr2 
    from  tab_inds_act
    where tab_cols_nk1 = app_abbr_in
     and  tab_cols_nk2 = tab_abbr_in
     and  tag          = ind_tag_in
    order by seq;
   if lower(substr(ind_tag_in,1,1)) = 'u'
   then
      return 'Unique index on columns: ' ||
              apex_util.table_to_string ( 
                 p_table => l_vc_arr2, 
                 p_string => ', ');
   end if;
   return 'Index on columns: ' ||
           apex_util.table_to_string ( 
              p_table => l_vc_arr2, 
              p_string => ', ');
end index_desc;
----------------------------------------
function create_index
      (column_string_in  in  varchar2
      ,tables_nk1_in     in  varchar2
      ,tables_nk2_in     in  varchar2
      ,uniq_in           in  varchar2)
   return number
as
   l_vc_arr2  apex_application_global.vc_arr2;
   maxnum     number;
   tagname    varchar2(20);
   numrows    number;
BEGIN
   l_vc_arr2 := APEX_UTIL.STRING_TO_TABLE(column_string_in);
   tagname := gen_ind_tag (tables_nk1_in, tables_nk2_in, uniq_in);
   numrows := 0;
   FOR i IN 1..l_vc_arr2.count
   LOOP
      insert into tab_inds_act
            (tab_cols_nk1
            ,tab_cols_nk2
            ,tab_cols_nk3
            ,tag
            ,seq)
         values
            (tables_nk1_in
            ,tables_nk2_in
            ,l_vc_arr2(i)
            ,tagname
            ,i);
      numrows := numrows + 1;
   END LOOP;
   return numrows;
end create_index;
----------------------------------------
function update_index
      (column_string_in  in  varchar2
      ,tables_nk1_in     in  varchar2
      ,tables_nk2_in     in  varchar2
      ,uniq_in           in  varchar2
      ,tagname_io    in out  varchar2)
   return number
as
   l_vc_arr2  apex_application_global.vc_arr2;
   colcnt     number;
   tagname    varchar2(20);
   numrows    number;
   col_match  boolean;
BEGIN
   l_vc_arr2 := APEX_UTIL.STRING_TO_TABLE(column_string_in);
   tagname := case upper(uniq_in)
              when 'Y' then 'u' else 'i'
              end || substr(tagname_io,2);
   if tagname != tagname_io
   then
      -- The tag name has changed. Check for existence of new tag name
      select count(tag)
        into colcnt
       from  tab_inds_act
       where tab_cols_nk1 = tables_nk1_in
        and  tab_cols_nk2 = tables_nk2_in
        and  tag          = tagname;
      if colcnt > 0
      then
         -- The new tag name already exists, Create a unique tag name
         tagname := gen_ind_tag (tables_nk1_in, tables_nk2_in, uniq_in);
      end if;
   end if;
   select count(tag)
     into colcnt
    from  tab_inds_act
    where tab_cols_nk1 = tables_nk1_in
     and  tab_cols_nk2 = tables_nk2_in
     and  tag          = tagname_io;
   if colcnt != l_vc_arr2.count
   then
      -- The number of columns has changed
      col_match := FALSE;
   else
      -- Check for column differences
      col_match := TRUE;
      for buff in (
         select tab_cols_nk3
               ,rownum
          from  tab_inds_act
          where tab_cols_nk1 = tables_nk1_in
           and  tab_cols_nk2 = tables_nk2_in
           and  tag          = tagname_io)
      loop
         if buff.tab_cols_nk3 != l_vc_arr2(buff.rownum)
         then
            -- Found a column mis-match
            col_match := FALSE;
         end if;
      end loop;
   end if;
   if not col_match
   then
      -- Delete and Insert because the columns have changed
      delete from tab_inds_act
       where tab_cols_nk1 = tables_nk1_in
        and  tab_cols_nk2 = tables_nk2_in
        and  tag          = tagname_io;
      numrows := SQL%ROWCOUNT;
      FOR i IN 1..l_vc_arr2.count
      LOOP
         insert into tab_inds_act
               (tab_cols_nk1
               ,tab_cols_nk2
               ,tab_cols_nk3
               ,tag
               ,seq)
            values
               (tables_nk1_in
               ,tables_nk2_in
               ,l_vc_arr2(i)
               ,tagname
               ,i);
         numrows := numrows + 1;
      END LOOP;
      tagname_io := tagname;
      return (numrows/2);
   end if;
   if tagname = tagname_io
   then
      -- No columns were changed and the tag names match
      return 0;
   end if;
   -- Update the tag name only
   update tab_inds_act
     set  tag = tagname
    where tab_cols_nk1 = tables_nk1_in
     and  tab_cols_nk2 = tables_nk2_in
     and  tag          = tagname_io;
   numrows := SQL%ROWCOUNT;
   tagname_io := tagname;
   return numrows;
end update_index;
----------------------------------------
procedure gen_all
      (app_abbr_in  in  varchar2
      ,job_num_in   in  number default null)
is
   lockname    varchar2(128);
   js_prefix   varchar2(50);
   job_status  varchar2(100);
   retstr      varchar2(100);
begin
   -- Single thread the longops processes so that FILE_LINES
   --   don't change while this is running and only one of
   --   these runs at any given time.
   lockname  := get_lockname(app_abbr_in);
   js_prefix := substr(lockname,1,40) || ' Generate';
   retstr := glob.request_lock(lockname);
   if retstr <> 'SUCCESS'
   then
      raise_application_error(-20000,
         'GLOB.REQUEST_LOCK returned ' || retstr);
   end if;
   generate.init(app_abbr_in);
   -- Create Scripts
   job_status := js_prefix || ' create_glob (1 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_glob;
   job_status := js_prefix || ' create_gdst (2 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_gdst;
   job_status := js_prefix || ' create_gusr (3 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_usyn;
   job_status := js_prefix || ' create_ods (4 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_ods;
   job_status := js_prefix || ' create_integ (5 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_integ;
   job_status := js_prefix || ' create_aa (6 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_integ;
   job_status := js_prefix || ' create_dist (7 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_dist;
   job_status := js_prefix || ' create_oltp (8 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_oltp;
   job_status := js_prefix || ' create_mods (9 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_mods;
   job_status := js_prefix || ' create_usyn (10 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_usyn;
   -- Delete Scripts
   job_status := js_prefix || ' delete_ods (11 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.delete_ods;
   -- Drop Scripts
   job_status := js_prefix || ' drop_usyn (12 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_usyn;
   job_status := js_prefix || ' drop_mods (13 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_mods;
   job_status := js_prefix || ' drop_oltp (14 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_oltp;
   job_status := js_prefix || ' drop_dist (15 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_dist;
   job_status := js_prefix || ' drop_aa (16 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_dist;
   job_status := js_prefix || ' drop_integ (17 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_integ;
   job_status := js_prefix || ' drop_ods (18 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_ods;
   job_status := js_prefix || ' drop_gdst (19 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_gdst;
   job_status := js_prefix || ' drop_glob (20 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.drop_glob;
   -- Create GUI Script
   job_status := js_prefix || ' create_flow (21 of 21)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   generate.create_flow;
   
   retstr := glob.release_lock;
   if retstr <> 'SUCCESS'
   then
      raise_application_error(-20000,
         'GLOB.RELEASE_LOCK returned ' || retstr);
   end if;
   job_status := js_prefix || ' All COMPLETE';
   apex_plsql_job.update_job_status(job_num_in, job_status);
end gen_all;
----------------------------------------
procedure asm_all
      (app_abbr_in  in  varchar2
      ,job_num_in   in  number default null
      ,flow_id_in   in  number default null)
is
   lockname    varchar2(128);
   js_prefix   varchar2(50);
   job_status  varchar2(100);
   retstr      varchar2(100);
begin
   -- Single thread the longops processes so that FILE_LINES
   --   don't change while this is running and only one of
   --   these runs at any given time.
   lockname := get_lockname(app_abbr_in);
   js_prefix := substr(lockname,1,40) || ' Assemble';
   retstr := glob.request_lock(lockname);
   if retstr <> 'SUCCESS'
   then
      raise_application_error(-20000,
         'GLOB.REQUEST_LOCK returned ' || retstr);
   end if;
   af_flow_id := nvl(flow_id_in, v('APP_ID'));
   -- install_db
   af_title        := 'install_db.sql';
   af_description  := app_abbr_in || ' database installation script';
   job_status := js_prefix || ' ' || af_title || ' (1 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'DB');
   -- install_db_sec
   af_title        := 'install_db_sec.sql';
   af_description  := app_abbr_in || ' database security installation script';
   job_status := js_prefix || ' ' || af_title || ' (2 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'DB', 'sec');
   -- install_mt
   af_title        := 'install_mt.sql';
   af_description  := app_abbr_in || ' mid-tier installation script';
   job_status := js_prefix || ' ' || af_title || ' (3 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'MT');
   -- install_mt_sec
   af_title        := 'install_mt_sec.sql';
   af_description  := app_abbr_in || ' mid-tier security installation script';
   job_status := js_prefix || ' ' || af_title || ' (4 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'MT', 'sec');
   -- install_usr
   af_title        := 'install_usr.sql';
   af_description  := app_abbr_in || ' user synonym installation script';
   job_status := js_prefix || ' ' || af_title || ' (5 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'USR');
   -- delete_db
   af_title        := 'delete_db.sql';
   af_description  := app_abbr_in || ' data delete script';
   job_status := js_prefix || ' ' || af_title || ' (6 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'delete', 'DB');
   -- uninstall_usr
   af_title        := 'uninstall_usr.sql';
   af_description  := app_abbr_in || ' user synonym uninstallation script';
   job_status := js_prefix || ' ' || af_title || ' (7 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'uninstall', 'USR');
   -- uninstall_mt
   af_title        := 'uninstall_mt.sql';
   af_description  := app_abbr_in || ' mid-tier uninstallation script';
   job_status := js_prefix || ' ' || af_title || ' (8 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'uninstall', 'MT');
   -- uninstall_db
   af_title        := 'uninstall_db.sql';
   af_description  := app_abbr_in || ' database uninstallation script';
   job_status := js_prefix || ' ' || af_title || ' (9 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'uninstall', 'DB');
   -- dtgen_dataload
   af_title        := 'dtgen_dataload.ctl';
   af_description  := app_abbr_in || ' DTGen dataload script';
   job_status := js_prefix || ' ' || af_title || ' (10 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'data');
   -- install_gui
   af_title        := 'install_gui.sql';
   af_description  := app_abbr_in || ' APEX maintenance GUI installation script';
   job_status := js_prefix || ' ' || af_title || ' (11 of 11)';
   apex_plsql_job.update_job_status(job_num_in, job_status);
   update_apex_app_files(app_abbr_in, 'install', 'GUI');
   --
   retstr := glob.release_lock;
   if retstr <> 'SUCCESS'
   then
      raise_application_error(-20000,
         'GLOB.RELEASE_LOCK returned ' || retstr);
   end if;
   job_status := js_prefix || ' All COMPLETE';
   apex_plsql_job.update_job_status(job_num_in, job_status);
end asm_all;
----------------------------------------
procedure del_all
      (app_abbr_in  in  varchar2
      ,flow_id_in   in  number)
is
begin
   dtgen_util.delete_files(app_abbr_in);
   delete from apex_application_files
    where flow_id = flow_id_in
     and  title   in (
          select title
           from apex_application_files
           where flow_id     = flow_id_in
            and  description like app_abbr_in || ' %');
end del_all;
----------------------------------------
begin
   dbms_lob.createtemporary(af_blob_content, true, dbms_lob.session);
end gui_util;