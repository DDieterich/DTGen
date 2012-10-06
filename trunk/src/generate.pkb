create or replace package body generate
as

/************************************************************
DTGEN "generate" Package Body

Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/

type lbuff_aa_type is table
  of file_lines%ROWTYPE
  index by PLS_INTEGER;
lbuff_orig_aa   lbuff_aa_type;
lbuff_apnd_aa   lbuff_aa_type;
lbuff_updt_aa   lbuff_aa_type;
lbuff_seq       file_lines.seq%TYPE;

lo_opname      varchar2(64);  -- Operation Name for LongOps
lo_num_tables  number;        -- Number of Tables for LongOps

ver  varchar2(20) := 'DTGen_0.12';
sec_lines  sec_lines_type;
sec_line0  sec_lines_type;  -- Used to reset the sec_lines array
sec_line   number;
abuff  applications%rowtype;
fbuff  files%rowtype;
tbuff  tables%rowtype;
cbuff  tab_cols%rowtype;
cbuf0  tab_cols%rowtype;  -- Used to Initialize cbuff
cnum   number;
pnum1  number := 1000;  -- Main Maintenance Menu, DML Pages Follow
pnum2  number := 1200;  -- UTIL_LOG page
-- DML Forms  := 1201;  -- DML Maintenance Forms use this empty space
pnum3  number := 1400;  -- OMNI Report Menu, DML Pages Follow
pnum4  number := 1600;  -- ASOF Report Menu, DML Pages Follow
HOA    varchar2(6);     -- HISTory or AUDit flag
SQ1    CONSTANT varchar2(1) := CHR(39);
SQ2    CONSTANT varchar2(2) := SQ1||SQ1;
SQ4    CONSTANT varchar2(4) := SQ2||SQ2;
SQ6    CONSTANT varchar2(6) := SQ4||SQ2;
usrfdt varchar2(40);    -- HIst/Aud User Full Datatype
usrdt  varchar2(40);    -- Hist/Aud User Short Datatype
usrcl  number;          -- Hist/Aud User Column Length

PROCEDURE p
      (text_in IN VARCHAR2)
   -- Put a newline into a file
   --   Requires the line of text
IS
   val_buff  file_lines_act.value%TYPE;
   i  number;
BEGIN
   lbuff_seq := lbuff_seq + 1;
   if lbuff_seq > lbuff_orig_aa.COUNT then
      i := lbuff_apnd_aa.COUNT + 1;
      lbuff_apnd_aa(i).file_id := fbuff.id;
      lbuff_apnd_aa(i).seq     := lbuff_seq;
      lbuff_apnd_aa(i).value   := text_in;
   else
      if NOT util.is_equal(lbuff_orig_aa(lbuff_seq).value, text_in) then
         i := lbuff_updt_aa.COUNT + 1;
         lbuff_updt_aa(i)       := lbuff_orig_aa(lbuff_seq);
         lbuff_updt_aa(i).value := text_in;
      end if;
   end if;
END p;
----------------------------------------
PROCEDURE pr
      (text_in IN VARCHAR2)
   -- Append a Line Feed Character with concatenation
   --   symbols before sending to "p"
IS
BEGIN
   p(text_in || '|| CHR(10) ||');
END pr;
----------------------------------------
PROCEDURE init_cr_nt
   -- Initialize the Copyright Nested Table
IS
   CRN_LEN  constant number := 74;  -- 80 minus 6 characters for comment marker
   SPC_PAT  constant varchar2(20) := '[ ' || CHR(9) || '-][^ ' || CHR(9) || '-]*$';
   LF       constant varchar2(1) := CHR(10);
   cr_pos   number;
   cr_len   number;
   spc_len  number;
   lf_len   number;
   cnt      number;
BEGIN
   if abuff.copyright is null then
      if cr_nt.EXISTS(1) then
         cr_nt.delete;
      end if;
      return;
   end if;
   cnt := 0;
   cr_nt := cr_nt_type(null);
   cnt := cnt + 1; cr_nt.extend; cr_nt(cnt) := '';
   cnt := cnt + 1; cr_nt.extend; cr_nt(cnt) := '   --';
   cr_pos := 1;
   cr_len := length(abuff.copyright);
   lf_len := instr(abuff.copyright,LF);
   while lf_len > 0 or cr_len > CRN_LEN
   loop
      cnt := cnt + 1; cr_nt.extend; cr_nt(cnt) := '   -- ';
      if lf_len between 1 and CRN_LEN+1 then
         -- Need to cut off at the LF and remove the LF
         cr_nt(cnt) := cr_nt(cnt) || substr(abuff.copyright,cr_pos,lf_len-1);
         -- LF is the last character in the string
         cr_pos := cr_pos + lf_len;
         cr_len := cr_len - lf_len;
         -- Find the next LF
         lf_len := nvl(instr(substr(abuff.copyright,cr_pos),LF),0);
      else
         -- Whether lf_len 0 or too long, cr_len is too long
         -- Need to cut off at a space, but keep the space
         spc_len := regexp_instr(substr(abuff.copyright,cr_pos,CRN_LEN),SPC_PAT);
         if spc_len = 0 or spc_len > CRN_LEN then spc_len := CRN_LEN; end if;
         cr_nt(cnt) := cr_nt(cnt) || substr(abuff.copyright,cr_pos,spc_len);
         cr_pos := cr_pos + spc_len;
         cr_len := cr_len - spc_len;
         if lf_len != 0 then
            -- lf_len must be > CRN_LEN+1
            -- Another LF is still in this string
            lf_len := lf_len - spc_len;
         end if;
      end if;
      if cnt > 4000 then
         -- Failsafe !!!
         raise_application_error(-20000, 'Infinite loop in init_cr_nt');
      end if;
   end loop;
   cnt := cnt + 1; cr_nt.extend; cr_nt(cnt) := '   -- ';
   -- If LF is the last character, cr_pos will be 1 past the string length
   cr_nt(cnt) := cr_nt(cnt) || substr(abuff.copyright,cr_pos);
   -- Add an extra empty comment line
   cnt := cnt + 1; cr_nt.extend; cr_nt(cnt) := '   -- ';
END init_cr_nt;
----------------------------------------
PROCEDURE header_comments
   -- Automatically place comments into an SQL script or PL/SQL program
IS
BEGIN
   p('');
   p('   -- Application: ' || abuff.name);
   p('   -- Generated by DTGen (http://code.google.com/p/dtgen)');
   p('   -- ' || to_char(sysdate,'Month DD, YYYY  HH:MI:SS AM'));
   if cr_nt.EXISTS(1) then
      for i in 1 .. cr_nt.COUNT
      loop
         p(cr_nt(i));
      end loop;
   end if;
END header_comments;
----------------------------------------
PROCEDURE open_file
   -- Create a new file or purge an existing file.
   --    Set fbuff.id and lbuff.
   --    Requires fbuff.name and application_id
IS
BEGIN
   if lbuff_orig_aa.COUNT != 0 then
      raise_application_error (-20000, 'File ' || fbuff.name ||
                              ' lbuff_orig_aa.COUNT != 0: ' || lbuff_orig_aa.COUNT);
   end if;
   if lbuff_updt_aa.COUNT != 0 then
      raise_application_error (-20000, 'File ' || fbuff.name ||
                              ' lbuff_updt_aa.COUNT != 0: ' || lbuff_updt_aa.COUNT);
   end if;
   if lbuff_apnd_aa.COUNT != 0 then
      raise_application_error (-20000, 'File ' || fbuff.name ||
                              ' lbuff_apnd_aa.COUNT != 0: ' || lbuff_apnd_aa.COUNT);
   end if;
   if lbuff_seq != 0 then
      raise_application_error (-20000, 'File ' || fbuff.name ||
                              ' lbuff_seq != 0: ' || lbuff_seq);
   end if;
   begin
      select F.id,     F.aud_beg_usr,     F.aud_beg_dtm
       into  fbuff.id, fbuff.aud_beg_usr, fbuff.aud_beg_dtm
       from  files  F
       where F.application_id = fbuff.application_id
        and  F.name           = fbuff.name;
   exception
      when no_data_found then
         fbuff.id := null;
      when others then
         raise;
   end;
   fbuff.created_dt := sysdate;
   if fbuff.id is null
   then
      files_dml.ins(fbuff);
   else
      -- The BULK COLLECT changes the size of the "lbuff_aa" as needed.
      -- Not Needed: lbuff_aa.trim(lbuff_aa.COUNT-SQL%ROWCOUNT);
      select * bulk collect into lbuff_orig_aa
       from  file_lines
       where file_id = fbuff.id
       order by seq;
      lbuff_seq := SQL%ROWCOUNT;
      FOR i IN 1 .. lbuff_seq
      LOOP
         if lbuff_orig_aa(i).seq != i then
            raise_application_error (-20000, 'File Lines in "' ||fbuff.name ||
                                     '" are out of sequence at SEQ ' || i );
         end if;
      END LOOP;
      lbuff_seq := 0;
   end if;
   p('');
   p('-- Script File "' || fbuff.name || '"');
   p('--    ' || fbuff.description);
   header_comments;
   p('');
END open_file;
----------------------------------------
PROCEDURE close_file
   -- Post Updates and Appended Lines
   -- Delete the remaining part of an existing file
IS
BEGIN
   --dbms_output.put_line('Closing File ' || fbuff.name);
   -- Send the Updates
   FOR i IN 1 .. lbuff_updt_aa.COUNT
   LOOP
      --dbms_output.put_line('Updating Seq ' || lbuff_updt_aa(i).seq);
      file_lines_dml.upd(lbuff_updt_aa(i));
   END LOOP;
   -- Append lines
   FOR i IN 1 .. lbuff_apnd_aa.COUNT
   LOOP
      --dbms_output.put_line('Appending Seq ' || lbuff_apnd_aa(i).seq);
      file_lines_dml.ins(lbuff_apnd_aa(i));
   END LOOP;
   -- Delete any remaining lines
   FOR i IN lbuff_seq+1 .. lbuff_orig_aa.COUNT
   LOOP
      --dbms_output.put_line('Deleting Seq ' || lbuff_orig_aa(i).seq);
      file_lines_dml.del(lbuff_orig_aa(i).id);
   END LOOP;
   -- Free the memory
   lbuff_apnd_aa.DELETE;
   lbuff_updt_aa.DELETE;
   lbuff_orig_aa.DELETE;
   lbuff_seq := 0;
END close_file;
----------------------------------------
PROCEDURE ps
      (text_in IN VARCHAR2)
   -- Insert text into the security array
   --   for later printing
IS
BEGIN
   sec_line := sec_line + 1;
   sec_lines(sec_line) := text_in;
END ps;
----------------------------------------
PROCEDURE dump_sec_lines
   -- Print the security array
IS
BEGIN
   --(There may be an old security script that needs to be cleared.)
   --if sec_lines.COUNT = 0 and sec_line = 0 then
   --   return;
   --end if;
   fbuff.name        := fbuff.name || '_sec';
   fbuff.description := 'Security script to ' || fbuff.description;
   open_file;
   p('');
   if sec_lines.COUNT != 0 then
      for i in sec_lines.FIRST .. sec_lines.LAST
      loop
         p(sec_lines(i));
      end loop;
   end if;
   p('');
   close_file;
   sec_lines := sec_line0;
   sec_line  := 0;
END dump_sec_lines;
----------------------------------------
procedure show_errors
      (type_in  in  user_errors.type%type
      ,name_in  in  user_errors.name%type)
   -- Select errors from user_errors view
   --    Requres the type and name of the database object
   --  *** DOES NOT USE SQL*Plus commands, only SQL
is
begin
   -- Queries must start with the word "select" and can only return 1 string
   p('select ''' || upper(name_in) || ''' as "' || initcap(type_in) || ':"');
   p(' from  user_errors');
   p(' where name  = '''||upper(name_in)||'''');
   p('  and  type  = '''||upper(type_in)||'''');
   p('  and  rownum = 1');
   p('/');
   -- Queries must start with the word "select" and can only return 1 string
   p('select ''(''||line||''/''||position||'') ''||text as error');
   p(' from  user_errors');
   p(' where name = '''||upper(name_in)||'''');
   p('  and  type = '''||upper(type_in)||'''');
   p(' order by sequence');
   p('/');
end show_errors;
----------------------------------------
function get_hoa
      (tab_type_in  in  varchar2)
   return varchar2
is
begin
   return case tab_type_in
          when 'EFF' then '_HIST'
          when 'LOG' then '_AUD'
          else '_BOGUS'
          end;
end get_hoa;
----------------------------------------
function get_domlen
      (domid_in  in  domains.id%type)
   return number
   --  For a domain ID, return the length of the domain
is
   rlen  number;
begin
   select DOM.len
    into  rlen
    from  domains  DOM
    where DOM.id = domid_in;
   return rlen;
end get_domlen;
----------------------------------------
function get_domlist
      (domid_in  in  domains.id%type)
   return varchar2
   -- For a domain ID, return the comma delimited list of values
   --    in the domain, surounded by parenthesis "()"
is
   ltxt       varchar2(32767);
   first_rec  boolean;
begin
   first_rec := TRUE;
   for buff in (
      select * from domain_values DV
       where DV.domain_id = domid_in
       order by DV.seq )
   loop
      if first_rec
      then
         ltxt      := '(''' || buff.value || '''';
         first_rec := FALSE;
      else
         ltxt := ltxt || ', ''' || buff.value || '''';
      end if;
   end loop;
   return ltxt || ')';
end get_domlist;
----------------------------------------
FUNCTION get_dtype
      (cbuff_in  in  tab_cols%rowtype
      ,tenv_in   in  varchar2  default null)
   RETURN VARCHAR2
   -- For a column buffer, return the simple data type
   -- If tenv_in is not null, then a clob will be used
   --   for varchar2 longer than 4000
IS
BEGIN
   if cbuff_in.d_domain_id is not null
   then
      if tenv_in is not null AND
         get_domlen(cbuff_in.d_domain_id) > 4000
      then
         return 'CLOB';
      else
         return 'VARCHAR2';
      end if;
   elsif cbuff_in.fk_table_id is not null
   then
      return 'NUMBER';
   elsif tenv_in is not null  AND
      cbuff_in.len  > 4000    AND
      cbuff_in.type = 'VARCHAR2'
   then
      return 'CLOB';
   end if;
   return cbuff_in.type;
END get_dtype;
----------------------------------------
FUNCTION get_dtype_full
      (cbuff_in  in  tab_cols%rowtype
      ,tenv_in   in  varchar2  default null)
   RETURN VARCHAR2
   -- For a column buffer, return the full data type
   -- If tenv_in is not null, then a clob will be used
   --   for varchar2 longer than 4000
IS
   rtxt    VARCHAR2(50);
BEGIN
   if cbuff_in.d_domain_id is not null
   then
      if tenv_in is not null AND
         get_domlen(cbuff_in.d_domain_id) > 4000
      then
         return 'CLOB';
      else
         return 'VARCHAR2(' || get_domlen(cbuff_in.d_domain_id) ||')';
      end if;
   elsif cbuff_in.fk_table_id is not null
   then
      return 'NUMBER(38)';
   end if;
   rtxt := cbuff_in.type;
   if cbuff_in.len is not null
   then
      if tenv_in is not null   AND
         cbuff_in.len  > 4000  AND
         cbuff_in.type = 'VARCHAR2'
      then
         return 'CLOB';
      else
	     if upper(rtxt) like 'TIMESTAMP WITH%'
		 then
		    rtxt := substr(rtxt,1,9) || '(' || cbuff_in.len || ')' || substr(rtxt,10);
		 else
            rtxt := rtxt || '(' || cbuff_in.len;
            if cbuff_in.scale IS NOT NULL
            then
               rtxt := rtxt || ',' || cbuff_in.scale || ')';
            else
               rtxt := rtxt || ')';
			end if;
         end if;
      end if;
   end if;
   return rtxt;
END get_dtype_full;
----------------------------------------
FUNCTION get_collen
      (cbuff_in  in  tab_cols%rowtype)
   RETURN number
   -- For a column buffer, return the length of the datatype
IS
BEGIN
   if cbuff_in.fk_table_id is not null
   then
      -- sign + number(38)
      return 39;
   elsif cbuff_in.d_domain_id is not null
   then
      return get_domlen(cbuff_in.d_domain_id);
   elsif cbuff_in.type like 'VARCHAR%'
   then
      return cbuff_in.len;
   elsif cbuff_in.type like 'DATE%'
   then
      -- 'DD-MON-YYYY HH:MI:SS'
      return 20;
   elsif cbuff_in.type = 'TIMESTAMP WITH TIME ZONE'
   then
      -- 'DD-MON-YYYY HH:MI:SS.FF(len) -TH:TM'
      return 28 + nvl(cbuff_in.len,6);
   elsif cbuff_in.type = 'TIMESTAMP WITH LOCAL TIME ZONE'
   then
      -- 'DD-MON-YYYY HH:MI:SS.FF(len)'
      return 21 + nvl(cbuff_in.len,6);
   elsif cbuff_in.type like 'NUMBER%'
   then
      if cbuff_in.len is not null
      then
         -- (sign)len(decimal point)scale
         return 1 + cbuff_in.len + nvl(1+cbuff_in.scale,0);
      else
         -- sign + 40 decimal digits + decimal point + 5 Exponential Digits
         return 47;
      end if;
   end if;
   return -1;
END get_collen;
----------------------------------------
function get_storage_size
      (datatype_in  in  varchar2
      ,len_in       in  number)
   return number
   --  Compute number of bytes of storage for each datatype
is
begin
   case datatype_in
   when 'VARCHAR2' then
      -- select vsize('ABCD') from dual;
      return ceil(len_in);
   when 'NUMBER' then
      -- select vsize(1234) from dual;
      -- Numbers are stored roughly 2 digits per byte plus a sign/exponent byte
      return ceil(nvl(len_in,38)/2) + 1;
   when 'DATE' then
      -- select vsize(systimestamp) from dual;
      return 7;
   when 'TIMESTAMP WITH LOCAL TIME ZONE' then
      -- select vsize(cast (systimestamp as timestamp(0) with local time zone)) from dual; = 7
      -- select vsize(cast (systimestamp as timestamp(1) with local time zone)) from dual; = 11
      -- select vsize(cast (systimestamp as timestamp(9) with local time zone)) from dual; = 11
      if len_in is not null and len_in = 0
      then
         return 7;
      else
         return 11;
      end if;
   when 'TIMESTAMP' then
      -- select vsize(cast (systimestamp as timestamp(0))) from dual; = 7
      -- select vsize(cast (systimestamp as timestamp(1))) from dual; = 11
      -- select vsize(cast (systimestamp as timestamp(9))) from dual; = 11
      if len_in is not null and len_in = 0
      then
         return 7;
      else
         return 11;
      end if;
   when 'TIMESTAMP WITH TIME ZONE' then
      -- select vsize(cast (systimestamp as timestamp(0) with time zone)) from dual; = 13
      -- select vsize(cast (systimestamp as timestamp(9) with time zone)) from dual; = 13
      return 13;
   when 'CLOB' then
      -- Oracle® Database SecureFiles and Large Objects Developer's Guide
      --     11g Release 2 (11.2)  Part Number E18294-01
      --   LOB Storage Parameters: Inline and Out-of-Line LOB Storage
      -- Row storage of a LOB is limited to 4000 bytee of data.  If a LOB is
      --   larger, the entire LOB is stored in LOB storage.
      return 4000;
   else
      raise_application_error (-20000, 'DATATYPE_IN is invalid for get_storage_size(): ' ||
                                        datatype_in);
   end case;
end get_storage_size;
----------------------------------------
function get_pctfree
      (onln_hist_pdat_in  in  varchar2
      ,data_indx_in       in  varchar2)
   return varchar2
   --  Compute PCTFREE
is
   pctf  number;
   num   number;
   tot   number;
   tmp   number;
begin
   if upper(data_indx_in) = 'INDX'
   then
      -- PCTFree for Indexes not yet implemented
      return '';
   end if;
   if upper(data_indx_in) != 'DATA'
   then
      raise_application_error(-20000,'Unknown data_indx_in in get_pctfree: ' ||
            data_indx_in );
   end if;
   case upper(onln_hist_pdat_in)
   when 'HIST' then pctf := 1;  -- This is a best guess
   when 'PDAT' then pctf := 1;  -- This is a best guess
   when 'ONLN' then
      -- accumulate a weigthed average of PCTFREEs
      num := 0;
      tot := 0;
      -- id is a number(38) with a pctfree of 0
      num := num + get_storage_size('NUMBER', 38);
      if tbuff.type in ('EFF', 'LOG')
      then
         if tbuff.type = 'EFF'
         then
            -- eff_beg_dtm is a timestamp(9) with local time zone
            --    with a pctfree of 0
            num := num + get_storage_size('TIMESTAMP WITH LOCAL TIME ZONE', 9);
         end if;
         -- aud_beg_usr is a usrfdt with a pctfree of 1
         tmp := get_storage_size(usrdt, usrcl);
         num := num + tmp;
         tot := tot + (tmp * 1);
         -- aud_beg_dtm is a timestamp(9) with local time zone
         --    with a pctfree of 0
         num := num + get_storage_size('TIMESTAMP WITH LOCAL TIME ZONE', 9);
      end if;
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         tmp := get_storage_size(get_dtype(buff, 'DB'), get_collen(buff));
         num := num + tmp;
         if buff.upd_res_pct is not null
         then
            tot := tot + (tmp * buff.upd_res_pct);
         else
            if buff.req is not null
            then
               tot := tot + (tmp * 5);
            else
               tot := tot + (tmp * 10);
            end if;
         end if;
      end loop;
      pctf := least(greatest(ceil(tot/num),1),80);
   else
      raise_application_error(-20000,'Unknown onln_hist_pdat_in in get_pctfree: ' ||
            onln_hist_pdat_in );
   end case;
   return ' pctfree ' || pctf;
end get_pctfree;
----------------------------------------
function get_tspace
      (onln_hist_pdat_in   in  varchar2
      ,data_indx_in        in  varchar2
      ,add_using_index_in  in  boolean default false)
   return varchar2
   --  Compute Tablespace Name with extras
is
   ts_str  varchar2(100);
begin
   if abuff.ts_null_override is not null
   then
      return '';
   end if;
   case upper(onln_hist_pdat_in || '_' || data_indx_in)
   when 'HIST_INDX' then
      ts_str := nvl(tbuff.ts_hist_indx, abuff.ts_onln_indx);
   when 'PDAT_INDX' then
      ts_str := nvl(tbuff.ts_hist_indx, abuff.ts_onln_indx);
   when 'ONLN_INDX' then
      ts_str := nvl(tbuff.ts_onln_indx, abuff.ts_onln_indx);
   when 'HIST_DATA' then
      ts_str := nvl(tbuff.ts_hist_data, abuff.ts_onln_data);
   when 'PDAT_DATA' then
      ts_str := nvl(tbuff.ts_hist_data, abuff.ts_onln_data);
   when 'ONLN_DATA' then
      ts_str := nvl(tbuff.ts_onln_data, abuff.ts_onln_data);
   else
      raise_application_error(-20000,'Unknown Parameters to get_tspace: ' ||
            upper(onln_hist_pdat_in || '_' || data_indx_in));
   end case;
   if ts_str is not null
   then
      ts_str := ' tablespace ' || ts_str;
      if add_using_index_in
      then
         ts_str := ' using index' || ts_str;
      end if;
   end if;
   return ts_str;
end get_tspace;
----------------------------------------
function get_tabname
      (tabid_in  in  tables.id%type)
   return varchar2
   --  For a table ID, return the table name
is
begin
   return nk_aa(tabid_in).tbuff.name;
end get_tabname;
----------------------------------------
function get_tababbr
      (tabid_in  in  tables.id%type)
   return varchar2
   --  For a table ID, return the table abbreviation
is
begin
   return nk_aa(tabid_in).tbuff.abbr;
end get_tababbr;
----------------------------------------
function get_tabtype
      (tabid_in  in  tables.id%type)
   return varchar2
   --  For a table ID, return the table type
is
begin
   return nk_aa(tabid_in).tbuff.type;
end get_tabtype;
----------------------------------------
function table_self_ref
      (tabid_in  in  tables.id%type)
   return boolean
   --  For a table ID, return TRUE if the table
   --  Contains a self-referencing foreign key
is
   cursor c1 is
      select 1 from tab_cols COL
       where COL.table_id = COL.fk_table_id
        and  COL.table_id = tabid_in;
   buf1 c1%ROWTYPE;
   retb  boolean;
begin
   open c1;
   fetch c1 into buf1;
   retb := c1%FOUND;
   close c1;
   return retb;
end table_self_ref;
----------------------------------------
function table_has_fk
      (tabid_in  in  tables.id%type)
   return boolean
   --  For a table ID, return TRUE if the table
   --  Contains a self-referencing foreign key
is
   cursor c1 is
      select 1 from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tabid_in;
   buf1 c1%ROWTYPE;
   retb  boolean;
begin
   open c1;
   fetch c1 into buf1;
   retb := c1%FOUND;
   close c1;
   return retb;
end table_has_fk;
----------------------------------------
function get_colformat
      (cbuff_in  in  tab_cols%rowtype)
   return varchar2
is
   rtxt  varchar2(100);
begin
   if cbuff_in.type like 'DAT%'
   then
      return 'DD-MON-YYYY HH24:MI:SS';
   elsif cbuff_in.type = 'TIMESTAMP WITH TIME ZONE'
   then
      return 'DD-MON-YYYY HH24:MI:SS.FF' || cbuff_in.len || ' TZR';
   elsif cbuff_in.type = 'TIMESTAMP WITH LOCAL TIME ZONE'
   then
      return 'DD-MON-YYYY HH24:MI:SS.FF' || cbuff_in.len;
   elsif cbuff_in.type like 'NUMBER%' and
         cbuff_in.len is not null
   then
      rtxt := null;
      for i in 1 .. cbuff_in.len
      loop
         rtxt := rtxt || '9';
      end loop;
      if cbuff_in.scale is not null
      then
         rtxt := rtxt || '.';
         for i in 1 .. cbuff_in.scale
         loop
            rtxt := rtxt || '9';
         end loop;
      end if;
      return rtxt;
   elsif cbuff_in.fk_table_id is not null
   then
      rtxt := null;
      for i in 1 .. 38
      loop
         rtxt := rtxt || '9';
      end loop;
      return rtxt;
   else
      return null;
   end if;
END get_colformat;
----------------------------------------
function get_collist
      (tabid_in  in  tables.id%type
      ,delim_in  in  varchar2)
   return varchar2
   --  For a table ID, return a delimited list of columns
is
   rtxt  varchar2(32767) := '';
begin
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tabid_in
       order by COL.seq )
   loop
      rtxt := rtxt || buff.name || delim_in;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            rtxt := rtxt || buff.fk_prefix || 'id_path' || delim_in;
            rtxt := rtxt || buff.fk_prefix || 'id_path' || delim_in;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            rtxt := rtxt || buff.fk_prefix ||
                            get_tabname(buff.fk_table_id) ||
                            '_nk' || i || delim_in;
         end loop;
      end if;
   end loop;
   return substr(rtxt,1,length(rtxt)-length(delim_in));
END get_collist;
----------------------------------------
function get_colsort_seq
      (tabid_in in  tables.id%type
      ,nk_in    in  tab_cols.nk%type)
   return number
   --  For the table ID and nk, return the sequence
is
   rseq  number;
begin
   if nk_in is null
   then
      return 0;
   end if;
   rseq := 0;
   for buff in (
      select COL.nk from tab_cols COL
       where COL.table_id = tabid_in
        and  COL.nk is not null
       order by COL.nk )
   loop
      rseq := rseq + 1;
      if buff.nk = nk_in
      then
         return rseq;
      end if;
   end loop;
   -- We should never arrive here.
   return (0 - rseq);
END get_colsort_seq;
----------------------------------------
function is_bigtext
      (cbuff_in  in  tab_cols%rowtype)
   return boolean
   --  For a table Column Record, return TRUE
   --  if it is a big text column
is
begin
   if cbuff_in.len  > 200  AND
      cbuff_in.type = 'VARCHAR2'
   then
      return true;
   else
      return false;
   end if;
end is_bigtext;
----------------------------------------
function allow_add_row
   return boolean
IS
   num_rows  number;
begin
   select count(c.type)
    into  num_rows
    from  tab_cols c
    where c.table_id = tbuff.id
     and  (   c.nk  is not null
           OR c.req is not null)
     and  c.type like 'BLOB%';
   if num_rows > 0
   then
      return false;
   end if;
   return true;
end allow_add_row;
----------------------------------------
procedure load_nk_aa
is
   nknum       number;
begin
   nk_aa.DELETE;
   for buff in (
      select * from tables tab
       where tab.application_id = abuff.id
       order by tab.seq)
   loop
      nk_aa(buff.id).tbuff := buff;
      nknum := 0;
      for buf2 in (
         select * from tab_cols_act tc
          where tc.nk is not null
           and  tc.table_id = buff.id
          order by tc.nk)
      loop
         if buf2.fk_table_id is not null and
            buf2.fk_table_id != buf2.table_id
         then
            -- Ensure the FK table has already been populated
            if not nk_aa.EXISTS(buf2.fk_table_id)
            then
               raise_application_error(-20000, 'load_nk_aa(): ' ||
                  buf2.fk_tables_nk2 || ' must precede ' ||
                  buff.abbr || ' in ascending table sequence.');
            end if;
            -- Populate the Foreign Key Table's Natural Keys
            -- Note: the original foreign key ID is added as well
            for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
            loop
               if nknum = 0
               then
                  -- Initialize the array
                  nk_aa(buff.id).cbuff_va       := tab_col_va_type(null);
                  nk_aa(buff.id).lvl1_fk_tid_va := fk_tid_va_type(null);
               else
                  -- Extend the array
                  nk_aa(buff.id).cbuff_va.extend;
                  nk_aa(buff.id).lvl1_fk_tid_va.extend;
               end if;
               nknum := nknum + 1;
               nk_aa(buff.id).cbuff_va(nknum) := nk_aa(buf2.fk_table_id).cbuff_va(i);
               nk_aa(buff.id).lvl1_fk_tid_va(nknum) := buf2.fk_table_id;
            end loop;
         else
            -- Populate the Table's next Natural Key Column
            if nknum = 0
            then
               -- Initialize the array
               nk_aa(buff.id).cbuff_va       := tab_col_va_type(null);
               nk_aa(buff.id).lvl1_fk_tid_va := fk_tid_va_type(null);
            else
               -- Extend the array
               nk_aa(buff.id).cbuff_va.extend;
               nk_aa(buff.id).lvl1_fk_tid_va.extend;
            end if;
            nknum := nknum + 1;
            select * into nk_aa(buff.id).cbuff_va(nknum)
             from  tab_cols COL where COL.id = buf2.id;
         end if;
      end loop;
   end loop;
   /*
   nknum := nk_aa.FIRST;
   loop
      for i in 1 .. nk_aa(nknum).cbuff_va.COUNT
      loop
         dbms_output.put_line(get_tabname(nknum) || '_nk' || i ||
          ': ' || get_tabname(nk_aa(nknum).cbuff_va(i).table_id) ||
                       '.' || nk_aa(nknum).cbuff_va(i).name ||
                       '(' || get_dtype(nk_aa(nknum).cbuff_va(i)) ||
                      ');' || nk_aa(nknum).lvl1_fk_tid_va(i));
      end loop;
      exit when nknum = nk_aa.LAST;
      dbms_output.put_line('-');
      nknum := nk_aa.NEXT(nknum);
   end loop;
   */
end load_nk_aa;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
/*
procedure nk_tabs
      (tabid_in  in  tab_cols.fk_table_id%type
      ,spc_in    in  varchar2
      ,rind_in   in  varchar2
      ,fkpre_in  in  varchar2
      ,jcol_in   in  varchar2)
   --  Using the "p" function, print out join statments for
   --    all the natural key columns in the table hierarchy.
   --    This function is called recursively.
IS
   tababbr   tables.abbr%type;
   join_txt  varchar2(30);
BEGIN
   if tabid_in is null
   then
      return;
   end if;
   tababbr := get_tababbr(tabid_in);
   if rind_in is null
   then
      join_txt := spc_in || 'left outer join ';
   else
      join_txt := spc_in || '     inner join ';
   end if;
   p(join_txt || get_tabname(tabid_in) || ' ' || fkpre_in || tababbr ||
       ' on ' || fkpre_in || tababbr || '.id' || ' = ' || jcol_in);
   for buff in
      (select * from tab_cols COL
        where COL.nk          is not null
         and  COL.fk_table_id is not null
         and  COL.fk_table_id != tabid_in
         and  COL.table_id     = tabid_in
        order by COL.nk desc)
   loop
      nk_tabs(buff.fk_table_id
             ,spc_in
             ,case when rind_in is null then null else nvl(buff.req,buff.nk) end
             ,fkpre_in
             ,fkpre_in || tababbr||'.'||buff.name);
   end loop;
END nk_tabs;
*/
----------------------------------------
PROCEDURE trig_no_dml
      (sp_name_in  in  varchar2
      ,sp_type_in  in  varchar2
      ,action_in   in  varchar2)
IS
   trigger_name  varchar2(30);
BEGIN
   if lower(sp_type_in) not in ('table', 'view') then
      raise_application_error (-20000, 'trig_no_dml(): Invalid SP_TYPE_IN: ' ||
                                       sp_type_in);
   end if;
   if lower(action_in) not in ('insert', 'update', 'delete') then
      raise_application_error (-20000, 'trig_no_dml(): Invalid ACTION_IN: ' ||
                                       action_in);
   end if;
   if lower(sp_type_in) = 'table' then
      trigger_name := sp_name_in || '_b' || substr(lower(action_in),1,1);
   else
      trigger_name := sp_name_in || '_io' || substr(lower(action_in),1,1);
   end if;
   p('create trigger ' || trigger_name);
   if lower(sp_type_in) = 'table' then
      p('   before ' || lower(action_in) || ' on ' || sp_name_in);
   else
      p('   instead of ' || lower(action_in) || ' on ' || sp_name_in);
   end if;
   p('   for each row');
   p('begin');
   p('');
   p('   -- Trigger ' || initcap(trigger_name));
   header_comments;
   p('');
   p('   -- util.log(''Trigger '||trigger_name||''');');
   p('   raise_application_error(-20001, ');
   p('      ''' || trigger_name || ':' || lower(action_in) ||
            ' is not allowed on this ' || lower(sp_type_in) || '.'');');
   p('');
   p('end ' || trigger_name || ';');
   p('/');
   show_errors('TRIGGER', trigger_name);
   p('');
END trig_no_dml;
----------------------------------------
PROCEDURE vtrig_fksets
      (sp_name  in  varchar2
      ,p_name   in  varchar2)
IS
   nkseq    number(2);
BEGIN
   --  Set self-referencing ID, if needed
   for buff in
      (select * from tab_cols COL
        where COL.fk_table_id = tbuff.id
         and  COL.table_id    = tbuff.id
        order by COL.seq)
   loop
      p('   -- Set self-referencing n_' || buff.name || ', if needed');
      case p_name
      when 'ins' then
         p('   if n_' || buff.name || ' is null');
      when 'upd' then
         if buff.nk is null and buff.req is null
         then
            p('   if util.is_equal(n_' || buff.name ||
                                ', o_' || buff.name || ')');
         else
            p('   if n_' || buff.name ||' = o_' || buff.name);
         end if;
      end case;
      p('   then');
      nkseq := 1;
      -- Collect Natural Key columns for self-referencing test
      for buf2 in
         (select * from tab_cols COL
           where COL.nk       is not null
            and  COL.table_id = tbuff.id
           order by COL.nk)
      loop
         if buf2.fk_table_id is null
         then
            -- Check the value directly against the table column name
            if nkseq = 1
            then
               p('      if     n_' || buff.fk_prefix || get_tabname(buff.fk_table_id) ||
                                 '_nk' || nkseq || ' = n_' || buf2.name);
            else
               p('         and n_' || buff.fk_prefix || get_tabname(buff.fk_table_id) ||
                                 '_nk' || nkseq || ' = n_' || buf2.name);
            end if;
            nkseq := nkseq + 1;
         else
            -- Check the value against a generated Natural Key column name
            for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
            loop
               if i = 1
               then
                  p('      if  n_' || buff.fk_prefix || get_tabname(buff.fk_table_id) ||
                                    '_nk' || nkseq || ' = n_' ||
                                     get_tabname(buf2.fk_table_id) || '_nk' || i);
               else
                  p('         and n_' || buff.fk_prefix || get_tabname(buff.fk_table_id) ||
                                    '_nk' || nkseq || ' = n_' ||
                                     get_tabname(buf2.fk_table_id) || '_nk' || i);
               end if;
               nkseq := nkseq + 1;
            end loop;
         end if;
      end loop;
      p('      then');
      case p_name
      when 'ins' then
         p('         n_' || buff.name || ' := n_id;');
      when 'upd' then
         p('         n_' || buff.name || ' := o_id;');
      end case;
      p('      end if;');
      p('   end if;');
   end loop;
   -- Set ID from the ID Path, if needed
   for buff in
      (select * from tab_cols COL
        where COL.fk_table_id = tbuff.id
         and  COL.table_id    = tbuff.id
        order by COL.seq)
   loop
      p('   -- Set n_' || buff.name || ' from n_' ||
                   buff.fk_prefix || 'id_path, if needed');
      case p_name
      when 'ins' then
         p('   if     n_' || buff.name || ' is null');
         p('      and n_' || buff.fk_prefix || 'id_path is not null');
      when 'upd' then
         if buff.nk is null and buff.req is null
         then
            p('   if     util.is_equal(n_' || buff.name ||
                                    ', o_' || buff.name || ')');
         else
            p('   if     n_' || buff.name ||' = o_' || buff.name);
         end if;
         p('      and not util.is_equal(n_' || buff.fk_prefix || 'id_path, ' ||
                                               tbuff.name     || '_dml.get_' ||
                                               buff.fk_prefix || 'id_path(o_id))');
         p('      and not util.is_equal(n_' || buff.fk_prefix || 'id_path, ' ||
                                       'o_' || buff.fk_prefix || 'id_path)');
      end case;
      p('   then');
      p('      n_' || buff.name || ' := ' || tbuff.name || '_dml.get_' ||
                      buff.fk_prefix || 'id_by_id_path(n_' || buff.fk_prefix ||
                      'id_path);');
      p('   end if;');
   end loop;
   -- Set ID from the Natural Key Sets Path, if needed
   for buff in
      (select * from tab_cols COL
        where COL.fk_table_id = tbuff.id
         and  COL.table_id    = tbuff.id
        order by COL.seq)
   loop
      p('   -- Set n_' || buff.name || ' from n_' ||
                   buff.fk_prefix || 'nk_path, if needed');
      case p_name
      when 'ins' then
         p('   if     n_' || buff.name || ' is null');
         p('      and n_' || buff.fk_prefix || 'nk_path is not null');
      when 'upd' then
         if buff.nk is null and buff.req is null
         then
            p('   if     util.is_equal(n_' || buff.name ||
                                    ', o_' || buff.name || ')');
         else
            p('   if     n_' || buff.name ||' = o_' || buff.name);
         end if;
         p('      and not util.is_equal(n_' || buff.fk_prefix || 'nk_path, ' ||
                                               tbuff.name     || '_dml.get_' ||
                                               buff.fk_prefix || 'nk_path(o_id))');
         p('      and not util.is_equal(n_' || buff.fk_prefix || 'nk_path, ' ||
                                       'o_' || buff.fk_prefix || 'nk_path)');
      end case;
      p('   then');
      p('      n_' || buff.name || ' := ' || tbuff.name || '_dml.get_' ||
                      buff.fk_prefix || 'id_by_nk_path(n_' || buff.fk_prefix ||
                      'nk_path);');
      p('   end if;');
   end loop;
   --  Set the ID from the Natural Keys, if needed
   for buff in
      (select * from tab_cols COL
        where COL.fk_table_id is not null
         and  COL.table_id    = tbuff.id
        order by COL.seq)
   loop
      p('   -- Set n_' || buff.name || ', if needed');
      case p_name
      when 'ins' then
         p('   if     n_'|| buff.name || ' is null');
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      and n_' || buff.fk_prefix ||
                         get_tabname(buff.fk_table_id) ||
                         '_nk' || i || ' is not null');
         end loop;
      when 'upd' then
         if buff.nk is null and buff.req is null
         then
            p('   if     util.is_equal(n_' || buff.name ||
                                    ', o_' || buff.name || ')');
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               if i = 1
               then
                  p('      and (   not util.is_equal(n_' || buff.fk_prefix ||
                               get_tabname(buff.fk_table_id) || '_nk' || i ||
                                                  ', o_' || buff.fk_prefix ||
                               get_tabname(buff.fk_table_id) || '_nk' || i ||
                                                  ')');
               else
                  p('           or not util.is_equal(n_' || buff.fk_prefix ||
                               get_tabname(buff.fk_table_id) || '_nk' || i ||
                                                  ', o_' || buff.fk_prefix ||
                               get_tabname(buff.fk_table_id) || '_nk' || i ||
                                                  ')');
               end if;
            end loop;
            p('          )');
         else
            p('   if     n_' || buff.name ||' = o_' || buff.name);
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               if i = 1
               then
                  p('      and (   not (n_' || buff.fk_prefix ||
                       get_tabname(buff.fk_table_id) || '_nk' || i ||
                           ' = o_' || buff.fk_prefix ||
                       get_tabname(buff.fk_table_id) || '_nk' || i ||
                           ')');
               else
                  p('           or not (n_' || buff.fk_prefix ||
                       get_tabname(buff.fk_table_id) || '_nk' || i ||
                           ' = o_' || buff.fk_prefix ||
                       get_tabname(buff.fk_table_id) || '_nk' || i ||
                           ')');
               end if;
            end loop;
            p('          )');
         end if;
      end case;
      p('   then');
      p('      n_' || buff.name || ' := ');
      p('         ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
      for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
      loop
         if i = 1
         then
            p('            (n_' || buff.fk_prefix ||
                            get_tabname(buff.fk_table_id) ||
                            '_nk' || i);
         else
            p('            ,n_' || buff.fk_prefix ||
                            get_tabname(buff.fk_table_id) ||
                            '_nk' || i);
         end if;
      end loop;
      p('            );');
      p('   end if;');
   end loop;
end vtrig_fksets;
----------------------------------------
FUNCTION exception_lines
   RETURN line_t_type PIPELINED
   --  Define PL/SQL Exceptions
IS
   line_rec  line_rec_type;
begin
   for buff in (
      select * from exceptions EXC
       where EXC.application_id = abuff.id
       order by EXC.code desc )
   loop
      line_rec.value := '   ' || buff.name || ' EXCEPTION;';
      pipe row(line_rec);
      line_rec.value := '   PRAGMA EXCEPTION_INIT(' ||
                        buff.name || ', ' || buff.code || ');';
      pipe row(line_rec);
   end loop;
   return;
end exception_lines;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
PROCEDURE def_col_comments
      (tname_in  in  varchar2)
   --  Defined Column Comments
IS
begin
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('comment on column ' || tname_in || '.' || buff.name || ' is ''' ||
         replace(buff.description,SQ1,SQ2) || '''');
      p('/');
   end loop;
end def_col_comments;
----------------------------------------
PROCEDURE pdat_col_comments
      (tname_in  in  varchar2)
   --  POP Data Table Column Comments
IS
begin
   p('comment on column ' || tname_in || '.' || tbuff.name || '_id is ''Surrogate Primary Key from the ACTIVE table''');
   p('/');
   p('comment on column ' || tname_in || '.pop_dml is ''Original DML that was popped: INSERT, UPDATE, or DELETE''');
   p('/');
   p('comment on column ' || tname_in || '.pop_dtm is ''Date/Time this record was popped''');
   p('/');
   p('comment on column ' || tname_in || '.pop_usr is ''User that ran the POP''');
   p('/');
   if tbuff.type = 'EFF'
   then
      p('comment on column ' || tname_in || '.eff_beg_dtm is ''Date/Time this record was effective before being POPed out of active''');
      p('/');
      p('comment on column ' || tname_in || '.eff_prev_beg_dtm is ''Date/Time the previous record was effective before being POPed back to active''');
      p('/');
   end if;
   p('comment on column ' || tname_in || '.aud_beg_usr is ''User that modified this record before being POPed out of active''');
   p('/');
   p('comment on column ' || tname_in || '.aud_prev_beg_usr is ''User that modified the previous record before being POPed back to active''');
   p('/');
   p('comment on column ' || tname_in || '.aud_beg_dtm is ''Date/Time this record was modified before being POPed out of active''');
   p('/');
   p('comment on column ' || tname_in || '.aud_prev_beg_dtm is ''Date/Time the previous record was modified before being POPed back to active''');
   p('/');
   def_col_comments(tname_in);
end pdat_col_comments;
----------------------------------------
PROCEDURE col_comments
      (tname_in  in  varchar2)
   --  Standard Column Comments
IS
begin
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('comment on column ' || tname_in || '.eff_beg_dtm is ''Date/Time this record became effective''');
         p('/');
      end if;
      p('comment on column ' || tname_in || '.aud_beg_usr is ''User that created this record''');
      p('/');
      p('comment on column ' || tname_in || '.aud_beg_dtm is ''Date/Time this record was created (must be in nanoseconds)''');
      p('/');
   end if;
   def_col_comments(tname_in);
end col_comments;
----------------------------------------
PROCEDURE tab_col_comments
      (tname_in  in  varchar2)
   --  Standard Column Comments
IS
begin
   p('comment on column ' || tname_in || '.id is ''Surrogate Primary Key for these ' || tname_in || '''');
   p('/');
   col_comments(tname_in);
end tab_col_comments;
----------------------------------------
PROCEDURE act_col_comments
      (tname_in  in  varchar2)
   --  Active View Column Comments
IS
begin
   tab_col_comments(tname_in);
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'id_path is ''Path of ancestor IDs hierarchy for this record''');
            p('/');
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'nk_path is ''Path of ancestor Natural Key Sets hierarchy for this record''');
            p('/');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('comment on column ' || tname_in || '.' || buff.fk_prefix ||
               get_tabname(buff.fk_table_id) || '_nk' || i || ' is ''' ||
               upper(get_tabname(buff.fk_table_id)) ||
               ' Natural Key Value ' || i || ': ' ||
               replace(nk_aa(buff.fk_table_id).cbuff_va(i).description,SQ1,SQ2) || '''');
            p('/');
         end loop;
      end if;
   end loop;
end act_col_comments;
----------------------------------------
PROCEDURE hoa_col_comments
      (tname_in  in  varchar2)
   --  History or Audit Table Column Comments
IS
begin
   p('comment on column ' || tname_in || '.' || tbuff.name || '_id is ''Surrogate Primary Key from the ACTIVE table''');
   p('/');
   if tbuff.type = 'EFF'
   then
      p('comment on column ' || tname_in || '.eff_end_dtm is ''Date/Time this record was no longer effective''');
      p('/');
   end if;
   p('comment on column ' || tname_in || '.aud_end_usr is ''User that modified this record''');
   p('/');
   p('comment on column ' || tname_in || '.aud_end_dtm is ''Date/Time this record was modified (must be in nanoseconds)''');
   p('/');
   col_comments(tname_in);
   p('comment on column ' || tname_in || '.last_active is ''Flag to indicate this as the last active record''');
   p('/');
end hoa_col_comments;
----------------------------------------
PROCEDURE aa_col_comments
      (tname_in  in  varchar2)
   --  ALL and ASOF Common View Column Comments
IS
begin
   if tbuff.type = 'EFF'
   then
      p('comment on column ' || tname_in || '.eff_beg_dtm is ''Date/Time this record became effective''');
      p('/');
      p('comment on column ' || tname_in || '.eff_end_dtm is ''Date/Time this record was no longer effective''');
      p('/');
   end if;
   p('comment on column ' || tname_in || '.aud_beg_usr is ''User that created this record''');
   p('/');
   p('comment on column ' || tname_in || '.aud_end_usr is ''User that deleted this record''');
   p('/');
   p('comment on column ' || tname_in || '.aud_beg_dtm is ''Date/Time this record was created (must be in nanoseconds)''');
   p('/');
   p('comment on column ' || tname_in || '.aud_end_dtm is ''Date/Time this record was deleted (must be in nanoseconds)''');
   p('/');
end aa_col_comments;
----------------------------------------
PROCEDURE l_col_comments
      (tname_in  in  varchar2)
   --  All Entities Helper View Column Comments
IS
begin
   p('comment on column ' || tname_in || '.' || tbuff.name || '_id is ''Surrogate Primary Key for this table''');
   p('/');
   p('comment on column ' || tname_in || '.stat is ''ACT for active records, DEL for deleted records''');
   p('/');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('comment on column ' || tname_in || '.' || buff.name || ' is ''' ||
         replace(buff.description,SQ1,SQ2) || '''');
      p('/');
      if buff.fk_table_id is not null and
         buff.fk_table_id != tbuff.id
      then
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('comment on column ' || tname_in || '.' || buff.fk_prefix ||
               get_tabname(buff.fk_table_id) || '_nk' || i || ' is ''' ||
               upper(get_tabname(buff.fk_table_id)) ||
               ' Natural Key Value ' || i || ': ' ||
               replace(nk_aa(buff.fk_table_id).cbuff_va(i).description,SQ1,SQ2) || '''');
            p('/');
         end loop;
      end if;
   end loop;
   aa_col_comments(tname_in);
end l_col_comments;
----------------------------------------
PROCEDURE all_col_comments
      (tname_in  in  varchar2)
   --  All Entities View Column Comments
IS
begin
   p('comment on column ' || tname_in || '.id is ''Surrogate Primary Key for this table''');
   p('/');
   p('comment on column ' || tname_in || '.stat is ''ACT for active records, DEL for deleted records''');
   p('/');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('comment on column ' || tname_in || '.' || buff.name || ' is ''' ||
         replace(buff.description,SQ1,SQ2) || '''');
      p('/');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'id_path is ''Path of ancestor IDs hierarchy for this record''');
            p('/');
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'nk_path is ''Path of ancestor Natural Key Sets hierarchy for this record''');
            p('/');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('comment on column ' || tname_in || '.' || buff.fk_prefix ||
               get_tabname(buff.fk_table_id) || '_nk' || i || ' is ''' ||
               upper(get_tabname(buff.fk_table_id)) ||
               ' Natural Key Value ' || i || ': ' ||
               replace(nk_aa(buff.fk_table_id).cbuff_va(i).description,SQ1,SQ2) || '''');
            p('/');
         end loop;
      end if;
   end loop;
   aa_col_comments(tname_in);
end all_col_comments;
----------------------------------------
PROCEDURE f_col_comments
      (tname_in  in  varchar2)
   --  ASOF Helper View Column Comments
IS
begin
   p('comment on column ' || tname_in || '.' || tbuff.name ||'_id is ''Surrogate Primary Key for this table''');
   p('/');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('comment on column ' || tname_in ||'.' || buff.name || ' is ''AS OF ' ||
         replace(buff.description,SQ1,SQ2) || '''');
      p('/');
      if buff.fk_table_id is not null and
         buff.fk_table_id != tbuff.id
      then
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
             p('comment on column ' || tname_in || '.' || buff.fk_prefix ||
               get_tabname(buff.fk_table_id) || '_nk' || i || ' is ''' ||
               upper(get_tabname(buff.fk_table_id)) ||
               ' Natural Key Value ' || i || ': ' ||
               replace(nk_aa(buff.fk_table_id).cbuff_va(i).description,SQ1,SQ2) || '''');
             p('/');
         end loop;
      end if;
   end loop;
   aa_col_comments(tname_in);
end f_col_comments;
----------------------------------------
PROCEDURE asof_col_comments
      (tname_in  in  varchar2)
   --  ASOF View Column Comments
IS
begin
   p('comment on column ' || tname_in || '.id is ''Surrogate Primary Key for this table''');
   p('/');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('comment on column ' || tname_in ||'.' || buff.name || ' is ''AS OF ' ||
         replace(buff.description,SQ1,SQ2) || '''');
      p('/');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'id_path is ''AS OF Path of ancestor IDs hierarchy for this record''');
            p('/');
            p('comment on column ' || tname_in || '.'|| buff.fk_prefix ||
               'nk_path is ''AS OF Path of ancestor Natural Key Sets hierarchy for this record''');
            p('/');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('comment on column ' || tname_in || '.' || buff.fk_prefix ||
               get_tabname(buff.fk_table_id) || '_nk' || i || ' is ''AS OF ' ||
               upper(get_tabname(buff.fk_table_id)) ||
               ' Natural Key Value ' || i || ': ' ||
               replace(nk_aa(buff.fk_table_id).cbuff_va(i).description,SQ1,SQ2) || '''');
            p('/');
         end loop;
      end if;
   end loop;
   aa_col_comments(tname_in);
end asof_col_comments;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
PROCEDURE drop_globals
   --  Drop the Globals
IS
BEGIN
   p('drop package glob');
   p('/');
END drop_globals;
----------------------------------------
--  NOTE: This package is somewhat duplicated
--    in the "create_gd" procedure below.
PROCEDURE create_globals
   --  Create the Globals
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   sp_type := 'package';
   sp_name := 'glob';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Globally available settings and functions');
   p('   --    (Centrally located, but globally visible)');
   header_comments;
   p('');
   p('   -- Current User for Audit');
   p('   procedure set_usr');
   p('         (usr_in  in  ' || usrdt || ');');
   p('   function get_usr');
   p('      return ' || usrdt || ';');
   p('');
   p('   -- TRUE - Table Triggers run TABLE_TAB calls');
   p('   -- FALSE - View_TABs run TABLE_TAB calls');
   p('   procedure set_db_constraints');
   p('      (bool_in  in  boolean);');
   p('   function get_db_constraints');
   p('      return boolean;');
   p('   function get_db_constraints_str');
   p('      return varchar2;');
   p('');
   p('   -- TRUE - Change string data to required case');
   p('   -- FALSE - Check string data for require case');
   p('   procedure set_fold_strings');
   p('      (bool_in  in  boolean);');
   p('   function get_fold_strings');
   p('      return boolean;');
   p('   function get_fold_strings_str');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure to set date/time for ASOF views');
   p('   procedure set_asof_dtm');
   p('         (asof_dtm_in  in  timestamp with time zone);');
   p('   function get_asof_dtm');
   p('      return timestamp with time zone;');
   p('');
   p('   -- TRUE - gen_no_change error is ignored during UPDATE');
   p('   -- FALSE - gen_no_change error is enforced during UPDATE');
   p('   procedure set_ignore_no_change');
   p('      (bool_in  in  boolean);');
   p('   function get_ignore_no_change');
   p('      return boolean;');
   p('   function get_ignore_no_change_str');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure for GLOBAL date/time');
   p('   function get_dtm');
   p('      return timestamp with local time zone;');
   p('');
   p('   -- Centralized procedure to set next ETL start date/time');
   p('   procedure upd_early_eff');
   p('      (table_name  in  varchar2');
   p('      ,eff_dtm_in  in  timestamp);');
   p('');
   p('   -- Centralized procedure GLOBAL locks');
   p('   function request_lock');
   p('         (lockname_in  in  varchar2');
   p('         ,timeout_in   in  INTEGER  default null)');
   p('      return varchar2;');
   p('   function release_lock');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure to delete all application data in database');
   p('   -- procedure delete_all_data;');
   p('');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on ' || sp_name || ' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
   sp_type := 'package body';
   sp_name := 'glob';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('-- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Globally available settings and functions');
   p('--    (Centrally located, but globally visible)');
   header_comments;
   p('');
   p('current_usr           ' || usrfdt || ';');
   p('db_constraints        boolean := true;');
   p('fold_strings          boolean := true;');
   p('asof_dtm              timestamp with time zone := ');
   p('   to_timestamp_tz(''2010-01-01 00:00:00 UTC'',''YYYY-MM-DD HH24:MI:SS TZR'');');
   p('ignore_no_change      boolean := true;');
   p('');
   p('st_lockhandle         varchar2(128);  -- Single Threaded DBMS_LOCK');
   p('st_lockname           varchar2(128);  -- Single Threaded DBMS_LOCK');
   p('');
   p('----------------------------------------');
   p('procedure set_usr');
   p('      (usr_in  in  ' || usrdt || ')');
   p('is');
   p('begin');
   if abuff.usr_datatype is not null
   then
      p('   current_usr := usr_in;');
   else
      p('   current_usr := substr(usr_in,1,30);');
   end if;
   p('end set_usr;');
   p('----------------------------------------');
   p('function get_usr');
   p('   return ' || usrdt);
   p('is');
   p('begin');
   p('   if current_usr is null');
   p('   then');
   p('      raise_application_error(-20002, ''Current User has not been set in the ' ||
                                            initcap(sp_name) || ' Package.'');');
   p('   end if;');
   p('   return current_usr;');
   p('end get_usr;');
   p('----------------------------------------');
   p('procedure set_db_constraints');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   db_constraints := bool_in;');
   p('end set_db_constraints;');
   p('----------------------------------------');
   p('function get_db_constraints');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return db_constraints;');
   p('end get_db_constraints;');
   p('----------------------------------------');
   p('function get_db_constraints_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if db_constraints');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('end get_db_constraints_str;');
   p('----------------------------------------');
   p('procedure set_fold_strings');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   fold_strings := bool_in;');
   p('end set_fold_strings;');
   p('----------------------------------------');
   p('function get_fold_strings');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return fold_strings;');
   p('end get_fold_strings;');
   p('----------------------------------------');
   p('function get_fold_strings_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if fold_strings');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('end get_fold_strings_str;');
   p('----------------------------------------');
   p('procedure set_asof_dtm');
   p('      (asof_dtm_in  in  timestamp with time zone)');
   p('is');
   p('begin');
   p('   asof_dtm := asof_dtm_in;');
   p('end set_asof_dtm;');
   p('----------------------------------------');
   p('function get_asof_dtm');
   p('   return timestamp with time zone');
   p('is');
   p('begin');
   p('   return asof_dtm;');
   p('end get_asof_dtm;');
   p('----------------------------------------');
   p('procedure set_ignore_no_change');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   ignore_no_change := bool_in;');
   p('end set_ignore_no_change;');
   p('----------------------------------------');
   p('function get_ignore_no_change');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return ignore_no_change;');
   p('end get_ignore_no_change;');
   p('----------------------------------------');
   p('function get_ignore_no_change_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if ignore_no_change');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('end get_ignore_no_change_str;');
   p('----------------------------------------');
   p('function get_dtm');
   p('      return timestamp with local time zone');
   p('is');
   p('begin');
   p('   return systimestamp;');
   p('end get_dtm;');
   p('----------------------------------------');
   p('procedure upd_early_eff');
   p('   (table_name  in  varchar2');
   p('   ,eff_dtm_in  in  timestamp)');
   p('   --   Needs a Global Table of some sort to store this.');
   p('is');
   p('begin');
   p('   null;');
   p('end upd_early_eff;');
   p('----------------------------------------');
   p('procedure allocate_lock');
   p('is');
   p('   PRAGMA AUTONOMOUS_TRANSACTION;');
   p('begin');
   p('   dbms_lock.allocate_unique(lockname        => st_lockname');
   p('                            ,lockhandle      => st_lockhandle');
   p('                            ,expiration_secs => 43200);');
   p('end allocate_lock;');
   p('----------------------------------------');
   p('function request_lock');
   p('      (lockname_in  in  varchar2');
   p('      ,timeout_in   in  INTEGER  default null)');
   p('   return varchar2');
   p('is');
   p('   retcd number;');
   p('begin');
   p('   if st_lockname is not null');
   p('   then');
   p('      if st_lockname = lockname_in');
   p('      then');
   p('         return ''SUCCESS'';');
   p('      else');
   p('         return ''RELEASE ONLY'';');
   p('      end if;');
   p('   end if;');
   p('   st_lockname := lockname_in;');
   p('   allocate_lock;');
   p('   retcd := dbms_lock.request(lockhandle        => st_lockhandle');
   p('                             ,lockmode          => DBMS_LOCK.X_MODE');
   p('                             ,timeout           => nvl(timeout_in,DBMS_LOCK.MAXWAIT)');
   p('                             ,release_on_commit => TRUE);');
   p('   case retcd');
   p('      when 0 then');
   p('         return ''SUCCESS'';');
   p('      when 4 then');
   p('         -- This session already owns the lock');
   p('         return ''SUCCESS'';');
   p('      when 1 then');
   p('         st_lockname   := null;');
   p('         return ''TIMEOUT'';');
   p('      when 2 then');
   p('         st_lockname   := null;');
   p('         return ''DEADLOCK'';');
   p('      when 3 then');
   p('         st_lockname   := null;');
   p('         return ''PARAMETER ERROR'';');
   p('      when 5 then');
   p('         st_lockname   := null;');
   p('         return ''ILLEGAL LOCKNAME'';');
   p('   end case;');
   p('   return ''END ERROR'';');
   p('end request_lock;');
   p('----------------------------------------');
   p('function release_lock');
   p('   return varchar2');
   p('is');
   p('   retcd INTEGER;');
   p('begin');
   p('   if st_lockname is null');
   p('   then');
   p('      return ''SUCCESS'';');
   p('   end if;');
   p('   retcd := dbms_lock.release(lockhandle => st_lockhandle);');
   p('   case retcd');
   p('      when 0 then');
   p('         st_lockname := null;');
   p('         return ''SUCCESS'';');
   p('      when 4 then');
   p('         -- This session doesn''t own the lock');
   p('         st_lockname := null;');
   p('         return ''SUCCESS'';');
   p('      when 3 then');
   p('         return ''PARAMETER ERROR'';');
   p('      when 5 then');
   p('         return ''ILLEGAL LOCKNAME'';');
   p('   end case;');
   p('   return ''END ERROR'';');
   p('end release_lock;');
   p('----------------------------------------');
   p('--  NOT GLOBAL: This Procedure is Application Specific');
   p('--procedure delete_all_data');
   p('   --  delete all rows in all tables');
   p('   --  EXECUTE IMMEDIATE is used because these tables');
   p('   --      don''t exist at UTIL PACKAGE compile time');
   p('--is');
   p('--begin');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq desc)
   LOOP
      p('--   EXECUTE IMMEDIATE ''delete from '|| buff.name||''';');
      if buff.type in ('EFF', 'LOG')
      then
         HOA := get_hoa(buff.type);
         p('--   EXECUTE IMMEDIATE ''delete from '|| buff.name||HOA||''';');
         p('--   EXECUTE IMMEDIATE ''delete from '|| buff.name||'_PDAT'';');
      end if;
   end loop;
   p('--   EXECUTE IMMEDIATE ''delete from util_log'';');
   p('--end delete_all_data;');
   p('----------------------------------------');
   p('begin');
   p('   st_lockname := null;');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_globals;
----------------------------------------
PROCEDURE drop_util
   --  Drop the Utility Package
IS
BEGIN
   p('drop package '|| 'util');
   p('/');
   p('drop table '|| 'util_log');
   p('/');
   p('drop type '|| 'col_type');
   p('/');
   p('drop type '|| 'pair_type');
   p('/');
END drop_util;
----------------------------------------
PROCEDURE create_util
   --  Create the Utility Package
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   p('-- Setup Varray Structures for Name/Value Pair Storage');
   p('create type pair_type as object');
   p('   (name  varchar2(30)');
   p('   ,data  varchar2(32767)');
   p('   )');
   p('/');
   show_errors('TYPE', 'PAIR_TYPE');
   ps('');
   ps('grant execute on pair_type to '||abuff.abbr||'_dml');
   ps('/');
   ps('---- audit rename on pair_type by access');
   ps('---- /');
   p('');
   p('create type col_type as varray(100) of pair_type');
   p('/');
   show_errors('TYPE', 'COL_TYPE');
   ps('');
   ps('grant execute on col_type to '||abuff.abbr||'_dml');
   ps('/');
   ps('---- audit rename on col_type by access');
   ps('---- /');
   p('');
   sp_type := 'package';
   sp_name := 'util';
   p('');
   p('-- Table of debug and error messages.');
   p('create table ' || sp_name || '_log');
   p('   (dtm              timestamp with local time zone');
   p('   ,usr              ' || usrfdt);
   p('   ,txt              varchar2(4000)');
   p('   ,loc              varchar2(2000))');
   p('/');
   p('');
   p('create index ' || sp_name || '_log_ix1 on ' || sp_name || '_log (dtm, usr)');
   p('/');
   p('');
   p('comment on table ' || sp_name || '_log is ''Error and Debug Messages''');
   p('/');
   p('');
   p('comment on column ' || sp_name || '_log.dtm is ''System time when message was logged''');
   p('/');
   p('comment on column ' || sp_name || '_log.usr is ''Username from glob.get_usr function''');
   p('/');
   p('comment on column ' || sp_name || '_log.txt is ''Error or Debug message text''');
   p('/');
   p('comment on column ' || sp_name || '_log.loc is ''Location in the source code where the message as logged''');
   p('/');
   ps('');
   ps('grant insert on ' || sp_name || '_log to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- grant update on ' || sp_name || '_log to ' || abuff.abbr || '_app');
   ps('-- /');
   ps('grant delete on ' || sp_name || '_log to ' || abuff.abbr || '_app');
   ps('/');
   ps('grant select on ' || sp_name || '_log to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' || sp_name || '_log by access');
   ps('-- /');
   p('');
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Utility settings and functions');
   p('   --    (A copy is located locally on a each node)');
   header_comments;
   p('');
   p('   -- Separates values within a set of Natural Keys');
   p('   nk_sep  constant varchar2(1) := '','';');
   p('   -- Separates values in a path hierarchy');
   p('   path_sep  constant varchar2(1) := '':'';');
   p('');
   p('   first_dtm  constant timestamp with time zone :=');
   p('        to_timestamp_tz(''1970-01-01 00:00:00 UTC'',''YYYY-MM-DD HH24:MI:SS TZR'');');
   p('   last_dtm   constant timestamp with time zone :=');
   p('        to_timestamp_tz(''4713-12-31 23:59:59 UTC'',''YYYY-MM-DD HH24:MI:SS TZR'');');
   p('');
   p('   function get_version');
   p('      return varchar2;');
   p('');
   p('   function get_first_dtm');
   p('      return timestamp with time zone;');
   p('   function get_last_dtm');
   p('      return timestamp with time zone;');
   p('');
   p('   function is_equal');
   p('         (t1_in  in  varchar2');
   p('         ,t2_in  in  varchar2');
   p('         )');
   p('      return boolean;');
   p('   function is_equal');
   p('         (n1_in  in  number');
   p('         ,n2_in  in  number');
   p('         )');
   p('      return boolean;');
   p('');
   p('   procedure init_longops');
   p('         (opname_in       in  varchar2');
   p('         ,totalwork_in    in  number');
   p('         ,target_desc_in  in  varchar2');
   p('         ,units_in        in  varchar2);');
   p('   procedure add_longops');
   p('         (add_sofar_in  in  number);');
   p('   procedure end_longops;');
   p('');
   p('   procedure log');
   p('         (txt_in  in  varchar2');
   p('         ,loc_in  in  varchar2 default null');
   p('         );');
   p('   procedure err');
   p('         (txt_in  in  varchar2');
   p('         );');
   p('');
   p('   function db_object_exists');
   p('         (name_in  in  varchar2');
   p('         ,type_in  in  varchar2');
   p('         )');
   p('     return boolean;');
   p('');
   p('   function col_to_clob');
   p('         (col_in  in  col_type');
   p('         )');
   p('     return clob;');
   p('   function col_data');
   p('         (col_in   in  col_type');
   p('         ,name_in  in  varchar2');
   p('         )');
   p('     return varchar2;');
   p('');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on ' || sp_name || ' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
   sp_type := 'package body';
   sp_name := 'util';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('-- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Utility settings and functions');
   p('--    (A copy is located locally on a each node)');
   header_comments;
   p('');
   p('lo_context      BINARY_INTEGER;  -- DBMS_APPLICATION.set_session_longops');
   p('lo_op_name      varchar2(64);    -- DBMS_APPLICATION.set_session_longops');
   p('lo_rindex       BINARY_INTEGER;  -- DBMS_APPLICATION.set_session_longops');
   p('lo_slno         BINARY_INTEGER;  -- DBMS_APPLICATION.set_session_longops');
   p('lo_sofar        number;          -- DBMS_APPLICATION.set_session_longops');
   p('lo_totalwork    number;          -- DBMS_APPLICATION.set_session_longops');
   p('lo_target       BINARY_INTEGER;  -- DBMS_APPLICATION.set_session_longops');
   p('lo_target_desc  varchar2(32);    -- DBMS_APPLICATION.set_session_longops');
   p('lo_units        varchar2(32);    -- DBMS_APPLICATION.set_session_longops');
   p('');
   p('----------------------------------------');
   p('function get_version');
   p('   return varchar2');
   p('is');
   p('begin');
   p('   return ''' || ver  || ''';');
   p('end get_version;');
   p('----------------------------------------');
   p('function get_first_dtm');
   p('   return timestamp with time zone');
   p('is');
   p('begin');
   p('   return first_dtm;');
   p('end get_first_dtm;');
   p('----------------------------------------');
   p('function get_last_dtm');
   p('      return timestamp with time zone');
   p('is');
   p('begin');
   p('   return last_dtm;');
   p('end get_last_dtm;');
   p('----------------------------------------');
   p('function is_equal');
   p('      (t1_in  in  varchar2');
   p('      ,t2_in  in  varchar2');
   p('      )');
   p('   return boolean');
   p('is');
   p('begin');
   p('   if t1_in = t2_in or (t1_in is null and t2_in is null)');
   p('   then');
   p('      return TRUE;');
   p('   else');
   p('      return FALSE;');
   p('   end if;');
   p('end is_equal;');
   p('----------------------------------------');
   p('function is_equal');
   p('      (n1_in  in  number');
   p('      ,n2_in  in  number');
   p('      )');
   p('   return boolean');
   p('is');
   p('begin');
   p('   if n1_in = n2_in or (n1_in is null and n2_in is null)');
   p('   then');
   p('      return TRUE;');
   p('   else');
   p('      return FALSE;');
   p('   end if;');
   p('end is_equal;');
   p('----------------------------------------');
   p('procedure init_longops');
   p('      (opname_in       in  varchar2');
   p('      ,totalwork_in    in  number');
   p('      ,target_desc_in  in  varchar2');
   p('      ,units_in        in  varchar2)');
   p('is');
   p('begin');
   p('   if lo_rindex = dbms_application_info.set_session_longops_nohint');
   p('   then');
   p('      lo_slno        := null;');
   p('      lo_op_name     := opname_in;');
   p('      lo_target      := 0;');
   p('      lo_context     := 0;');
   p('      lo_sofar       := 0;');
   p('      lo_totalwork   := totalwork_in;');
   p('      lo_target_desc := target_desc_in;');
   p('      lo_units       := units_in;');
   p('      dbms_application_info.set_session_longops');
   p('         (lo_rindex, lo_slno, lo_op_name, lo_target, lo_context,');
   p('          lo_sofar, lo_totalwork, lo_target_desc, lo_units);');
   p('   end if;');
   p('end init_longops;');
   p('----------------------------------------');
   p('procedure add_longops');
   p('      (add_sofar_in  in  number)');
   p('is');
   p('begin');
   p('   if lo_rindex <> dbms_application_info.set_session_longops_nohint');
   p('   then');
   p('      lo_sofar := lo_sofar + add_sofar_in;');
   p('      dbms_application_info.set_session_longops');
   p('         (lo_rindex, lo_slno, lo_op_name, lo_target, lo_context,');
   p('          lo_sofar, lo_totalwork, lo_target_desc, lo_units);');
   p('   end if;');
   p('end add_longops;');
   p('----------------------------------------');
   p('procedure end_longops');
   p('is');
   p('begin');
   p('   if lo_rindex <> dbms_application_info.set_session_longops_nohint');
   p('   then');
   p('      lo_sofar := lo_totalwork;');
   p('      dbms_application_info.set_session_longops');
   p('         (lo_rindex, lo_slno, lo_op_name, lo_target, lo_context,');
   p('          lo_sofar, lo_totalwork, lo_target_desc, lo_units);');
   p('      lo_rindex := dbms_application_info.set_session_longops_nohint;');
   p('   end if;');
   p('end end_longops;');
   p('----------------------------------------');
   p('procedure log');
   p('      (txt_in  in  varchar2');
   p('      ,loc_in  in  varchar2 default null');
   p('      )');
   p('is');
   p('/*  Sample output from DBMS_UTILITY.FORMAT_CALL_STACK:');
   p('----- PL/SQL Call Stack -----');
   p('  object      line  object');
   p('  handle    number  name');
   p('A4A6A840        76  package body GEN2.UTIL');
   p('AA345744         6  anonymous block');
   p('AA345744        16  anonymous block');
   p('*/');
   p('   PRAGMA AUTONOMOUS_TRANSACTION;');
   p('   usr_buff  ' || usrfdt || ';');
   p('   fcs_txt  varchar2(2000);');
   p('begin');
   p('   -- pragma restrict_references(format_call_stack,WNDS);');
   p('   -- WNDS Asserts that the subprogram writes no database state');
   p('   --      (does not modify database tables).');
   p('   -- DBMS_UTILITY.FORMAT_CALL_STACK returns up to 2000 characters');
   p('   fcs_txt := DBMS_UTILITY.FORMAT_CALL_STACK;');
   p('   begin');
   p('      usr_buff := glob.get_usr;');
   p('   exception when others then');
   p('      usr_buff := null;');
   p('   end;');
   p('   insert into ' || sp_name || '_log');
   p('         (dtm');
   p('         ,usr');
   p('         ,txt');
   p('         ,loc');
   p('         )');
   p('      values');
   p('         (systimestamp');
   p('         ,usr_buff');
   p('         ,substr(txt_in,1,4000)');
   p('         ,nvl(substr(loc_in,1,4000), fcs_txt)');
   p('         );');
   p('   dbms_output.put_line(txt_in || fcs_txt);');
   p('   commit;');
   p('end log;');
   p('----------------------------------------');
   p('procedure err');
   p('      (txt_in  in  varchar2');
   p('      )');
   p('is');
   p('   fcs_txt  varchar2(2000) := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;');
   p('   retstr   varchar2(100);');
   p('begin');
   p('   log (txt_in, fcs_txt);');
   p('   end_longops;');
   p('   retstr := glob.release_lock;');
   p('end err;');
   p('----------------------------------------');
   p('function db_object_exists');
   p('      (name_in  in  varchar2');
   p('      ,type_in  in  varchar2');
   p('      )');
   p('   return boolean');
   p('is');
   p('   cursor c1 is');
   p('      select * from all_objects');
   p('       where object_type = type_in');
   P('        and  object_name = name_in;');
   p('   buf1 c1%ROWTYPE;');
   p('   retb boolean;');
   p('begin');
   p('   open c1;');
   p('   fetch c1 into buf1;');
   p('   retb := c1%FOUND;');
   p('   close c1;');
   p('   return retb;');
   p('end db_object_exists;');
   p('----------------------------------------');
   p('function col_to_clob');
   p('      (col_in  in  col_type');
   p('      )');
   p('   return clob');
   p('is');
   p('   rclob  clob;');
   p('   rlen   number;');
   p('begin');
   p('   rclob := '''';');
   p('   for i in 1 .. col_in.COUNT');
   p('   loop');
   p('      rclob := rclob ||');
   p('               col_in(i).name || '':'' ||');
   p('               col_in(i).data || CHR(10);');
   p('   end loop;');
   p('   rlen := length(rclob);');
   p('   if rlen > 32768');
   p('   then');
   p('      rlen := 32768;');
   p('   end if;');
   p('   return substr(rclob,1,rlen-1);');
   p('exception');
   p('  when SUBSCRIPT_BEYOND_COUNT');
   p('  then');
   p('     return null;');
   p('  when COLLECTION_IS_NULL');
   p('  then');
   p('     return null;');
   p('  when others');
   p('  then');
   p('     raise;');
   p('end col_to_clob;');
   p('----------------------------------------');
   p('function col_data');
   p('         (col_in   in  col_type');
   p('         ,name_in  in  varchar2');
   p('         )');
   p('     return varchar2');
   p('is');
   p('   --');
   p('   -- col_data was used for the POP_AUDIT log table');
   p('   --');
   p('begin');
   p('   for i in 1 .. col_in.COUNT');
   p('   loop');
   p('      if lower(name_in) = lower(col_in(i).name)');
   p('      then');
   p('         return col_in(i).data;');
   p('      end if;');
   p('   end loop;');
   p('   return null;');
   p('exception');
   p('  when SUBSCRIPT_BEYOND_COUNT');
   p('  then');
   p('     return null;');
   p('  when COLLECTION_IS_NULL');
   p('  then');
   p('     return null;');
   p('  when others');
   p('  then');
   p('     raise;');
   p('end col_data;');
   p('----------------------------------------');
   p('begin');
   p('   lo_rindex := dbms_application_info.set_session_longops_nohint;');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
   HOA := '';
END create_util;
----------------------------------------
PROCEDURE drop_gd
   --  Drop the Distributed Globals
IS
BEGIN
   p('drop package glob');
   p('/');
END drop_gd;
----------------------------------------
PROCEDURE create_gd
   --  Create the Distributed Globals
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   sp_type := 'package';
   sp_name := 'glob';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('   -- MT FACADE and CACHE for ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Globally available settings and functions');
   p('   --    (Procedures and functions use link '||abuff.dbid||')');
   header_comments;
   p('');
   p('   -- Current User for Audit');
   p('   procedure set_usr');
   p('         (usr_in  in  ' || usrdt || ');');
   p('   function get_usr');
   p('      return ' || usrdt || ';');
   p('');
   p('   -- TRUE - Table Triggers run TABLE_TAB calls');
   p('   -- FALSE - View_TABs run TABLE_TAB calls');
   p('   procedure set_db_constraints');
   p('      (bool_in  in  boolean);');
   p('   function get_db_constraints');
   p('      return boolean;');
   p('   function get_db_constraints_str');
   p('      return varchar2;');
   p('');
   p('   -- TRUE - Change string data to required case');
   p('   -- FALSE - Check string data for require case');
   p('   procedure set_fold_strings');
   p('      (bool_in  in  boolean);');
   p('   function get_fold_strings');
   p('      return boolean;');
   p('   function get_fold_strings_str');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure to set date/time for ASOF views');
   p('   procedure set_asof_dtm');
   p('         (asof_dtm_in  in  timestamp with time zone);');
   p('   function get_asof_dtm');
   p('      return timestamp with time zone;');
   p('');
   p('   -- TRUE - gen_no_change error is ignored during UPDATE');
   p('   -- FALSE - gen_no_change error is enforced during UPDATE');
   p('   procedure set_ignore_no_change');
   p('      (bool_in  in  boolean);');
   p('   function get_ignore_no_change');
   p('      return boolean;');
   p('   function get_ignore_no_change_str');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure for GLOBAL date/time');
   p('   function get_dtm');
   p('      return timestamp with local time zone;');
   p('');
   p('   -- Centralized procedure to set next ETL start date/time');
   p('   procedure upd_early_eff');
   p('      (table_name  in  varchar2');
   p('      ,eff_dtm_in  in  timestamp);');
   p('');
   p('   -- Centralized procedure GLOBAL locks');
   p('   function request_lock');
   p('      (lockname_in  in  varchar2');
   p('      ,timeout_in   in  INTEGER  default null)');
   p('      return varchar2;');
   p('   function release_lock');
   p('      return varchar2;');
   p('');
   p('   -- Centralized procedure to delete all application data in database');
   p('   --procedure delete_all_data;');
   p('');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on ' || sp_name || ' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
   sp_type := 'package body';
   sp_name := 'glob';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('is');
   p('');
   p('-- MT FACADE ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Globally available settings and functions');
   p('--    (All procedures and functions point to link '||abuff.dbid||')');
   header_comments;
   p('');
   p('current_usr           ' || usrfdt || ';');
   p('db_constraints        boolean := true;');
   p('fold_strings          boolean := true;');
   p('asof_dtm              timestamp with time zone := ');
   p('   to_timestamp_tz(''2010-01-01 00:00:00 UTC'',''YYYY-MM-DD HH24:MI:SS TZR'');');
   p('ignore_no_change      boolean := true;');
   p('');
   p('----------------------------------------');
   p('procedure set_usr');
   p('      (usr_in  in  ' || usrdt || ')');
   p('is');
   p('begin');
   if abuff.usr_datatype is not null
   then
      p('   current_usr := usr_in;');
   else
      p('   current_usr := substr(usr_in,1,30);');
   end if;
   p('   '||abuff.db_auth||'glob.set_usr@'||abuff.dbid||'(usr_in);');
   p('end set_usr;');
   p('----------------------------------------');
   p('function get_usr');
   p('   return ' || usrdt);
   p('is');
   p('begin');
   p('   if current_usr is null');
   p('   then');
   p('      raise_application_error(-20002, ''Current User has not been set in the ' ||
                                            initcap(sp_name) || ' Package.'');');
   p('   end if;');
   p('   return current_usr;');
   p('   --return '||abuff.db_auth||'glob.get_usr@'||abuff.dbid||';');
   p('end get_usr;');
   p('----------------------------------------');
   p('procedure set_db_constraints');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   db_constraints := bool_in;');
   p('   '||abuff.db_auth||'glob.set_db_constraints@'||abuff.dbid||'(bool_in);');
   p('end set_db_constraints;');
   p('----------------------------------------');
   p('function get_db_constraints');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return db_constraints;');
   p('   --return '||abuff.db_auth||'glob.get_db_constraints@'||abuff.dbid||';');
   p('end get_db_constraints;');
   p('----------------------------------------');
   p('function get_db_constraints_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if db_constraints');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('   --return '||abuff.db_auth||'glob.get_db_constraints_str@'||abuff.dbid||';');
   p('end get_db_constraints_str;');
   p('----------------------------------------');
   p('procedure set_fold_strings');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   fold_strings := bool_in;');
   p('   '||abuff.db_auth||'glob.set_fold_strings@'||abuff.dbid||'(bool_in);');
   p('end set_fold_strings;');
   p('----------------------------------------');
   p('function get_fold_strings');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return fold_strings;');
   p('   --return '||abuff.db_auth||'glob.get_fold_strings@'||abuff.dbid||';');
   p('end get_fold_strings;');
   p('----------------------------------------');
   p('function get_fold_strings_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if fold_strings');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('   --return '||abuff.db_auth||'glob.get_fold_strings_str@'||abuff.dbid||';');
   p('end get_fold_strings_str;');
   p('----------------------------------------');
   p('procedure set_asof_dtm');
   p('      (asof_dtm_in  in  timestamp with time zone)');
   p('is');
   p('begin');
   p('   asof_dtm := asof_dtm_in;');
   p('   '||abuff.db_auth||'glob.set_asof_dtm@'||abuff.dbid||'(asof_dtm_in);');
   p('end set_asof_dtm;');
   p('----------------------------------------');
   p('function get_asof_dtm');
   p('   return timestamp with time zone');
   p('is');
   p('begin');
   p('   return asof_dtm;');
   p('   --return '||abuff.db_auth||'glob.get_asof_dtm@'||abuff.dbid||';');
   p('end get_asof_dtm;');
   p('----------------------------------------');
   p('procedure set_ignore_no_change');
   p('      (bool_in  in  boolean)');
   p('is');
   p('begin');
   p('   ignore_no_change := bool_in;');
   p('   '||abuff.db_auth||'glob.set_ignore_no_change@'||abuff.dbid||'(bool_in);');
   p('end set_ignore_no_change;');
   p('----------------------------------------');
   p('function get_ignore_no_change');
   p('      return boolean');
   p('is');
   p('begin');
   p('   return ignore_no_change;');
   p('   --return '||abuff.db_auth||'glob.get_ignore_no_change@'||abuff.dbid||';');
   p('end get_ignore_no_change;');
   p('----------------------------------------');
   p('function get_ignore_no_change_str');
   p('      return varchar2');
   p('is');
   p('begin');
   p('   if ignore_no_change');
   p('   then return ''TRUE'';');
   p('   else return ''FALSE'';');
   p('   end if;');
   p('   --return '||abuff.db_auth||'glob.get_ignore_no_change_str@'||abuff.dbid||';');
   p('end get_ignore_no_change_str;');
   p('----------------------------------------');
   p('function get_dtm');
   p('      return timestamp with local time zone');
   p('is');
   p('begin');
   p('   return '||abuff.db_auth||'glob.get_dtm@'||abuff.dbid||';');
   p('end get_dtm;');
   p('----------------------------------------');
   p('procedure upd_early_eff');
   p('   (table_name  in  varchar2');
   p('   ,eff_dtm_in  in  timestamp)');
   p('   --   Needs a Global Table of some sort to store this.');
   p('is');
   p('begin');
   p('   null;');
   p('   --'||abuff.db_auth||'glob.upd_early_eff@'||abuff.dbid||'(table_name, eff_dtm_in);');
   p('end upd_early_eff;');
   p('----------------------------------------');
   p('function request_lock');
   p('      (lockname_in  in  varchar2');
   p('      ,timeout_in   in  INTEGER  default null)');
   p('   return varchar2');
   p('is');
   p('begin');
   p('   return '||abuff.db_auth||'glob.request_lock@'||abuff.dbid||'(lockname_in, timeout_in);');
   p('end request_lock;');
   p('----------------------------------------');
   p('function release_lock');
   p('   return varchar2');
   p('is');
   p('begin');
   p('   return '||abuff.db_auth||'glob.release_lock@'||abuff.dbid||';');
   p('end release_lock;');
   p('----------------------------------------');
   p('--procedure delete_all_data;');
   p('--is');
   p('--begin');
   p('--   '||abuff.db_auth||'glob.delete_all_data@'||abuff.dbid||';');
   p('--end delete_all_data;');
   p('----------------------------------------');
   p('end ' || sp_name || ';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_gd;
----------------------------------------
PROCEDURE drop_tab
   --  For a tbuff, drop the tables
IS
BEGIN
   ps('');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop table '|| tbuff.name||'_PDAT');
      p('/');
      p('drop table '|| tbuff.name||HOA);
      p('/');
   end if;
   p('drop table '|| tbuff.name);
   p('/');
   p('drop sequence '|| tbuff.name||'_seq');
   p('/');
END drop_tab;
----------------------------------------
PROCEDURE create_tab_act
   --  For a tbuff, create the tables
IS
   tname    varchar2(30);
BEGIN
   --  For a tbuff, create the sequence
   p('create sequence '|| tbuff.name||'_seq');
   p('/');
   ps('');
   ps('grant alter on '|| tbuff.name||'_seq to '||abuff.abbr||'_dml');
   ps('/');
   ps('grant select on '|| tbuff.name||'_seq to '||abuff.abbr||'_app');
   ps('/');
   ps('-- audit rename on '|| tbuff.name||'_seq by access');
   ps('-- /');
   p('');
   --  Create the ACTIVE table
   tname := tbuff.name;
   p('create table ' || tname);
   p('   (id   NUMBER(38)');
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('   ,eff_beg_dtm   timestamp(9) with local time zone');
         p('         constraint ' || tname || '_nnh1 not null');
      end if;
      p('   ,aud_beg_usr   ' || usrfdt);
      p('         constraint ' || tname || '_nnh3 not null');
      -- Note: aud_beg_dtm and aud_end_dtm must be in nanoseconds
      p('   ,aud_beg_dtm   timestamp(9) with local time zone');
      p('         constraint ' || tname || '_nnh5 not null');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   ,'||buff.name||'   '||get_dtype_full(buff, 'DB'));
      if buff.nk  is not null or
         buff.req is not null
      then
         p('         constraint ' || tname || '_nn' || buff.seq || ' not null');
      end if;
   end loop;
   p('   )' || get_pctfree('ONLN','DATA') || get_tspace('ONLN','DATA'));
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if get_dtype(buff, 'DB') like '%LOB'
      then
         -- Oracle® Database SecureFiles and Large Objects Developer's Guide
         --   11g Release 2 (11.2)   Part Number E18294-01
         --   LOB Storage Parameters: Defining Tablespace and Storage
         --                           Characteristics for Persistent LOBs
         p('   LOB (' || buff.name || ') STORE AS BASICFILE ' || tbuff.name ||
                   '_' || substr(get_dtype(buff,'DB'),1,2) || buff.seq );
         p('       (CACHE LOGGING' || get_tspace('ONLN','DATA') || ')');
      end if;
   end loop;
   p('/');
   ps('');
   ps('grant select on ' || tname|| ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('grant insert on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('grant update on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('grant delete on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('-- audit rename on ' || tname || ' by access');
   ps('-- /');
   p('');
   p('comment on table ' || tname || ' is ''' || 
      replace(tbuff.description,SQ1,SQ2) || '''');
   p('/');
   p('');
   tab_col_comments(tname);
   p('');
   --  Primary Key
   p('alter table ' || tname || ' add constraint ' || tname || '_pk');
   p('   primary key (id)' || get_pctfree('ONLN','INDX') ||
                              get_tspace('ONLN','INDX',TRUE));
   p('/');
   p('');
   --  Create the Materialized View Log
   if tbuff.mv_refresh_hr IS NOT NULL
   then
      p('--  Oracle11g eXpress Edition does not allow materialized view logs');
      p('create materialized view log on '|| tname||
            get_pctfree('ONLN','DATA') || get_tspace('ONLN','DATA'));
      p('/');
      p('');
   end if;
END create_tab_act;
----------------------------------------
PROCEDURE create_tab_hoa
   --  For a tbuff, create the history tables
IS
   tname  varchar2(30);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- There is no HIST table
      return;
   end if;
   --  Create the HIST Table
   tname := tbuff.name || HOA;
   p('create table ' || tname);
   p('   (' || tbuff.name || '_id   NUMBER(38)');
   if tbuff.type = 'EFF'
   then
      p('   ,eff_beg_dtm   timestamp(9) with local time zone');
      p('         constraint ' || tname || '_nnh1 not null');
      p('   ,eff_end_dtm   timestamp(9) with local time zone');
      p('         constraint ' || tname || '_nnh2 not null');
   end if;
   p('   ,aud_beg_usr   ' || usrfdt);
   p('         constraint ' || tname || '_nnh3 not null');
   p('   ,aud_end_usr   ' || usrfdt);
   p('         constraint ' || tname || '_nnh4 not null');
   -- Note: aud_beg_dtm and aud_end_dtm must be in nanoseconds
   p('   ,aud_beg_dtm   timestamp(9) with local time zone');
   p('         constraint ' || tname || '_nnh5 not null');
   p('   ,aud_end_dtm   timestamp(9) with local time zone');
   p('         constraint ' || tname || '_nnh6 not null');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   ,'||buff.name||'   '||get_dtype_full(buff, 'DB'));
   end loop;
   p('   ,last_active  varchar2(1)');
   p('   )' || get_pctfree('HIST','DATA') || get_tspace('HIST','DATA'));
   p('/');
   ps('');
   ps('grant select on ' || tname|| ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('grant insert on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('-- grant update on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('-- /');
   ps('grant delete on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('-- audit rename on ' || tname || ' by access');
   ps('-- /');
   p('');
   p('comment on table ' || tname || ' is ''' ||
      replace(tbuff.description,SQ1,SQ2) || ' (history)''');
   p('/');
   p('');
   hoa_col_comments(tname);
   p('');
   trig_no_dml(tname, 'table', 'update');
   p('');
   --  Create the POP Table
   tname := tbuff.name || '_PDAT';
   p('create table ' || tname);
   p('   (' || tbuff.name || '_id       NUMBER(38)');
   p('   ,pop_dml              varchar2(6)');
   p('         constraint ' || tname || '_nnp1 not null');
   p('   ,pop_dtm              timestamp(9)');
   p('         constraint ' || tname || '_nnp2 not null');
   p('   ,pop_usr              ' || usrfdt);
   p('         constraint ' || tname || '_nnp3 not null');
   if tbuff.type = 'EFF'
   then
      p('   ,eff_beg_dtm          timestamp(9) with local time zone');
      p('         constraint ' || tname || '_nnh1 not null');
      p('   ,eff_prev_beg_dtm     timestamp(9) with local time zone');
      -- POP INSERT has no eff_prev_beg_dtm for this column
      --p('         constraint ' || tname || '_nnh2 not null');
   end if;
   p('   ,aud_beg_usr          ' || usrfdt);
   p('         constraint ' || tname || '_nnh3 not null');
   p('   ,aud_prev_beg_usr     ' || usrfdt);
   -- POP INSERT has no aud_prev_beg_usr for this column
   --p('         constraint ' || tname || '_nnh4 not null');
   p('   ,aud_beg_dtm          timestamp(9) with local time zone');
   p('         constraint ' || tname || '_nnh5 not null');
   p('   ,aud_prev_beg_dtm     timestamp(9) with local time zone');
   -- POP INSERT has no aud_prev_beg_dtm for this column
   --p('         constraint ' || tname || '_nnh6 not null');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   ,'||buff.name||'     '||get_dtype_full(buff, 'DB'));
      --  Can't add these non-null constraints because a 'DELETE' pop hsa no data
      --if buff.nk  is not null or
      --   buff.req is not null
      --then
      --   p('         constraint ' || tname || '_nn' || buff.seq || ' not null');
      --end if;
   end loop;
   p('   )' || get_pctfree('PDAT','DATA') || get_tspace('PDAT','DATA'));
   p('/');
   ps('');
   ps('grant select on ' || tname|| ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('grant insert on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('-- grant update on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('-- /');
   ps('grant delete on ' || tname|| ' to ' || abuff.abbr || '_dml');
   ps('/');
   ps('-- audit rename on ' || tname || ' by access');
   ps('-- /');
   p('');
   p('comment on table ' || tname || ' is ''' ||
      replace(tbuff.description,SQ1,SQ2) || ' (POP function audit log)''');
   p('/');
   p('');
   pdat_col_comments(tname);
   p('');
   trig_no_dml(tname, 'table', 'update');
END create_tab_hoa;
----------------------------------------
PROCEDURE drop_pop
   --  For a tbuff, drop the pop package
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop package '|| tbuff.name||'_pop');
      p('/');
   end if;
END drop_pop;
----------------------------------------
--  NOTE: The at_server function is somewhat
--    duplicated in the "create_rem" procedure below
PROCEDURE create_pop_spec
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      --  There is nothing to POP
	  return;
   end if;
   sp_type := 'package';
   sp_name := tbuff.name||'_pop';
   p('create '|| sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Pop (UNDO) functions');
   p('   --    (Centrally located, but globally visible)');
   header_comments;
   p('');
   p('   procedure at_server');
   p('         (id_in  in  number);');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on ' || sp_name || ' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
END create_pop_spec;
----------------------------------------
PROCEDURE create_pop_body
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   nkseq    number(2);
   tstr     varchar2(200);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      --  There is nothing to POP
	  return;
   end if;
   sp_type := 'package body';
   sp_name := tbuff.name||'_pop';
   p('create ' || sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('-- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Pop (UNDO) functions');
   p('--    (Centrally located, but globally visible)');
   header_comments;
   p('');
   p('----------------------------------------');
   p('function tab_to_col');
   p('      (id_in  in  number)');
   p('   return col_type');
   p('is');
   p('   -- This function is duplicated in '||tbuff.name||'_DML');
   p('   cursor acur is');
   p('      select * from ' || tbuff.name);
   p('       where id = id_in;');
   p('   abuf   acur%ROWTYPE;');
   p('   rcol      col_type;');
   p('begin');
   p('   open acur;');
   p('   fetch acur into abuf;');
   p('   if acur%NOTFOUND');
   p('   then');
   p('      rcol := COL_TYPE(null);');
   p('      close acur;');
   p('      return rcol;');
   p('   end if;');
   p('   rcol := COL_TYPE');
   nkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if buff.type like 'DATE%'   OR
         buff.type like 'TIMESTAMP%'
      then
         tstr := ''', to_char(abuf.' || buff.name ||
                   ', ''' || get_colformat(buff) || '''))';
      elsif buff.type like 'NUMBER%' OR
         buff.fk_table_id is not null
      then
         tstr := ''', to_char(abuf.' || buff.name || '))';
      else
         tstr := ''', abuf.' || buff.name || ')';
      end if;
      if nkseq = 0
      then
         p('             (PAIR_TYPE(''' || buff.name || tstr);
         nkseq := 1;
      else
         p('             ,PAIR_TYPE(''' || buff.name || tstr);
      end if;
   end loop;
   p('                );');
   p('   close acur;');
   p('   return rcol;');
   p('end tab_to_col;');
   p('----------------------------------------');
   p('procedure at_server');
   p('      (id_in  in  number)');
   p('is');
   p('   cursor acur is');
   p('      select * from ' || tbuff.name);
   p('       where id = id_in;');
   p('   abuf   acur%ROWTYPE;');
   p('   cursor hcur is');
   p('      select * from ' || tbuff.name || HOA);
   p('       where ' || tbuff.name || '_id = id_in');
   p('       order by aud_end_dtm desc;');
   p('   hbuf   hcur%ROWTYPE;');
   p('   rcol      col_type;');
   p('   orig_dbc  boolean := null;');
   p('begin');
   p('   -- Turn off trigger checks and history records');
   p('   orig_dbc := glob.get_db_constraints;');
   p('   glob.set_db_constraints(FALSE);');
   p('   -- Check for a current record');
   p('   open acur;');
   p('   fetch acur into abuf;');
   p('   if acur%NOTFOUND');
   p('   then');
   p('      -- No current record found');
   p('      -- Check for any history/audit records');
   p('      open hcur;');
   p('      fetch hcur into hbuf;');
   p('      -- if hcur%NOTFOUND');
   p('      -- then');
   p('      --    -- There are no history/audit records');
   p('      --    ERROR: NOTHING TO POP');
   p('      -- end if');
   p('      if hcur%FOUND');
   p('      then');
   p('         -- Found history/audit records');
   p('         -- Add the History/Audit record to the pop_audit table');
   p('         insert into ' || tbuff.name || '_PDAT');
   p('               (' || tbuff.name || '_id');
   p('               ,pop_dml');
   p('               ,pop_dtm');
   p('               ,pop_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm');
      p('               ,eff_prev_beg_dtm');
   end if;
   p('               ,aud_beg_usr');
   p('               ,aud_prev_beg_usr');
   p('               ,aud_beg_dtm');
   p('               ,aud_prev_beg_dtm)');
   p('            values');
   p('               (hbuf.' || tbuff.name || '_id');
   p('               ,''DELETE''');
   p('               ,glob.get_dtm');
   p('               ,glob.get_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,hbuf.eff_end_dtm');
      p('               ,hbuf.eff_beg_dtm');
   end if;
   p('               ,hbuf.aud_end_usr');
   p('               ,hbuf.aud_beg_usr');
   p('               ,hbuf.aud_end_dtm');
   p('               ,hbuf.aud_beg_dtm);');
   p('         -- Add the last history/audit record to the ' || tbuff.name || ' table');
   p('         insert into ' || tbuff.name);
   p('               (id');
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('               ,'||buff.name);
   end loop;
   p('               ,aud_beg_dtm');
   p('               ,aud_beg_usr');
   p('               )');
   p('            values');
   p('               (hbuf.' || tbuff.name || '_id');
   if tbuff.type = 'EFF'
   then
      p('               ,hbuf.eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('               ,hbuf.' || buff.name);
   end loop;
   p('               ,hbuf.aud_beg_dtm');
   p('               ,hbuf.aud_beg_usr');
   p('               );');
   p('         -- Delete the last history/audit record from the history/audit table');
   p('         delete from ' || tbuff.name || HOA);
   p('          where ' || tbuff.name || '_id = id_in');
   if tbuff.type = 'EFF'
   then
      p('           and  eff_beg_dtm = hbuf.eff_beg_dtm;');
   else
      p('           and  aud_beg_dtm = hbuf.aud_beg_dtm;');
   end if;
   p('      end if;');
   p('      close hcur;');
   p('   else');
   p('      -- Found a current record');
   p('      -- Build the ACTIVE record COL object');
   p('      rcol := tab_to_col(id_in);');
   p('      -- Check for any history/audit records');
   p('      open hcur;');
   p('      fetch hcur into hbuf;');
   p('      if hcur%NOTFOUND');
   p('      then');
   p('         -- No history/audit records found');
   p('         -- Add the Active record to the pop_audit table');
   p('         insert into ' || tbuff.name || '_PDAT');
   p('               (' || tbuff.name || '_id');
   p('               ,pop_dml');
   p('               ,pop_dtm');
   p('               ,pop_usr');
   p('               ,aud_beg_dtm');
   p('               ,aud_beg_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
         p('               ,' || buff.name);
   end loop;
   p('               )');
   p('            values');
   p('               (abuf.id');
   p('               ,''INSERT''');
   p('               ,glob.get_dtm');
   p('               ,glob.get_usr');
   p('               ,abuf.aud_beg_dtm');
   p('               ,abuf.aud_beg_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,abuf.eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
         p('               ,abuf.' || buff.name);
   end loop;
   p('               );');
   p('         delete from  ' || tbuff.name);
   p('          where id = id_in;');
   p('         -- util.log(''POPed insert of ' || tbuff.name || ' record: '' ||');
   p('         --          substr(util.col_to_clob(rcol),1,32000));');
   p('      else');
   p('         -- Found history/audit records');
   p('         -- Add the Active and History/Audit record to the pop_audit table');
   p('         insert into ' || tbuff.name || '_PDAT');
   p('               (' || tbuff.name || '_id');
   p('               ,pop_dml');
   p('               ,pop_dtm');
   p('               ,pop_usr');
   p('               ,aud_beg_dtm');
   p('               ,aud_prev_beg_dtm');
   p('               ,aud_beg_usr');
   p('               ,aud_prev_beg_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm');
      p('               ,eff_prev_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
         p('               ,' || buff.name);
   end loop;
   p('               )');
   p('            values');
   p('               -- Add History/Audit dates/users to pop_audit');
   p('               (abuf.id');
   p('               ,''UPDATE''');
   p('               ,glob.get_dtm');
   p('               ,glob.get_usr');
   p('               ,hbuf.aud_end_dtm');
   p('               ,hbuf.aud_beg_dtm');
   p('               ,hbuf.aud_end_usr');
   p('               ,hbuf.aud_beg_usr');
   if tbuff.type = 'EFF'
   then
      p('               ,hbuf.eff_end_dtm');
      p('               ,hbuf.eff_beg_dtm');
   end if;
   p('               -- Add Active data to pop_audit');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
         p('               ,abuf.' || buff.name);
   end loop;
   p('               );');
   p('         -- Update ' || tbuff.name || ' table from the last history/audit record');
   p('         update ' || tbuff.name);
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('           set  ' || buff.name || ' = hbuf.' || buff.name);
         nkseq := 2;
      else
         p('               ,' || buff.name || ' = hbuf.' || buff.name);
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm = hbuf.eff_beg_dtm');
   end if;
   p('               ,aud_beg_usr = hbuf.aud_beg_usr');
   p('               ,aud_beg_dtm = hbuf.aud_beg_dtm');
   p('          where id = hbuf.' || tbuff.name || '_id;');
   p('         -- Delete the last history/audit record from the history/audit table');
   p('         delete from  ' || tbuff.name || HOA);
   p('          where ' || tbuff.name || '_id = id_in');
   if tbuff.type = 'EFF'
   then
      p('           and  eff_beg_dtm = hbuf.eff_beg_dtm;');
   else
      p('           and  aud_beg_dtm = hbuf.aud_beg_dtm;');
   end if;
   p('         -- util.log(''POPed insert of ' || tbuff.name || ' record: '' ||');
   p('         --          substr(util.col_to_clob(rcol),1,32000));');
   p('      end if;');
   p('      close hcur;');
   p('   end if;');
   p('   close acur;');
   p('   -- Restore trigger checks and history records');
   p('   glob.set_db_constraints(orig_dbc);');
   p('exception');
   p('   when others then');
   p('      util.err(sqlerrm);');
   p('      if orig_dbc is not null then');
   p('         glob.set_db_constraints(orig_dbc);');
   p('      end if;');
   p('      raise;');
   p('end at_server;');
   p('----------------------------------------');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_pop_body;
----------------------------------------
PROCEDURE drop_tp
   --  For a tbuff, drop the tab package
IS
BEGIN
   p('drop package ' || tbuff.name||'_tab');
   p('/');
END drop_tp;
----------------------------------------
PROCEDURE create_tp_spec
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   sp_type := 'package';
   sp_name := tbuff.name||'_tab';
   p('create ' || sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Table functions');
   p('   --    (DML and integrity checks)');
   p('   --    ');
   header_comments;
   p('');
   p('   procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,n_aud_beg_usr  out  ' || usrdt);
      p('      ,n_aud_beg_dtm  out  timestamp with local time zone');
   end if;
   p('      );');
   p('   procedure upd');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in   ' || usrdt);
      p('      ,n_aud_beg_usr  out  ' || usrdt);
      p('      ,o_aud_beg_dtm  in   timestamp with local time zone');
      p('      ,n_aud_beg_dtm  out  timestamp with local time zone');
   end if;
   p('      );');
   p('   procedure del');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package Delete History columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in  ' || usrdt);
      p('      ,o_aud_beg_dtm  in  timestamp with local time zone');
   end if;
   p('      );');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on '||sp_name||' to '||abuff.abbr||'_dml');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access;');
   ps('---- /');
   p('');
END create_tp_spec;
----------------------------------------
PROCEDURE create_tp_body
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   nkseq    number(2);
BEGIN
   sp_type := 'package body';
   sp_name := tbuff.name||'_tab';
   p('create ' || sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('-- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Table functions');
   p('--    (DML and integrity checks)');
   header_comments;
   p('');
   p('----------------------------------------');
   p('procedure check_rec');
   p('      (id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,'||buff.name||'  in out  '||get_dtype(buff));
   end loop;
   p('      )');
   p('is');
   p('begin');
   p('   -- Fold the case, as needed');
   select count(COL.name)
    into  nkseq
    from             tab_cols COL
     left outer join domains  DOM on DOM.id = COL.d_domain_id
    where (   COL.fold        is not null
           or COL.d_domain_id is not null )
     and  COL.table_id = tbuff.id;
   if nkseq > 0
   then
      p('   if glob.get_fold_strings');
      p('   then');
      for buff in (
         select COL.name
               ,nvl(DOM.fold, COL.fold) fold
          from             tab_cols COL
           left outer join domains  DOM on DOM.id = COL.d_domain_id
          where (   COL.fold        is not null
                 or COL.d_domain_id is not null )
           and  COL.table_id = tbuff.id
          order by COL.seq )
      loop
         case buff.fold
         when 'U' then
            p('      ' || buff.name || ' := upper(' || buff.name || ');');
         when 'L' then
            p('      ' || buff.name || ' := lower(' || buff.name || ');');
         when 'I' then
            p('      ' || buff.name || ' := initcap(' || buff.name || ');');
         end case;
      end loop;
      p('   else');
      for buff in (
         select COL.name
               ,nvl(DOM.fold, COL.fold) fold
          from             tab_cols COL
           left outer join domains  DOM on DOM.id = COL.d_domain_id
          where (   COL.fold        is not null
                 or COL.d_domain_id is not null )
           and  COL.table_id = tbuff.id
          order by COL.seq )
      loop
         case buff.fold
         when 'U' then
            p('      if ' || buff.name || ' != upper(' || buff.name || ')');
            p('      then');
            p('         raise_application_error(-20003, ''' || sp_name || '.check_rec' ||
                             '(): ' || buff.name || ' must be upper case.'');');
            p('      end if;');
         when 'L' then
            p('      if ' || buff.name || ' != lower(' || buff.name || ')');
            p('      then');
            p('         raise_application_error(-20003, ''' || sp_name || '.check_rec' ||
                             '(): ' || buff.name || ' must be lower case.'');');
            p('      end if;');
         when 'I' then
            p('      if ' || buff.name || ' != initcap(' || buff.name || ')');
            p('      then');
            p('         raise_application_error(-20003, ''' || sp_name || '.check_rec' ||
                             '(): ' || buff.name || ' must be initial case.'');');
            p('      end if;');
         end case;
      end loop;
      p('   end if;');
   end if;
   p('   --  Check for NOT NULL');
   for buff in
      (select * from tab_cols COL
        where (   COL.req is not null
               or COL.nk  is not null )
         and  COL.table_id    = tbuff.id
        order by COL.seq)
   loop
      p('   if ' || buff.name || ' is null');
      p('   then');
      p('      raise_application_error(-20004, ''' || sp_name || '.check_rec' ||
                    '(): ' || buff.name || ' cannot be null.'');');
      p('   end if;');
   end loop;
   p('   -- Check for Domain Values');
   for buff in
      (select * from tab_cols COL
        where d_domain_id is not null
         and  COL.table_id = tbuff.id
        order by COL.seq)
   loop
      p('   if '|| buff.name || ' not in ' || get_domlist(buff.d_domain_id));
      p('   then');
      p('      raise_application_error(-20005, ''' || sp_name || '.check_rec' ||
                    '(): ' || buff.name || ' must be one of ' ||
                    replace(get_domlist(buff.d_domain_id),SQ1,'"') || '.'');');
      p('   end if;');
   end loop;
   p('   -- Custom Constraint Checks');
   for buff in (
      select * from check_cons CK
       where CK.table_id = tbuff.id
       order by CK.seq )
   loop
      p('   if not (' || replace(buff.text,''',''''') || ')');
      p('   then');
      p('      raise_application_error(-20006, ''' || sp_name || '.check_rec' ||
                    '(): ' || replace(buff.description,SQ1,'"') || ''');');
      p('   end if;');
   end loop;
   p('   --  Set eff_beg_dtm, if needed');
   if tbuff.type = 'EFF'
   then
      p('   if eff_beg_dtm is null');
      p('   then');
      p('      eff_beg_dtm := systimestamp;');
      p('   elsif eff_beg_dtm > systimestamp + to_dsinterval (''0 00:00:10'')');
      p('   then');
      p('      raise_application_error(-20007, ''' || sp_name || '.check_rec' ||
                     '(): eff_beg_dtm cannot be in the future.'');');
      p('   else');
      p('       glob.upd_early_eff(''' || tbuff.name || ''', eff_beg_dtm);');
      p('   end if;');
   end if;
   p('end check_rec;');
   p('----------------------------------------');
   p('procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,n_aud_beg_usr  out  ' || usrdt);
      p('      ,n_aud_beg_dtm  out  timestamp with local time zone');
   end if;
   p('      )');
   p('is');
   p('   sql_txt  varchar2(200);');
   p('begin');
   p('   -- Set n_id, if needed');
   p('   if n_id is null');
   p('   then');
   if abuff.dbid is null
   then
      p('      select '||tbuff.name||'_seq.nextval');
      p('       into  n_id from dual;');
   else
      p('      -- This is required because synonyms to remote sequences do not work');
      p('      sql_txt := ''select '||tbuff.name||'_seq.nextval'';');
      p('      if NOT util.db_object_exists(''' || upper(tbuff.name)||'_SEQ'', ''SEQUENCE'')');
      p('      then');
      p('         sql_txt := sql_txt || ''@' || abuff.dbid || ''';');
      p('      end if;');
      p('      sql_txt := sql_txt || '' into :a from dual'';');
      p('      execute immediate sql_txt into n_id;');
   end if;
   p('   end if;');
   p('   check_rec (n_id');
   if tbuff.type = 'EFF'
   then
      p('             ,n_eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('             ,n_'||buff.name);
   end loop;
   p('             );');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   n_aud_beg_usr := glob.get_usr;');
      p('   n_aud_beg_dtm := glob.get_dtm;');
   end if;
   p('end ins;') ;
   p('----------------------------------------');
   p('procedure upd');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in      timestamp with local time zone');
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in      '||get_dtype(buff));
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in   ' || usrdt);
      p('      ,n_aud_beg_usr  out  ' || usrdt);
      p('      ,o_aud_beg_dtm  in   timestamp with local time zone');
      p('      ,n_aud_beg_dtm  out  timestamp with local time zone');
   end if;
   p('      )');
   p('is');
   p('begin');
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         if buff.nk is null and buff.req is null
         then
            p('   if     util.is_equal(o_' || buff.name ||
                                    ', n_' || buff.name || ')');
         else
            p('   if     o_' || buff.name || ' = n_' || buff.name);
         end if;
         nkseq := 2;
      else
         if buff.nk is null and buff.req is null
         then
            p('      and util.is_equal(o_' || buff.name ||
                                    ', n_' || buff.name || ')');
         else
            p('      and o_' || buff.name || ' = n_' || buff.name);
         end if;
      end if;
   end loop;
   p('   then');
   p('      if glob.get_ignore_no_change');
   p('      then');
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('         -- If no beg_dtm was set, :new.beg_dtm will be the same as :old.beg_dtm');
      end if;
      p('         n_aud_beg_usr := o_aud_beg_usr;');
      p('         n_aud_beg_dtm := o_aud_beg_dtm;');
   end if;
   p('         return;');
   p('      end if;');
   p('      raise_application_error(-20008, ''' || sp_name || '.upd' ||
            '(): Must update one of''');
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('            || '' ' || buff.name || '''');
         nkseq := 2;
      else
         p('            || '', ' || buff.name || '''');
      end if;
   end loop;
   p('            || ''.'');');
   p('   end if;');
   p('   check_rec (o_id');
   if tbuff.type = 'EFF'
   then
      p('             ,n_eff_beg_dtm');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('             ,n_'||buff.name);
   end loop;
   p('             );');
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('  -- If no beg_dtm was set, :new.beg_dtm will be the same as :old.beg_dtm');
         p('   if n_eff_beg_dtm <= o_eff_beg_dtm');
         p('   then');
         p('      n_eff_beg_dtm := systimestamp;');
         p('   elsif n_eff_beg_dtm <= o_eff_beg_dtm');
         p('   then');
         p('      raise_application_error(-20009, ''' || sp_name || '.upd' ||
                  '(): The new Effectivity Date must be greater than '' || o_eff_beg_dtm);');
         p('   end if;');
      end if;
      p('   n_aud_beg_usr := glob.get_usr;');
      p('   n_aud_beg_dtm := glob.get_dtm;');
      p('   if n_aud_beg_dtm <= o_aud_beg_dtm');
      p('   then');
      p('      raise_application_error(-20009, ''' || sp_name || '.upd' ||
               '(): The New Audit Date must be greater than '' || o_aud_beg_dtm);');
      p('   end if;');
      p('   insert into '||tbuff.name || HOA);
      p('         (' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('         ,eff_beg_dtm');
         p('         ,eff_end_dtm');
      end if;
      --  Generate an insert column list
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
           order by COL.seq )
       loop
         p('         ,'||buff.name);
      end loop;
      p('         ,aud_beg_usr');
      p('         ,aud_end_usr');
      p('         ,aud_beg_dtm');
      p('         ,aud_end_dtm');
      p('         )');
      p('   values') ;
      p('         (o_id');
      if tbuff.type = 'EFF'
      then
         p('         ,o_eff_beg_dtm');
         p('         ,n_eff_beg_dtm');
      end if;
      -- Generate an insert values list
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('         ,o_'||buff.name||'');
      end loop;
      p('         ,o_aud_beg_usr');
      p('         ,n_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
      p('         ,n_aud_beg_dtm');
      p('         );');
   end if;
   p('end upd;') ;
   p('----------------------------------------');
   p('procedure del');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in      timestamp with local time zone');
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup History Table insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in   ' || usrdt);
      p('      ,o_aud_beg_dtm  in   timestamp with local time zone');
   end if;
   p('      )');
   p('is');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   n_aud_beg_usr  ' || usrfdt || ';');
      p('   n_aud_beg_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('   if x_eff_end_dtm is null or');
         p('      x_eff_end_dtm > systimestamp + to_dsinterval (''0 00:00:10'')');
         p('   then');
         p('      x_eff_end_dtm := systimestamp;');
         p('   else');
         p('      if x_eff_end_dtm < o_eff_beg_dtm');
         p('      then');
         p('         x_eff_end_dtm := o_eff_beg_dtm;');
         p('      end if;');
         p('      glob.upd_early_eff(''' || tbuff.name || ''', x_eff_end_dtm);');
         p('   end if;');
      end if;
      p('   n_aud_beg_usr := glob.get_usr;');
      p('   n_aud_beg_dtm := glob.get_dtm;');
      p('   if n_aud_beg_dtm <= o_aud_beg_dtm');
      p('   then');
      p('      raise_application_error(-20009, ''' || sp_name || '.del' ||
               '(): The New Audit Date must be greater than '' || o_aud_beg_dtm);');
      p('   end if;');
      p('   insert into '||tbuff.name || HOA);
      p('         (' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('         ,eff_beg_dtm');
         p('         ,eff_end_dtm');
      end if;
      --  Generate an insert column list
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('         ,'||buff.name);
      end loop;
      p('         ,aud_beg_usr');
      p('         ,aud_end_usr');
      p('         ,aud_beg_dtm');
      p('         ,aud_end_dtm');
      p('         ,last_active)');
      p('   values') ;
      p('         (o_id');
      if tbuff.type = 'EFF'
      then
         p('         ,o_eff_beg_dtm');
         p('         ,x_eff_end_dtm');
      end if;
      -- Generate an insert values list
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('         ,o_'||buff.name||'');
      end loop;
      p('         ,o_aud_beg_usr');
      p('         ,n_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
      p('         ,n_aud_beg_dtm');
      p('         ,''Y'');');
   end if;
   p('   return;') ;
   p('end del;') ;
   p('----------------------------------------');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_tp_body;
----------------------------------------
PROCEDURE drop_sh
   --  For a tbuff, drop the sh package
IS
BEGIN
   if table_self_ref(tbuff.id)
   then
      p('drop package ' || tbuff.name||'_sh');
      p('/');
   end if;
END drop_sh;
----------------------------------------
PROCEDURE create_sh_spec
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   if not table_self_ref(tbuff.id)
   then
      return;
   end if;
   if tbuff.type not in ('EFF', 'LOG')
   then
      return;
   end if;
   sp_type := 'package';
   sp_name := tbuff.name||'_sh';
   p('create ' || sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Self-Referencing Hist/Aud Helper functions');
   p('   --    (_L, _ALL, _F, _ASOF, hierarchy and lookup)');
   header_comments;
   p('');
   -- Setup hierarchy functions
   p('   function get_id_L');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number;');
   p('   function get_id_F');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number;');
   p('');
   p('  function get_nk_L');
   p('      (id_in  in  number)');
   p('   return varchar2;');
   p('  function get_nk_F');
   p('      (id_in  in  number)');
   p('   return varchar2;');
   p('');
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id = tbuff.id
        and  COL.table_id    = tbuff.id )
   loop
      p('   function get_' || buff.fk_prefix || 'id_path_L');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('   function get_' || buff.fk_prefix || 'id_path_F');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('');
      p('   function get_' || buff.fk_prefix || 'nk_path_L');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('   function get_' || buff.fk_prefix || 'nk_path_F');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('');
      p('   function get_' || buff.fk_prefix || 'id_by_id_path_L');
      p('      (id_path_in  varchar2');
      p('      ) return number;');
      p('   function get_' || buff.fk_prefix || 'id_by_id_path_F');
      p('      (id_path_in  varchar2');
      p('      ) return number;');
      p('');
      p('   function get_' || buff.fk_prefix || 'id_by_nk_path_L');
      p('      (nk_path_in  varchar2');
      p('      ) return number;');
      p('   function get_' || buff.fk_prefix || 'id_by_nk_path_F');
      p('      (nk_path_in  varchar2');
      p('      ) return number;');
      p('');
   end loop;
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on '||sp_name||' by access');
   ps('---- /');
   p('');
END create_sh_spec;
----------------------------------------
PROCEDURE create_sh_body
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   nkseq    number(2);
BEGIN
   if not table_self_ref(tbuff.id)
   then
      return;
   end if;
   if tbuff.type not in ('EFF', 'LOG')
   then
      return;
   end if;
   sp_type := 'package body';
   sp_name := tbuff.name||'_sh';
   p('create ' || sp_type || ' ' || sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Self-Referencing Hist/Aud Helper functions');
   p('   --    (_L, _ALL, _F, _ASOF, hierarchy and lookup)');
   header_comments;
   p('');
   -- Setup hierarchy functions
   p('----------------------------------------');
   p('function get_id_L');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number');
   p('   -- For all the Natural Key Columns, Return an ID');
   p('is');
   p('   retid  number(38);');
   p('begin');
   p('   select id');
   p('    into  retid');
   p('    from  ' || tbuff.name || '_ALL  ' || tbuff.abbr);
   nkseq  := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.fk_table_id is null
      then
         -- Set the Natural Key Column directly from the paramter
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         end if;
         nkseq := nkseq + 1;
      else
         -- Use the get_id function to set the Natural Key Column
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            if i = 1
            then
               p('             (' || tbuff.name || '_nk' || nkseq);
            else
               p('             ,' || tbuff.name || '_nk' || nkseq);
            end if;
            nkseq := nkseq + 1;
         end loop;
         p('             )');
      end if;
   end loop;
   p('    ;');
   p('   return retid;');
   p('exception');
   p('   when no_data_found');
   p('   then');
   p('      return null;');
   p('   when others');
   p('   then');
   p('      raise;');
   p('end get_id_L;');
   p('----------------------------------------');
   p('function get_id_F');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number');
   p('   -- For all the Natural Key Columns, Return an ID');
   p('is');
   p('   retid  number(38);');
   p('begin');
   p('   select id');
   p('    into  retid');
   p('    from  ' || tbuff.name || '_ASOF  ' || tbuff.abbr);
   nkseq  := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.fk_table_id is null
      then
         -- Set the Natural Key Column directly from the paramter
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         end if;
         nkseq := nkseq + 1;
      else
         -- Use the get_id function to set the Natural Key Column
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            if i = 1
            then
               p('             (' || tbuff.name || '_nk' || nkseq);
            else
               p('             ,' || tbuff.name || '_nk' || nkseq);
            end if;
            nkseq := nkseq + 1;
         end loop;
         p('             )');
      end if;
   end loop;
   p('    ;');
   p('   return retid;');
   p('exception');
   p('   when no_data_found');
   p('   then');
   p('      return null;');
   p('   when others');
   p('   then');
   p('      raise;');
   p('end get_id_F;');
   p('----------------------------------------');
   p('function get_nk_L');
   p('      (id_in  in  number)');
   p('   return varchar2');
   p('   -- For an ID, return a delimited list of Natural Key Values');
   p('is');
   p('   rtxt  varchar2(32767);');
   p('begin');
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk )
   loop
      if buff.fk_table_id is null
      then
         -- Set the delimited list directly from the table data
         if nkseq = 1
         then
            p('   select substr(   ' || tbuff.abbr || '.' || buff.name);
         else
            p('    || util.nk_sep || ' || tbuff.abbr || '.' || buff.name);
         end if;
      else
         -- Use the get_nk function to set the delimted list
         if nkseq = 1
         then
            p('   select substr(   ' || get_tabname(buff.fk_table_id) ||
                   '_sh.get_nk_L(' || tbuff.abbr || '.' || buff.name || ')');
         else
            p('    || util.nk_sep || ' || get_tabname(buff.fk_table_id) ||
                   '_sh.get_nk_L(' || tbuff.abbr || '.' || buff.name || ')');
         end if;
      end if;
      nkseq := nkseq + 1;
   end loop;
   p('                         ,1,32767)');
   p('    into  rtxt');
   p('    from  ' || tbuff.name || ' ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = id_in;');
   p('   return rtxt;');
   p('exception');
   p('   when no_data_found then');
   p('      return null;');
   p('   when others then');
   p('      raise;');
   p('end get_nk_L;');
   p('----------------------------------------');
   p('function get_nk_F');
   p('      (id_in  in  number)');
   p('   return varchar2');
   p('   -- For an ID, return a delimited list of Natural Key Values');
   p('is');
   p('   rtxt  varchar2(32767);');
   p('begin');
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk )
   loop
      if buff.fk_table_id is null
      then
         -- Set the delimited list directly from the table data
         if nkseq = 1
         then
            p('   select substr(   ' || tbuff.abbr || '.' || buff.name);
         else
            p('    || util.nk_sep || ' || tbuff.abbr || '.' || buff.name);
         end if;
      else
         -- Use the get_nk function to set the delimted list
         if nkseq = 1
         then
            p('   select substr(   ' || get_tabname(buff.fk_table_id) ||
                   '_sh.get_nk_F(' || tbuff.abbr || '.' || buff.name || ')');
         else
            p('    || util.nk_sep || ' || get_tabname(buff.fk_table_id) ||
                   '_sh.get_nk_F(' || tbuff.abbr || '.' || buff.name || ')');
         end if;
      end if;
      nkseq := nkseq + 1;
   end loop;
   p('                         ,1,32767)');
   p('    into  rtxt');
   p('    from  ' || tbuff.name || '_ASOF ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = id_in;');
   p('   return rtxt;');
   p('exception');
   p('   when no_data_found then');
   p('      return null;');
   p('   when others then');
   p('      raise;');
   p('end get_nk_F;');
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id = tbuff.id
           and  COL.table_id    = tbuff.id )
      loop
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_path_L');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of IDs');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select ' || tbuff.name || '_id, level from ' || tbuff.name || '_L');
      p('       start with ' || tbuff.name || '_id = id_in');
      p('       connect by nocycle ' || tbuff.name || '_id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.' || tbuff.name || '_id);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.' || tbuff.name || '_id || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'id_path_L;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_path_F');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of IDs');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select ' || tbuff.name || '_id, level from ' || tbuff.name || '_F');
      p('       start with ' || tbuff.name || '_id = id_in');
      p('       connect by nocycle ' || tbuff.name || '_id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.' || tbuff.name || '_id);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.' || tbuff.name || '_id || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'id_path_F;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'nk_path_L');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of');
      p('   --    Natural Key sets');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select ' || tbuff.name || '_sh.get_nk_L(' || tbuff.name || '_id) nk');
      p('            ,level');
      p('       from  ' || tbuff.name || '_L');
      p('       start with ' || tbuff.name || '_id = id_in');
      p('       connect by nocycle ' || tbuff.name || '_id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.nk);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.nk || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'nk_path_L;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'nk_path_F');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of');
      p('   --    Natural Key sets');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select ' || tbuff.name || '_sh.get_nk_F(' || tbuff.name || '_id) nk');
      p('            ,level');
      p('       from  ' || tbuff.name || '_F');
      p('       start with ' || tbuff.name || '_id = id_in');
      p('       connect by nocycle ' || tbuff.name || '_id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.nk);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.nk || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'nk_path_F;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_id_path_L');
      p('      (id_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || '_ALL ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_sh.get_' ||
                         buff.fk_prefix || 'id_path_L('  ||
                        tbuff.abbr      || '.id) || util.path_sep || ' );
      p('          ' || tbuff.abbr      || '.id = id_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_id_path_L;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_id_path_F');
      p('      (id_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || '_ASOF ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_sh.get_' ||
                         buff.fk_prefix || 'id_path_F('  ||
                        tbuff.abbr      || '.id) || util.path_sep || ' );
      p('          ' || tbuff.abbr      || '.id = id_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_id_path_F;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_nk_path_L');
      p('      (nk_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || '_ALL ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_sh.get_' ||
                         buff.fk_prefix || 'nk_path_L('  ||
                        tbuff.abbr      || '.id) || util.path_sep ||' );
      p('          ' || tbuff.name      || '_sh.get_nk_L(' ||
                        tbuff.abbr      || '.id) = nk_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_nk_path_L;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_nk_path_F');
      p('      (nk_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || '_ASOF ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_sh.get_' ||
                         buff.fk_prefix || 'nk_path_F('  ||
                        tbuff.abbr      || '.id) || util.path_sep ||' );
      p('          ' || tbuff.name      || '_sh.get_nk_F(' ||
                        tbuff.abbr      || '.id) = nk_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_nk_path_F;');
   end loop;
   p('');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_sh_body;
----------------------------------------
PROCEDURE drop_fk
   --  For a tbuff, drop foreign keys on active table
IS
   tname    varchar2(30);
   fkseq    number(2);
BEGIN
   tname := tbuff.name;
   --  Foreign Keys
   if abuff.usr_frgn_key is not null
   then
      p('alter table ' || tname || ' drop constraint ' ||
                          tname || '_fa1');
      p('/');
   end if;
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq desc)
   loop
      fkseq := fkseq + 1;
      p('alter table ' || tname || ' drop constraint ' ||
                          tname || '_' || 'fk' || fkseq);
      p('/');
   end loop;
   p('');
END drop_fk;
----------------------------------------
PROCEDURE create_fk
   --  For a tbuff, create foreign keys on active table
IS
   tname    varchar2(30);
   fkseq    number(2);
BEGIN
   p('/***  ACTIVE Foreign Keys  ***/');
   tname := tbuff.name;
   --  Foreign Keys
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_' || 'fk' || fkseq);
      p('   foreign key (' || buff.name || ') references ' ||
                              get_tabname(buff.fk_table_id) || ' (id)');
      p('/');
   end loop;
   if abuff.usr_frgn_key is not null
   then
      p('/***  ACTIVE Audit Foreign Key ***/');
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_fa1');
      p('   foreign key (aud_beg_usr) references ' ||
                        abuff.usr_frgn_key);
      p('/');
   end if;
   p('');
END create_fk;
----------------------------------------
PROCEDURE create_ind_act
   --  For a tbuff, create the indexes for active tables
   --     and materialized views
IS
   tname    varchar2(30);
   dup_ind  number;
   nk_cols  number;
   fkseq    number(2);
BEGIN
   --  Create ACTIVE table indexes
   p('/***  ACTIVE Indexes  ***/');
   tname := tbuff.name;
   --  Natural Keys
   p('alter table ' || tname || ' add constraint ' || tname || '_nk');
   for buff in (
      select COL.name
            ,COL.nk
            ,(select min(COL2.nk)
               from  tab_cols  COL2
               where COL2.nk is not null
                and  COL2.table_id = tbuff.id) min_nk
       from  tab_cols COL
       where COL.nk is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.nk = buff.min_nk
      then
         p('    unique (' || buff.name);
      else
         p('           ,' || buff.name);
      end if;
   end loop;
   p('           )' || get_pctfree('ONLN','INDX') ||
                       get_tspace('ONLN','INDX',TRUE));
   p('/');
/*
 Commenting out for removal of UNIQ column from indexes table
   --  Check for UNIQ Flag Entry Errors
   for buf2 in (
      select tab_cols_nk2, tag, count(*) uniq_cnt
       from  (select tab_cols_nk2, tag, uniq
               from  indexes_act
               where tab_cols_nk1 = abuff.abbr
               group by tab_cols_nk2, tag, uniq)
       group by tab_cols_nk2, tag
       having count(*) > 1 )
   loop
      raise_application_error(-20000,
         'Error in '        || buf2.tag          ||
         ' index on table ' || buf2.tab_cols_nk2 ||
         ', found '         || buf2.uniq_cnt     ||
         ' different values for UNIQ.');
   end loop;
*/
   --  Unique Key Indexes
   for buf2 in (
      select IND.tag
       from  tab_cols  COL
            ,tab_inds  IND
       where COL.table_id = tbuff.id
        and  COL.id       = IND.tab_col_id
       -- and  IND.uniq     is not null
        and  lower(substr(IND.tag,1,1)) = 'u'
       group by IND.tag
       order by IND.tag )
   loop
      p('alter table ' || tname || ' add constraint ' || tname || '_' || buf2.tag);
      for buff in (
         select COL.name
               ,IND.seq
               ,(select min(IND2.seq)
                  from  tab_cols COL2
                       ,tab_inds IND2
                  where COL2.table_id = tbuff.id
                   and  COL2.id       = IND2.tab_col_id
                  -- This is not needed because buf2.tag is unique 
                  -- and  IND2.uniq     is not null
                   and  IND2.tag      = buf2.tag  ) min_seq
          from  tab_cols COL
               ,tab_inds IND
          where COL.table_id = tbuff.id
           and  COL.id       = IND.tab_col_id
          -- This is not needed because buf2.tag is unique 
          -- and  IND.uniq     is not null
           and  IND.tag      = buf2.tag
          group by COL.name
               ,IND.seq
          order by IND.seq)
      loop
         if buff.seq = buff.min_seq
         then
            p('    unique (' || buff.name);
         else
            p('           ,' || buff.name);
         end if;
      end loop;
      p('           )' || get_pctfree('ONLN','INDX') ||
                          get_tspace('ONLN','INDX',TRUE));
      p('/');
   end loop;
   fkseq := 0;
   --  Foreign Key Indexes
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      -- Don't create a duplicate index on this foreign key
      select count(IND.id)
       into  dup_ind
       from  tab_inds IND
       where IND.tab_col_id = buff.id
        and  seq = (
             select min(IND2.seq)
              from  tab_inds IND2
              where IND2.tab_col_id in (
                    select COL.id
                     from  tab_cols COL
                     where COL.table_id = tbuff.id ) );
      if dup_ind > 0
      then
         p('--  Skipping duplicate FK index on ' || buff.name);
      else
         -- Don't create a duplicate natural key index on this foreign key
         select count(COL.id)
          into  nk_cols
          from  tab_cols COL
          where COL.table_id = tbuff.id
           and  nk        is not null
           and  exists (
                select 'X'
                 from  tab_cols COL2
                 where COL2.id = buff.id
                  and  nk     is not null );
         if nk_cols = 1
         then
            p('--  Skipping duplicate FK index on ' || tname || ' NK');
         else
            p('create index ' || tname || '_' || 'fx' || fkseq || ' on ' ||
                                 tname || '(' || buff.name || ')' ||
                                 get_pctfree('ONLN','INDX') ||
                                 get_tspace('ONLN','INDX'));
            p('/');
         end if;
      end if;
   end loop;
   --  Non-unique Key Indexes
   for buf2 in (
      select IND.tag
       from  tab_cols  COL
            ,tab_inds  IND
       where COL.table_id = tbuff.id
        and  COL.id       = IND.tab_col_id
        and  lower(substr(IND.tag,1,1)) != 'u'
       -- and  IND.uniq     is null
       group by IND.tag
       order by IND.tag )
   loop
      p('create index ' || tname || '_' || buf2.tag);
      p('    on ' || tname);
      for buff in (
         select COL.name
               ,IND.seq
               ,(select min(IND2.seq)
                  from  tab_cols  COL2
                       ,tab_inds  IND2
                  where COL2.table_id = tbuff.id
                   and  COL2.id       = IND2.tab_col_id
                  -- This is not needed because buf2.tag is not unique
                  -- and  IND2.uniq     is null
                   and  IND2.tag      = buf2.tag )  min_seq
          from  tab_cols  COL
               ,tab_inds  IND
          where COL.table_id = tbuff.id
           and  COL.id       = IND.tab_col_id
          -- This is not needed because buf2.tag is not unique
          -- and  IND.uniq     is null
           and  IND.tag      = buf2.tag
          order by IND.seq)
      loop
         if buff.seq = buff.min_seq
         then
            p('           (' || buff.name);
         else
            p('           ,' || buff.name);
         end if;
      end loop;
      p('           )' || get_pctfree('ONLN','INDX') ||
                          get_tspace('ONLN','INDX'));
      p('/');
   end loop;
   p('');
   if tbuff.type = 'EFF'
   then
      p('/***  ACTIVE Effectivity Indexes  ***/');
      p('create index ' || tname || '_it1 on ' ||
                           tname || '(eff_beg_dtm)' ||
                           get_pctfree('ONLN','INDX') ||
                           get_tspace('ONLN','INDX'));
      p('/');
   end if;
   p('');
   p('/***  ACTIVE Audit Foreign Key Indexes  ***/');
   p('-- create index ' || tname || '_ia1 on ' ||
                           tname || '(aud_beg_usr)' ||
                           get_pctfree('ONLN','INDX') ||
                           get_tspace('ONLN','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia2 on ' ||
                           tname || '(aud_beg_dtm)' ||
                           get_pctfree('ONLN','INDX') ||
                           get_tspace('ONLN','INDX'));
   p('-- /');
   p('');
END create_ind_act;
----------------------------------------
PROCEDURE create_ind_hoa
   --  For a tbuff, create the indexes on HOA table
IS
   tname    varchar2(30);
   dup_ind  number;
   nk_cols  number;
   fkseq    number(2);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- There is no HOA table
      return;
   end if;
   --  Create HISTORY table indexes
   tname := tbuff.name || HOA;
   p('/***  HISTORY Foreign Keys and Indexes  ***/');
   --  Primary Key Index
   p('alter table ' || tname || ' add constraint ' || tname || '_pk');
   p('   primary key (' || tbuff.name || '_id');
   if tbuff.type = 'EFF'
   then
      p('               ,eff_beg_dtm');
   else
      p('               ,aud_beg_dtm');
   end if;
   p('               )' || get_pctfree('HIST','INDX') ||
                           get_tspace('HIST','INDX',TRUE));
   p('/');
   --  Natural Keys - No unique indexes in history
   p('create index ' || tname || '_nk');
   p('   on ' || tname);
   for buff in (
      select COL.name
            ,COL.nk
            ,(select min(COL2.nk)
               from  tab_cols COL2
               where COL2.nk is not null
                and  COL2.table_id = tbuff.id  )  min_nk
       from  tab_cols COL
       where COL.nk is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.nk = buff.min_nk
      then
         p('           (' || buff.name);
      else
         p('           ,' || buff.name);
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('           ,eff_beg_dtm');
   else
      p('           ,aud_beg_dtm');
   end if;
   p('           )' || get_pctfree('HIST','INDX') ||
                       get_tspace('HIST','INDX'));
   p('/');
   --  Foreign Key Indexes
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      -- Don't create a duplicate index on this foreign key
      select count(IND.id)
       into  dup_ind
       from  tab_inds  IND
       where IND.tab_col_id = buff.id
        and  seq = (
             select min(IND2.seq)
              from  tab_inds  IND2
              where IND2.tab_col_id in (
                    select COL.id
                     from  tab_cols COL
                     where COL.table_id = tbuff.id ) );
      if dup_ind > 0
      then
         p('--  Skipping duplicate FK index on ' || buff.name);
      else
         -- Don't create a duplicate natural key index on this foreign key
         select count(COL.id)
          into  nk_cols
          from  tab_cols COL
          where COL.table_id = tbuff.id
           and  nk        is not null
           and  exists (
                select 'X'
                 from  tab_cols COL2
                 where COL2.id = buff.id
                  and  nk     is not null );
         if nk_cols = 1
         then
            p('--  Skipping duplicate FK index on ' || tname || ' NK');
         else
            p('create index ' || tname || '_' || 'fx' || fkseq);
            p('   on ' || tname);
            p('           (' || buff.name);
            if tbuff.type = 'EFF'
            then
               p('           ,eff_beg_dtm');
            else
               p('           ,aud_beg_dtm');
            end if;
            p('           )' || get_pctfree('HIST','INDX') ||
                                get_tspace('HIST','INDX'));
            p('/');
         end if;
      end if;
   end loop;
   -- Other Indexes - No unique indexes in history
   for buf2 in (
      select IND.tag
       from  tab_cols  COL
            ,tab_inds  IND
       where COL.table_id = tbuff.id
        and  COL.id       = IND.tab_col_id
        and  lower(substr(IND.tag,1,1)) != 'u'
       -- and  IND.uniq     is null
       group by IND.tag
       order by IND.tag )
   loop
      p('create index ' || tname || '_' || buf2.tag);
      p('    on ' || tname);
      for buff in (
         select COL.name
               ,IND.seq
               ,(select min(IND2.seq)
                  from  tab_cols  COL2
                       ,tab_inds  IND2
                  where COL2.table_id = tbuff.id
                   and  COL2.id       = IND2.tab_col_id
                   and  IND2.tag      = buf2.tag  )  min_seq
          from  tab_cols  COL
               ,tab_inds  IND
          where COL.table_id = tbuff.id
           and  COL.id       = IND.tab_col_id
           and  IND.tag      = buf2.tag
          order by IND.seq)
      loop
         if buff.seq = buff.min_seq
         then
            p('           (' || buff.name);
         else
            p('           ,' || buff.name);
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('           ,eff_beg_dtm');
      else
         p('           ,aud_beg_dtm');
      end if;
      p('           )' || get_pctfree('HIST','INDX') ||
                          get_tspace('HIST','INDX'));
      p('/');
   end loop;
   p('');
   if tbuff.type = 'EFF'
   then
      p('/***  HISTORY Effectivity Indexes  ***/');
      p('-- create index ' || tname || '_it1 on ' ||
                              tname || '(eff_beg_dtm)' ||
                              get_pctfree('HIST','INDX') ||
                              get_tspace('HIST','INDX'));
      p('-- /');
      p('-- create index ' || tname || '_it2 on ' ||
                              tname || '(eff_end_dtm)' ||
                              get_pctfree('HIST','INDX') ||
                              get_tspace('HIST','INDX'));
      p('-- /');
   end if;
   p('');
   p('/***  HISTORY Audit Foreign Key and Indexes  ***/');
   if abuff.usr_frgn_key is not null
   then
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_fa1');
      p('   foreign key aud_end_usr references ' ||
                           abuff.usr_frgn_key);
      p('/');
   end if;
   p('-- create index ' || tname || '_ia1 on ' ||
                           tname || '(aud_beg_usr, aud_beg_dtm)' ||
                           get_pctfree('HIST','INDX') ||
                           get_tspace('HIST','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia2 on ' ||
                           tname || '(aud_beg_dtm)' ||
                           get_pctfree('HIST','INDX') ||
                           get_tspace('HIST','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia3 on ' ||
                           tname || '(aud_end_usr, aud_beg_dtm)' ||
                           get_pctfree('HIST','INDX') ||
                           get_tspace('HIST','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia4 on ' ||
                           tname || '(aud_end_dtm)' ||
                           get_pctfree('HIST','INDX') ||
                           get_tspace('HIST','INDX'));
   p('-- /');
   p('');
END create_ind_hoa;
----------------------------------------
PROCEDURE create_ind_pdat
   --  For a tbuff, create the indexes on POP table
IS
   tname    varchar2(30);
   dup_ind  number;
   nk_cols  number;
   fkseq    number(2);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- There is no POP table
      return;
   end if;
   --  Create POP table indexes
   tname := tbuff.name || '_PDAT';
   p('/***  POP Foreign Keys and Indexes  ***/');
   --  Primary Key Index
   p('alter table ' || tname || ' add constraint ' || tname || '_pk');
   p('   primary key (' || tbuff.name || '_id');
   p('               ,aud_beg_dtm');
   p('               )' || get_pctfree('PDAT','INDX') ||
                           get_tspace('PDAT','INDX',TRUE));
   p('/');
   --  Natural Keys - No unique indexes in POP
   p('create index ' || tname || '_nk');
   p('   on ' || tname);
   for buff in (
      select COL.name
            ,COL.nk
            ,(select min(COL2.nk)
               from  tab_cols COL2
               where COL2.nk is not null
                and  COL2.table_id = tbuff.id  )  min_nk
       from  tab_cols COL
       where COL.nk is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.nk = buff.min_nk
      then
         p('           (' || buff.name);
      else
         p('           ,' || buff.name);
      end if;
   end loop;
   p('           ,aud_beg_dtm');
   p('           )' || get_pctfree('PDAT','INDX') ||
                       get_tspace('PDAT','INDX'));
   p('/');
   --  Foreign Key Indexes
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      -- Don't create a duplicate index on this foreign key
      select count(IND.id)
       into  dup_ind
       from  tab_inds  IND
       where IND.tab_col_id = buff.id
        and  seq = (
             select min(IND2.seq)
              from  tab_inds  IND2
              where IND2.tab_col_id in (
                    select COL.id
                     from  tab_cols COL
                     where COL.table_id = tbuff.id ) );
      if dup_ind > 0
      then
         p('--  Skipping duplicate FK index on ' || buff.name);
      else
         -- Don't create a duplicate natural key index on this foreign key
         select count(COL.id)
          into  nk_cols
          from  tab_cols COL
          where COL.table_id = tbuff.id
           and  nk        is not null
           and  exists (
                select 'X'
                 from  tab_cols COL2
                 where COL2.id = buff.id
                  and  nk     is not null );
         if nk_cols = 1
         then
            p('--  Skipping duplicate FK index on ' || tname || ' NK');
         else
            p('create index ' || tname || '_' || 'fx' || fkseq);
            p('   on ' || tname);
            p('           (' || buff.name);
            if tbuff.type = 'EFF'
            then
               p('           ,eff_beg_dtm');
            else
               p('           ,aud_beg_dtm');
            end if;
            p('           )' || get_pctfree('PDAT','INDX') ||
                                get_tspace('PDAT','INDX'));
            p('/');
         end if;
      end if;
   end loop;
   -- Other Indexes - No unique indexes in POP
   for buf2 in (
      select IND.tag
       from  tab_cols  COL
            ,tab_inds  IND
       where COL.table_id = tbuff.id
        and  COL.id       = IND.tab_col_id
        and  lower(substr(IND.tag,1,1)) != 'u'
       -- and  IND.uniq     is null
       group by IND.tag
       order by IND.tag )
   loop
      p('create index ' || tname || '_' || buf2.tag);
      p('    on ' || tname);
      for buff in (
         select COL.name
               ,IND.seq
               ,(select min(IND2.seq)
                  from  tab_cols  COL2
                       ,tab_inds  IND2
                  where COL2.table_id = tbuff.id
                   and  COL2.id       = IND2.tab_col_id
                   and  IND2.tag      = buf2.tag  )  min_seq
          from  tab_cols  COL
               ,tab_inds  IND
          where COL.table_id = tbuff.id
           and  COL.id       = IND.tab_col_id
           and  IND.tag      = buf2.tag
          order by IND.seq)
      loop
         if buff.seq = buff.min_seq
         then
            p('           (' || buff.name);
         else
            p('           ,' || buff.name);
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('           ,eff_beg_dtm');
      else
         p('           ,aud_beg_dtm');
      end if;
      p('           )' || get_pctfree('PDAT','INDX') ||
                          get_tspace('PDAT','INDX'));
      p('/');
   end loop;
   p('');
   if tbuff.type = 'EFF'
   then
      p('/***  HISTORY Effectivity Indexes  ***/');
      p('-- create index ' || tname || '_it1 on ' ||
                              tname || '(eff_beg_dtm)' ||
                              get_pctfree('PDAT','INDX') ||
                              get_tspace('PDAT','INDX'));
      p('-- /');
      p('-- create index ' || tname || '_it2 on ' ||
                              tname || '(eff_prev_beg_dtm)' ||
                              get_pctfree('PDAT','INDX') ||
                              get_tspace('PDAT','INDX'));
      p('-- /');
   end if;
   p('');
   p('/***  HISTORY Audit Foreign Key and Indexes  ***/');
   if abuff.usr_frgn_key is not null
   then
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_fa1');
      p('   foreign key pop_usr references ' ||
                          abuff.usr_frgn_key);
      p('/');
   end if;
   p('-- create index ' || tname || '_ia1 on ' ||
                           tname || '(aud_beg_usr, aud_beg_dtm)' ||
                           get_pctfree('PDAT','INDX') ||
                           get_tspace('PDAT','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia2 on ' ||
                           tname || '(aud_beg_dtm)' ||
                           get_pctfree('PDAT','INDX') ||
                           get_tspace('PDAT','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia3 on ' ||
                           tname || '(aud_prev_beg_usr, aud_beg_dtm)' ||
                           get_pctfree('PDAT','INDX') ||
                           get_tspace('PDAT','INDX'));
   p('-- /');
   p('-- create index ' || tname || '_ia4 on ' ||
                           tname || '(aud_prev_beg_dtm)' ||
                           get_pctfree('PDAT','INDX') ||
                           get_tspace('PDAT','INDX'));
   p('-- /');
   p('');
END create_ind_pdat;
----------------------------------------
PROCEDURE drop_cons
   --  For a tbuff, drop the constraints
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('-- alter table ' || tbuff.name || '_PDAT drop constraint ' ||
                             tbuff.name || '_PDAT_la1');
      p('-- /');
      p('-- alter table ' || tbuff.name || '_PDAT drop constraint ' ||
                             tbuff.name || '_PDAT_au1');
      p('-- /');
      if tbuff.type = 'EFF'
      then
         p('-- alter table ' || tbuff.name || '_PDAT drop constraint ' ||
                                tbuff.name || '_PDAT_ef1');
         p('-- /');
      end if;
      p('alter table ' || tbuff.name || HOA || ' drop constraint ' ||
                          tbuff.name || HOA || '_la1');
      p('/');
      p('alter table ' || tbuff.name || HOA || ' drop constraint ' ||
                          tbuff.name || HOA || '_au1');
      p('/');
      if tbuff.type = 'EFF'
      then
         p('alter table ' || tbuff.name || HOA || ' drop constraint ' ||
                             tbuff.name || HOA || '_ef1');
         p('/');
      end if;
   end if;
   -- Drop the domain check constraints
   for buff in (
      select COL.name
            ,COL.d_domain_id
            ,rownum  rnum
       from  tab_cols  COL
       where d_domain_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq desc)
   loop
      p('alter table ' || tbuff.name || ' drop constraint ' ||
                          tbuff.name || '_dm' || buff.rnum);
      p('/');
   end loop;
   -- Drop the case fold checking
   for buff in (
      select COL.name
            ,COL.fold
            ,rownum  rnum
       from  tab_cols  COL
       where fold is not null
        and  COL.table_id = tbuff.id
       order by COL.seq desc)
   loop
      p('alter table ' || tbuff.name || ' drop constraint ' ||
                          tbuff.name || '_fld' || buff.rnum);
      p('/');
   end loop;
   -- Drop the custom check constraints
   for buff in (
      select * from check_cons CK
       where CK.table_id = tbuff.id
       order by CK.seq desc)
   loop
      p('alter table ' || tbuff.name || ' drop constraint ' ||
                          tbuff.name || '_ck' || buff.seq);
      p('/');
   end loop;
END drop_cons;
----------------------------------------
procedure create_cons
   -- For a tbuff, create constraints
is
   tname    varchar2(30);
begin
   tname := tbuff.name;
   -- Custom Check Constraints
   for buff in (
      select * from check_cons CK
       where CK.table_id = tbuff.id
       order by CK.seq )
   loop
      -- A complete implementation of Issue 48 "Need to Change Single
      --   Column Table Constraints to Column Constraints" might need
      --   to include a conversion of this table constraint to a column
      --   constraint after checking for one, and only one, column name
      --   in buff.text.  However, it may not make a difference to the
      --   optimizer.
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_ck' || buff.seq);
      p('   check (' || replace(buff.text,''',''''') || ')');
      p('/');
   end loop;
   -- Check case
   for buff in (
      select COL.name
            ,COL.fold
            ,rownum  rnum
       from  tab_cols  COL
       where fold is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_fld' || buff.rnum);
      case buff.fold
      when 'U' then
         p('   check (' || buff.name || ' = upper(' || buff.name || '))');
      when 'L' then
         p('   check (' || buff.name || ' = lower(' || buff.name || '))');
      when 'I' then
         p('   check (' || buff.name || ' = initcap(' || buff.name || '))');
      end case;
      p('/');
   end loop;
   -- Domain Check Constraints
   for buff in (
      select COL.name
            ,COL.d_domain_id
            ,rownum  rnum
       from  tab_cols  COL
       where d_domain_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('alter table ' || tname || ' add constraint ' ||
                          tname || '_dm' || buff.rnum);
      p('   check (' || buff.name || ' in ' ||
            get_domlist(buff.d_domain_id) || ')');
      p('/');
   end loop;
   p('');
   if tbuff.type in ('EFF', 'LOG')
   then
      tname := tbuff.name || HOA;
      if tbuff.type = 'EFF'
      then
         p('alter table ' || tname || ' add constraint ' || tname || '_ef1');
         p('      check (eff_beg_dtm < eff_end_dtm)');
         p('/');
      end if;
      p('alter table ' || tname || ' add constraint ' || tname || '_au1');
      p('      check (aud_beg_dtm < aud_end_dtm)');
      p('/');
      p('alter table ' || tname || ' add constraint ' || tname || '_la1');
      p('      check (last_active = ''Y'')');
      p('/');
      p('');
      tname := tbuff.name || '_PDAT';
      if tbuff.type = 'EFF'
      then
         p('-- alter table ' || tname || ' add constraint ' || tname || '_ef1');
         p('--       check (eff_beg_dtm < eff_prev_beg_dtm)');
         p('-- /');
      end if;
      p('-- alter table ' || tname || ' add constraint ' || tname || '_au1');
      p('--       check (aud_beg_dtm < aud_prev_beg_dtm)');
      p('-- /');
      p('-- alter table ' || tname || ' add constraint ' || tname || '_la1');
      p('--       check (last_active = ''Y'')');
      p('-- /');
      p('');
   end if;
END create_cons;
----------------------------------------
PROCEDURE drop_ttrig
   --  For a tbuff, drop the table triggers
IS
BEGIN
   p('drop TRIGGER ' || tbuff.name || '_bi');
   p('/');
   p('drop TRIGGER ' || tbuff.name || '_bu');
   p('/');
   p('drop TRIGGER ' || tbuff.name || '_bd');
   p('/');
END drop_ttrig;
----------------------------------------
PROCEDURE create_ttrig
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   sp_type := 'TRIGGER';
   sp_name := tbuff.name||'_bi';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('   BEFORE INSERT');
   p('   ON ' || tbuff.name || ' FOR EACH ROW');
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   p('   -- util.log(''Trigger '||sp_name||''');');
   p('   if glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.ins');
   p('         (:new.id');
   if tbuff.type = 'EFF'
   then
      p('         ,:new.eff_beg_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,:new.'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,:new.aud_beg_usr');
      p('         ,:new.aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
   sp_type := 'TRIGGER';
   sp_name := tbuff.name||'_bu';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('   BEFORE UPDATE');
   p('   ON ' || tbuff.name || ' FOR EACH ROW');
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   p('   -- util.log(''Trigger '||sp_name||''');');
   p('   if glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.upd');
   p('         (:old.id');
   if tbuff.type = 'EFF'
   then
      p('         ,:old.eff_beg_dtm');
      p('         ,:new.eff_beg_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,:old.'||buff.name);
      p('         ,:new.'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,:old.aud_beg_usr');
      p('         ,:new.aud_beg_usr');
      p('         ,:old.aud_beg_dtm');
      p('         ,:new.aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
   sp_type := 'TRIGGER';
   sp_name := tbuff.name||'_bd';
   p('CREATE ' || sp_type || ' ' || sp_name);
   p('   BEFORE DELETE');
   p('   ON ' || tbuff.name || ' FOR EACH ROW');
   if tbuff.type = 'EFF'
   then
      p('declare');
      p('   x_eff_end_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   p('   -- util.log(''Trigger '||sp_name||''');');
   p('   if glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.del');
   p('         (:old.id');
   if tbuff.type = 'EFF'
   then
      p('         ,:old.eff_beg_dtm');
      p('         ,x_eff_end_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,:old.'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,:old.aud_beg_usr');
      p('         ,:old.aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_ttrig;
----------------------------------------
PROCEDURE drop_rem
   --  For a tbuff, drop the materialized view or synonym
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop package '||tbuff.name||'_pop');
      p('/');
      p('drop view '||tbuff.name||'_PDAT');
      p('/');
      p('drop view '||tbuff.name||HOA);
      p('/');
   end if;
   if tbuff.mv_refresh_hr IS NOT NULL
   then
      p('drop materialized view '||tbuff.name);
      p('/');
   else
      p('drop view '||tbuff.name);
      p('/');
   end if;
   p('drop synonym '||tbuff.name||'_seq');
   p('/');
END drop_rem;
----------------------------------------
PROCEDURE create_rem
   --  For a tbuff, create the materialized view or synonym
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   p('');
   sp_type := 'synonym';
   sp_name := tbuff.name||'_seq';
   p('create ' || sp_type || ' ' || sp_name);
   p('   for '||abuff.db_auth||tbuff.name||'_seq@'||abuff.dbid);
   p('/');
   ps('');
   ps('-- audit rename on '||sp_name||' by access');
   ps('-- /');
   sp_type := 'view';
   sp_name := tbuff.name;
   if tbuff.mv_refresh_hr IS NOT NULL
   then
      p('');
      p('create materialized ' || sp_type || ' ' || sp_name);
      p('   refresh next sysdate + '||tbuff.mv_refresh_hr||'/24');
      p('   as select * from '||abuff.db_auth||sp_name||'@'||abuff.dbid);
      p('/');
   else
      p('');
      p('create ' || sp_type || ' ' || sp_name);
      p('   as select * from '||abuff.db_auth||sp_name||'@'||abuff.dbid);
      p('/');
   end if;
   p('comment on table ' || sp_name || ' is ''' ||
      replace(tbuff.description,SQ1,SQ2) || '''');
   p('/');
   ps('');
   ps('grant select on ' || sp_name || ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' || sp_name || ' by access');
   ps('-- /');
   p('');
   tab_col_comments(sp_name);
   p('');
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- No need for any HOA or POP stuff
	  return;
   end if;
   sp_type := 'view';
   sp_name := tbuff.name||HOA;
   p('create ' || sp_type || ' ' || sp_name);
   p('   as select * from '||abuff.db_auth||sp_name||'@'||abuff.dbid);
   p('/');
   ps('');
   ps('grant select on ' || sp_name || ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' || sp_name || ' by access');
   ps('-- /');
   p('');
   hoa_col_comments(sp_name);
   p('');
   sp_type := 'view';
   sp_name := tbuff.name||'_PDAT';
   p('create ' || sp_type || ' ' || sp_name);
   p('   as select * from '||abuff.db_auth||sp_name||'@'||abuff.dbid);
   p('/');
   ps('');
   ps('grant select on ' || sp_name || ' to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' || sp_name || ' by access');
   ps('-- /');
   p('');
   pdat_col_comments(sp_name);
   p('');
   trig_no_dml(sp_name, sp_type, 'insert');
   trig_no_dml(sp_name, sp_type, 'update');
   trig_no_dml(sp_name, sp_type, 'delete');
   sp_type := 'package';
   sp_name := tbuff.name||'_pop';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p('   -- MT FACADE ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    Pop (UNDO) functions');
   p('   --    (All procedures and functions point to link '||abuff.dbid||')');
   header_comments;
   p('');
   p('   procedure at_server');
   p('         (id_in  in  number);');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
   sp_type := 'package body';
   sp_name := tbuff.name||'_pop';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p('-- MT FACADE ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    Pop (UNDO) functions');
   p('--    (All procedures and functions point to link '||abuff.dbid||')');
   header_comments;
   p('');
   p('procedure at_server');
   p('      (id_in  in  number)');
   p('is');
   p('begin');
   p('   '||abuff.db_auth||sp_name||'.at_server@'||abuff.dbid||'(id_in);');
   p('end at_server;');
   p('');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
END create_rem;
----------------------------------------
PROCEDURE drop_rem_all_asof
   --  For a tbuff, drop the materialized view or synonym
IS
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- This table has no _ALL or _ASOF views
      return;
   end if;
   p('');
   p('drop view '||tbuff.name||'_ASOF');
   p('/');
   p('drop view '||tbuff.name||'_ALL');
   p('/');
   if table_self_ref(tbuff.id)
   then
      -- Tables with self-referencing foreign keys must
      -- have this intermediate view "_L" and "_F" to compute
      -- the ALL and ASOF data before the self-referencing can
      -- be accomplished in the main "_ALL" and "_ASOF" views.
      p('drop view '||tbuff.name||'_F');
      p('/');
      p('drop view '||tbuff.name||'_L');
      p('/');
   end if;
END drop_rem_all_asof;
----------------------------------------
PROCEDURE create_rem_all_asof
   --  For a tbuff, create the materialized view or synonym
IS
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- This table has no _ALL or _ASOF views
      return;
   end if;
   p('');
   p('create view '||tbuff.name||'_ALL');
   p('   as select * from '||abuff.db_auth||tbuff.name||'_all@'||abuff.dbid);
   p('/');
   p('');
   all_col_comments(tbuff.name||'_all');
   ps('');
   ps('grant select on ' ||tbuff.name|| '_ALL to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' ||tbuff.name || '_ALL by access');
   ps('-- /');
   p('create view '||tbuff.name||'_ASOF');
   p('   as select * from '||abuff.db_auth||tbuff.name||'_asof@'||abuff.dbid);
   p('/');
   p('');
   asof_col_comments(tbuff.name||'_asof');
   ps('');
   ps('grant select on ' ||tbuff.name|| '_ASOF to ' || abuff.abbr || '_app');
   ps('/');
   ps('-- audit rename on ' ||tbuff.name || '_ASOF by access');
   ps('-- /');
END create_rem_all_asof;
----------------------------------------
PROCEDURE drop_vp
   --  For a tbuff, drop the view package
IS
BEGIN
   p('drop package '||tbuff.name||'_view');
   p('/');
END drop_vp;
----------------------------------------
PROCEDURE create_vp_spec
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
BEGIN
   sp_type := 'package';
   sp_name := tbuff.name||'_view';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   --    View functions');
   p('   --    (DML, Foreign Keys, Paths, and )');
   p('   --    ');
   header_comments;
   p('');
   p('   procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,n_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' ||
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
   end loop;
   p('      );');
   p('   procedure upd');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,o_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,o_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,o_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' || 
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,n_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' || 
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in  ' || usrdt);
      p('      ,o_aud_beg_dtm  in  timestamp with local time zone');
   end if;
   p('      );');
   p('   procedure del');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package Delete History columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in  ' || usrdt);
      p('      ,o_aud_beg_dtm  in  timestamp with local time zone');
   end if;
   p('      );');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on '||sp_name||' to '||abuff.abbr||'_dml');
   ps('/');
   ps('---- audit rename on ' || sp_name || ' by access');
   ps('---- /');
   p('');
END create_vp_spec;
----------------------------------------
PROCEDURE create_vp_body
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   first_time  boolean;
BEGIN
   sp_type := 'package body';
   sp_name := tbuff.name||'_view';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p('-- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('--    View functions');
   p('--    (DML, Foreign Keys, Paths, and )');
   header_comments;
   p('');
   p('----------------------------------------');
   p('procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff)) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,n_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' || 
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
   end loop;
   p('      )');
   p('   -- View insert procedure');
   p('is');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   n_aud_beg_usr  ' || usrfdt || ';');
      p('   n_aud_beg_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   p('   if util.db_object_exists('''||upper(tbuff.name)||''', ''MATERIALIZED VIEW'')');
   p('   then');
   p('      raise_application_error(-20010, ''Insert not allowed on materialized view ' ||
            tbuff.name || '.  Inserts on ' || tbuff.name ||
            ' must be performed on the central database.'');');
   p('   end if;');
   vtrig_fksets(sp_name, 'ins');
   p('   if not glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.ins');
   p('         (n_id');
   if tbuff.type = 'EFF'
   then
      p('         ,n_eff_beg_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,n_'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,n_aud_beg_usr');
      p('         ,n_aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('   insert into '||tbuff.name);
   p('         (id');
   if tbuff.type = 'EFF'
   then
      p('         ,eff_beg_dtm');
   end if;
   --  Generate an insert column list
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,aud_beg_usr');
      p('         ,aud_beg_dtm');
   end if;
   p('         )');
   p('   values') ;
   p('         (n_id');
   if tbuff.type = 'EFF'
   then
      p('         ,n_eff_beg_dtm');
   end if;
   -- Generate an insert values list
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,n_'||buff.name||'');
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,n_aud_beg_usr');
      p('         ,n_aud_beg_dtm');
   end if;
   p('         ) returning id into n_id;');
   p('end ins;') ;
   p('----------------------------------------');
   p('procedure upd');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,o_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,o_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,o_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' || 
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path  in  VARCHAR2');
            p('      ,n_'|| buff.fk_prefix || 'nk_path  in  VARCHAR2');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '  in  ' || 
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)));
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  ' || usrdt);
      p('      ,o_aud_beg_dtm  timestamp with local time zone');
   end if;
   p('      )');
   p('   -- View Update procedure');
   p('is');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   n_aud_beg_usr  ' || usrfdt || ';');
      p('   n_aud_beg_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   p('   if util.db_object_exists('''||upper(tbuff.name)||''', ''MATERIALIZED VIEW'')');
   p('   then');
   p('      raise_application_error(-20010, ''Update not allowed on materialized view ' ||
            tbuff.name || '.  Updates on ' || tbuff.name ||
            ' must be performed on the central database.'');');
   p('   end if;');
   vtrig_fksets(sp_name, 'upd');
   p('   if not glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.upd');
   p('         (o_id');
   if tbuff.type = 'EFF'
   then
      p('         ,o_eff_beg_dtm');
      p('         ,n_eff_beg_dtm');
   end if;
   -- Setup DML package update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,o_'||buff.name);
      p('         ,n_'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,o_aud_beg_usr');
      p('         ,n_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
      p('         ,n_aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('   update ' || tbuff.name || ' ' || tbuff.abbr);
   first_time := TRUE;
   --  Generate an update column list
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if first_time then
         p('     set  ' || tbuff.abbr || '.' || buff.name || ' = n_' || buff.name);
         first_time:=FALSE;
      else
         p('         ,' || tbuff.abbr || '.' || buff.name || ' = n_' || buff.name);
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      if tbuff.type = 'EFF'
      then
         p('         ,' || tbuff.abbr || '.eff_beg_dtm = n_eff_beg_dtm');
      end if;
      p('         ,' || tbuff.abbr || '.aud_beg_dtm = n_aud_beg_dtm');
      p('         ,' || tbuff.abbr || '.aud_beg_usr = n_aud_beg_usr');
   end if;
   p('    where ' || tbuff.abbr || '.id = o_id;');
   p('end upd;') ;
   p('----------------------------------------');
   p('procedure del');
   p('      (o_id  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm  in  timestamp with local time zone');
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup History Table insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name||'  in  '||get_dtype(buff));
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr  in  ' || usrdt);
      p('      ,o_aud_beg_dtm  in  timestamp with local time zone');
   end if;
   p('      )');
   p('is');
   p('begin');
   p('   if util.db_object_exists('''||upper(tbuff.name)||''', ''MATERIALIZED VIEW'')');
   p('   then');
   p('      raise_application_error(-20010, ''Delete not allowed on materialized view ' ||
            tbuff.name || '.  Deletes on ' || tbuff.name ||
            ' must be performed on the central database.'');');
   p('   end if;');
   p('   if not glob.get_db_constraints');
   p('   then');
   p('      ' || tbuff.name || '_tab.del');
   p('         (o_id');
   if tbuff.type = 'EFF'
   then
      p('         ,o_eff_beg_dtm');
      p('         ,x_eff_end_dtm');
   end if;
   -- Setup History Table insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('         ,o_'||buff.name);
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,o_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
   end if;
   p('         );');
   p('   end if;');
   p('   delete from ' || tbuff.name || ' ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = o_id;');
   p('end del;') ;
   p('----------------------------------------');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_vp_body;
----------------------------------------
PROCEDURE drop_act
   --  For a tbuff, drop the active view
IS
BEGIN
   p('drop view '||tbuff.name||'_act');
   p('/');
END drop_act;
----------------------------------------
PROCEDURE create_act
IS
   sp_type   user_errors.type%type;
   sp_name   user_errors.name%type;
   fkseq     number(2);
   tababbr   tables.abbr%type;
   join_txt  varchar2(30);
   fk_tid    number;
   nkseq     number;
BEGIN
   sp_type := 'view';
   sp_name := tbuff.name||'_act';
   p('create '||sp_type||' '||sp_name);
   p('      (id');
   if tbuff.type = 'EFF'
   then
      p('      ,eff_beg_dtm');
   end if;
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,'||buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,'|| buff.fk_prefix || 'id_path');
            p('      ,'|| buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,aud_beg_usr');
      p('      ,aud_beg_dtm');
   end if;
   p('      )');
   p('   as select ') ;
   p('       '||tbuff.abbr||'.id');
   if tbuff.type = 'EFF'
   then
      p('      ,' || tbuff.abbr || '.eff_beg_dtm');
   end if;
   -- Generate a list of columns for the select
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,' || tbuff.abbr || '.'|| buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,' || tbuff.name || '_dml.get_'|| buff.fk_prefix || 'id_path(' ||
                           tbuff.abbr || '.id)');
            p('      ,' || tbuff.name || '_dml.get_'|| buff.fk_prefix || 'nk_path(' ||
                           tbuff.abbr || '.id)');
         end if;
         fk_tid := -1;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            if nk_aa(buff.fk_table_id).lvl1_fk_tid_va(i) is null
            then
               p('      ,' || buff.fk_prefix ||
                              get_tababbr(buff.fk_table_id) ||
                       '.' || nk_aa(buff.fk_table_id).cbuff_va(i).name);
               fk_tid := -1;  -- The same Foreign Key Table may be referenced
                              --   twice, back-to-back, in column order
            else
               if fk_tid != nk_aa(buff.fk_table_id).lvl1_fk_tid_va(i)
               then
                  fk_tid := nk_aa(buff.fk_table_id).lvl1_fk_tid_va(i);
                  nkseq := 1;
               else
                  nkseq := nkseq + 1;
               end if;
               p('      ,' || buff.fk_prefix ||
                              get_tababbr(buff.fk_table_id) ||
                       '.' || get_tabname(nk_aa(buff.fk_table_id).lvl1_fk_tid_va(i)) ||
                     '_nk' || nkseq);
            end if;
         end loop;
/*
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,' || buff.fk_prefix ||
               get_tababbr(nk_aa(buff.fk_table_id).cbuff_va(i).table_id) ||
                    '.' || nk_aa(buff.fk_table_id).cbuff_va(i).name);
         end loop;
*/
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
   end if;
   p(' from             ' || tbuff.name || ' ' || tbuff.abbr);
   -- Generate a table join list for the view
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id    = tbuff.id
       order by COL.seq )
   loop
      tababbr := get_tababbr(buff.fk_table_id);
      if nvl(buff.req, buff.nk) is null
      then
         join_txt := '  left outer join ';
      else
         join_txt := '       inner join ';
      end if;
      p(join_txt || get_tabname(buff.fk_table_id) || '_act ' ||
          buff.fk_prefix || tababbr || ' on ' ||
          buff.fk_prefix || tababbr || '.id = ' ||
          tbuff.abbr || '.' || buff.name);
/*
      -- nk_tabs is a recursive procedure
      nk_tabs(buff.fk_table_id, '  ', nvl(buff.req,buff.nk), buff.fk_prefix,
              tbuff.abbr || '.' || buff.name);
*/
   end loop;
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant select on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('grant insert on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('grant update on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('grant delete on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('-- audit rename on '||sp_name||' by access');
   ps('-- /');
   p('');
   p('comment on table ' ||sp_name|| ' is ''' ||
      replace(tbuff.description,SQ1,SQ2) || '''');
   p('/');
   p('');
   act_col_comments(sp_name);
   p('');
   p('alter view '||sp_name||' add constraint '||sp_name||'_pk');
   p('   primary key (id) disable');
   p('/');
   p('');
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      p('alter view ' || sp_name || ' add constraint ' ||
                         sp_name || '_' || 'fk' || fkseq);
      p('   foreign key (' || buff.name || ') references ' ||
                         get_tabname(buff.fk_table_id) || '_act (id) disable');
      p('/');
   end loop;
   p('');
END create_act;
----------------------------------------
PROCEDURE drop_all
   --  For a tbuff, drop the active and deleted view
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop view '||tbuff.name||'_all');
      p('/');
      if table_self_ref(tbuff.id)
      then
         p('drop view '||tbuff.name||'_L');
         p('/');
      end if;
   end if;
END drop_all;
----------------------------------------
PROCEDURE create_all
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   fkseq    number(2);
   view_suffix  varchar2(10);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- This table has no _ALL view
      return;
   end if;
   if table_self_ref(tbuff.id)
   then
      -- Tables with self-referencing foreign keys must
      -- have this intermediate view "_L" to compute
      -- the ALL data before the self-referencing can
      -- be accomplished in the main "_ALL" view.
      sp_type := 'view';
      sp_name := tbuff.name||'_L';
      p('create '||sp_type||' '||sp_name);
      p('      (' || tbuff.name || '_id');
      p('      ,stat');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,eff_end_dtm');
      end if;
      p('      ,aud_beg_usr');
      p('      ,aud_end_usr');
      p('      ,aud_beg_dtm');
      p('      ,aud_end_dtm)');
      p('   as select ') ;
      p('       id');
      p('      ,''ACT''');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,cast(util.get_last_dtm as TIMESTAMP WITH LOCAL TIME ZONE)');
      end if;
      p('      ,aud_beg_usr');
      p('      ,null');
      p('      ,aud_beg_dtm');
      p('      ,null');
      p(' from  ' || tbuff.name || '_ACT');
      p(' union all select');
      p('       ' || tbuff.abbr || '.' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('      ,''HIST''');
      else
         p('      ,''AUD''');
      end if;
      -- Generate a list of columns for the select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'  || tbuff.abbr || '.' || buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for buf2 in (
               select * from tab_cols COL
                where COL.nk is not null
                 and  COL.table_id = buff.fk_table_id
                order by COL.nk )
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tababbr(buff.fk_table_id) ||
                        '.' || buf2.name);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.aud_end_dtm');
      p(' from             ' || tbuff.name || HOA || ' ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.fk_table_id != tbuff.id
           and  COL.table_id     = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ALL ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      p(' where last_active = ''Y''');
      p(' union all select');
      p('       ' || tbuff.abbr || '.' || tbuff.name || '_id');
      p('      ,''POP''');
      -- Generate a list of columns for the select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'  || tbuff.abbr || '.' || buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for buf2 in (
               select * from tab_cols COL
                where COL.nk is not null
                 and  COL.table_id = buff.fk_table_id
                order by COL.nk )
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tababbr(buff.fk_table_id) ||
                        '.' || buf2.name);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.pop_dtm eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.pop_usr aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.pop_dtm aud_end_dtm');
      p(' from             ' || tbuff.name || '_PDAT ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.fk_table_id != tbuff.id
           and  COL.table_id     = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ALL ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      p(' where pop_dml = ''INSERT''');
      p('/');
      show_errors(sp_type, sp_name);
      ps('');
      ps('grant select on '||sp_name||' to '||abuff.abbr||'_app');
      ps('/');
      ps('-- audit rename on '||sp_name||' by access');
      ps('-- /');
      p('');
      p('comment on table ' ||sp_name|| ' is ''Active and Deleted ' ||
         replace(tbuff.description,SQ1,SQ2) ||
        '.  NOTE: Deleted records in this view with missing FK data for a non-null FK ID cannot be "popped"''');
      p('/');
      p('');
	  l_col_comments(sp_name);
      p('');
      p('alter view '||sp_name||' add constraint '||sp_name||'_pk');
      p('   primary key (' || tbuff.name || '_id) disable');
      p('/');
      p('');
	  fkseq := 0;
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id = tbuff.id
          order by COL.seq )
      loop
	     fkseq := fkseq + 1;
         p('alter view ' || sp_name || ' add constraint ' ||
                            sp_name || '_' || 'fk' || fkseq);
         p('   foreign key (' || buff.name || ') references ' ||
                            get_tabname(buff.fk_table_id) || '_act (id) disable');
         p('/');
      end loop;
      p('');
      trig_no_dml(sp_name, sp_type, 'insert');
      trig_no_dml(sp_name, sp_type, 'update');
      trig_no_dml(sp_name, sp_type, 'delete');
   end if;
   sp_type := 'view';
   sp_name := tbuff.name||'_all';
   p('create '||sp_type||' '||sp_name);
   p('      (id');
   p('      ,stat');
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,'||buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,'|| buff.fk_prefix || 'id_path');
            p('      ,'|| buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('      ,eff_beg_dtm');
      p('      ,eff_end_dtm');
   end if;
   p('      ,aud_beg_usr');
   p('      ,aud_end_usr');
   p('      ,aud_beg_dtm');
   p('      ,aud_end_dtm)');
   p('   as select ') ;
   if table_self_ref(tbuff.id)
   then
      p('       '||tbuff.abbr||'.' || tbuff.name || '_id');
      p('      ,'||tbuff.abbr||'.stat');
      -- Generate a list of columns for the "L" select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,' || tbuff.abbr || '.'|| buff.name);
         if buff.fk_table_id is not null
         then
            if buff.fk_table_id = tbuff.id
            then
               -- Setup the path functions for the hierarchy
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'id_path_L(' ||
                              tbuff.abbr || '.' || tbuff.name || '_id)');
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'nk_path_L(' ||
                           tbuff.abbr || '.' || tbuff.name || '_id)');
            end if;
            if table_self_ref(tbuff.id) and
               buff.fk_table_id != buff.table_id
            then
               for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
               loop
                  p('      ,' || buff.fk_prefix || tbuff.abbr ||
                           '.' || get_tabname(buff.fk_table_id) ||
                           '_nk' || i);
               end loop;
            else
               for buf2 in (
                  select * from tab_cols COL
                   where COL.nk is not null
                    and  COL.table_id = buff.fk_table_id
                   order by COL.nk )
               loop
                  if buf2.fk_table_id is not null
                  then
                     for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
                     loop
                        p('      ,' || buff.fk_prefix ||
                                       get_tababbr(buff.fk_table_id) ||
                                 '.' || buf2.fk_prefix ||
                                        get_tabname(buf2.fk_table_id) ||
                                 '_nk' || i);
                     end loop;
                  else
                     p('      ,' || buff.fk_prefix ||
                                    get_tababbr(buff.fk_table_id) ||
                              '.' || buf2.name);
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.aud_end_dtm');
      p(' from             ' || tbuff.name || '_L ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.fk_table_id = tbuff.id
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_L ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.' ||
                   tbuff.name || '_id = ' || tbuff.abbr || '.' || buff.name);
      end loop;
   else
      p('       id');
      p('      ,''ACT''');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null
         then
            if buff.fk_table_id = tbuff.id
            then
               -- Setup the path functions for the hierarchy
               p('      ,'|| buff.fk_prefix || 'id_path');
               p('      ,'|| buff.fk_prefix || 'nk_path');
            end if;
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,cast(util.get_last_dtm as TIMESTAMP WITH LOCAL TIME ZONE)');
      end if;
      p('      ,aud_beg_usr');
      p('      ,null');
      p('      ,aud_beg_dtm');
      p('      ,null');
      p(' from  ' || tbuff.name || '_ACT');
      p(' union all select');
      p('       '||tbuff.abbr||'.' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('      ,''HIST''');
      else
         p('      ,''AUD''');
      end if;
      -- Generate a list of columns for the select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,' || tbuff.abbr || '.'|| buff.name);
         if buff.fk_table_id is not null
         then
            if buff.fk_table_id = tbuff.id
            then
               -- Setup the path functions for the hierarchy
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'id_path_L(' ||
                              tbuff.abbr || '.' || tbuff.name || '_id)');
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'nk_path_L(' ||
                              tbuff.abbr || '.' || tbuff.name || '_id)');
            end if;
            if table_self_ref(tbuff.id) and
               buff.fk_table_id != buff.table_id
            then
               for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
               loop
                  p('      ,' || buff.fk_prefix || tbuff.abbr ||
                           '.' || get_tabname(buff.fk_table_id) ||
                           '_nk' || i);
               end loop;
            else
               for buf2 in (
                  select * from tab_cols COL
                   where COL.nk is not null
                    and  COL.table_id = buff.fk_table_id
                   order by COL.nk )
               loop
                  if buf2.fk_table_id is not null
                  then
                     for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
                     loop
                        p('      ,' || buff.fk_prefix ||
                                       get_tababbr(buff.fk_table_id) ||
                                 '.' || buf2.fk_prefix ||
                                        get_tabname(buf2.fk_table_id) ||
                                 '_nk' || i);
                     end loop;
                  else
                     p('      ,' || buff.fk_prefix ||
                                    get_tababbr(buff.fk_table_id) ||
                              '.' || buf2.name);
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.aud_end_dtm');
      p(' from             ' || tbuff.name || HOA || ' ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ALL ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      p(' where last_active = ''Y''');
      p(' union all select');
      p('       '||tbuff.abbr||'.' || tbuff.name || '_id');
      p('      ,''POP''');
      -- Generate a list of columns for the select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,' || tbuff.abbr || '.'|| buff.name);
         if buff.fk_table_id is not null
         then
            if buff.fk_table_id = tbuff.id
            then
               -- Setup the path functions for the hierarchy
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'id_path_L(' ||
                              tbuff.abbr || '.' || tbuff.name || '_id)');
               p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'nk_path_L(' ||
                              tbuff.abbr || '.' || tbuff.name || '_id)');
            end if;
            if table_self_ref(tbuff.id) and
               buff.fk_table_id != buff.table_id
            then
               for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
               loop
                  p('      ,' || buff.fk_prefix || tbuff.abbr ||
                           '.' || get_tabname(buff.fk_table_id) ||
                           '_nk' || i);
               end loop;
            else
               for buf2 in (
                  select * from tab_cols COL
                   where COL.nk is not null
                    and  COL.table_id = buff.fk_table_id
                   order by COL.nk )
               loop
                  if buf2.fk_table_id is not null
                  then
                     for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
                     loop
                        p('      ,' || buff.fk_prefix ||
                                       get_tababbr(buff.fk_table_id) ||
                                 '.' || buf2.fk_prefix ||
                                        get_tabname(buf2.fk_table_id) ||
                                 '_nk' || i);
                     end loop;
                  else
                     p('      ,' || buff.fk_prefix ||
                                    get_tababbr(buff.fk_table_id) ||
                              '.' || buf2.name);
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.pop_dtm eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.pop_usr aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.pop_dtm aud_end_dtm');
      p(' from             ' || tbuff.name || '_PDAT ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ALL ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      p(' where pop_dml = ''INSERT''');
   end if;
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant select on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('-- audit rename on '||sp_name||' by access');
   ps('-- /');
   p('');
   p('comment on table ' ||sp_name|| ' is ''Active and Deleted ' ||
      replace(tbuff.description,SQ1,SQ2) ||
     '.  NOTE: Deleted records in this view with missing FK data for a non-null FK ID cannot be "popped"''');
   p('/');
   p('');
   all_col_comments(sp_name);
   p('');
   p('alter view '||sp_name||' add constraint '||sp_name||'_pk');
   p('   primary key (id) disable');
   p('/');
   p('');
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      p('alter view ' || sp_name || ' add constraint ' ||
                         sp_name || '_' || 'fk' || fkseq);
      p('   foreign key (' || buff.name || ') references ' ||
                          get_tabname(buff.fk_table_id) || '_act (id) disable');
      p('/');
   end loop;
   p('');
   trig_no_dml(sp_name, sp_type, 'insert');
   trig_no_dml(sp_name, sp_type, 'update');
   trig_no_dml(sp_name, sp_type, 'delete');
END create_all;
----------------------------------------
PROCEDURE drop_asof
   --  For a tbuff, drop the deleted view
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop view '||tbuff.name||'_asof');
      p('/');
      if table_self_ref(tbuff.id)
      then
         p('drop view '||tbuff.name||'_F');
         p('/');
      end if;
   end if;
END drop_asof;
----------------------------------------
--  This view will be missing the "Natural Key" values
--  for foreign keys if there is a mis-match in an
--  Effective Beginning/Ending Date/Time in either the
--  base table or the foreign key table.  However, the
--  ID of the foreign key will not be missing.
PROCEDURE create_asof
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   fkseq    number(2);
   view_suffix  varchar2(10);
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- Don't create the _ASOF view
      return;
   end if;
   if table_self_ref(tbuff.id)
   then
      -- Tables with self-referencing foreign keys must
      -- have this intermediate view "_F" to compute
      -- the ASOF data before the self-referencing can
      -- be accomplished in the main "_ASOF" view.
      sp_type := 'view';
      sp_name := tbuff.name||'_F';
      p('create '||sp_type||' '||sp_name);
      p('      (' || tbuff.name || '_id');
      p('      ,stat');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id     = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,eff_end_dtm');
      end if;
      p('      ,aud_beg_usr');
      p('      ,aud_end_usr');
      p('      ,aud_beg_dtm');
      p('      ,aud_end_dtm)');
      p('   as select ') ;
      p('       id');
      p('      ,''ACT''');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id     = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,cast(util.get_last_dtm as TIMESTAMP WITH LOCAL TIME ZONE)');
      end if;
      p('      ,aud_beg_usr');
      p('      ,null');
      p('      ,aud_beg_dtm');
      p('      ,null');
      p(' from ' || tbuff.name || '_ACT');
      if tbuff.type = 'EFF'
      then
         p(' where eff_beg_dtm <= glob.get_asof_dtm');
      else
         p(' where aud_beg_dtm <= glob.get_asof_dtm');
      end if;
      p(' union all select') ;
      p('       ' || tbuff.abbr || '.' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('      ,''HIST''');
      else
         p('      ,''AUD''');
      end if;
      -- Generate a list of columns for the select
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'  || tbuff.abbr || '.' || buff.name);
         if buff.fk_table_id is not null and
            buff.fk_table_id != tbuff.id
         then
            for buf2 in (
               select * from tab_cols COL
                where COL.nk is not null
                 and  COL.table_id = buff.fk_table_id
                order by COL.nk )
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tababbr(buff.fk_table_id) ||
                        '.' || buf2.name);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,' || tbuff.abbr || '.eff_beg_dtm');
         p('      ,' || tbuff.abbr || '.eff_end_dtm');
      end if;
      p('      ,' || tbuff.abbr || '.aud_beg_usr');
      p('      ,' || tbuff.abbr || '.aud_end_usr');
      p('      ,' || tbuff.abbr || '.aud_beg_dtm');
      p('      ,' || tbuff.abbr || '.aud_end_dtm');
      p(' from             ' || tbuff.name || HOA || ' ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.fk_table_id != tbuff.id
           and  COL.table_id     = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ALL ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      if tbuff.type = 'EFF'
      then
         p(' where ' || tbuff.abbr || '.eff_beg_dtm <= glob.get_asof_dtm');
         p('  and  ' || tbuff.abbr || '.eff_end_dtm >  glob.get_asof_dtm');
      else
         p(' where ' || tbuff.abbr || '.aud_beg_dtm <= glob.get_asof_dtm');
         p('  and  ' || tbuff.abbr || '.aud_end_dtm >  glob.get_asof_dtm');
      end if;
      p('/');
      show_errors(sp_type, sp_name);
      ps('');
      ps('grant select on '||sp_name||' to '||abuff.abbr||'_app');
      ps('/');
      ps('-- audit rename on '||sp_name||' by access');
      ps('-- /');
      p('');
      p('comment on table ' ||sp_name|| ' is ''AS OF glob.get_asof_dtm ' ||
         replace(tbuff.description,SQ1,SQ2) || '''');
      p('/');
      p('');
      f_col_comments(sp_name);
      p('');
      p('alter view '||sp_name||' add constraint '||sp_name||'_pk');
      p('   primary key (' || tbuff.name || '_id) disable');
      p('/');
      p('');
	  fkseq := 0;
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id = tbuff.id
          order by COL.seq )
      loop
	     fkseq := fkseq + 1;
         p('alter view ' || sp_name || ' add constraint ' ||
                            sp_name || '_' || 'fk' || fkseq);
         p('   foreign key (' || buff.name || ') references ' ||
                             get_tabname(buff.fk_table_id) || '_act (id) disable');
         p('/');
      end loop;
      p('');
      trig_no_dml(sp_name, sp_type, 'insert');
      trig_no_dml(sp_name, sp_type, 'update');
      trig_no_dml(sp_name, sp_type, 'delete');
   end if;
   sp_type := 'view';
   sp_name := tbuff.name||'_asof';
   p('create '||sp_type||' '||sp_name);
   p('      (id');
   p('      ,stat');
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,'||buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,'|| buff.fk_prefix || 'id_path');
            p('      ,'|| buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('      ,eff_beg_dtm');
      p('      ,eff_end_dtm');
   end if;
   p('      ,aud_beg_usr');
   p('      ,aud_end_usr');
   p('      ,aud_beg_dtm');
   p('      ,aud_end_dtm)');
   p('   as select ') ;
   if NOT table_self_ref(tbuff.id)
   then
      p('       id');
      p('      ,''ACT''');
      -- Generate a column list for the view
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,'||buff.name);
         if buff.fk_table_id is not null
         then
            if buff.fk_table_id = tbuff.id
            then
               -- Setup the path functions for the hierarchy
               p('      ,'|| buff.fk_prefix || 'id_path');
               p('      ,'|| buff.fk_prefix || 'nk_path');
            end if;
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         end if;
      end loop;
      if tbuff.type = 'EFF'
      then
         p('      ,eff_beg_dtm');
         p('      ,cast(util.get_last_dtm as TIMESTAMP WITH LOCAL TIME ZONE)');
      end if;
      p('      ,aud_beg_usr');
      p('      ,null');
      p('      ,aud_beg_dtm');
      p('      ,null');
      p(' from ' || tbuff.name || '_ACT');
      if tbuff.type = 'EFF'
      then
         p(' where eff_beg_dtm <= glob.get_asof_dtm');
      else
         p(' where aud_beg_dtm <= glob.get_asof_dtm');
      end if;
      p(' union all select') ;
      p('       '||tbuff.abbr||'.' || tbuff.name || '_id');
      if tbuff.type = 'EFF'
      then
         p('      ,''HIST''');
      else
         p('      ,''AUD''');
      end if;
   else
      p('       '||tbuff.abbr||'.' || tbuff.name || '_id');
      p('      ,'||tbuff.abbr||'.stat');
   end if;
   -- Generate a list of columns for the select
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,' || tbuff.abbr || '.'|| buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = buff.table_id
         then
            -- Setup the path functions for the hierarchy
            p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'id_path_F(' ||
                           tbuff.abbr || '.' || tbuff.name || '_id)');
            p('      ,' || tbuff.name || '_sh.get_'|| buff.fk_prefix || 'nk_path_F(' ||
                           tbuff.abbr || '.' || tbuff.name || '_id)');
         end if;
         if table_self_ref(tbuff.id) and
            buff.fk_table_id != buff.table_id
         then
            --  This is a self-referencing table, but
            --  this is not a self-referenced foreign key
            for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
            loop
               p('      ,' || buff.fk_prefix || tbuff.abbr ||
                        '.' || get_tabname(buff.fk_table_id) ||
                        '_nk' || i);
            end loop;
         else
            --  This is NOT a self-referencing table
            for buf2 in (
               select * from tab_cols COL
                where COL.nk is not null
                 and  COL.table_id = buff.fk_table_id
                order by COL.nk )
            loop
               -- These are the NK columns from the FK
               if buf2.fk_table_id is not null
               then
                  --  This NK column from the FK table is a FK
                  for i in 1 .. nk_aa(buf2.fk_table_id).cbuff_va.COUNT
                  loop
                     -- Get the NK columns from the FK of the FK
                     p('      ,' || buff.fk_prefix ||
                                    get_tababbr(buff.fk_table_id) ||
                              '.' || buf2.fk_prefix ||
                                     get_tabname(buf2.fk_table_id) ||
                              '_nk' || i);
                  end loop;
               else
                  --  This NK column from the FK table is NOT a FK
                  p('      ,' || buff.fk_prefix ||
                                 get_tababbr(buff.fk_table_id) ||
                           '.' || buf2.name);
               end if;
            end loop;
         end if;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('      ,' || tbuff.abbr || '.eff_beg_dtm');
      p('      ,' || tbuff.abbr || '.eff_end_dtm');
   end if;
   p('      ,' || tbuff.abbr || '.aud_beg_usr');
   p('      ,' || tbuff.abbr || '.aud_end_usr');
   p('      ,' || tbuff.abbr || '.aud_beg_dtm');
   p('      ,' || tbuff.abbr || '.aud_end_dtm');
   if table_self_ref (tbuff.id)
   then
      p(' from             ' || tbuff.name || '_F ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.fk_table_id = tbuff.id
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_F ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.' ||
                   tbuff.name || '_id = ' || tbuff.abbr || '.' || buff.name);
      end loop;
   else
      p(' from             ' || tbuff.name || HOA || ' ' || tbuff.abbr);
      -- Generate a table join list for the view
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if get_tabtype(buff.fk_table_id) = 'NON' then
            view_suffix := '_ACT ';
         else
            view_suffix := '_ASOF ';
         end if;
         p('  left outer join ' || 
                   get_tabname(buff.fk_table_id) || view_suffix ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || ' on ' ||
                   buff.fk_prefix || get_tababbr(buff.fk_table_id) || '.id = ' ||
                   tbuff.abbr || '.' || buff.name);
      end loop;
      if tbuff.type = 'EFF'
      then
         p(' where ' || tbuff.abbr || '.eff_beg_dtm <= glob.get_asof_dtm');
         p('  and  ' || tbuff.abbr || '.eff_end_dtm >  glob.get_asof_dtm');
      else
         p(' where ' || tbuff.abbr || '.aud_beg_dtm <= glob.get_asof_dtm');
         p('  and  ' || tbuff.abbr || '.aud_end_dtm >  glob.get_asof_dtm');
      end if;
   end if;
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant select on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('-- audit rename on '||sp_name||' by access');
   ps('-- /');
   p('');
   p('comment on table ' ||sp_name|| ' is ''AS OF glob.get_asof_dtm ' ||
      replace(tbuff.description,SQ1,SQ2) || '''');
   p('/');
   p('');
   asof_col_comments(sp_name);
   p('');
   p('alter view '||sp_name||' add constraint '||sp_name||'_pk');
   p('   primary key (id) disable');
   p('/');
   p('');
   fkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id is not null
        and  COL.table_id = tbuff.id
       order by COL.seq )
   loop
      fkseq := fkseq + 1;
      p('alter view ' || sp_name || ' add constraint ' ||
                         sp_name || '_' || 'fk' || fkseq);
      p('   foreign key (' || buff.name || ') references ' ||
                          get_tabname(buff.fk_table_id) || '_act (id) disable');
      p('/');
   end loop;
   p('');
   trig_no_dml(sp_name, sp_type, 'insert');
   trig_no_dml(sp_name, sp_type, 'update');
   trig_no_dml(sp_name, sp_type, 'delete');
END create_asof;
----------------------------------------
PROCEDURE create_vtrig
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   fkcol    varchar2(100);
BEGIN
   sp_type := 'TRIGGER';
   sp_name := tbuff.name||'_act_ioi';
   p('create '||sp_type||' '||sp_name);
   p('   instead of insert on '||tbuff.name||'_act');
   p('   for each row');
   p('declare');
   p('   n_id  NUMBER(38);');
   if tbuff.type = 'EFF'
   then
      p('   n_eff_beg_dtm   timestamp(9) with local time zone;');
   end if;
   -- Generate a list of column declarations
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   n_'||buff.name||'  '||get_dtype_full(buff)||';');
   end loop;
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   p('   n_id := :new.id;');
   if tbuff.type = 'EFF'
   then
      p('   n_eff_beg_dtm := :new.eff_beg_dtm;');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   n_' || buff.name || ' := :new.' || buff.name || ';');
   end loop;
   p('   '||tbuff.name||'_view.ins');
   p('      (n_id');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm');
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,:new.' || buff.fk_prefix || 'id_path');
            p('      ,:new.' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,:new.' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i );
         end loop;
      end if;
   end loop;
   p('      );') ;
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
   /****************************************************************/
   sp_name := tbuff.name||'_act_iou';
   p('create '||sp_type||' '||sp_name);
   p('   instead of update on '||tbuff.name||'_act');
   p('   for each row');
   p('declare');
   if tbuff.type = 'EFF'
   then
      p('   n_eff_beg_dtm   timestamp(9) with local time zone;');
   end if;
   -- Generate a list of column declarations
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   n_'||buff.name||'  '||get_dtype_full(buff)||';');
   end loop;
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   if tbuff.type = 'EFF'
   then
      p('   n_eff_beg_dtm := :new.eff_beg_dtm;');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   n_' || buff.name || ' := :new.' || buff.name || ';');
   end loop;
   p('   '||tbuff.name||'_view.upd ');
   p('      (:old.id');
   if tbuff.type = 'EFF'
   then
      p('      ,:old.eff_beg_dtm');
      p('      ,n_eff_beg_dtm');
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,:old.'||buff.name) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,:old.' || buff.fk_prefix || 'id_path');
            p('      ,:old.' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,:old.' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
      p('      ,n_'||buff.name) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,:new.' || buff.fk_prefix || 'id_path');
            p('      ,:new.' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,:new.' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,:old.aud_beg_usr');
      p('      ,:old.aud_beg_dtm');
   end if;
   p('      );') ;
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
   /****************************************************************/
   sp_name := tbuff.name||'_act_iod';
   p('create '||sp_type||' '||sp_name);
   p('   instead of delete on '||tbuff.name||'_act');
   p('   for each row');
   if tbuff.type = 'EFF'
   then
      p('declare');
      p('   x_eff_end_dtm   timestamp(9) with local time zone;');
   end if;
   p('begin');
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   header_comments;
   p('');
   p('   '||tbuff.name||'_view.del ');
   p('      (:old.id');
   if tbuff.type = 'EFF'
   then
      p('      ,:old.eff_beg_dtm');
      p('      ,x_eff_end_dtm');
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,:old.'||buff.name) ;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,:old.aud_beg_usr');
      p('      ,:old.aud_beg_dtm');
   end if;
   p('      );') ;
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_vtrig;
----------------------------------------
PROCEDURE drop_dp
   --  For a tbuff, drop the dml package
IS
BEGIN
   p('drop package '||tbuff.name||'_dml');
   p('/');
END drop_dp;
----------------------------------------
PROCEDURE create_dp_spec
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   nkfnd    boolean;
BEGIN
   sp_type := 'package';
   sp_name := tbuff.name||'_dml';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p('   -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p('   -- (Data Manipulation Language, Foreign Key and Path Lookup)');
   header_comments;
   p('');
   p('   function get_next_id');
   p('      return number;');
   p('   function get_curr_id');
   p('      return number;');
   p('');
   p('   function get_id');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) || '_nk' || i ||
                   '  in  ' || get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number;');
   p('   function get_nk');
   p('      (id_in  in  number');
   p('      ) return varchar2;');
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id = tbuff.id
        and  COL.table_id    = tbuff.id )
   loop
      p('');
      p('   function get_' || buff.fk_prefix || 'id_path');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('   function get_' || buff.fk_prefix || 'nk_path');
      p('      (id_in  in  number');
      p('      ) return varchar2;');
      p('   function get_' || buff.fk_prefix || 'id_by_id_path');
      p('      (id_path_in  varchar2');
      p('      ) return number;');
      p('   function get_' || buff.fk_prefix || 'id_by_nk_path');
      p('      (nk_path_in  varchar2');
      p('      ) return number;');
   end loop;
   p('');
   p('   function tab_to_col');
   p('         (id_in  in  number)');
   p('      return col_type;');
   p('');
   p('   procedure clear');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE);');
   if tbuff.type in ('EFF', 'LOG') or table_has_fk(tbuff.id)
   then
      p('   procedure clear');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE);');
   end if;
   p('');
   p('   procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path_in  in  VARCHAR2  default null');
            p('      ,n_'|| buff.fk_prefix || 'nk_path_in  in  VARCHAR2  default null');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '_in  in  ' ||
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                     '  default null');
         end loop;
      end if;
   end loop;
   p('      );');
   p('   procedure ins');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE);');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   procedure ins');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE);');
   end if;
   p('');
   p('   procedure upd');
   p('      (o_id_in  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   nkfnd := FALSE;
   -- Setup DML package new update columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         nkfnd := TRUE;
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_' || buff.fk_prefix || 'id_path_in  in  VARCHAR2  default null');
            p('      ,n_' || buff.fk_prefix || 'nk_path_in  in  VARCHAR2  default null');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '_in  in  ' ||
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                     '  default null');
         end loop;
      end if;
   end loop;
   --if nkfnd
   --then
      p('      ,nkdata_provided_in  in   VARCHAR2  default ''Y''');
   --end if;
   p('      );');
   p('   procedure upd');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE);');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   procedure upd');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE);');
   end if;
   p('');
   p('   procedure del');
   p('      (o_id_in  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   p('      );');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      p('   procedure pop');
      p('      (id_in  in  number);');
   end if;
   p('');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   ps('');
   ps('grant execute on '||sp_name||' to '||abuff.abbr||'_app');
   ps('/');
   ps('---- audit rename on '||sp_name||' by access');
   ps('---- /');
   p('');
END create_dp_spec;
----------------------------------------
PROCEDURE create_dp_body
IS
   sp_type  user_errors.type%type;
   sp_name  user_errors.name%type;
   tstr     varchar2(200);
   nkseq    number(2);
   nkfnd    boolean;
BEGIN
   sp_type := 'package body';
   sp_name := tbuff.name||'_dml';
   p('create '||sp_type||' '||sp_name);
   p('is') ;
   p('');
   p(' -- ' || initcap(sp_type) || ' ' || initcap(sp_name));
   p(' -- (Data Manipulation Language, Foreign Key and Path Lookup)');
   header_comments;
   p('');
   p('----------------------------------------');
   p('function get_next_id');
   p('      return number');
   p('is');
   p('   retid  number;');
   if abuff.dbid is null
   then
      p('begin');
      p('   select '||tbuff.name||'_seq.nextval');
      p('    into  retid from dual;');
   else
      p('   sql_txt  varchar2(200);');
      p('begin');
      p('   -- This is required because synonyms to remote sequences do not work');
      p('   sql_txt := ''select '||tbuff.name||'_seq.nextval'';');
      p('   if NOT util.db_object_exists(''' || upper(tbuff.name)||'_SEQ'', ''SEQUENCE'')');
      p('   then');
      p('      sql_txt := sql_txt || ''@' || abuff.dbid || ''';');
      p('   end if;');
      p('   sql_txt := sql_txt || '' into :a from dual'';');
      p('   execute immediate sql_txt into retid;');
   end if;
   p('   return retid;');
   p('end get_next_id;');
   p('----------------------------------------');
   p('function get_curr_id');
   p('      return number');
   p('is');
   p('   retid  number;');
   if abuff.dbid is null
   then
      p('begin');
      p('   select '||tbuff.name||'_seq.currval');
      p('    into  retid from dual;');
   else
      p('   sql_txt  varchar2(200);');
      p('begin');
      p('   -- This is required because synonyms to remote sequences do not work');
      p('   sql_txt := ''select '||tbuff.name||'_seq.currval'';');
      p('   if NOT util.db_object_exists(''' || upper(tbuff.name)||'_SEQ'', ''SEQUENCE'')');
      p('   then');
      p('      sql_txt := sql_txt || ''@' || abuff.dbid || ''';');
      p('   end if;');
      p('   sql_txt := sql_txt || '' into :a from dual'';');
      p('   execute immediate sql_txt into retid;');
   end if;
   p('   return retid;');
   p('end get_curr_id;');
   p('----------------------------------------');
   p('function get_id');
   for i in 1 .. nk_aa(tbuff.id).cbuff_va.COUNT
   loop
      if i = 1
      then
         p('      (' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      else
         p('      ,' || get_tabname(tbuff.id) ||
                  '_nk' || i || '  in  ' ||
                  get_dtype(nk_aa(tbuff.id).cbuff_va(i)));
      end if;
   end loop;
   p('      ) return number');
   p('   -- For all the Natural Key Columns, Return an ID');
   p('is');
   p('   retid  number(38);');
   p('begin');
   p('   select id');
   p('    into  retid');
   p('    from  ' || tbuff.name || '  ' || tbuff.abbr);
   nkseq  := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk)
   loop
      if buff.fk_table_id is null
      then
         -- Set the Natural Key Column directly from the paramter
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || tbuff.name || '_nk' || nkseq);
         end if;
         nkseq := nkseq + 1;
      else
         -- Use the get_id function to set the Natural Key Column
         if nkseq = 1
         then
            p('    where ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         else
            p('     and  ' || tbuff.abbr || '.' || buff.name ||
               ' = ' || get_tabname(buff.fk_table_id) || '_dml.get_id');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            if i = 1
            then
               p('             (' || tbuff.name || '_nk' || nkseq);
            else
               p('             ,' || tbuff.name || '_nk' || nkseq);
            end if;
            nkseq := nkseq + 1;
         end loop;
         p('             )');
      end if;
   end loop;
   p('    ;');
   p('   return retid;');
   p('exception');
   p('   when no_data_found');
   p('   then');
   p('      return null;');
   p('   when others');
   p('   then');
   p('      raise;');
   p('end get_id;');
   p('----------------------------------------');
   p('function get_nk');
   p('      (id_in  in  number)');
   p('   return varchar2');
   p('   -- For an ID, return a delimited list of Natural Key Values');
   p('is');
   p('   rtxt  varchar2(32767);');
   p('begin');
   nkseq := 1;
   for buff in (
      select * from tab_cols COL
       where COL.nk       is not null
        and  COL.table_id = tbuff.id
       order by COL.nk )
   loop
      if buff.fk_table_id is null
      then
         -- Set the delimited list directly from the table data
         if nkseq = 1
         then
            p('   select substr(   ' || tbuff.abbr || '.' || buff.name);
         else
            p('    || util.nk_sep || ' || tbuff.abbr || '.' || buff.name);
         end if;
      else
         -- Use the get_nk function to set the delimted list
         if nkseq = 1
         then
            p('   select substr(   ' || get_tabname(buff.fk_table_id) ||
                   '_dml.get_nk(' || tbuff.abbr || '.' || buff.name || ')');
         else
            p('    || util.nk_sep || ' || get_tabname(buff.fk_table_id) ||
                   '_dml.get_nk(' || tbuff.abbr || '.' || buff.name || ')');
         end if;
      end if;
      nkseq := nkseq + 1;
   end loop;
   p('                         ,1,32767)');
   p('    into  rtxt');
   p('    from  ' || tbuff.name || ' ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = id_in;');
   p('   return rtxt;');
   p('exception');
   p('   when no_data_found then');
   p('      return null;');
   p('   when others then');
   p('      raise;');
   p('end get_nk;');
   -- Setup hierarchy functions
   for buff in (
      select * from tab_cols COL
       where COL.fk_table_id = tbuff.id
        and  COL.table_id    = tbuff.id )
   loop
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_path');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of IDs');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select id, level from ' || tbuff.name);
      p('       start with id = id_in');
      p('       connect by nocycle id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.id);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.id || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'id_path;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'nk_path');
      p('      (id_in  in  number)');
      p('   return varchar2');
      p('   -- For a hierarchy ID, return a delimited list of');
      p('   --    Natural Key sets');
      p('is');
      p('   rtxt  varchar2(4000);');
      p('   rlen  number(4);');
      p('begin');
      p('   rtxt := NULL;');
      p('   rlen := 0;');
      p('   for buff in (');
      p('      select ' || tbuff.name || '_dml.get_nk(id) nk');
      p('            ,level');
      p('       from  ' || tbuff.name);
      p('       start with id = id_in');
      p('       connect by nocycle id = prior ' || buff.name);
      p('       order by level desc )');
      p('   loop');
      p('      if buff.level > 1');
      p('      then');
      p('         rlen := rlen + length(buff.nk);');
      p('         if rlen > 4000 - 3');
      p('         then');
      p('            return rtxt || ''...'';');
      p('         end if;');
      p('         rtxt := rtxt || buff.nk || util.path_sep;');
      p('      end if;');
      p('   end loop;');
      p('   return substr(rtxt,1,length(rtxt)-1);');
      p('end get_' || buff.fk_prefix || 'nk_path;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_id_path');
      p('      (id_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || ' ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_dml.get_' ||
                         buff.fk_prefix || 'id_path('  ||
                        tbuff.abbr      || '.id) || util.path_sep || ' );
      p('          ' || tbuff.abbr      || '.id = id_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_id_path;');
      p('----------------------------------------');
      p('function get_' || buff.fk_prefix || 'id_by_nk_path');
      p('      (nk_path_in  varchar2');
      p('      ) return number');
      p('is');
      p('   retid  number(38);');
      p('begin');
      p('   select ' || tbuff.abbr || '.id');
      p('    into  retid');
      p('    from  ' || tbuff.name || ' ' || tbuff.abbr);
      p('    where ' || tbuff.name      || '_dml.get_' ||
                         buff.fk_prefix || 'nk_path('  ||
                        tbuff.abbr      || '.id) || util.path_sep ||' );
      p('          ' || tbuff.name      || '_dml.get_nk(' ||
                        tbuff.abbr      || '.id) = nk_path_in;' );
      p('   return retid;');
      p('exception');
      p('   when no_data_found then');
      p('      return null;');
      p('   when others then');
      p('      raise;');
      p('end get_' || buff.fk_prefix || 'id_by_nk_path;');
   end loop;
   p('----------------------------------------');
   p('function tab_to_col');
   p('      (id_in  in  number)');
   p('   return col_type');
   p('is');
   p('   -- This function is duplicated in '||tbuff.name||'_POP');
   p('   cursor acur is');
   p('      select * from ' || tbuff.name);
   p('       where id = id_in;');
   p('   abuf   acur%ROWTYPE;');
   p('   rcol      col_type;');
   p('begin');
   p('   open acur;');
   p('   fetch acur into abuf;');
   p('   if acur%NOTFOUND');
   p('   then');
   p('      rcol := COL_TYPE(null);');
   p('      close acur;');
   p('      return rcol;');
   p('   end if;');
   p('   rcol := COL_TYPE');
   nkseq := 0;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if buff.type like 'DATE%'   OR
         buff.type like 'TIMESTAMP%'
      then
         tstr := ''', to_char(abuf.' || buff.name ||
                   ', ''' || get_colformat(buff) || '''))';
      elsif buff.type like 'NUMBER%' OR
         buff.fk_table_id is not null
      then
         tstr := ''', to_char(abuf.' || buff.name || '))';
      else
         tstr := ''', abuf.' || buff.name || ')';
      end if;
      if nkseq = 0
      then
         p('             (PAIR_TYPE(''' || buff.name || tstr);
         nkseq := 1;
      else
         p('             ,PAIR_TYPE(''' || buff.name || tstr);
      end if;
   end loop;
   p('                );');
   p('   close acur;');
   p('   return rcol;');
   p('end tab_to_col;');
   p('----------------------------------------');
   p('procedure clear');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE)');
   p('   -- Clear a %ROWTYPE buffer');
   p('is');
   p('begin');
   p('   n_buff.id := null;');
   if tbuff.type = 'EFF'
   then
      p('   n_buff.eff_beg_dtm := null;');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   n_buff.'||buff.name||' := null;');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('   n_buff.'|| buff.fk_prefix || 'id_path := null;');
            p('   n_buff.'|| buff.fk_prefix || 'nk_path := null;');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('   n_buff.' || buff.fk_prefix ||
                  get_tabname(buff.fk_table_id) ||
                  '_nk' || i || ' := null;');
         end loop;
      end if;
   end loop;
   p('end clear;');
   if tbuff.type in ('EFF', 'LOG') or table_has_fk(tbuff.id)
   then
      p('----------------------------------------');
      p('procedure clear');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE)');
      p('   -- Clear a %ROWTYPE buffer');
      p('is');
      p('begin');
      p('   n_buff.id := null;');
      if tbuff.type = 'EFF'
      then
         p('   n_buff.eff_beg_dtm := null;');
      end if;
      -- Setup DML package insert columns
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('   n_buff.'||buff.name||' := null;');
      end loop;
      p('end clear;');
   end if;
   p('----------------------------------------');
   p('procedure ins');
   p('      (n_id  in out  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff)) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path_in  in  VARCHAR2  default null');
            p('      ,n_'|| buff.fk_prefix || 'nk_path_in  in  VARCHAR2  default null');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '_in  in  ' ||
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                     '  default null');
         end loop;
      end if;
   end loop;
   p('      )');
   p('   -- Application Insert procedure');
   p('is');
   p('begin');
   p('   ' || tbuff.name || '_view.ins');
   p('      (n_id');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path_in');
            p('      ,n_'|| buff.fk_prefix || 'nk_path_in');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '_in');
         end loop;
      end if;
   end loop;
   p('      );');
   p('end ins;') ;
   p('----------------------------------------');
   p('procedure ins');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE)');
   p('   -- Application Insert procedure with %ROWTYPE');
   p('is');
   p('begin');
   p('   ' || tbuff.name || '_dml.ins');
   p('      (n_buff.id');
   if tbuff.type = 'EFF'
   then
      p('      ,n_buff.eff_beg_dtm');
   end if;
   -- Setup DML package insert columns
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_buff.'||buff.name);
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_buff.'||buff.fk_prefix||'id_path');
            p('      ,n_buff.'||buff.fk_prefix||'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_buff.'||buff.fk_prefix||get_tabname(buff.fk_table_id)||
                        '_nk'||i);
         end loop;
      end if;
   end loop;
   p('      );');
   p('end ins;') ;
   if tbuff.type in ('EFF', 'LOG') or table_has_fk(tbuff.id)
   then
      p('----------------------------------------');
      p('procedure ins');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE)');
      p('   -- Application Insert procedure with %ROWTYPE');
      p('is');
      p('begin');
      p('   ' || tbuff.name || '_dml.ins');
      p('      (n_id => n_buff.id');
      if tbuff.type = 'EFF'
      then
         p('      ,n_eff_beg_dtm => n_buff.eff_beg_dtm');
      end if;
      -- Setup DML package insert columns
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,n_'||buff.name||' => n_buff.'||buff.name);
      end loop;
        p('      );');
      p('end ins;') ;
   end if;
   p('----------------------------------------');
   p('procedure upd');
   p('      (o_id_in  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,n_eff_beg_dtm  in out  timestamp with local time zone');
   end if;
   nkfnd := FALSE;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_'||buff.name||'  in out  '||get_dtype(buff));
      if buff.fk_table_id is not null
      then
         nkfnd := TRUE;
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_'|| buff.fk_prefix || 'id_path_in  in  VARCHAR2  default null');
            p('      ,n_'|| buff.fk_prefix || 'nk_path_in  in  VARCHAR2  default null');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i || '_in  in  ' ||
                     get_dtype(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                     '  default null');
         end loop;
      end if;
   end loop;
   --if nkfnd
   --then
      p('      ,nkdata_provided_in  in   VARCHAR2  default ''Y''');
   --end if;
   p('      )');
   p('   -- Application Update procedure');
   p('is');
   if tbuff.type = 'EFF'
   then
      p('   o_eff_beg_dtm   timestamp(9) with local time zone;');
   end if;
   -- Generate a list of column declarations
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   o_'||buff.name||'  '||get_dtype_full(buff)||';');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('   o_'|| buff.fk_prefix || 'id_path  VARCHAR2(4000);');
            p('   o_'|| buff.fk_prefix || 'nk_path  VARCHAR2(4000);');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('   o_' || buff.fk_prefix ||
                  get_tabname(buff.fk_table_id) ||
                  '_nk' || i || '  ' ||
                  get_dtype_full(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                  ';');
         end loop;
         if buff.fk_table_id = tbuff.id
         then
            p('   n_'|| buff.fk_prefix || 'id_path  VARCHAR2(4000);');
            p('   n_'|| buff.fk_prefix || 'nk_path  VARCHAR2(4000);');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('   n_' || buff.fk_prefix ||
                  get_tabname(buff.fk_table_id) ||
                  '_nk' || i || '  ' ||
                  get_dtype_full(nk_aa(buff.fk_table_id).cbuff_va(i)) ||
                  ';');
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   o_aud_beg_usr  ' || usrfdt || ';');
      p('   o_aud_beg_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   p('   -- Retrieve the old (before update) data');
   nkseq := 1;
   if tbuff.type = 'EFF'
   then
      p('   select ' || tbuff.abbr || '.eff_beg_dtm');
      nkseq := 2;
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('   select ' || tbuff.abbr || '.'||buff.name) ;
         nkseq := 2;
      else
         p('         ,' || tbuff.abbr || '.'||buff.name) ;
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('         ,' || tbuff.abbr || '.' || buff.fk_prefix || 'id_path');
            p('         ,' || tbuff.abbr || '.' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('         ,' || tbuff.abbr || '.' || buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) || '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,' || tbuff.abbr || '.aud_beg_usr');
      p('         ,' || tbuff.abbr || '.aud_beg_dtm');
   end if;
   nkseq := 1;
   if tbuff.type = 'EFF'
   then
      p('    into  o_eff_beg_dtm');
      nkseq := 2;
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('    into  o_'||buff.name) ;
         nkseq := 2;
      else
         p('         ,o_'||buff.name) ;
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            p('         ,o_'||buff.fk_prefix||'id_path');
            p('         ,o_'||buff.fk_prefix||'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('         ,o_'||buff.fk_prefix ||
                        get_tabname(buff.fk_table_id) || '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,o_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
   end if;
   p('    from  ' || tbuff.name || '_act  ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = o_id_in;');
   if nkfnd
   then
      p('   -- Set the Natural Key data as indicated by NKDATA_PROVIDED');
      p('   if upper(substr(nvl(nkdata_provided_in,''Y''),1,1)) in (''Y'',''T'')');
      p('   then');
      p('      -- Use the Natural Key Data that was provided');
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if buff.fk_table_id = tbuff.id
         then
            p('      n_'||buff.fk_prefix||'id_path := n_'||buff.fk_prefix||'id_path_in;');
            p('      n_'||buff.fk_prefix||'nk_path := n_'||buff.fk_prefix||'nk_path_in;');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      n_'||buff.fk_prefix||get_tabname(buff.fk_table_id)||'_nk'||i||
                ' := n_'||buff.fk_prefix||get_tabname(buff.fk_table_id)||'_nk'||i||
                     '_in;');
         end loop;
      end loop;
      p('   else');
      p('      -- Use the old Natural Key Data');
      for buff in (
         select * from tab_cols COL
          where COL.fk_table_id is not null
           and  COL.table_id    = tbuff.id
          order by COL.seq )
      loop
         if buff.fk_table_id = tbuff.id
         then
            p('      n_'||buff.fk_prefix||'id_path := o_'||buff.fk_prefix||'id_path;');
            p('      n_'||buff.fk_prefix||'nk_path := o_'||buff.fk_prefix||'nk_path;');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      n_'||buff.fk_prefix||get_tabname(buff.fk_table_id)||'_nk'||i||
                ' := o_'||buff.fk_prefix||get_tabname(buff.fk_table_id)||'_nk'||i||
                     ';');
         end loop;
      end loop;
      p('   end if;');
   end if;
   p('   -- Run the update');
   p('   '||tbuff.name||'_view.upd');
   p('      (o_id_in');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm');
      p('      ,n_eff_beg_dtm');
   end if;
   -- Generate a column list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,o_' || buff.fk_prefix || 'id_path');
            p('      ,o_' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,o_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) || '_nk' || i);
         end loop;
      end if;
      p('      ,n_'||buff.name) ;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('      ,n_' || buff.fk_prefix || 'id_path');
            p('      ,n_' || buff.fk_prefix || 'nk_path');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) || '_nk' || i);
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr');
      p('      ,o_aud_beg_dtm');
   end if;
   p('      );') ;
   p('end upd;') ;
   p('----------------------------------------');
   p('procedure upd');
   p('      (n_buff  in out  ' || tbuff.name || '_ACT%ROWTYPE)');
   p('is');
   p('begin');
   p('   ' || tbuff.name || '_dml.upd');
   p('      (n_buff.id');
   if tbuff.type = 'EFF'
   then
      p('      ,n_buff.eff_beg_dtm');
   end if;
   nkfnd := FALSE;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,n_buff.'||buff.name);
      if buff.fk_table_id is not null
      then
         nkfnd := TRUE;
         if buff.fk_table_id = tbuff.id
         then
            p('      ,n_buff.'|| buff.fk_prefix || 'id_path_in');
            p('      ,n_buff.'|| buff.fk_prefix || 'nk_path_in');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('      ,n_buff.' || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_nk' || i);
         end loop;
      end if;
   end loop;
   if nkfnd
   then
      p('      ,''Y''');
   end if;
   p('      );') ;
   p('end upd;') ;
   if tbuff.type in ('EFF', 'LOG') or table_has_fk(tbuff.id)
   then
      p('----------------------------------------');
      p('procedure upd');
      p('      (n_buff  in out  ' || tbuff.name || '%ROWTYPE)');
      p('is');
      p('begin');
      p('   ' || tbuff.name || '_dml.upd');
      p('      (o_id_in => n_buff.id');
      if tbuff.type = 'EFF'
      then
         p('      ,n_eff_beg_dtm => n_buff.eff_beg_dtm');
      end if;
      nkfnd := FALSE;
      for buff in (
         select * from tab_cols COL
          where COL.table_id = tbuff.id
          order by COL.seq )
      loop
         p('      ,n_'||buff.name||' => n_buff.'||buff.name);
      end loop;
      --if nkfnd
      --then
         p('      ,nkdata_provided_in => ''N''');
      --end if;
      p('      );') ;
      p('end upd;') ;
   end if;
   p('----------------------------------------');
   p('procedure del');
   p('      (o_id_in  in  NUMBER');
   if tbuff.type = 'EFF'
   then
      p('      ,x_eff_end_dtm  in out  timestamp with local time zone');
   end if;
   p('      )');
   p('   -- Application Delete procedure');
   p('is');
   if tbuff.type = 'EFF'
   then
      p('   o_eff_beg_dtm   timestamp(9) with local time zone;');
   end if;
   -- Generate a list of column declarations
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('   o_'||buff.name||'  '||get_dtype_full(buff)||';');
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('   o_aud_beg_usr  ' || usrfdt || ';');
      p('   o_aud_beg_dtm  timestamp(9) with local time zone;');
   end if;
   p('begin');
   nkseq := 1;
   if tbuff.type = 'EFF'
   then
      p('   select ' || tbuff.abbr || '.eff_beg_dtm');
      nkseq := 2;
   end if;
   -- Generate a column list for the select statement
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('   select ' || tbuff.abbr || '.'||buff.name) ;
         nkseq := 2;
      else
         p('         ,' || tbuff.abbr || '.'||buff.name) ;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,aud_beg_usr');
      p('         ,aud_beg_dtm');
   end if;
   nkseq := 1;
   if tbuff.type = 'EFF'
   then
      p('    into  o_eff_beg_dtm');
      nkseq := 2;
   end if;
   -- Generate a variable list for the Master Insert call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if nkseq = 1
      then
         p('    into  o_'||buff.name) ;
         nkseq := 2;
      else
         p('         ,o_'||buff.name) ;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('         ,o_aud_beg_usr');
      p('         ,o_aud_beg_dtm');
   end if;
   p('    from  ' || tbuff.name || '  ' || tbuff.abbr);
   p('    where ' || tbuff.abbr || '.id = o_id_in;');
   p('   '||tbuff.name||'_view.del');
   p('      (o_id_in');
   if tbuff.type = 'EFF'
   then
      p('      ,o_eff_beg_dtm');
      p('      ,x_eff_end_dtm');
   end if;
   -- Generate a column list for the Master delete call
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('      ,o_'||buff.name) ;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('      ,o_aud_beg_usr');
      p('      ,o_aud_beg_dtm');
   end if;
   p('      );') ;
   p('end del;') ;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('----------------------------------------');
      p('procedure pop');
      p('      (id_in  in  number');
      p('      )');
      p('is');
      p('begin');
      p('   ' || tbuff.name || '_pop.at_server(id_in);');
      p('end pop;');
   end if;
   p('----------------------------------------');
   p('end '||sp_name||';');
   p('/');
   show_errors(sp_type, sp_name);
   p('');
END create_dp_body;
----------------------------------------
PROCEDURE drop_prg
   --  Drop the Stored Program Units
IS
BEGIN
   for buff in (
      select * FROM programs PRG
       where PRG.application_id = abuff.id
       order by PRG.name desc)
   LOOP
      p('drop '||buff.type||' '||buff.name);
      p('/');
   END LOOP;
END drop_prg;
----------------------------------------
PROCEDURE create_prg
   --  Create Shells for the Stored Program Units
IS
BEGIN
   for buff in (
      select * FROM programs PRG
       where PRG.application_id = abuff.id
       order by PRG.name)
   LOOP
      p('create ' || buff.type || ' ' || buff.name);
      if buff.type = 'FUNCTION'
      then
         p('   return varchar2');
      end if;
      p('as');
      if buff.type != 'PACKAGE'
      then
         p('   null;');
      end if;
      p('end ' || buff.name || ';');
      p('/');
   ps('');
   ps('grant execute on ' || buff.name || ' to '|| abuff.abbr || '_app');
   ps('/');
   ps('---- audit rename on ' || buff.name || ' by access');
   ps('---- /');
   p('');
   END LOOP;
END create_prg;
----------------------------------------
PROCEDURE drop_gsyn
   --  Drop the user's global synonyms
IS
BEGIN
   p('drop synonym util');
   p('/');
   p('drop synonym util_log');
   p('/');
   p('drop synonym glob');
   p('/');
   p('');
END drop_gsyn;
----------------------------------------
PROCEDURE create_gsyn
   --  Create the user's global synonyms
IS
BEGIN
   p('create synonym glob');
   p('   for '||abuff.db_schema||'.glob');
   p('/');
   p('create synonym util_log');
   p('   for '||abuff.db_schema||'.util_log');
   p('/');
   p('create synonym util');
   p('   for '||abuff.db_schema||'.util');
   p('/');
   p('');
END create_gsyn;
----------------------------------------
PROCEDURE drop_tsyn
   --  For a tbuff, drop the user's table synonyms
IS
BEGIN
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop synonym '||tbuff.name||'_asof');
      p('/');
      p('drop synonym '||tbuff.name||'_all');
      p('/');
   end if;
   p('drop synonym '||tbuff.name||'_act');
   p('/');
   p('drop synonym '||tbuff.name||'_dml');
   p('/');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('drop synonym '||tbuff.name||'_pop');
      p('/');
      p('drop synonym '||tbuff.name||'_PDAT');
      p('/');
      p('drop synonym '||tbuff.name||HOA);
      p('/');
   end if;
   p('drop synonym '||tbuff.name);
   p('/');
   p('drop synonym '||tbuff.name||'_seq');
   p('/');
   p('');
END drop_tsyn;
----------------------------------------
PROCEDURE create_tsyn
   --  For a tbuff, create the user's table synonyms
IS
BEGIN
   p('');
   p('--  Should use "'||tbuff.name||'_dml.get_next_id" instead of sequence');
   p('create synonym '||tbuff.name||'_seq');
   p('   for '||abuff.db_schema||'.'||tbuff.name||'_seq');
   p('/');
   p('create synonym '||tbuff.name);
   p('   for '||abuff.db_schema||'.'||tbuff.name);
   p('/');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('create synonym '||tbuff.name||HOA);
      p('   for '||abuff.db_schema||'.'||tbuff.name||HOA);
      p('/');
      p('create synonym '||tbuff.name||'_PDAT');
      p('   for '||abuff.db_schema||'.'||tbuff.name||'_PDAT');
      p('/');
      p('create synonym '||tbuff.name||'_pop');
      p('   for '||abuff.db_schema||'.'||tbuff.name||'_pop');
      p('/');
   end if;
   p('create synonym '||tbuff.name||'_dml');
   p('   for '||abuff.db_schema||'.'||tbuff.name||'_dml');
   p('/');
   p('create synonym '||tbuff.name||'_act');
   p('   for '||abuff.db_schema||'.'||tbuff.name||'_act');
   p('/');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('create synonym '||tbuff.name||'_all');
      p('   for '||abuff.db_schema||'.'||tbuff.name||'_all');
      p('/');
      p('create synonym '||tbuff.name||'_asof');
      p('   for '||abuff.db_schema||'.'||tbuff.name||'_asof');
      p('/');
   end if;
   p('');
END create_tsyn;
----------------------------------------
PROCEDURE drop_msyn
   --  Drop the user's program synonyms
IS
BEGIN
   for buff in (
      select * FROM programs PRG
       where PRG.application_id = abuff.id
       order by PRG.name desc)
   LOOP
      p('drop synonym '||buff.name);
      p('/');
   END LOOP;
   p('');
END drop_msyn;
----------------------------------------
PROCEDURE create_msyn
   --  Create the user's program synonyms
IS
BEGIN
   for buff in (
      select * FROM programs PRG
       where PRG.application_id = abuff.id
       order by PRG.name)
   LOOP
      p('create synonym '||buff.name);
      p('   for '||abuff.db_schema||'.'||buff.name);
      p('/');
   END LOOP;
   p('');
END create_msyn;
----------------------------------------
PROCEDURE create_search_where
IS
   dform  varchar2(100);
   dfunc  varchar2(30);
BEGIN
   if cbuff.d_domain_id is not null
   then
      pr('        '' and (   :P'' || pnum || ''_' || upper(cbuff.name) || ' is null'' ');
      pr('        ''      or instr('''':''''||:P'' || pnum || ''_' ||
                          upper(cbuff.name) || '||'''':'''', '''':''''||' ||
                                cbuff.name || '||'''':'''') > 0'' ');
      pr('        ''      )'' ');
   elsif cbuff.type = 'NUMBER' OR
         cbuff.fk_table_id is not null
   then
      pr('        '' and  (   (    :P'' || pnum || ''_' || upper(cbuff.name) || '_MIN is null'' ');
      pr('        ''           and :P'' || pnum || ''_' || upper(cbuff.name) || '_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''       or (   ' || cbuff.name || ' between nvl(:P'' || pnum || ''_' || upper(cbuff.name) || '_MIN,-1E125)'' ');
      pr('        ''                  and nvl(:P'' || pnum || ''_' || upper(cbuff.name) || '_MAX, 1E125)'' ');
      pr('        ''          )   )'' ');
   elsif cbuff.type = 'VARCHAR2'
   then
      pr('        '' and (   :P'' || pnum || ''_' || upper(cbuff.name) || ' is null'' ');
      pr('        ''      or ' || cbuff.name || ' like :P'' || pnum || ''_' || upper(cbuff.name) || ''' ');
      pr('        ''      )'' ');
   elsif cbuff.type in ('DATE', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE')
   then
      if cbuff.type = 'DATE'
      then
         dform := 'DD-MON-YYYY HH24.MI.SS';
         dfunc := 'to_date';
      elsif cbuff.type = 'TIMESTAMP WITH TIME ZONE'
      then
         dform := 'DD-MON-YYYY HH24.MI:SS:SS.FF9 TZR';
         dfunc := 'to_timestamp_tz';
      elsif cbuff.type = 'TIMESTAMP WITH LOCAL TIME ZONE'
      then
         dform := 'DD-MON-YYYY HH24:MI:SS.FF9';
         dfunc := 'to_timestamp';
      end if;
      pr('        '' and (   (    :P'' || pnum || ''_' || upper(cbuff.name) || '_MIN is null'' ');
      pr('        ''          and :P'' || pnum || ''_' || upper(cbuff.name) || '_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''      or (   ' || cbuff.name || ' between nvl('||dfunc||'(:P'' || pnum || ''_' || upper(cbuff.name) || '_MIN'' ');
      pr('        ''                                   ,''''' || dform || '''''), "#OWNER#".util.get_first_dtm)'' ');
      pr('        ''                             and nvl('||dfunc||'(:P'' || pnum || ''_' || upper(cbuff.name) || '_MAX'' ');
      pr('        ''                                   ,''''' || dform || '''''), "#OWNER#".util.get_last_dtm)'' ');
      pr('        ''          )   )'' ');
   else
      pr('        '' -- ' || cbuff.type || ' is not recognized for ' || cbuff.name || ''' ');
   end if;
END create_search_where;
----------------------------------------
PROCEDURE create_crc
IS
   display_as   varchar2(30);
   alignment    varchar2(30);
   lov_nulls    varchar2(3);
BEGIN
   if is_bigtext(cbuff)
   then
      display_as := 'TEXTAREA';
      alignment  := 'LEFT';
   else
      case get_dtype(cbuff)
      when 'NUMBER' then
         display_as := 'TEXT';
         alignment  := 'RIGHT';
      when 'VARCHAR2' then
         display_as := 'TEXT';
         alignment  := 'LEFT';
      when 'DATE' then
         display_as := '_DATE_';
         alignment  := 'CENTER';
      when 'TIMESTAMP WITH TIME ZONE' then
         display_as := 'DISPLAY_AND_SAVE';
         alignment  := 'LEFT';
      when 'TIMESTAMP WITH LOCAL TIME ZONE' then
         display_as := 'DISPLAY_AND_SAVE';
         alignment  := 'LEFT';
      end case;
   end if;
   if cbuff.req is not null
   then
      lov_nulls  := 'YES';
   else
      lov_nulls  := 'NO';
   end if;
   cnum := cnum + 1;
   p('');
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''' || upper(cbuff.name) || ''',');
   p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
   p('      p_column_heading=> ''' || initcap(replace(cbuff.name,'_',' ')) || ''',');
   p('      p_column_format=> ''' || get_colformat(cbuff) || ''',');
   p('      p_column_alignment=>''' || alignment || ''',');
   p('      p_heading_alignment=>''' || alignment || ''',');
   p('      p_default_sort_column_sequence=>' || get_colsort_seq(tbuff.id, cbuff.nk) || ',');
   p('      p_disable_sort_column=>''N'',');
   p('      p_sum_column=> ''N'',');
   p('      p_hidden_column=> ''N'',');
   p('      p_display_as=>''' || case display_as
                                    when '_DATE_' then 'DATE_PICKER'
                                    else display_as
                                    end || ''',');
   p('      p_lov_show_nulls=> ''' || lov_nulls || ''',');
   if is_bigtext(cbuff)
   then
      p('      p_column_width=> ''50'',');
      p('      p_column_height=> ''2'',');
   else
      p('      p_column_width=> ''' || to_char(least(trunc((get_collen(cbuff)*0.5)+1),50)) || ''',');
   end if;
   p('      p_cattributes=> ''onfocus=''''this.setAttribute("maxLength","' ||
                                    get_collen(cbuff) || '")'''''',');
   p('      p_is_required=> false,');
   p('      p_pk_col_source=> null,');
   if cbuff.default_value is not null
   then
      p('      p_column_default=> ''''''' || cbuff.default_value || ''''''',');
      p('      p_column_default_type=> ''FUNCTION'',');
   end if;
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_include_in_export=> ''Y'',');
   p('      p_ref_schema=> sch_name,');
   p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
   p('      p_ref_column_name=> ''' || upper(cbuff.name) || ''',');
   p('      p_column_comment=>''' || replace(cbuff.description,SQ1,SQ2) || ''');');
   p('');
   p('   wwv_flow_api.create_region_rpt_cols (');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_plug_id=> ract_id,');
   p('      p_column_sequence=> ' || (cnum - 1) || ',');
   p('      p_query_column_name=> ''' || upper(cbuff.name) || ''',');
   p('      p_display_as=> ''' || case display_as
                                     when '_DATE_' then 'DATE_POPUP'
                                     else display_as
                                     end || ''',');
   p('      p_column_comment=> ''' || replace(cbuff.description,SQ1,SQ2) || ''');');
END create_crc;
----------------------------------------
PROCEDURE create_search_crc
      (note_txt  in  varchar2  default null)
IS

   attr_01     varchar2(6) := 'Y';
   attr_02     varchar2(6) := 'N';
   colspan     number := 3;
   display_as  varchar2(50) := 'NATIVE_TEXT_FIELD';
   help_text   varchar2(1000) := null;
   item_seq    number := cnum * 10;
   named_lov   varchar2(30) := null;
   new_line    varchar2(5) := 'YES';
   pi_suffix   varchar2(50) := '_' || upper(cbuff.name);
   prompt_txt  varchar2(50) := null;
   saved_id    number;
   saved_type  varchar2(30);

BEGIN

   if cbuff.type is null and
      cbuff.fk_table_id is not null
   then
      saved_id := cbuff.fk_table_id;
      cbuff.fk_table_id := null;
      -- Recursively Call this Procedure --
      cbuff.type := 'NUMBER1';
      create_search_crc;
      cbuff.type := 'NUMBER2';
      create_search_crc;
      -------------------------------------
      cbuff.fk_table_id := saved_id;
      cbuff.type := null;
      return;

   elsif cbuff.type = 'NUMBER'
   then
      saved_type := cbuff.type;
      -- Recursively Call this Procedure --
      cbuff.type := 'NUMBER1';
      create_search_crc;
      cbuff.type := 'NUMBER2';
      create_search_crc;
      -------------------------------------
      cbuff.type := saved_type;
      return;

   elsif cbuff.type = 'NUMBER1'
   then
      -- Called Recursively --
      colspan := 1;
      help_text := 'Search range for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                   ' "From" and "To" Numbers will be included in range.';
      pi_suffix := pi_suffix || '_MIN';
      prompt_txt := initcap(replace(upper(cbuff.name),'_',' ')) ||
                    note_txt || ' Range from:';
      p('');
      p('   lov_id := null;');

   elsif cbuff.type = 'NUMBER2'
   then
      -- Called Recursively --
      colspan := 1;
      help_text := 'Search range for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                   ' "From" and "To" Numbers will be included in range.';
      item_seq := item_seq + 5;
      new_line := 'NO';
      pi_suffix := pi_suffix || '_MAX';
      prompt_txt := 'to:';
      p('');
      p('   lov_id := null;');

   elsif cbuff.type = 'VARCHAR2'
   then
      help_text  := 'Search string for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                    ' Use "%" to wildcard one or more letters.' ||
                    ' Use "_" to wildcard only 1 letter.';
      prompt_txt := initcap(replace(upper(
                    cbuff.name),'_',' ')) ||
                    note_txt || ' Search:';
      p('');
      p('   lov_id := null;');

   elsif cbuff.type = 'DATE'
     OR  cbuff.type like 'TIMESTAMP WITH%'
   then
      saved_type := cbuff.type;
      -- Recursively Call this Procedure --
      cbuff.type := 'DATE1';
      create_search_crc;
      cbuff.type := 'DATE2';
      create_search_crc;
      -------------------------------------
      cbuff.type := saved_type;
      return;

   elsif cbuff.type = 'DATE1'
   then
      -- Called Recursively --
      colspan := 1;
      help_text := 'Search range for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                   ' "From" and "To" Dates may not be included in range.';
      pi_suffix := pi_suffix || '_MIN';
      prompt_txt := initcap(replace(upper(cbuff.name),'_',' ')) ||
                    note_txt || ' Range from:';
      p('');
      p('   lov_id := null;');

   elsif cbuff.type = 'DATE2'
   then
      -- Called Recursively --
      colspan := 1;
      help_text := 'Search range for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                   ' "From" and "To" Dates may not be included in range.';
      item_seq := item_seq + 5;
      new_line := 'NO';
      pi_suffix := pi_suffix || '_MAX';
      prompt_txt := 'to:';
      p('');
      p('   lov_id := null;');

   elsif cbuff.d_domain_id is not null
   then
      attr_01   := 'NONE';
      attr_02   := 'Y';
      display_as := 'NATIVE_SELECT_LIST';
      help_text := 'Search list for ' || upper(cbuff.name) ||
                   ' (' || replace(cbuff.description,SQ1,SQ2) || ').' ||
                   ' Select one or more values from the list.';
      prompt_txt := initcap(replace(upper(
                    cbuff.name),'_',' ')) ||
                    note_txt || ' Select:';
      for buff in (
         select * from domains DOM
          where DOM.id = cbuff.d_domain_id )
      loop
         named_lov  := upper(buff.name);
         p('   lov_id := get_lov_id(''' || upper(buff.name) ||
                             ''', ''Static'');');
      end loop;

   end if;

   p('');
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''' || pi_suffix || ''',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (item_seq + 100) || ',');
   p('      p_item_plug_id => fcp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>''' || prompt_txt || ''',');
   p('      p_format_mask=>''' || get_colformat(cbuff) || ''',');
   p('      p_source=>''P'' || pnum || ''' || pi_suffix || ''',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''' || display_as || ''',');
   p('      p_named_lov=> ''' || named_lov || ''',');
   p('      p_lov=> lov_id,');
   p('      p_lov_display_null=> ''YES'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_lov_null_text=>''(null)'',');
   p('      p_lov_null_value=> '''',');
   p('      p_cSize=> ' || least(trunc((get_collen(cbuff)*0.5)+1),50) || ',');
   p('      p_cMaxlength=> ' || get_collen(cbuff) || ',');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''' || new_line || ''',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> ' || colspan || ',');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_help_text=> ''' || help_text || ''',');
   p('      p_attribute_01 => ''' || attr_01 || ''',');
   p('      p_attribute_02 => ''' || attr_02 || ''',');
   p('      p_show_quick_picks=> ''N'',');
   p('      p_item_comment => '''');');
END create_search_crc;
----------------------------------------
PROCEDURE create_cpi
      (vseq      in out  number
      ,note_txt  in      varchar2  default null)
IS
   attr_01     varchar2(6);
   attr_02     varchar2(6);
   attr_03     varchar2(6);
   attr_04     varchar2(6);
   attr_05     varchar2(6);
   attr_07     varchar2(6);
   display_as  varchar2(50);
   help_text   varchar2(1000) := replace(cbuff.description,SQ1,SQ2);
   item_seq    number         := cnum * 10;
   named_lov   varchar2(30);
   pi_suffix   varchar2(50)   := '_' || upper(cbuff.name);
   prompt_txt  varchar2(50)   := initcap(replace(upper(cbuff.name),'_',' ')) ||
                                 note_txt || ':';
   saved_id    number;
   saved_type  varchar2(30);
BEGIN
   p('');
   if cbuff.d_domain_id is not null
   then
      for buff in (
         select * from domains DOM
          where DOM.id = cbuff.d_domain_id )
      loop
         named_lov  := upper(buff.name);
         p('   lov_id := get_lov_id(''' || upper(buff.name) ||
                             ''', ''Static'');');
      end loop;
   else
      p('   lov_id := null;');
   end if;
   --
   if is_bigtext(cbuff)
   then
      attr_01   := 'Y';
      attr_02   := 'N';
      attr_03   := 'N';
      display_as := 'NATIVE_TEXTAREA';
   elsif upper(cbuff.type) like 'VARCHAR%'
     OR  upper(cbuff.type) like 'TIME%'
   then
      attr_01   := 'N';
      attr_02   := 'N';
      attr_03   := 'N';
      display_as := 'NATIVE_TEXT_FIELD';
      if upper(cbuff.type) like 'TIME%'
      then
         help_text := help_text || '<br><br>Use the format: "' ||
                      get_colformat(cbuff) || '"';
      end if;
   elsif upper(cbuff.type) = 'NUMBER'
     OR  cbuff.fk_table_id is not null
   then
      attr_03   := 'right';
      display_as := 'NATIVE_NUMBER_FIELD';
   elsif cbuff.d_domain_id is not null
   then
      attr_01   := 'NONE';
      attr_02   := 'Y';
      display_as := 'NATIVE_SELECT_LIST';
   elsif upper(cbuff.type) = 'DATE'
   then
      attr_04   := 'button';
      attr_05   := 'N';
      attr_07   := 'NONE';
      display_as := 'NATIVE_DATE_PICKER';
   else
      raise_application_error(-20000, 'Unknown cbuff.type');
   end if;
   --
   p('   item_id := wwv_flow_id.next_val;');
   p('');
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> item_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''' || pi_suffix || ''',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || item_seq || ',');
   p('      p_item_plug_id => irp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_prompt=>''' || prompt_txt || ''',');
   p('      p_format_mask=>''' || get_colformat(cbuff) || ''',');
   p('      p_source=>''' || upper(cbuff.name) || ''',');
   p('      p_source_type=> ''DB_COLUMN'',');
   p('      p_display_as=> ''' || display_as || ''',');
   p('      p_named_lov=> ''' || named_lov || ''',');
   p('      p_lov=> lov_id,');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_lov_null_text=>''(null)'',');
   p('      p_lov_null_value=> '''',');
   p('      p_cSize=> ' || least(get_collen(cbuff),100) || ',');
   p('      p_cMaxlength=> ' || get_collen(cbuff) || ',');
   p('      p_cHeight=> 1,');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''RIGHT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''' || help_text || ''',');
   p('      p_attribute_01 => ''' || attr_01 || ''',');
   p('      p_attribute_02 => ''' || attr_02 || ''',');
   p('      p_attribute_03 => ''' || attr_03 || ''',');
   p('      p_attribute_04 => ''' || attr_04 || ''',');
   p('      p_attribute_05 => ''' || attr_05 || ''',');
   p('      p_attribute_06 => ''' || attr_07 || ''',');
   p('      p_show_quick_picks=> ''N'',');
   p('      p_item_comment => '''');');
   if upper(cbuff.type) like 'TIME%'
   then
      p('');
      vseq := vseq + 1;
      p('   wwv_flow_api.create_page_validation(');
      p('      p_id => wwv_flow_id.next_val,');
      p('      p_flow_id => wwv_flow.g_flow_id,');
      p('      p_flow_step_id => pnum,');
      p('      p_tabular_form_region_id => null,');
      p('      p_validation_name => ''P'' || pnum || ''_' || upper(cbuff.name) ||
               ' must be timestamp'',');
      p('      p_validation_sequence=> ' || (vseq * 10) || ',');
      p('      p_validation => ''P'' || pnum || ''_' || upper(cbuff.name) || ''',');
      p('      p_validation_type => ''ITEM_IS_TIMESTAMP'',');
      p('      p_error_message => ''#LABEL# must be a valid timestamp.'',');
      p('      p_associated_item=> item_id,');
      p('      p_error_display_location=>''INLINE_WITH_FIELD_AND_NOTIFICATION'',');
      p('      p_validation_comment=> '''');');
   end if;
END create_cpi;
----------------------------------------
PROCEDURE create_rep_col
      (region_id_txt_in  varchar2
      ,hidden_col_in     varchar2 default null)
IS
BEGIN
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ' || region_id_txt_in || ',');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''' || upper(cbuff.name) || ''',');
   p('      p_column_display_sequence=> ' || cnum || ',');
   p('      p_column_heading=> ''' || initcap(replace(cbuff.name,'_',' ')) || ''',');
   p('      p_column_format=> ''' || get_colformat(cbuff) || ''',');
   p('      p_column_alignment=>''LEFT'',');
   p('      p_default_sort_column_sequence=> ' || get_colsort_seq(tbuff.id, cbuff.nk) || ',');
   if upper(cbuff.name) like '%_DTM'
   then
      p('      p_default_sort_dir=>''desc'',');
   end if;
   p('      p_disable_sort_column=>''N'',');
   p('      p_sum_column=> ''N'',');
   if hidden_col_in is not null
   then
      p('      p_hidden_column=> ''Y'',');
      p('      p_display_as=>''HIDDEN'',');
   else
      p('      p_hidden_column=> ''N'',');
      p('      p_display_as=>''ESCAPE_SC'',');
   end if;
   p('      p_is_required=> false,');
   p('      p_pk_col_source=> null,');
   p('      p_column_comment=>'''');');
END create_rep_col;
----------------------------------------
PROCEDURE create_ws_col
IS
   dtype  varchar2(100) := get_dtype(cbuff);
   dsply  varchar2(100) := 'RIGHT';
   tzdep  varchar2(100) := 'N';
BEGIN
   if dtype = 'VARCHAR2'
   then
      dtype := 'STRING';
      dsply := 'LEFT';
   elsif dtype like 'TIME%'
   then
      if dtype like '%ZONE'
      then
         tzdep := 'Y';
      end if;
      dtype := 'DATE';
      dsply := 'LEFT';
   end if;
   p('   wwv_flow_api.create_worksheet_column (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id=> irws_id,');
   p('      p_db_column_name         =>''' || upper(cbuff.name) || ''',');
   p('      p_display_order          =>' || cnum || ',');
   p('      p_group_id               =>null,');
   p('      p_column_identifier      =>''' || chr(64+cnum) || ''',');
   p('      p_column_label           =>''' || initcap(replace(cbuff.name,'_',' ')) || ''',');
   p('      p_report_label           =>''' || initcap(replace(cbuff.name,'_',' ')) || ''',');
   p('      p_sync_form_label        =>''Y'',');
   p('      p_display_in_default_rpt =>''Y'',');
   p('      p_is_sortable            =>''Y'',');
   p('      p_allow_sorting          =>''Y'',');
   p('      p_allow_filtering        =>''Y'',');
   p('      p_allow_highlighting     =>''Y'',');
   p('      p_allow_ctrl_breaks      =>''Y'',');
   p('      p_allow_aggregations     =>''Y'',');
   p('      p_allow_computations     =>''Y'',');
   p('      p_allow_charting         =>''Y'',');
   p('      p_allow_group_by         =>''Y'',');
   p('      p_allow_hide             =>''Y'',');
   p('      p_others_may_edit        =>''Y'',');
   p('      p_others_may_view        =>''Y'',');
   p('      p_column_type            =>''' || dtype || ''',');
   p('      p_display_as             =>''TEXT'',');
   if is_bigtext(cbuff)
   then
      p('      p_display_text_as        =>''WITHOUT_MODIFICATION'',');
   else
      p('      p_display_text_as        =>''ESCAPE_SC'',');
   end if;
   p('      p_heading_alignment      =>''CENTER'',');
   p('      p_column_alignment       =>''' || dsply || ''',');
   p('      p_tz_dependent           =>''' || tzdep || ''',');
   p('      p_rpt_distinct_lov       =>''Y'',');
   p('      p_rpt_show_filter_lov    =>''D'',');
   p('      p_rpt_filter_date_ranges =>''ALL'',');
   p('      p_help_text              =>'''');');
END create_ws_col;
----------------------------------------
PROCEDURE init_flow
IS
BEGIN
   p('');
   p('set verify off');
   p('set serveroutput on size 1000000');
   p('set feedback off');
   p('set define on');
   p('WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK');
   p('');
   p('-- Application Export:');
   p('--   Date and Time:   ' || to_char(sysdate,'HH24:MI Day MonthDD, YYYY'));
   p('--   Exported By:     ' || glob.get_usr);
   p('--   Flashback:       0');
   p('--   Export Type: Custom Generated');
   p('--   Version: 4.0.2.00.07');
   p('');
   p('-- Import:');
   p('--   Using application builder');
   p('--     or');
   p('--   Using SQL*Plus as the Oracle user APEX_040000 or as the owner');
   p('--    (parsing schema) of the application.');
   p('');
   p('--       AAAA       PPPPP   EEEEEE  XX      XX');
   p('--      AA  AA      PP  PP  EE       XX    XX');
   p('--     AA    AA     PP  PP  EE        XX  XX');
   p('--    AAAAAAAAAA    PPPPP   EEEE       XXXX');
   p('--   AA        AA   PP      EE        XX  XX');
   p('--  AA          AA  PP      EE       XX    XX');
   p('--  AA          AA  PP      EEEEEE  XX      XX');
   p('');
   p('-- Note: Because this is expected to be the first load of these pages,');
   p('--       "wwv_flow_api.g_id_offset" is not used.  IDs are queried from');
   p('--       APEX and "wwv_flow_id.next_val" is used to create new IDs.');
   p('');
   p('declare');
   p('   ws_id  number;');
   p('   app_id number;');
   p('begin');
   p('   wwv_flow_application_install.set_schema(''' ||
                abuff.apex_schema || ''');');
   p('   ws_id := apex_util.find_security_group_id(''' ||
                abuff.apex_ws_name || ''');');
   p('   wwv_flow_application_install.set_workspace_id(ws_id);');
   P('   begin');
   P('      select application_id');
   P('       into  app_id');
   P('       from  apex_applications');
   P('       where workspace        = ''' || abuff.apex_ws_name || '''');
   P('        and  application_name = ''' || abuff.apex_app_name || ''';');
   P('   exception');
   P('      when no_data_found');
   p('      then');
   P('         -- app_id := apex_util.minimum_free_application_id;');
   p('         raise_application_error(-20011, ''APEX: Unable to find Application ID'' || ');
   p('            '' for application "' || abuff.apex_app_name || '"'' ||');
   p('            '' in workspace "'    || abuff.apex_ws_name  || '"'');');
   p('      when others');
   p('      then');
   P('         raise;');
   P('   end;');
   p('   dbms_output.put_line(''   APPLICATION '' || app_id || '' - ' ||
                                abuff.apex_app_name || ''');');
   p('   wwv_flow_application_install.set_application_id(app_id);');
   p('   wwv_flow_application_install.set_application_name(''' ||
                                abuff.apex_app_name || ''');');
   p('   -- Start of Import');
   p('   wwv_flow.g_import_in_progress := true;');
   p('');
   p('   dbms_output.put_line(''  Set Credentials...'');');
   p('   -- Assumes you are running the script connected to SQL*Plus as the');
   p('   -- Oracle user APEX_040000 or as the owner (parsing schema) of the application.');
   p('   wwv_flow_api.set_security_group_id');
   p('      (p_security_group_id => ws_id);');
   p('');
   p('   -- Set NLS');
   p('   select value');
   p('    into  wwv_flow_api.g_nls_numeric_chars');
   p('    from  nls_session_parameters');
   p('    where parameter=''NLS_NUMERIC_CHARACTERS'';');
   p('   execute immediate ''alter session set nls_numeric_characters=''''.,'''''';');
   p('   wwv_flow.g_browser_language := ''en'';');
   p('');
   p('   dbms_output.put_line(''  Check Compatibility...'');');
   p('   -- This date identifies the minimum version required to import this file.');
   p('   wwv_flow_api.set_version(p_version_yyyy_mm_dd=>''2010.05.13'');');
   p('');
   p('   dbms_output.put_line(''  Set Application ID...'');');
   p('   wwv_flow.g_flow_id := app_id;');
   p('');
   p('end;');
   p('/');
   p('');
   p('set define off');
   p('');
END init_flow;
----------------------------------------
PROCEDURE fin_flow
IS
BEGIN
   p('');
   p('commit;');
   p('');
   p('begin');
   p('execute immediate ''begin dbms_session.set_nls( param => ''''NLS_NUMERIC_CHARACTERS'''', value => '''''''''''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''''''''''','''''''''''''''''''''''') || ''''''''''''''''); end;'';');
   p('end;');
   p('/');
   p('');
   p('set verify on');
   p('set feedback on');
   p('set define on');
   p('WHENEVER SQLERROR CONTINUE');
   p('');
   p('prompt  ...done');
   p('');
END fin_flow;
----------------------------------------
PROCEDURE func_flow
IS
BEGIN
   p('   -- Function Definitions');
   p('');
   p('   function get_template_id');
   p('         (type_in      in varchar2');
   p('         ,class_in      in varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
/*
-- Query to match theme classes with template names
select *
 from (select workspace
             ,application_id
             ,'Breadcrumb'             template_type
             ,theme_class
             ,breadcrumb_template_id   template_id
             ,template_name
        from  apex_040000.apex_application_temp_bc
       union all
       select workspace
             ,application_id
             ,'Button'                 template_type
             ,theme_class
             ,button_template_id       template_id
             ,template_name
        from  apex_040000.apex_application_temp_button
       union all
       select workspace
             ,application_id
             ,'Calendar'               template_type
             ,theme_class
             ,calendar_template_id     template_id
             ,template_name
        from  apex_040000.apex_application_temp_calendar
       union all
       select workspace
             ,application_id
             ,'Item Label'             template_type
             ,theme_class
             ,label_template_id        template_id
             ,template_name
        from  apex_040000.apex_application_temp_label
       union all
       select workspace
             ,application_id
             ,'List'                   template_type
             ,theme_class
             ,list_template_id         template_id
             ,template_name
        from  apex_040000.apex_application_temp_list
       union all
       select workspace
             ,application_id
             ,'Page'                   template_type
             ,theme_class
             ,template_id              template_id
             ,template_name
        from  apex_040000.apex_application_temp_page
       union all
       select workspace
             ,application_id
             ,'Popup List of Values'   template_type
             ,theme_class
             ,template_id              template_id
             ,'Popup LOV'              template_name
        from  apex_040000.apex_application_temp_popuplov
       union all
       select workspace
             ,application_id
             ,'Region'                 template_type
             ,theme_class
             ,region_template_id       template_id
             ,template_name
        from  apex_040000.apex_application_temp_region
       union all
       select workspace
             ,application_id
             ,'Report'                 template_type
             ,theme_class
             ,template_id              template_id
             ,template_name
        from  apex_040000.apex_application_temp_report);
*/
   p('      --  min(template_id) is a BIG KLUDGE because there are muptliple region');
   p('      --                templates for the "List Region with Icon" theme class');
-- *** The min() group function will allow a null to be fetched
--     witout throwing the "NO_DATA_FOUND" exception
   p('      select min(template_id)');
   p('       into  retval');
   p('       from  (select breadcrumb_template_id  template_id');
   p('               from  apex_application_temp_bc');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Breadcrumb''       = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select button_template_id  template_id');
   p('               from  apex_application_temp_button');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Button''           = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select calendar_template_id  template_id');
   p('               from  apex_application_temp_calendar');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Calendar''         = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select label_template_id  template_id');
   p('               from  apex_application_temp_label');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Item Label''       = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select list_template_id  template_id');
   p('               from  apex_application_temp_list');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''List''             = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select template_id  template_id');
   p('               from  apex_application_temp_page');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Page''             = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select template_id  template_id');
   p('               from  apex_application_temp_popuplov');
   p('               where application_id         = app_id');
   p('                and  workspace              = ws_name');
   p('                and  ''Popup List of Values'' = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select region_template_id  template_id');
   p('               from  apex_application_temp_region');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Region''           = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('              union all');
   p('              select template_id  template_id');
   p('               from  apex_application_temp_report');
   p('               where application_id     = app_id');
   p('                and  workspace          = ws_name');
   p('                and  ''Report''           = type_in');
   p('                and  upper(theme_class) like upper(class_in)');
   p('             );');
   p('      if retval is null');
   p('      then');
   p('         raise_application_error(-20011, ''APEX: Unable to find ''  || type_in  ||');
   p('            '' template ''        || class_in  ||');
   p('            '' for application '' || app_name ||');
   p('            '' in workspace ''    || ws_name  );');
   p('      end if;');
   p('      return retval;');
--   p('   exception');
--   p('      when no_data_found');
--   p('      then');
--   p('         raise_application_error(-20011, ''APEX: Unable to find ''  || type_in  ||');
--   p('            '' template ''        || class_in  ||');
--   p('            '' for application '' || app_name ||');
--   p('            '' in workspace ''    || ws_name  );');
--   p('      when others');
--   p('      then');
--   p('         raise;');
   p('   end get_template_id;');
   p('');
   p('   function get_lov_id');
   p('         (name_in  in  varchar2');
   p('         ,type_in  in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select lov_id');
   p('       into  retval');
   p('       from  apex_application_lovs');
   p('       where application_name    = app_name');
   p('        and  workspace           = ws_name');
   p('        and  lov_type            = type_in');
   p('        and  list_of_values_name = name_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_lov_id;');
   p('');
   p('   function get_list_id');
   p('         (name_in  in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select list_id');
   p('       into  retval');
   p('       from  apex_application_lists');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  list_name        = name_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_list_id;');
   p('');
   p('   function get_list_entry_id');
   p('         (lst_id_in  in  number');
   p('         ,text_in    in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select list_entry_id');
   p('       into  retval');
   p('       from  apex_application_list_entries');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  list_id          = lst_id_in');
   p('        and  entry_text       = text_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_list_entry_id;');
   p('');
   p('   function get_menu_id');
   p('         (name_in  in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select breadcrumb_id');
   p('       into  retval');
   p('       from  apex_application_breadcrumbs');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  breadcrumb_name  = name_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_menu_id;');
   p('');
   p('   function get_menu_option_id');
   p('         (mnu_id_in  in  number');
   p('         ,label_in   in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select breadcrumb_entry_id');
   p('       into  retval');
   p('       from  apex_application_bc_entries');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  breadcrumb_id    = mnu_id_in');
   p('        and  entry_label      = label_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_menu_option_id;');
   p('');
END func_flow;
----------------------------------------
PROCEDURE app_flow
IS
   rseq       number;          -- Region Sequence Number
   pseq       number;          -- Process Sequence Number
   dseq       number;          -- LOV Data Value Sequence Number
BEGIN
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('   -- Shared Component Export Variables');
   p('   ts_name    varchar2(30);    -- Tab Set Name');
   p('   ulp_id     number;          -- UTIL Log Plug ID');
   p('   irws_id    number;          -- Interactive Report Worksheet ID');
   p('   arp_id     number;          -- ASOF Report Plug ID');
   p('   lbl_tid    number;          -- (List Type) Button List Template ID');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Region Type) Report Region Template ID');
   p('   rlwi_tid   number;          -- (Region Type) List Region with Icon Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   lov_id     number;          -- List of Values ID');
   p('   lst_id     number;          -- Navigation List ID');
   p('   lst_name   varchar2(32767); -- Navigation List Name');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   bcp_id     number;          -- Breadcrumb Parent ID');
   p('   bcp2_id    number;          -- Secondary Breadcrumb Parent ID');
   p('   tab_cnt    number;          -- Number of Tab IDs found');
   p('   p          number;          -- Temporary Number');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('   function get_fp_id');
   p('         (name_in  in  varchar2');
   p('         ,type_in  in  varchar2)');
   p('      return number');
   p('   as');
   p('     retval  number;');
   p('   begin');
   p('      select application_process_id');
   p('       into  retval');
   p('       from  apex_application_processes');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  process_type     = type_in');
   p('        and  process_name     = name_in;');
   p('      return retval;');
   p('   exception');
   p('      when no_data_found');
   p('      then');
   p('         return null;');
   p('      when others');
   p('      then');
   p('         raise;');
   p('   end get_fp_id;');
   p('');
   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('   lbl_tid   := get_template_id(''List'',''Button List'');');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rlwi_tid  := get_template_id(''Region'',''List Region with Icon'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional Label with Help'');');
   p('   ts_name  := ''UTIL_TS'';');
   p('   ulp_id   := wwv_flow_id.next_val;');
   p('   irws_id  := wwv_flow_id.next_val;');
   p('   arp_id   := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   p('   dbms_output.put_line(''  ...application processes'');');
   p('   --application/shared_components/logic/application_processes/set_usr');
   p('');
   if abuff.usr_datatype is not null
   then
      p('      -- An alternate form of SET_USR must be created');
      p('      --    for USR_DATATYPE: ' || abuff.usr_datatype);
      p('      dbms_output.put_line(''  NOTE Flow Process "SET_USR" NOT CREATED'');');
   else
      p('   if get_fp_id(''SET_USR'', ''PL/SQL Anonymous Block'') is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create Flow Process "SET_USR"'');');
      p('');
      p('      wwv_flow_api.create_flow_process(');
      p('         p_id     => wwv_flow_id.next_val,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_process_sequence=> 10,');
      p('         p_process_point=> ''AFTER_SUBMIT'',');
      p('         p_process_type=> ''PLSQL'',');
      p('         p_process_name=> ''SET_USR'',');
      p('         p_process_sql_clob => ''"#OWNER#".glob.set_usr(:APP_USER);'',');
      p('         p_process_error_message=> ''SET_USR: Unable to set user in UTIL package.'',');
      p('         p_process_when=> '''',');
      p('         p_process_when_type=> '''',');
      p('         p_process_comment=>'''');');
      p('');
      p('   end if;');
   end if;
   p('');
   p('   dbms_output.put_line(''  ...Shared Lists of values'');');
   p('   --application/shared_components/user_interface/lov/domains');
   p('');
   for buff in (
      select * from domains DOM
       where DOM.application_id = abuff.id
       order by DOM.name )
   loop
      p('   ----------------------------------------');
      p('');
      p('   if get_lov_id(''' || upper(buff.name) ||
                          ''', ''Static'') is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create LOV "' ||
                   upper(buff.name) || '"'');');
      p('      lov_id := wwv_flow_id.next_val;');
      p('');
      p('      wwv_flow_api.create_list_of_values (');
      p('         p_id       => lov_id,');
      p('         p_flow_id  => wwv_flow.g_flow_id,');
      p('         p_lov_name => ''' || upper(buff.name) || ''',');
      p('         p_lov_query=> ''.'' || lov_id || ''.'');');
      p('');
      dseq := 0;
      for buf2 in (
         select * from domain_values
          where domain_id = buff.id
          order by seq )
      loop
         dseq := dseq + 1;
         p('      wwv_flow_api.create_static_lov_data (');
         p('         p_id=>wwv_flow_id.next_val,');
         p('         p_lov_id=>lov_id,');
         p('         p_lov_disp_sequence=>' || (dseq * 10) || ',');
         p('         p_lov_disp_value=>''' || buf2.value || ' (' ||
                                       replace(buf2.description,SQ1,SQ2) ||
                                       ')'',');
         p('         p_lov_return_value=>''' || buf2.value || ''',');
         p('         p_lov_data_comment=> '''');');
         p('');
      end loop;
      p('   end if;');
      p('');
   end loop;
   p('');
   p('   ----------------------------------------');
   p('');
   p('   pnum  := ' || pnum1 || ' + page_os;');
   p('   pname := ''Maintenance Menu'';');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> pname,');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rrr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('     p_plug_source=> ''This is the "'' || pname || ''" page.  Click on one of the buttons in the navigation lists below for maintenance (grid edit) pages.  Use the "'' || pname || ''" tab on any of those pages to return back to this page.'',');
   p('     p_plug_source_type=> ''STATIC_TEXT'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ''f?p=&APP_ID.:'' || pnum || '':&SESSION.'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> 99,');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Tabs (for '' || pname || '')'');');
   p('');
   p('   select count(tab_id)');
   p('    into  tab_cnt');
   p('    from  apex_application_tabs');
   p('    where application_name = app_name');
   p('     and  workspace        = ws_name');
   p('     and  tab_set          = ts_name');
   p('     and  tab_name         = pname;');
   p('   if tab_cnt = 0');
   p('   then');
   p('      dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('      wwv_flow_api.create_tab (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_tab_set=> ts_name,');
   p('         p_tab_sequence=> pnum,');
   p('         p_tab_name => pname,');
   p('         p_tab_text=> pname,');
   p('         p_tab_step => pnum,');
   p('         p_tab_also_current_for_pages => '''',');
   p('         p_tab_parent_tabset=>'''',');
   p('         p_tab_comment  => '''');');
   p('   end if;');
   --------------------------------------------------------------
   /*
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
       group by TAB.group_name )
   loop
      p('');
      p('   s  := ''' || buff.group_name || '_MAINT_TS'';');
      p('');
      p('   select count(tab_id)');
      p('    into  tab_cnt');
      p('    from  apex_application_tabs');
      p('    where application_name = app_name');
      p('     and  workspace        = ws_name');
      p('     and  tab_set          = s');
      p('     and  tab_name         = pname;');
      p('   if tab_cnt = 0');
      p('   then');
      p('      dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || s || '' ...'');');
      p('      wwv_flow_api.create_tab (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_tab_set=> s,');
      p('         p_tab_sequence=> 1,');
      p('         p_tab_name => pname,');
      p('         p_tab_text=> pname,');
      p('         p_tab_step => pnum,');
      p('         p_tab_also_current_for_pages => '''',');
      p('         p_tab_parent_tabset=>'''',');
      p('         p_tab_comment  => '''');');
      p('   end if;');
   end loop;
   */
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Lists'');');
   rseq := 0;
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
       group by TAB.group_name )
   loop
      rseq := rseq + 1;
      p('');
      p('   --application/shared_components/navigation/lists/' || buff.group_name || '_maintenance_forms');
      p('');
      p('   lst_name := ''' || buff.group_name || ' ' || ''' || pname;');
      p('   lst_id   := get_list_id(lst_name);');
      p('');
      p('   if lst_id is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create LIST "'' || lst_name || ''"'');');
      p('      lst_id := wwv_flow_id.next_val;');
      p('');
      p('      wwv_flow_api.create_list (');
      p('         p_id=> lst_id,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_name=> lst_name,');
      p('         p_list_status=> ''PUBLIC'',');
      p('         p_list_displayed=> ''BY_DEFAULT'',');
      p('         p_display_row_template_id=> lbl_tid);');
      p('');
      p('   end if;');
      p('');
      for buf2 in (
         select * from tables TAB
          where TAB.application_id = abuff.id
           and  (   TAB.group_name = buff.group_name
		         or (    TAB.group_name  is null
				     and buff.group_name is null)  )
          order by TAB.seq )
      loop
         p('   s := ''' || initcap(replace(buf2.name,'_',' ')) || ' Maint'';');
         p('');
         p('   if get_list_entry_id(lst_id, s) is null');
         p('   then');
         p('');
         p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
         p('      p := ' || (pnum1 + buf2.seq) || ' + page_os;');
         p('');
         p('      wwv_flow_api.create_list_item (');
         p('         p_id=> wwv_flow_id.next_val,');
         p('         p_list_id=> lst_id,');
         p('         p_list_item_type=> ''LINK'',');
         p('         p_list_item_status=> ''PUBLIC'',');
         p('         p_item_displayed=> ''BY_DEFAULT'',');
         p('         p_list_item_display_sequence=> ' || (buf2.seq*10) || ',');
         p('         p_list_item_link_text=> s,');
         p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
         p('         p_list_text_01=> '''',');
         p('         p_list_item_current_type=> '''',');
         p('         p_list_item_current_for_pages=> '''' || p || '''',');
         p('         p_list_item_owner=> '''');');
         p('');
         p('   end if;');
         p('');
      end loop;
      p('');
      p('   dbms_output.put_line(''  ... Add LIST "'' || lst_name || ''" to page '' || pnum);');
      p('');
      p('   wwv_flow_api.create_page_plug (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_page_id=> pnum,');
      p('      p_plug_name=> lst_name,');
      p('      p_region_name=>'''',');
      p('      p_plug_template=> rlwi_tid,');
      p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
      p('      p_plug_display_column=> 1,');
      p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
      p('      p_plug_source=> s||lst_id,');   -- does this need a trim(to_char())???
      p('      p_plug_source_type=> lst_id,');
      p('      p_plug_display_error_message=> ''#SQLERRM#'',');
      p('      p_plug_query_row_template=> 1,');
      p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
      p('      p_plug_query_row_count_max => 500,');
      p('      p_plug_display_condition_type => '''',');
      p('      p_plug_caching=> ''NOT_CACHED'',');
      p('      p_plug_comment=> '''');');
   end loop;
   p('   ----------------------------------------');
   p('');
   p('   pnum  := ' || pnum2 || ' + page_os;');
   p('   pname := ''Utility Log Report'';');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_first_item => ''NO_FIRST_ITEM''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''Report for the Utility Log records''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   --------------------------------------------------------------
   rseq := 0;
                              --  ...Create UTIL_LOG Report Plug'');');
   p('   dbms_output.put_line(''  ...Create UTIL_LOG Report Plug'');');
   pr('   s := ''select DTM'' ');
   pr('              '',USR'' ');
   pr('              '',TXT'' ');
   pr('              '',LOC'' ');
   pr('        ''from "#OWNER#".UTIL_LOG'' ');
   p('        ''order by DTM desc'';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> ulp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> pname,');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rrr_tid,');
   p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> s,');
   p('      p_plug_source_type=> ''DYNAMIC_QUERY'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_plug_query_row_count_max => 500,');
   p('      p_plug_query_show_nulls_as => ''-'',');
   p('      p_plug_display_condition_type => null,');
   p('      p_pagination_display_position=>''BOTTOM_LEFT'',');
   p('      p_plug_customized=>''0'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_worksheet(');
   p('      p_id=> irws_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_region_id=> ulp_id,');
   p('      p_name=> pname,');
   p('      p_folder_id=> null, ');
   p('      p_alias=> '''',');
   p('      p_report_id_item=> '''',');
   p('      p_max_row_count=> ''10000'',');
   p('      p_max_row_count_message=> ''This query returns more than #MAX_ROW_COUNT# rows, please filter your data to ensure complete results.'',');
   p('      p_no_data_found_message=> ''No data found.'',');
   p('      p_max_rows_per_page=>'''',');
   p('      p_search_button_label=>'''',');
   p('      p_page_items_to_submit=>'''',');
   p('      p_sort_asc_image=>'''',');
   p('      p_sort_asc_image_attr=>'''',');
   p('      p_sort_desc_image=>'''',');
   p('      p_sort_desc_image_attr=>'''',');
   p('      p_sql_query => s,');
   p('      p_status=>''AVAILABLE_FOR_OWNER'',');
   p('      p_allow_report_saving=>''Y'',');
   p('      p_allow_save_rpt_public=>''N'',');
   p('      p_allow_report_categories=>''N'',');
   p('      p_show_nulls_as=>''-'',');
   p('      p_pagination_type=>''ROWS_X_TO_Y'',');
   p('      p_pagination_display_pos=>''BOTTOM_LEFT'',');
   p('      p_show_finder_drop_down=>''Y'',');
   p('      p_show_display_row_count=>''N'',');
   p('      p_show_search_bar=>''Y'',');
   p('      p_show_search_textbox=>''Y'',');
   p('      p_show_actions_menu=>''Y'',');
   p('      p_report_list_mode=>''TABS'',');
   p('      p_show_detail_link=>''N'',');
   p('      p_show_select_columns=>''Y'',');
   p('      p_show_rows_per_page=>''Y'',');
   p('      p_show_filter=>''Y'',');
   p('      p_show_sort=>''Y'',');
   p('      p_show_control_break=>''Y'',');
   p('      p_show_highlight=>''Y'',');
   p('      p_show_computation=>''Y'',');
   p('      p_show_aggregate=>''Y'',');
   p('      p_show_chart=>''Y'',');
   p('      p_show_group_by=>''Y'',');
   p('      p_show_notify=>''N'',');
   p('      p_show_calendar=>''N'',');
   p('      p_show_flashback=>''Y'',');
   p('      p_show_reset=>''Y'',');
   p('      p_show_download=>''Y'',');
   p('      p_show_help=>''Y'',');
   p('      p_download_formats=>''CSV:HTML:EMAIL'',');
   p('      p_allow_exclude_null_values=>''N'',');
   p('      p_allow_hide_extra_columns=>''N'',');
   p('      p_icon_view_enabled_yn=>''N'',');
   p('      p_icon_view_columns_per_row=>1,');
   p('      p_detail_view_enabled_yn=>''N'',');
   p('      p_owner=>ws_name);');
   p('');
   p('   wwv_flow_api.create_worksheet_column (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id=> irws_id,');
   p('      p_db_column_name         =>''DTM'',');
   p('      p_display_order          =>1,');
   p('      p_group_id               =>null,');
   p('      p_column_identifier      =>''A'',');
   p('      p_column_label           =>''Log Date/Time'',');
   p('      p_report_label           =>''Log Date/Time'',');
   p('      p_sync_form_label        =>''Y'',');
   p('      p_display_in_default_rpt =>''Y'',');
   p('      p_is_sortable            =>''Y'',');
   p('      p_allow_sorting          =>''Y'',');
   p('      p_allow_filtering        =>''Y'',');
   p('      p_allow_highlighting     =>''Y'',');
   p('      p_allow_ctrl_breaks      =>''Y'',');
   p('      p_allow_aggregations     =>''Y'',');
   p('      p_allow_computations     =>''Y'',');
   p('      p_allow_charting         =>''Y'',');
   p('      p_allow_group_by         =>''Y'',');
   p('      p_allow_hide             =>''Y'',');
   p('      p_others_may_edit        =>''Y'',');
   p('      p_others_may_view        =>''Y'',');
   p('      p_column_type            =>''DATE'',');
   p('      p_display_as             =>''TEXT'',');
   p('      p_display_text_as        =>''ESCAPE_SC'',');
   p('      p_heading_alignment      =>''CENTER'',');
   p('      p_column_alignment       =>''LEFT'',');
   p('      p_tz_dependent           =>''Y'',');
   p('      p_rpt_distinct_lov       =>''Y'',');
   p('      p_rpt_show_filter_lov    =>''D'',');
   p('      p_rpt_filter_date_ranges =>''ALL'',');
   p('      p_help_text              =>'''');');
   p('');
   p('   wwv_flow_api.create_worksheet_column (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id=> irws_id,');
   p('      p_db_column_name         =>''USR'',');
   p('      p_display_order          =>2,');
   p('      p_group_id               =>null,');
   p('      p_column_identifier      =>''B'',');
   p('      p_column_label           =>''User'',');
   p('      p_report_label           =>''User'',');
   p('      p_sync_form_label        =>''Y'',');
   p('      p_display_in_default_rpt =>''Y'',');
   p('      p_is_sortable            =>''Y'',');
   p('      p_allow_sorting          =>''Y'',');
   p('      p_allow_filtering        =>''Y'',');
   p('      p_allow_highlighting     =>''Y'',');
   p('      p_allow_ctrl_breaks      =>''Y'',');
   p('      p_allow_aggregations     =>''Y'',');
   p('      p_allow_computations     =>''Y'',');
   p('      p_allow_charting         =>''Y'',');
   p('      p_allow_group_by         =>''Y'',');
   p('      p_allow_hide             =>''Y'',');
   p('      p_others_may_edit        =>''Y'',');
   p('      p_others_may_view        =>''Y'',');
   p('      p_column_type            =>''STRING'',');
   p('      p_display_as             =>''TEXT'',');
   p('      p_display_text_as        =>''ESCAPE_SC'',');
   p('      p_heading_alignment      =>''CENTER'',');
   p('      p_column_alignment       =>''LEFT'',');
   p('      p_tz_dependent           =>''N'',');
   p('      p_rpt_distinct_lov       =>''Y'',');
   p('      p_rpt_show_filter_lov    =>''D'',');
   p('      p_rpt_filter_date_ranges =>''ALL'',');
   p('      p_help_text              =>'''');');
   p('');
   p('   wwv_flow_api.create_worksheet_column (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id=> irws_id,');
   p('      p_db_column_name         =>''TXT'',');
   p('      p_display_order          =>3,');
   p('      p_group_id               =>null,');
   p('      p_column_identifier      =>''C'',');
   p('      p_column_label           =>''Log Text'',');
   p('      p_report_label           =>''Log Text'',');
   p('      p_sync_form_label        =>''Y'',');
   p('      p_display_in_default_rpt =>''Y'',');
   p('      p_is_sortable            =>''Y'',');
   p('      p_allow_sorting          =>''Y'',');
   p('      p_allow_filtering        =>''Y'',');
   p('      p_allow_highlighting     =>''Y'',');
   p('      p_allow_ctrl_breaks      =>''Y'',');
   p('      p_allow_aggregations     =>''Y'',');
   p('      p_allow_computations     =>''Y'',');
   p('      p_allow_charting         =>''Y'',');
   p('      p_allow_group_by         =>''Y'',');
   p('      p_allow_hide             =>''Y'',');
   p('      p_others_may_edit        =>''Y'',');
   p('      p_others_may_view        =>''Y'',');
   p('      p_column_type            =>''STRING'',');
   p('      p_display_as             =>''TEXT'',');
   p('      p_display_text_as        =>''ESCAPE_SC'',');
   p('      p_heading_alignment      =>''CENTER'',');
   p('      p_column_alignment       =>''LEFT'',');
   p('      p_tz_dependent           =>''N'',');
   p('      p_rpt_distinct_lov       =>''Y'',');
   p('      p_rpt_show_filter_lov    =>''D'',');
   p('      p_rpt_filter_date_ranges =>''ALL'',');
   p('      p_help_text              =>'''');');
   p('');
   p('   wwv_flow_api.create_worksheet_column (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id=> irws_id,');
   p('      p_db_column_name         =>''LOC'',');
   p('      p_display_order          =>4,');
   p('      p_group_id               =>null,');
   p('      p_column_identifier      =>''D'',');
   p('      p_column_label           =>''Source Location of the Log'',');
   p('      p_report_label           =>''Source Location of the Log'',');
   p('      p_sync_form_label        =>''Y'',');
   p('      p_display_in_default_rpt =>''Y'',');
   p('      p_is_sortable            =>''Y'',');
   p('      p_allow_sorting          =>''Y'',');
   p('      p_allow_filtering        =>''Y'',');
   p('      p_allow_highlighting     =>''Y'',');
   p('      p_allow_ctrl_breaks      =>''Y'',');
   p('      p_allow_aggregations     =>''Y'',');
   p('      p_allow_computations     =>''Y'',');
   p('      p_allow_charting         =>''Y'',');
   p('      p_allow_group_by         =>''Y'',');
   p('      p_allow_hide             =>''Y'',');
   p('      p_others_may_edit        =>''Y'',');
   p('      p_others_may_view        =>''Y'',');
   p('      p_column_type            =>''STRING'',');
   p('      p_display_as             =>''TEXT'',');
   p('      p_display_text_as        =>''ESCAPE_SC'',');
   p('      p_heading_alignment      =>''CENTER'',');
   p('      p_column_alignment       =>''LEFT'',');
   p('      p_tz_dependent           =>''N'',');
   p('      p_rpt_distinct_lov       =>''Y'',');
   p('      p_rpt_show_filter_lov    =>''D'',');
   p('      p_rpt_filter_date_ranges =>''ALL'',');
   p('      p_help_text              =>'''');');
   p('');
   p('   wwv_flow_api.create_worksheet_rpt(');
   p('      p_id => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id => irws_id,');
   p('      p_session_id  => null,');
   p('      p_base_report_id  => null,');
   p('      p_application_user => ''APXWS_DEFAULT'',');
   p('      p_report_seq              =>10,');
   p('      p_report_alias            =>''Util Log Default'',');
   p('      p_status                  =>''PUBLIC'',');
   p('      p_category_id             =>null,');
   p('      p_is_default              =>''Y'',');
   p('      p_display_rows            =>15,');
   p('      p_report_columns          =>''DTM:USR:TXT:LOC'',');
   p('      p_flashback_enabled       =>''N'',');
   p('      p_calendar_display_column =>'''');');
   p('');
   p('   ---------------------------------------');
   p('   --   MISSING PAGE VALIDATION   --');
   p('   ---------------------------------------');
   p('');
   pseq := 0;
                              --  ...Create Page Processing'');');
   p('   dbms_output.put_line(''  ...Create Page Processing'');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ');
   p('       ''f?p=&APP_ID.:'' || pnum || '':&SESSION.&success_msg=#SUCCESS_MSG#'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> ' || (pseq * 10) || ',');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Tabs (for '' || pname || '')'');');
   p('');
   p('   select count(tab_id)');
   p('    into  tab_cnt');
   p('    from  apex_application_tabs');
   p('    where application_name = app_name');
   p('     and  workspace        = ws_name');
   p('     and  tab_set          = ts_name');
   p('     and  tab_name         = pname;');
   p('   if tab_cnt = 0');
   p('   then');
   p('      dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('      wwv_flow_api.create_tab (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_tab_set=> ts_name,');
   p('         p_tab_sequence=> pnum,');
   p('         p_tab_name => pname,');
   p('         p_tab_text=> pname,');
   p('         p_tab_step => pnum,');
   p('         p_tab_also_current_for_pages => '''',');
   p('         p_tab_parent_tabset=>'''',');
   p('         p_tab_comment  => '''');');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   pnum := ' || pnum3 || ' + page_os;');
   p('   pname := ''OMNI Reports Menu'';');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> pname,');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rrr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('     p_plug_source=> ''This is the "'' || pname || ''" page.  Click on one of the buttons in the navigation lists below for OMNI interactive report pages.  Use the "'' || pname || ''" tab on any of those pages to return back to this page.'',');
   p('     p_plug_source_type=> ''STATIC_TEXT'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ''f?p=&APP_ID.:'' || pnum || '':&SESSION.'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> 99,');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Tabs (for '' || pname || '')'');');
   p('');
   p('   select count(tab_id)');
   p('    into  tab_cnt');
   p('    from  apex_application_tabs');
   p('    where application_name = app_name');
   p('     and  workspace        = ws_name');
   p('     and  tab_set          = ts_name');
   p('     and  tab_name         = ''T_OMNI'';');
   p('   if tab_cnt = 0');
   p('   then');
   p('      dbms_output.put_line(''  Adding T_OMNI Tab to '' || ts_name || '' ...'');');
   p('      wwv_flow_api.create_tab (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_tab_set=> ts_name,');
   p('         p_tab_sequence=> pnum,');
   p('         p_tab_name => ''T_OMNI'',');
   p('         p_tab_text=> pname,');
   p('         p_tab_step => pnum,');
   p('         p_tab_also_current_for_pages => '''',');
   p('         p_tab_parent_tabset=>'''',');
   p('         p_tab_comment  => '''');');
   p('   end if;');
   --------------------------------------------------------------
   /*
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       group by TAB.group_name )
   loop
      p('');
      p('   s  := ''' || buff.group_name || '_OMNI_TS'';');
      p('');
      p('   select count(tab_id)');
      p('    into  tab_cnt');
      p('    from  apex_application_tabs');
      p('    where application_name = app_name');
      p('     and  workspace        = ws_name');
      p('     and  tab_set          = s');
      p('     and  tab_name         = ''T_OMNI'';');
      p('   if tab_cnt = 0');
      p('   then');
      p('      dbms_output.put_line(''  Adding T_OMNI Tab to '' || s || '' ...'');');
      p('      wwv_flow_api.create_tab (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_tab_set=> s,');
      p('         p_tab_sequence=> 1,');
      p('         p_tab_name => ''T_OMNI'',');
      p('         p_tab_text=> pname,');
      p('         p_tab_step => pnum,');
      p('         p_tab_also_current_for_pages => '''',');
      p('         p_tab_parent_tabset=>'''',');
      p('         p_tab_comment  => '''');');
      p('   end if;');
   end loop;
   */
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Lists'');');
   rseq := 0;
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       group by TAB.group_name )
   loop
      rseq := rseq + 1;
      p('');
      p('   --application/shared_components/navigation/lists/' || buff.group_name || '_omni_reports');
      p('');
      p('   lst_name := ''' || buff.group_name || ' ' || ''' || pname;');
      p('   lst_id   := get_list_id(lst_name);');
      p('');
      p('   if lst_id is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create LIST "'' || lst_name || ''"'');');
      p('      lst_id := wwv_flow_id.next_val;');
      p('');
      p('      wwv_flow_api.create_list (');
      p('         p_id=> lst_id,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_name=> lst_name,');
      p('         p_list_status=> ''PUBLIC'',');
      p('         p_list_displayed=> ''BY_DEFAULT'',');
      p('         p_display_row_template_id=> lbl_tid);');
      p('');
      p('   end if;');
      p('');
      for buf2 in (
         select * from tables TAB
          where TAB.application_id = abuff.id
           and  (    TAB.group_name = buff.group_name
		         or (    TAB.group_name  is null
				     and buff.group_name is null)  )
           and  TAB.type in ('EFF', 'LOG')
          order by TAB.seq )
      loop
         p('   s := ''' || initcap(replace(buf2.name,'_',' ')) || ' OMNI'';');
         p('');
         p('   if get_list_entry_id(lst_id, s) is null');
         p('   then');
         p('');
         p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
         p('      p := ' || (pnum3 + buf2.seq) || ' + page_os;');
         p('');
         p('      wwv_flow_api.create_list_item (');
         p('         p_id=> wwv_flow_id.next_val,');
         p('         p_list_id=> lst_id,');
         p('         p_list_item_type=> ''LINK'',');
         p('         p_list_item_status=> ''PUBLIC'',');
         p('         p_item_displayed=> ''BY_DEFAULT'',');
         p('         p_list_item_display_sequence=> ' || (buf2.seq*10) || ',');
         p('         p_list_item_link_text=> s,');
         p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
         p('         p_list_text_01=> '''',');
         p('         p_list_item_current_type=> '''',');
         p('         p_list_item_current_for_pages=> '''' || p || '''',');
         p('         p_list_item_owner=> '''');');
         p('');
         p('   end if;');
         p('');
      end loop;
      p('');
      p('   dbms_output.put_line(''  ... Add LIST "'' || lst_name || ''" to page '' || pnum);');
      p('');
      p('   wwv_flow_api.create_page_plug (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_page_id=> pnum,');
      p('      p_plug_name=> lst_name,');
      p('      p_region_name=>'''',');
      p('      p_plug_template=> rlwi_tid,');
      p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
      p('      p_plug_display_column=> 1,');
      p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
      p('      p_plug_source=> s||lst_id,');   -- does this need a trim(to_char())???
      p('      p_plug_source_type=> lst_id,');
      p('      p_plug_display_error_message=> ''#SQLERRM#'',');
      p('      p_plug_query_row_template=> 1,');
      p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
      p('      p_plug_query_row_count_max => 500,');
      p('      p_plug_display_condition_type => '''',');
      p('      p_plug_caching=> ''NOT_CACHED'',');
      p('      p_plug_comment=> '''');');
   end loop;
   p('');
   p('   ----------------------------------------');
   p('');
   p('   pnum := ' || pnum4 || ' + page_os;');
   p('   pname := ''ASOF Reports Menu'';');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   s := ''This is the "ASOF Reports Menu" page. Click on one of the buttons in the navigation lists below for ASOF interactive report pages. Use the "ASOF Reports Menu" tab on any of those pages to return back to this page. To change the ASOF Date for all the ASOF Reports, Enter the a new ASOF Date/Timein the box below.'';');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> arp_id,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> pname,');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rrr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''BEFORE_SHOW_ITEMS'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''STATIC_TEXT'',');
   p('     p_translate_title=> ''Y'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ''f?p=&APP_ID.:'' || pnum || '':&SESSION.'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> 99,');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   pseq := 0;
   p('');
   p('   s := ''Enter the ASOF Date/Time.  This Date/Time will be used on all the ASOF Reports.  To save the new Date/Time, press "Enter" on the field, or click the "Set ASOF Date/Time button.'';');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=>wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_ASOF_DTM'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> true,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (pseq * 10) || ',');
   p('      p_item_plug_id => arp_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default=> ''to_char(glob.get_asof_dtm,''''DD-MON-YYYY HH:MI:SS PM'''')'',');
   p('      p_item_default_type=> ''PLSQL_EXPRESSION'',');
   p('      p_prompt=>''ASOF Date/Time:'',');
   p('      p_format_mask=>''DD-MON-YYYY HH:MI:SS PM'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''NATIVE_DATE_PICKER'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 4000,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''RIGHT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_lov_display_extra=>''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_help_text => s,');
   p('      p_attribute_04 => ''button'',');
   p('      p_attribute_05 => ''N'',');
   p('      p_attribute_07 => ''NONE'',');
   p('      p_show_quick_picks=>''N'',');
   p('      p_item_comment => '''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=>wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_SUBMIT'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (pseq * 10) || ',');
   p('      p_item_plug_id => arp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default=> ''SUBMIT'',');
   p('      p_prompt=>''Set ASOF Date/Time'',');
   p('      p_source=>''SUBMIT'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''BUTTON'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> null,');
   p('      p_cMaxlength=> 2000,');
   p('      p_cHeight=> null,');
   p('      p_tag_attributes  => ''template:''||bb_tid,');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT'',');
   p('      p_is_persistent=> ''N'',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_item_comment => '''');');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Tabs (for '' || pname || '')'');');
   p('');
   p('   select count(tab_id)');
   p('    into  tab_cnt');
   p('    from  apex_application_tabs');
   p('    where application_name = app_name');
   p('     and  workspace        = ws_name');
   p('     and  tab_set          = ts_name');
   p('     and  tab_name         = ''T_ASOF'';');
   p('   if tab_cnt = 0');
   p('   then');
   p('      dbms_output.put_line(''  Adding T_ASOF Tab to '' || ts_name || '' ...'');');
   p('      wwv_flow_api.create_tab (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_tab_set=> ts_name,');
   p('         p_tab_sequence=> pnum,');
   p('         p_tab_name => ''T_ASOF'',');
   p('         p_tab_text=> pname,');
   p('         p_tab_step => pnum,');
   p('         p_tab_also_current_for_pages => '''',');
   p('         p_tab_parent_tabset=>'''',');
   p('         p_tab_comment  => '''');');
   p('   end if;');
   --------------------------------------------------------------
   /*
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       group by TAB.group_name )
   loop
      p('');
      p('   s  := ''' || buff.group_name || '_ASOF_TS'';');
      p('');
      p('   select count(tab_id)');
      p('    into  tab_cnt');
      p('    from  apex_application_tabs');
      p('    where application_name = app_name');
      p('     and  workspace        = ws_name');
      p('     and  tab_set          = s');
      p('     and  tab_name         = ''T_ASOF'';');
      p('   if tab_cnt = 0');
      p('   then');
      p('      dbms_output.put_line(''  Adding T_ASOF Tab to '' || s || '' ...'');');
      p('      wwv_flow_api.create_tab (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_tab_set=> s,');
      p('         p_tab_sequence=> 1,');
      p('         p_tab_name => ''T_ASOF'',');
      p('         p_tab_text=> pname,');
      p('         p_tab_step => pnum,');
      p('         p_tab_also_current_for_pages => '''',');
      p('         p_tab_parent_tabset=>'''',');
      p('         p_tab_comment  => '''');');
      p('   end if;');
   end loop;
   */
   p('');
   p('   ----------------------------------------');
   p('');
   p('   dbms_output.put_line(''  ...Navigation Lists'');');
   rseq := 0;
   for buff in (
      select TAB.group_name from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       group by TAB.group_name )
   loop
      rseq := rseq + 1;
      p('');
      p('   --application/shared_components/navigation/lists/' || buff.group_name || '_asof_reports');
      p('');
      p('   lst_name := ''' || buff.group_name || ' ' || ''' || pname;');
      p('   lst_id   := get_list_id(lst_name);');
      p('');
      p('   if lst_id is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create LIST "'' || lst_name || ''"'');');
      p('      lst_id := wwv_flow_id.next_val;');
      p('');
      p('      wwv_flow_api.create_list (');
      p('         p_id=> lst_id,');
      p('         p_flow_id=> wwv_flow.g_flow_id,');
      p('         p_name=> lst_name,');
      p('         p_list_status=> ''PUBLIC'',');
      p('         p_list_displayed=> ''BY_DEFAULT'',');
      p('         p_display_row_template_id=> lbl_tid);');
      p('');
      p('   end if;');
      p('');
      for buf2 in (
         select * from tables TAB
          where TAB.application_id = abuff.id
           and  (    TAB.group_name = buff.group_name
		         or (    TAB.group_name  is null
				     and buff.group_name is null)  )
           and  TAB.type in ('EFF', 'LOG')
          order by TAB.seq )
      loop
         p('   s := ''' || initcap(replace(buf2.name,'_',' ')) || ' ASOF'';');
         p('');
         p('   if get_list_entry_id(lst_id, s) is null');
         p('   then');
         p('');
         p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
         p('      p := ' || (pnum4 + buf2.seq) || ' + page_os;');
         p('');
         p('      wwv_flow_api.create_list_item (');
         p('         p_id=> wwv_flow_id.next_val,');
         p('         p_list_id=> lst_id,');
         p('         p_list_item_type=> ''LINK'',');
         p('         p_list_item_status=> ''PUBLIC'',');
         p('         p_item_displayed=> ''BY_DEFAULT'',');
         p('         p_list_item_display_sequence=> ' || (buf2.seq*10) || ',');
         p('         p_list_item_link_text=> s,');
         p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
         p('         p_list_text_01=> '''',');
         p('         p_list_item_current_type=> '''',');
         p('         p_list_item_current_for_pages=> '''' || p || '''',');
         p('         p_list_item_owner=> '''');');
         p('');
         p('   end if;');
         p('');
      end loop;
      p('');
      p('   dbms_output.put_line(''  ... Add LIST "'' || lst_name || ''" to page '' || pnum);');
      p('');
      p('   wwv_flow_api.create_page_plug (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_page_id=> pnum,');
      p('      p_plug_name=> lst_name,');
      p('      p_region_name=>'''',');
      p('      p_plug_template=> rlwi_tid,');
      p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
      p('      p_plug_display_column=> 1,');
      p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
      p('      p_plug_source=> ''s'' || lst_id,');
      p('      p_plug_source_type=> lst_id,');
      p('      p_plug_display_error_message=> ''#SQLERRM#'',');
      p('      p_plug_query_row_template=> 1,');
      p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
      p('      p_plug_query_row_count_max => 500,');
      p('      p_plug_display_condition_type => '''',');
      p('      p_plug_caching=> ''NOT_CACHED'',');
      p('      p_plug_comment=> '''');');
   end loop;
   p('');
   p('   --application/shared_components/navigation/lists/utility_menu');
   p('');
   p('   lst_name := ''Utility Menu'';');
   p('   lst_id   := get_list_id(lst_name);');
   p('');
   p('   if lst_id is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create LIST "'' || lst_name || ''"'');');
   p('      lst_id := wwv_flow_id.next_val;');
   p('');
   p('      wwv_flow_api.create_list (');
   p('         p_id=> lst_id,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_name=> lst_name,');
   p('         p_list_status=> ''PUBLIC'',');
   p('         p_list_displayed=> ''BY_DEFAULT'',');
   p('         p_display_row_template_id=> lbl_tid);');
   p('');
   p('   end if;');
   p('');
   p('   s := ''Maintenance Menu'';');
   p('   if get_list_entry_id(lst_id, s) is null');
   p('   then');
   p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum1 || ' + page_os;');
   p('      wwv_flow_api.create_list_item (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_list_id=> lst_id,');
   p('         p_list_item_type=> ''LINK'',');
   p('         p_list_item_status=> ''PUBLIC'',');
   p('         p_item_displayed=> ''BY_DEFAULT'',');
   p('         p_list_item_display_sequence=> ' || pnum1 || ',');
   p('         p_list_item_link_text=> s,');
   p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
   p('         p_list_text_01=> '''',');
   p('         p_list_item_current_type=> '''',');
   p('         p_list_item_current_for_pages=> '''' || p || '''',');
   p('         p_list_item_owner=> '''');');
   p('   end if;');
   p('');
   p('   s := ''Utility Log Report'';');
   p('   if get_list_entry_id(lst_id, s) is null');
   p('   then');
   p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum2 || ' + page_os;');
   p('      wwv_flow_api.create_list_item (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_list_id=> lst_id,');
   p('         p_list_item_type=> ''LINK'',');
   p('         p_list_item_status=> ''PUBLIC'',');
   p('         p_item_displayed=> ''BY_DEFAULT'',');
   p('         p_list_item_display_sequence=> ' || pnum2 || ',');
   p('         p_list_item_link_text=> s,');
   p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
   p('         p_list_text_01=> '''',');
   p('         p_list_item_current_type=> '''',');
   p('         p_list_item_current_for_pages=> '''' || p || '''',');
   p('         p_list_item_owner=> '''');');
   p('   end if;');
   p('');
   p('   s := ''OMNI Reports Menu'';');
   p('   if get_list_entry_id(lst_id, s) is null');
   p('   then');
   p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum3 || ' + page_os;');
   p('      wwv_flow_api.create_list_item (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_list_id=> lst_id,');
   p('         p_list_item_type=> ''LINK'',');
   p('         p_list_item_status=> ''PUBLIC'',');
   p('         p_item_displayed=> ''BY_DEFAULT'',');
   p('         p_list_item_display_sequence=> ' || pnum3 || ',');
   p('         p_list_item_link_text=> s,');
   p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
   p('         p_list_text_01=> '''',');
   p('         p_list_item_current_type=> '''',');
   p('         p_list_item_current_for_pages=> '''' || p || '''',');
   p('         p_list_item_owner=> '''');');
   p('   end if;');
   p('');
   p('   s := ''ASOF Reports Menu'';');
   p('   if get_list_entry_id(lst_id, s) is null');
   p('   then');
   p('      dbms_output.put_line(''  ...Create LIST ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum4 || ' + page_os;');
   p('      wwv_flow_api.create_list_item (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_list_id=> lst_id,');
   p('         p_list_item_type=> ''LINK'',');
   p('         p_list_item_status=> ''PUBLIC'',');
   p('         p_item_displayed=> ''BY_DEFAULT'',');
   p('         p_list_item_display_sequence=> ' || pnum4 || ',');
   p('         p_list_item_link_text=> s,');
   p('         p_list_item_link_target=> ''f?p=&APP_ID.:'' || p || '':&SESSION.:'',');
   p('         p_list_text_01=> '''',');
   p('         p_list_item_current_type=> '''',');
   p('         p_list_item_current_for_pages=> '''' || p || '''',');
   p('         p_list_item_owner=> '''');');
   p('   end if;');
   p('');

--   This process is done by each OMNI page, instead of in the Menu, because
--   the Home Page Navigation Tree Allows a jump directly to each OMNI page
--   pseq := 0;
--                              --  ...Create Page Processing'');');
--   p('   dbms_output.put_line(''  ...Create Page Processing'');');
--   p('');
--   pseq := pseq + 1;
--   p('');
--   p('   wwv_flow_api.create_page_process(');
--   p('      p_id     => wwv_flow_id.next_val,');
--   p('      p_flow_id=> wwv_flow.g_flow_id,');
--   p('      p_flow_step_id => pnum,');
--   p('      p_process_sequence=> ' || (pseq * 10) || ',');
--   p('      p_process_point=> ''AFTER_SUBMIT'',');
--   p('      p_process_type=> ''PLSQL'',');
--   p('      p_process_name=> ''SET_ASOF_DTM'',');
--   p('      p_process_sql_clob => ''glob.set_asof_dtm(:P'' || pnum || ''_ASOF_DTM);'',');
--   p('      p_process_error_message=> ''Global ASOF Date/Time failed to set.'',');
--   p('      p_process_success_message=> ''Global ASOF Date/Time has been set.',');
--   p('      p_process_is_stateful_y_n=>''N'',');
--   p('      p_process_comment=>'''');');
--   p('');

   p('   ----------------------------------------');
   p('');
   p('   --application/shared_components/navigation/breadcrumbs');
   p('   dbms_output.put_line(''Adding Breadcrumbs'');');
   p('');
   p('   if mnu_id is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create BREADCRUMB "'' || mnu_name || ''"'');');
   p('      mnu_id := wwv_flow_id.next_val;');
   p('');
   p('      wwv_flow_api.create_menu (');
   p('         p_id=> mnu_id,');
   p('         p_flow_id=> wwv_flow.g_flow_id,');
   p('         p_name=> mnu_name);');
   p('');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   s      := ''Maintenance Menu'';');
   p('   bcp_id := get_menu_option_id(mnu_id, s);');
   p('');
   p('   if bcp_id is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum1 || ' + page_os;');
   p('      bcp_id := wwv_flow_id.next_val;');
   p('');
   p('      wwv_flow_api.create_menu_option (');
   p('         p_id=> bcp_id,');
   p('         p_menu_id=> mnu_id,');
   p('         p_parent_id=>null,');
   p('         p_option_sequence=>' || pnum1 || ',');
   p('         p_short_name=>s,');
   p('         p_long_name=>'''',');
   p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
   p('         p_page_id=>p,');
   p('         p_also_current_for_pages=> '''');');
   p('');
   p('   end if;');
   p('');
   for buff in (
      select * from tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq )
   loop
      p('   ----------------------------------------');
      p('');
      p('   s := ''' || initcap(replace(buff.name,'_',' ')) || ' Maint'';');
      p('   bcp2_id := get_menu_option_id(mnu_id, s);');
      p('');
      p('   if bcp2_id is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
      p('      p := ' || (pnum1 + buff.seq) || ' + page_os;');
      p('      bcp2_id := wwv_flow_id.next_val;');
      p('');
      p('      wwv_flow_api.create_menu_option (');
      p('         p_id=> bcp2_id,');
      p('         p_menu_id=> mnu_id,');
      p('         p_parent_id=>bcp_id,');
      p('         p_option_sequence=>' || (pnum1 + buff.seq) || ',');
      p('         p_short_name=>s,');
      p('         p_long_name=>'''',');
      p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
      p('         p_page_id=>p,');
      p('         p_also_current_for_pages=> '''');');
      p('');
      p('   end if;');
      p('');
      p('   ----------------------------------------');
      p('');
      p('   s := ''' || initcap(replace(buff.name,'_',' ')) || ' Form'';');
      p('');
      p('   if get_menu_option_id(mnu_id, s) is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
      p('      p := ' || (pnum2 + buff.seq) || ' + page_os;');
      p('');
      p('      wwv_flow_api.create_menu_option (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_menu_id=> mnu_id,');
      p('         p_parent_id=>bcp2_id,');
      p('         p_option_sequence=>' || (pnum2 + buff.seq) || ',');
      p('         p_short_name=>s,');
      p('         p_long_name=>'''',');
      p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
      p('         p_page_id=>p,');
      p('         p_also_current_for_pages=> '''');');
      p('');
      p('   end if;');
      p('');
   end loop;
   p('   ----------------------------------------');
   p('');
   p('   s := ''Utility Log Report'';');
   p('');
   p('   if get_menu_option_id(mnu_id, s) is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum2 || ' + page_os;');
   p('');
   p('      wwv_flow_api.create_menu_option (');
   p('         p_id=> wwv_flow_id.next_val,');
   p('         p_menu_id=> mnu_id,');
   p('         p_parent_id=> null,');
   p('         p_option_sequence=>' || pnum2 || ',');
   p('         p_short_name=>s,');
   p('         p_long_name=>'''',');
   p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
   p('         p_page_id=>p,');
   p('         p_also_current_for_pages=> '''');');
   p('');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('   s := ''OMNI Reports Menu'';');
   p('   bcp_id := get_menu_option_id(mnu_id, s);');
   p('');
   p('   if bcp_id is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum3 || ' + page_os;');
   p('      bcp_id := wwv_flow_id.next_val;');
   p('');
   p('      wwv_flow_api.create_menu_option (');
   p('         p_id=> bcp_id,');
   p('         p_menu_id=> mnu_id,');
   p('         p_parent_id=> null,');
   p('         p_option_sequence=>' || pnum3 || ',');
   p('         p_short_name=>s,');
   p('         p_long_name=>'''',');
   p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
   p('         p_page_id=>p,');
   p('         p_also_current_for_pages=> '''');');
   p('');
   p('   end if;');
   p('');
   for buff in (
      select * from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       order by TAB.seq )
   loop
      p('   ----------------------------------------');
      p('');
      p('   s := ''' || initcap(replace(buff.name,'_',' ')) || ' OMNI'';');
      p('');
      p('   if get_menu_option_id(mnu_id, s) is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
      p('      p := ' || (pnum3 + buff.seq) || ' + page_os;');
      p('');
      p('      wwv_flow_api.create_menu_option (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_menu_id=> mnu_id,');
      p('         p_parent_id=>bcp_id,');
      p('         p_option_sequence=>' || (pnum3 + buff.seq) || ',');
      p('         p_short_name=>s,');
      p('         p_long_name=>'''',');
      p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
      p('         p_page_id=>p,');
      p('         p_also_current_for_pages=> '''');');
      p('');
      p('   end if;');
      p('');
   end loop;
   p('   ----------------------------------------');
   p('');
   p('   s := ''ASOF Reports Menu'';');
   p('   bcp_id := get_menu_option_id(mnu_id, s);');
   p('');
   p('   if bcp_id is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
   p('      p := ' || pnum4 || ' + page_os;');
   p('      bcp_id := wwv_flow_id.next_val;');
   p('');
   p('      wwv_flow_api.create_menu_option (');
   p('         p_id=> bcp_id,');
   p('         p_menu_id=> mnu_id,');
   p('         p_parent_id=> null,');
   p('         p_option_sequence=>' || pnum4 || ',');
   p('         p_short_name=>s,');
   p('         p_long_name=>'''',');
   p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
   p('         p_page_id=>p,');
   p('         p_also_current_for_pages=> '''');');
   p('');
   p('   end if;');
   p('');
   for buff in (
      select * from tables TAB
       where TAB.application_id = abuff.id
        and  TAB.type in ('EFF', 'LOG')
       order by TAB.seq )
   loop
      p('   ----------------------------------------');
      p('');
      p('   s := ''' || initcap(replace(buff.name,'_',' ')) || ' ASOF'';');
      p('');
      p('   if get_menu_option_id(mnu_id, s) is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create BREADCRUMB ENTRY "'' || s || ''"'');');
      p('      p := ' || (pnum4 + buff.seq) || ' + page_os;');
      p('');
      p('      wwv_flow_api.create_menu_option (');
      p('         p_id=> wwv_flow_id.next_val,');
      p('         p_menu_id=> mnu_id,');
      p('         p_parent_id=>bcp_id,');
      p('         p_option_sequence=>' || (pnum4 + buff.seq) || ',');
      p('         p_short_name=>s,');
      p('         p_long_name=>'''',');
      p('         p_link=>''f?p=&APP_ID.:'' || p || '':&SESSION.'',');
      p('         p_page_id=>p,');
      p('         p_also_current_for_pages=> '''');');
      p('');
      p('   end if;');
      p('');
   end loop;
   p('');
   p('end;');
   p('/');
END app_flow;
----------------------------------------
PROCEDURE maint_flow
   -- To convert this from page generation to application generation,
   --   Templates like "wwv_flow_api.create_row_template" must be added
   --   to the export script, to include matching "p_id => 1283510651569179"
   --   references for every usage of the row_template in the export script.
IS
   rseq       number;          -- Region Sequence Number
   pseq       number;          -- Process Sequence Number
BEGIN
   -- NOTE: There is a conditional return about mid-way through this procedure
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('   -- Page Export Variables');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   ts_name    varchar2(30);    -- Tab Set Name');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Report Type) Report Region Template ID');
   p('   rsarc_tid  number;          -- (Report Type) Standard, Alternating Row');
   p('                               --                      Colors Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   ract_id    number;          -- (Report Region) Active View ID');
   p('   rdel_id    number;          -- (Report Region) Delete View ID');
   p('   fcp_id     number;          -- Filter Criteria Plug ID');
   p('   subb_id    number;          -- Submit Button ID');
   p('   lov_id     number;          -- List of Values ID');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   tab_cnt    number;          -- Number of Tab IDs found');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('');
   p('   if sch_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: sch_name is null.'');');
   p('   end if;');
   p('   if ws_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_id is null.'');');
   p('   end if;');
   p('   if ws_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_name is null.'');');
   p('   end if;');
   p('   if app_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_id is null.'');');
   p('   end if;');
   p('   if app_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_name is null.'');');
   p('   end if;');
   p('');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rsarc_tid := get_template_id(''Report'',''Standard, Alternating Row Colors'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional Label with Help'');');
   p('');
   p('   dbms_output.put_line(''' || tbuff.name || ' maint1, ' || tbuff.seq || ''');');
   p('   pnum     := ' || (pnum1 + tbuff.seq) || ' + page_os;');
   p('   pname    := ''' || initcap(replace(tbuff.name,'_',' ')) || ' Maint'';');
   p('   ts_name  := ''' || tbuff.group_name || '_MAINT_TS'';');
   p('   ract_id  := wwv_flow_id.next_val;');
   p('   rdel_id  := wwv_flow_id.next_val;');
   p('   fcp_id   := wwv_flow_id.next_val;');
   p('   subb_id  := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   p('   if get_lov_id(''' || upper(tbuff.name) ||
                         '_LOV'', ''Dynamic'') is null');
   p('   then');
   p('');
   p('      dbms_output.put_line(''  ...Create Shared LOV "' ||
                upper(tbuff.name) || '_LOV"'');');
   p('      s := ''select ' || tbuff.name || '_dml.get_nk(id) '' ||');
   p('             '' || ''''('''' || id  || '''')'''' d, id r'' || CHR(10) ||');
   p('            ''from  "#OWNER#".' || tbuff.name || ''' || CHR(10) ||');
   p('            ''order by 1'';');
   p('');
   p('      wwv_flow_api.create_list_of_values (');
   p('         p_id       => wwv_flow_id.next_val,');
   p('         p_flow_id  => wwv_flow.g_flow_id,');
   p('         p_lov_name => ''' || upper(tbuff.name) || '_LOV'',');
   p('         p_lov_query=> s);');
   p('');
   p('   end if;');
   p('');
   for buff in (
      select * from tab_cols COL
       where COl.fk_table_id = tbuff.id
        and  COL.table_id    = tbuff.id
       order by COL.seq )
   loop
      p('   if get_lov_id(''' || upper(buff.fk_prefix||tbuff.name) ||
                            '_LOV'', ''Dynamic'') is null');
      p('   then');
      p('');
      p('      dbms_output.put_line(''  ...Create Shared LOV "' ||
                   upper(buff.fk_prefix || tbuff.name) || '_LOV"'');');
      -- Oracle APEX Bug won't repace #OWNER# in Tabular Report
      -- p('      s := ''select "#OWNER#"' || tbuff.name || '_dml.get_' ||
      p('      s := ''select "#OWNER#"' || tbuff.name || '_dml.get_' ||
                              buff.fk_prefix || 'nk_path(id) ||');
      p('          ''''('''' || id  || '''')'''' d, id r'' || CHR(10) ||');
      -- Oracle APEX Bug won't repace #OWNER# in Tabular Report
      -- p('                    ''from "#OWNER#".' || tbuff.name || ''' || CHR(10) ||');
      p('                    ''from "#OWNER#".' || tbuff.name || ''' || CHR(10) ||');
      p('                   ''order by 1'';');
      p('');
      p('      wwv_flow_api.create_list_of_values (');
      p('         p_id       => wwv_flow_id.next_val,');
      p('         p_flow_id  => wwv_flow.g_flow_id,');
      p('         p_lov_name => ''' || upper(buff.fk_prefix || tbuff.name) ||
                                '_LOV'',');
      p('         p_lov_query=> s);');
      p('');
      p('   end if;');
      p('');
   end loop;
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_first_item => ''NO_FIRST_ITEM''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_javascript_code => ');
   p('       ''var htmldb_delete_message=''''"DELETE_CONFIRM_MSG"'''';''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''' || replace(tbuff.description,SQ1,SQ2) || '''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   --------------------------------------------------------------
   rseq := 0;
                               -- ...Create Main Grid Edit'');');
   p('   dbms_output.put_line(''  ...Create Main Grid Edit'');');
   pr('   s := ''select ID'' ');
   pr('              '',ID ID_DISPLAY'' ');
   pr('              '',''''Edit Record'''' EDIT_RECORD_LINK_COLUMN_NAME'' ');
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
   end if;
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('              '',' || upper(buff.name) || ''' ');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('              '',' || upper(buff.fk_prefix) ||
                              'ID_PATH'' ');
            pr('              '',' || upper(buff.fk_prefix) ||
                              'NK_PATH'' ');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('              '',' || upper(buff.fk_prefix) ||
                              get_tabname(buff.fk_table_id) ||
                              '_nk' || i || ''' ');
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      pr('              '',AUD_BEG_USR'' ');
      pr('              '',AUD_BEG_DTM'' ');
   end if;
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || '_ACT'' ');
   pr('        ''where (   (    :P'' || pnum || ''_ID_MIN is null'' ');
   pr('        ''           and :P'' || pnum || ''_ID_MAX is null'' ');
   pr('        ''          )'' ');
   pr('        ''       or (    id between nvl(:P'' || pnum || ''_ID_MIN,-1E125)'' ');
   pr('        ''                      and nvl(:P'' || pnum || ''_ID_MAX, 1E125)'' ');
   pr('        ''          )   )'' ');
   if tbuff.type = 'EFF'
   then
      pr('        '' and (   (    :P'' || pnum || ''_EFF_BEG_DTM_MIN is null'' ');
      pr('        ''          and :P'' || pnum || ''_EFF_BEG_DTM_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''      or (eff_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MIN,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
      pr('        ''                          and nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MAX,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
      pr('        ''          )   )'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      create_search_where;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'id_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;   --5;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_search_where;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'nk_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;   --20;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_search_where;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_nk' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_search_where;
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      pr('        '' and (   :P'' || pnum || ''_AUD_BEG_USR is null'' ');
      pr('        ''      or aud_beg_usr like :P'' || pnum || ''_AUD_BEG_USR'' ');
                              -- NOTE: "Like" works with numbers and strings
      pr('        ''      )'' ');
      pr('        '' and (   (    :P'' || pnum || ''_AUD_BEG_DTM_MIN is null'' ');
      pr('        ''          and :P'' || pnum || ''_AUD_BEG_DTM_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''      or (   aud_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MIN,'' ');
      pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
      pr('        ''                             and nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MAX,'' ');
      pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
      pr('        ''          )   )'' ');
   end if;
   p('        '''';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_report_region (');
   p('      p_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_name=> pname,');
   p('      p_region_name=>'''',');
   p('      p_template=> rrr_tid,');
   p('      p_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_display_column=> 1,');
   p('      p_display_point=> ''BEFORE_SHOW_ITEMS'',');
   p('      p_source=> s,');
   p('      p_source_type=> ''UPDATABLE_SQL_QUERY'',');
   p('      p_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_customized=> ''0'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_ajax_enabled=> ''Y'',');
   p('      p_query_row_template=> rsarc_tid,');
   p('      p_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_query_num_rows=> ''15'',');
   p('      p_query_options=> ''DERIVED_REPORT_COLUMNS'',');
   p('      p_query_show_nulls_as=> ''-'',');
   p('      p_query_no_data_found=> ''No data found.'',');
   p('      p_query_num_rows_type=> ''NEXT_PREVIOUS_LINKS'',');
   p('      p_query_row_count_max=> ''500'',');
   p('      p_pagination_display_position=> ''BOTTOM_LEFT'',');
   p('      p_query_asc_image=> ''apex/builder/dup.gif'',');
   p('      p_query_asc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_query_desc_image=> ''apex/builder/ddown.gif'',');
   p('      p_query_desc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_plug_query_strip_html=> ''Y'',');
   p('      p_comment=>'''');');
   cnum := 0;
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''CHECK$01'',');
   p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
   p('      p_column_heading=> ''&nbsp;'',');
   p('      p_column_alignment=>''LEFT'',');
   p('      p_heading_alignment=>''CENTER'',');
   p('      p_disable_sort_column=>''Y'',');
   p('      p_sum_column=> ''N'',');
   p('      p_hidden_column=> ''N'',');
   p('      p_display_as=>''CHECKBOX'',');
   p('      p_is_required=> false,');
   p('      p_pk_col_source=> null,');
   p('      p_derived_column=> ''Y'',');
   p('      p_column_comment=>''Action Checkbox'');');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''ID'',');
   p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
   p('      p_column_heading=> ''ID'',');
   p('      p_column_alignment=>''LEFT'',');
   p('      p_heading_alignment=>''LEFT'',');
   p('      p_default_sort_column_sequence=>0,');
   p('      p_disable_sort_column=>''N'',');
   p('      p_sum_column=> ''N'',');
   p('      p_hidden_column=> ''Y'',');
   p('      p_display_as=>''HIDDEN'',');
   p('      p_column_width=> ''12'',');
   p('      p_is_required=> false,');
   p('      p_pk_col_source_type=> ''T'',');
   p('      p_pk_col_source=> null,');
   p('      p_include_in_export=> ''Y'',');
   p('      p_ref_schema=> sch_name,');
   p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
   p('      p_ref_column_name=> ''ID'',');
   p('      p_column_comment=>''Surrogate Primary Key'');');
   p('');
   p('   wwv_flow_api.create_region_rpt_cols (');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_plug_id=> ract_id,');
   p('      p_column_sequence=> ' || (cnum - 1) || ',');
   p('      p_query_column_name=> ''ID'',');
   p('      p_display_as=> ''TEXT'',');
   p('      p_column_comment=> '''');');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''ID_DISPLAY'',');
   p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
   p('      p_column_heading=> ''ID'',');
   p('      p_column_alignment=>''LEFT'',');
   p('      p_heading_alignment=>''LEFT'',');
   p('      p_default_sort_column_sequence=>0,');
   p('      p_disable_sort_column=>''N'',');
   p('      p_sum_column=> ''N'',');
   p('      p_hidden_column=> ''N'',');
   p('      p_display_as=>''ESCAPE_SC'',');
   p('      p_column_width=> ''12'',');
   p('      p_is_required=> false,');
   p('      p_pk_col_source=> null,');
   p('      p_include_in_export=> ''Y'',');
   p('      p_ref_schema=> sch_name,');
   p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
   p('      p_ref_column_name=> ''ID_DISPLAY'',');
   p('      p_column_comment=>''Surrogate Primary Key'');');
   p('');
   p('   wwv_flow_api.create_region_rpt_cols (');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_plug_id=> ract_id,');
   p('      p_column_sequence=> ' || (cnum - 1) || ',');
   p('      p_query_column_name=> ''ID_DISPLAY'',');
   p('      p_display_as=> ''TEXT'',');
   p('      p_column_comment=> '''');');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_report_columns (');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_region_id=> ract_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_query_column_id=> ' || cnum || ',');
   p('      p_form_element_id=> null,');
   p('      p_column_alias=> ''EDIT_RECORD_LINK_COLUMN_NAME'',');
   p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
   p('      p_column_heading=> ''Form Link'',');
   p('      p_column_link=>''javascript:apex.submit({request:''''GOTO_FORM'''', set:{''''P'' ||');
   p('         (' || (pnum1 + tbuff.seq) || ' + page_os) || ''_FORM_ID'''':#ID#}});'',');
   p('      p_column_linktext=>''<img src="#IMAGE_PREFIX#ed-item.gif" alt="Save Changes and Edit Record #ID#">'',');
   p('      p_column_link_attr=>''title="Save Changes and Edit Record #ID#"'',');
   p('      p_column_alignment=>''LEFT'',');
   p('      p_heading_alignment=>''CENTER'',');
   p('      p_default_sort_column_sequence=>0,');
   p('      p_disable_sort_column=>''Y'',');
   p('      p_sum_column=> ''N'',');
   p('      p_hidden_column=> ''N'',');
   p('      p_display_as=>''ESCAPE_SC'',');
   p('      p_lov_show_nulls=> ''NO'',');
   p('      p_is_required=> false,');
   p('      p_pk_col_source=> '''',');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_include_in_export=> ''Y'',');
   p('      p_column_comment=>'''');');
   p('');
   p('   wwv_flow_api.create_region_rpt_cols (');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_plug_id=> ract_id,');
   p('      p_column_sequence=> ' || (cnum - 1) || ',');
   p('      p_query_column_name=> ''EDIT_RECORD_LINK_COLUMN_NAME'',');
   p('      p_display_as=> ''TEXT'',');
   p('      p_column_comment=> '''');');
   if tbuff.type = 'EFF'
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_report_columns (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_region_id=> ract_id,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_query_column_id=> ' || cnum || ',');
      p('      p_form_element_id=> null,');
      p('      p_column_alias=> ''EFF_BEG_DTM'',');
      p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
      p('      p_column_heading=> ''Eff Beg DTM'',');
      p('      p_column_format=> ''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_column_alignment=>''LEFT'',');
      p('      p_heading_alignment=>''LEFT'',');
      p('      p_default_sort_column_sequence=>0,');
      p('      p_disable_sort_column=>''N'',');
      p('      p_sum_column=> ''N'',');
      p('      p_hidden_column=> ''N'',');
      p('      p_display_as=>''TEXT'',');
      p('      p_column_width=> ''15'',');
      p('      p_cattributes=> ''onfocus=''''this.setAttribute("maxLength","30")'''''',');
      p('      p_is_required=> false,');
      p('      p_pk_col_source=> null,');
      p('      p_column_default=> ''systimestamp'',');
      p('      p_column_default_type=> ''FUNCTION'',');
      p('      p_include_in_export=> ''Y'',');
      p('      p_ref_schema=> sch_name,');
      p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
      p('      p_ref_column_name=> ''EFF_BEG_DTM'',');
      p('      p_column_comment=>''Date/Time Created'');');
      p('');
      p('   wwv_flow_api.create_region_rpt_cols (');
      p('      p_id     => wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_plug_id=> ract_id,');
      p('      p_column_sequence=> ' || (cnum - 1) || ',');
      p('      p_query_column_name=> ''EFF_BEG_DTM'',');
      p('      p_display_as=> ''TEXT'',');
      p('      p_column_comment=> '''');');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      cnum := cnum + 1;
      create_crc;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'id_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;   --5;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_crc;
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'nk_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;   --20;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_crc;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cnum := cnum + 1;
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_nk' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_crc;
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_report_columns (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_region_id=> ract_id,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_query_column_id=> ' || cnum || ',');
      p('      p_form_element_id=> null,');
      p('      p_column_alias=> ''AUD_BEG_USR'',');
      p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
      p('      p_column_heading=> ''Aud Beg Usr'',');
      p('      p_column_alignment=>''LEFT'',');
      p('      p_heading_alignment=>''LEFT'',');
      p('      p_default_sort_column_sequence=>0,');
      p('      p_disable_sort_column=>''N'',');
      p('      p_sum_column=> ''N'',');
      p('      p_hidden_column=> ''N'',');
      p('      p_display_as=>''ESCAPE_SC'',');
      p('      p_column_width=> ''' || usrcl || ''',');
      p('      p_is_required=> false,');
      p('      p_pk_col_source=> null,');
      p('      p_include_in_export=> ''Y'',');
      p('      p_ref_schema=> sch_name,');
      p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
      p('      p_ref_column_name=> ''AUD_BEG_USR'',');
      p('      p_column_comment=>''Created by'');');
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_report_columns (');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_region_id=> ract_id,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_query_column_id=> ' || cnum || ',');
      p('      p_form_element_id=> null,');
      p('      p_column_alias=> ''AUD_BEG_DTM'',');
      p('      p_column_display_sequence=> ' || (cnum * 10) || ',');
      p('      p_column_heading=> ''Aud Beg DTM'',');
      p('      p_column_format=> ''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_column_alignment=>''LEFT'',');
      p('      p_heading_alignment=>''LEFT'',');
      p('      p_default_sort_column_sequence=>0,');
      p('      p_disable_sort_column=>''N'',');
      p('      p_sum_column=> ''N'',');
      p('      p_hidden_column=> ''N'',');
      p('      p_display_as=>''ESCAPE_SC'',');
      p('      p_column_width=> ''15'',');
      p('      p_is_required=> false,');
      p('      p_pk_col_source=> null,');
      p('      p_include_in_export=> ''Y'',');
      p('      p_ref_schema=> sch_name,');
      p('      p_ref_table_name=> ''' || upper(tbuff.name) || '_ACT'',');
      p('      p_ref_column_name=> ''AUD_BEG_DTM'',');
      p('      p_column_comment=>''Date/Time Created'');');
   end if;
   pseq := 0;
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => ract_id,');
   p('      p_button_name    => ''CANCEL'',');
   p('      p_button_image   => ''template:'' || bb_tid,');
   p('      p_button_image_alt=> ''Cancel'',');
   p('      p_button_position=> ''REGION_TEMPLATE_CLOSE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ''f?p=&APP_ID.:' || pnum1 || ':&SESSION.::&DEBUG.:::'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => ract_id,');
   p('      p_button_name    => ''MULTI_ROW_DELETE'',');
   p('      p_button_image   => ''template:'' || bb_tid,');
   p('      p_button_image_alt=> ''Delete'',');
   p('      p_button_position=> ''REGION_TEMPLATE_DELETE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ');
   p('       ''javascript:apex.confirm(htmldb_delete_message,''''MULTI_ROW_DELETE'''');'',');
   p('      p_button_execute_validations=>''N'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => subb_id,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => ract_id,');
   p('      p_button_name    => ''SUBMIT'',');
   p('      p_button_image   => ''template:'' || bb_tid,');
   p('      p_button_image_alt=> ''Submit'',');
   p('      p_button_position=> ''REGION_TEMPLATE_CHANGE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> '''',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_required_patch => null);');
   if allow_add_row
   then
      p('');
      pseq := pseq + 1;
      p('   wwv_flow_api.create_page_button(');
      p('      p_id             => wwv_flow_id.next_val,');
      p('      p_flow_id        => wwv_flow.g_flow_id,');
      p('      p_flow_step_id   => pnum,');
      p('      p_button_sequence=> ' || (pseq * 10) || ',');
      p('      p_button_plug_id => ract_id,');
      p('      p_button_name    => ''ADD'',');
      p('      p_button_image   => ''template:'' || bb_tid,');
      p('      p_button_image_alt=> ''Add Row'',');
      p('      p_button_position=> ''BOTTOM'',');
      p('      p_button_alignment=> ''RIGHT'',');
      p('      p_button_redirect_url=> ''javascript:addRow();'',');
      p('      p_button_execute_validations=>''Y'',');
      p('      p_required_patch => null);');
   end if;
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => ract_id,');
   p('      p_button_name    => ''CREATE NEW'',');
   p('      p_button_image   => ''template:'' || bb_tid,');
   p('      p_button_image_alt=> ''Cancel and Create New Row with Form'',');
   p('      p_button_position=> ''BOTTOM'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ''f?p=&APP_ID.:'' || (' || (pnum2 + tbuff.seq) ||
             ' + page_os) || '':&SESSION.::&DEBUG.:'' || (' || (pnum2 + tbuff.seq) ||
             ' + page_os),');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=> ''P'' || pnum || ''_FORM_ID'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (pseq * 10) || ',');
   p('      p_item_plug_id => ract_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=> ''P'' || pnum || ''_FORM_ID:'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''NATIVE_HIDDEN'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_is_persistent=> ''Y'',');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_show_quick_picks=> ''N'',');
   p('      p_item_comment => '''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=> ''P'' || pnum || ''_MRU_COUNT'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (pseq * 10) || ',');
   p('      p_item_plug_id => ract_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=> ''Rows Updated:'',');
   p('      p_source=> ''P'' || pnum || ''_MRU_COUNT'',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''Number of records updated in the MULTI_ROW_UPDATE procedure'',');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_attribute_02 => ''VALUE'',');
   p('      p_attribute_04 => ''N'',');
   p('      p_show_quick_picks=> ''N'',');
   p('      p_item_comment => '''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=> ''P'' || pnum || ''_MRI_COUNT'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (pseq * 10) || ',');
   p('      p_item_plug_id => ract_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=> ''Rows Inserted:'',');
   p('      p_source=> ''P'' || pnum || ''_MRI_COUNT'',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''Number of records inserted in the MULTI_ROW_UPDATE procedure'',');
   p('      p_lov_display_extra=> ''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_attribute_02 => ''VALUE'',');
   p('      p_attribute_04 => ''N'',');
   p('      p_show_quick_picks=> ''N'',');
   p('      p_item_comment => '''');');
   p('');
   ---------------------------------------------------------------
                              --  ...Create Filter Criteria'');');
   p('   dbms_output.put_line(''  ...Create Filter Criteria'');');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> fcp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> ''Filter Criteria (Press ENTER in any field to activate filter, cancels all changes))'',');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rrr_tid,');
   p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> null,');
   p('      p_plug_source_type=> ''STATIC_TEXT_ESCAPE_SC'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''QUERY_COLUMNS'',');
   p('      p_plug_query_num_rows => 15,');
   p('      p_plug_query_num_rows_type => ''NEXT_PREVIOUS_LINKS'',');
   p('      p_plug_query_row_count_max => 500,');
   p('      p_plug_query_show_nulls_as => ''-'',');
   p('      p_plug_display_condition_type => '''',');
   p('      p_pagination_display_position=>''BOTTOM_LEFT'',');
   p('      p_plug_customized=>''0'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   cnum := 0;
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_ID_MIN'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || ((cnum * 10) + 100) || ',');
   p('      p_item_plug_id => fcp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>''ID Range from:'',');
   p('      p_format_mask=>'''',');
   p('      p_source=> ''P'' || pnum || ''_ID_MIN'',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
   p('      p_cSize=> ''12'',');    -- ' || trunc(39*0.8) || '
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''Search range for ID. "From" and "To" Numbers will be included in range.'',');
   p('      p_attribute_01 => ''Y'',');
   p('      p_attribute_02 => ''N'',');
   p('      p_item_comment => '''');');
   p('');
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_ID_MAX'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || ((cnum * 10) + 105) || ',');
   p('      p_item_plug_id => fcp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>''to:'',');
   p('      p_format_mask=>'''',');
   p('      p_source=> ''P'' || pnum || ''_ID_MAX'',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
   p('      p_cSize=> ''12'',');    -- ' || trunc(39*0.8) || '
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''Search range for ID. "From" and "To" Numbers will be included in range.'',');
   p('      p_attribute_01 => ''Y'',');
   p('      p_attribute_02 => ''N'',');
   p('      p_item_comment => '''');');
   if tbuff.type = 'EFF'
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_EFF_BEG_DTM_MIN'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 100) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''EFF_BEG_DTM Range from:'',');
      p('      p_format_mask=>''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_source=> ''P'' || pnum || ''_EFF_BEG_DTM_MIN'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
      p('      p_cSize=> 15,');   -- ' || trunc(37*0.8) || '
      p('      p_cMaxlength=> 50,');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Search range for EFF_BEG_DTM. "From" and "To" Dates may not be included in range.'',');
      p('      p_attribute_01 => ''Y'',');
      p('      p_attribute_02 => ''N'',');
      p('      p_item_comment => '''');');
      p('');
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_EFF_BEG_DTM_MAX'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 105) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''to:'',');
      p('      p_format_mask=>''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_source=> ''P'' || pnum || ''_EFF_BEG_DTM_MAX'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
      p('      p_cSize=> 15,');   -- ' || trunc(37*0.8) || '
      p('      p_cMaxlength=> 50,');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''NO'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Search range for EFF_BEG_DTM. "From" and "To" Dates may not be included in range.'',');
      p('      p_attribute_01 => ''Y'',');
      p('      p_attribute_02 => ''N'',');
      p('      p_item_comment => '''');');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      cnum := cnum + 1;
      create_search_crc;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'id_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;   --5;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_search_crc('');
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'nk_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;   --20;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_search_crc('');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cnum := cnum + 1;
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_nk' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_search_crc('');
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_AUD_BEG_USR'',');
      p('      p_data_type=> ''VARCHAR'',');     -- usrdt
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 100) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''AUD_BEG_USR Search:'',');
      p('      p_format_mask=>'''',');
      p('      p_source=> ''P'' || pnum || ''_AUD_BEG_USR'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
      p('      p_cSize=> ' || usrcl/2 || ',');
      p('      p_cMaxlength=> ' || usrcl || ',');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 3,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Search string for AUD_BEG_USR. Use "%" to wildcard one or more letters. Use "_" to wildcard only 1 letter.'',');
      p('      p_attribute_01 => ''Y'',');
      p('      p_attribute_02 => ''N'',');
      p('      p_item_comment => '''');');
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_AUD_BEG_DTM_MIN'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 100) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''EFF_BEG_DTM Range from:'',');
      p('      p_format_mask=>''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_source=> ''P'' || pnum || ''_AUD_BEG_DTM_MIN'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
      p('      p_cSize=> 15,');   -- ' || trunc(37*0.8) || '
      p('      p_cMaxlength=> 50,');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Search range for AUD_BEG_DTM. "From" and "To" Dates may not be included in range.'',');
      p('      p_attribute_01 => ''Y'',');
      p('      p_attribute_02 => ''N'',');
      p('      p_item_comment => '''');');
      p('');
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=> wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_AUD_BEG_DTM_MAX'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 105) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''to:'',');
      p('      p_format_mask=>''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_source=> ''P'' || pnum || ''_AUD_BEG_DTM_MAX'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_TEXT_FIELD'',');
      p('      p_cSize=> 15,');   -- ' || trunc(37*0.8) || '
      p('      p_cMaxlength=> 50,');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''NO'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Search range for AUD_BEG_DTM. "From" and "To" Dates may not be included in range.'',');
      p('      p_attribute_01 => ''Y'',');
      p('      p_attribute_02 => ''N'',');
      p('      p_item_comment => '''');');
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=>wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P''||pnum||''_SHOW_HIST'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || ((cnum * 10) + 100) || ',');
      p('      p_item_plug_id => fcp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default=> ''HIDE_HISTORY'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''(CANCELS pending changes)'',');
      p('      p_source=>''P''||pnum||''_SHOW_HIST'',');
      p('      p_source_type=> ''ITEM'',');
      p('      p_display_as=> ''NATIVE_SELECT_LIST'',');
      p('      p_lov=> ''STATIC:HIDE_HISTORY,SHOW_HISTORY'',');
      p('      p_lov_display_null=> ''NO'',');
      p('      p_lov_translated=> ''N'',');
      p('      p_cSize=> 30,');
      p('      p_cMaxlength=> 50,');
      p('      p_cHeight=> 1,');
      p('      p_cAttributes=> ''nowrap="nowrap"'',');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''LEFT'',');
      p('      p_field_alignment=> ''LEFT'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_help_text=> ''Show the history reports below. Changing this selection will immediately discard all changed pending on this form.'',');
      p('      p_lov_display_extra=>''NO'',');
      p('      p_protection_level => ''N'',');
      p('      p_escape_on_http_output => ''Y'',');
      p('      p_attribute_01 => ''REDIRECT_SET_VALUE'',');
      p('      p_show_quick_picks=>''N'',');
      p('      p_item_comment => '''');');
   end if;
   p('');
   p('   ---------------------------------------');
   p('   --   MISSING PAGE VALIDATION   --');
   p('   ---------------------------------------');
   p('');
   pseq := 0;
                              --  ...Create Page Processing'');');
   p('   dbms_output.put_line(''  ...Create Page Processing'');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_computation(');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_flow_step_id=> pnum,');
   p('     p_computation_sequence => ' || (pseq * 10) || ',');
   p('     p_computation_item=> ''P'' || (' || (pnum2 + tbuff.seq) || ' + page_os) || ''_ID'',');
   p('     p_computation_point=> ''AFTER_SUBMIT'',');
   p('     p_computation_type=> ''ITEM_VALUE'',');
   p('     p_computation_processed=> ''REPLACE_EXISTING'',');
   p('     p_computation=> ''P'' || pnum || ''_FORM_ID'',');
   p('     p_compute_when => ''GOTO_FORM'',');
   p('     p_compute_when_type=>''REQUEST_EQUALS_CONDITION'');');
   p('');
   pseq := pseq + 1;
   pr('   s := '':P'' || pnum || ''_MRU_COUNT := null;'' ');
   p('        '':P'' || pnum || ''_MRI_COUNT := null;'';');
   p('');
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''ON_SUBMIT_BEFORE_COMPUTATION'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''CLR_COUNTS'',');
   p('      p_process_sql_clob => s,');
   p('      p_process_error_message=> ''CLR_COUNTS: Unable to clear counts.'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   --  Create the PL/SQL for the Mult-Row Update Process
   pr('  s := ''declare'' ');
   --  Create the needed exceptions
   for buff in (
      select * from table(exception_lines) t1
       where t1.value like '%gen_no_change%' )
   loop
      pr('       ''' || buff.value || ''' ');
   end loop;
   --  Setup Variables
   pr('       ''   MRI_COUNT  number := 0;'' ');
   pr('       ''   MRU_COUNT  number := 0;'' ');
   pr('       ''   rows       number;'' ');
   pr('       ''begin'' ');
   pr('       ''   glob.get_ignore_no_change := FALSE;'' ');
   pr('       ''   for i in 1 .. apex_application.g_f02.count'' ');
   pr('       ''   loop'' ');
   --  Create the update statement
   pr('       ''      rows := 0;'' ');
   pr('       ''      if apex_application.g_f02(i) is not null'' ');
   pr('       ''      then'' ');
   pr('       ''         begin'' ');
   pr('       ''            update #OWNER#.' || tbuff.name || '_act'' ');
   cnum := 2;
   --  Setup the effectivity column
   if tbuff.type = 'EFF'
   then
      cnum := cnum + 1;
      pr('       ''              set  eff_beg_dtm = '' ');
      pr('       ''                      to_timestamp(apex_application.g_f' ||
                                              trim(to_char(cnum,'09')) || '(i)'' ');
      pr('       ''                             ,''''DD-MON-YYYY HH24:MI:SS.FF9'''')'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq)
   loop
      cnum := cnum + 1;
      if cnum = 3
      then
         pr('       ''              set  ' || buff.name || ' = '' ');
      else
         pr('       ''                  ,' || buff.name || ' = '' ');
      end if;
      if buff.type like 'DAT%' or
         buff.type like 'TIMESTAMP WITH%'
      then
         if buff.type like 'DAT%'
         then
            pr('       ''                      to_date(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
         elsif buff.type = 'TIMESTAMP WITH TIME ZONE'
         then
            pr('       ''                      to_timestamp_tz(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
         else
            pr('       ''                      to_timestamp(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
         end if;
         pr('       ''                             ,''''' || get_colformat(buff) || ''''')'' ');
      else
         pr('       ''                      apex_application.g_f' ||
                                         trim(to_char(cnum,'09')) ||
                                                          '(i)'' ');
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cnum := cnum + 1;
            pr('       ''                  ,' || buff.fk_prefix || 'id_path = '' ');
            pr('       ''                      apex_application.g_f' ||
                                            trim(to_char(cnum,'09')) ||
                                                          '(i)'' ');
            cnum := cnum + 1;
            pr('       ''                  ,' || buff.fk_prefix || 'nk_path = '' ');
            pr('       ''                      apex_application.g_f' ||
                                            trim(to_char(cnum,'09')) ||
                                                             '(i)'' ');
         end if;
         --  Setup the Foreign Key columns
         for j in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cnum := cnum + 1;
            pr('       ''                  ,' || buff.fk_prefix ||
                                  get_tabname(buff.fk_table_id) ||
                                          '_nk' || j || ' = '' ');
            pr('       ''                      apex_application.g_f' ||
                                            trim(to_char(cnum,'09')) ||
                                                             '(i)'' ');
         end loop;
      end if;
   end loop;
   pr('       ''             where id = apex_application.g_f02(i);'' ');
   pr('       ''            rows := SQL%ROWCOUNT;'' ');
   pr('       ''         exception'' ');
   pr('       ''            when gen_no_change'' ');
   pr('       ''            then'' ');
   pr('       ''               -- A matching record was found, but the data'' ');
   pr('       ''               -- in the record is the same as the new data'' ');
   pr('       ''               goto NEXT_ITERATION;'' ');
   pr('       ''            when others'' ');
   pr('       ''            then'' ');
   pr('       ''               raise;'' ');
   pr('       ''         end;'' ');
   pr('       ''      end if;'' ');
   pr('       ''      if rows = 0'' ');
   pr('       ''      then'' ');
   -- Create the insert statement to run if the update didn't update anything
   pr('       ''         insert into #OWNER#.' || tbuff.name || '_act'' ');
   pr('       ''               (id'' ');
   if tbuff.type = 'EFF'
   then
      pr('       ''               ,eff_beg_dtm'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('       ''               ,' || buff.name || ''' ');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('       ''               ,' || buff.fk_prefix || 'id_path'' ');
            pr('       ''               ,' || buff.fk_prefix || 'nk_path'' ');
         end if;
         for j in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('       ''               ,' || buff.fk_prefix ||
                               get_tabname(buff.fk_table_id) ||
                                             '_nk' || j || ''' ');
         end loop;
      end if;
   end loop;
   pr('       ''               )'' ');
   pr('       ''         values '' ');
   pr('       ''               (apex_application.g_f02(i)'' ');
   cnum := 2;
   if tbuff.type = 'EFF'
   then
      cnum := cnum + 1;
      pr('       ''               ,to_timestamp(apex_application.g_f' ||
                                        trim(to_char(cnum,'09')) || '(i)'' ');
      pr('       ''                       ,''''DD-MON-YYYY HH24:MI:SS.FF9'''')'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cnum := cnum + 1;
      if buff.type like 'DAT%' or
         buff.type like 'TIMESTAMP WITH%'
      then
         if buff.type like 'DAT%'
         then
            pr('       ''               ,to_date(apex_application.g_f' ||
                                              trim(to_char(cnum,'09')) || '(i)'' ');
         elsif buff.type = 'TIMEZONE WITH TIME STAMP'
         then
            pr('       ''               ,to_timestamp_tz(apex_application.g_f' ||
                                              trim(to_char(cnum,'09')) || '(i)'' ');
         else
            pr('       ''               ,to_timestamp(apex_application.g_f' ||
                                              trim(to_char(cnum,'09')) || '(i)'' ');
         end if;
         pr('       ''                       ,''''' || get_colformat(buff) || ''''')'' ');
      else
         pr('       ''               ,apex_application.g_f' ||
                                      trim(to_char(cnum,'09')) || '(i)'' ');
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cnum := cnum + 1;
            -- id_path
            pr('       ''               ,apex_application.g_f' ||
                                         trim(to_char(cnum,'09')) || '(i)'' ');
            cnum := cnum + 1;
            -- nk_path
            pr('       ''               ,apex_application.g_f' ||
                                         trim(to_char(cnum,'09')) || '(i)'' ');
         end if;
         for j in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cnum := cnum + 1;
            if nk_aa(buff.fk_table_id).cbuff_va(j).type like 'DAT%' or
               nk_aa(buff.fk_table_id).cbuff_va(j).type like 'TIMESTAMP WITH%'
            then
               if nk_aa(buff.fk_table_id).cbuff_va(j).type like 'DAT%'
               then
                  pr('       ''               ,to_date(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
               elsif nk_aa(buff.fk_table_id).cbuff_va(j).type = 'TIMESTAMP WITH TIME ZONE'
               then
                  pr('       ''               ,to_timestamp_tz(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
               else
                  pr('       ''               ,to_timestamp(apex_application.g_f' ||
                                                    trim(to_char(cnum,'09')) || '(i)'' ');
               end if;
               pr('       ''                       ,''''' || get_colformat(nk_aa(buff.fk_table_id).cbuff_va(j)) || ''''')'' ');
            else
               pr('       ''               ,apex_application.g_f' ||
                                            trim(to_char(cnum,'09')) || '(i)'' ');
            end if;
         end loop;
      end if;
   end loop;
   pr('       ''               );'' ');
   pr('       ''         MRI_COUNT := MRI_COUNT + 1;'' ');
   pr('       ''      elsif rows = 1'' ');
   pr('       ''      then'' ');
   pr('       ''         MRU_COUNT := MRU_COUNT + 1;'' ');
   pr('       ''      else'' ');
   pr('       ''         raise_application_error(-20013, ''''GEN_MRU updated '''' ||'' ');
   pr('       ''                                 rows || '''' rows for ID '''' ||'' ');
   pr('       ''                                 apex_application.g_f02(i));'' ');
   pr('       ''      end if;'' ');
   pr('       ''      <<NEXT_ITERATION>>  -- not allowed unless an executable statement follows'' ');
   pr('       ''      NULL;               -- add NULL statement to avoid error'' ');
   pr('       ''   end loop;'' ');
   pr('       ''   if MRI_COUNT > 0 or MRU_COUNT > 0'' ');
   pr('       ''   then'' ');
   pr('       ''      :P'' || pnum || ''_MRI_COUNT := MRI_COUNT;'' ');
   pr('       ''      :P'' || pnum || ''_MRU_COUNT := MRU_COUNT;'' ');
   pr('       ''   end if;'' ');
   pr('       ''exception when others then util.err(:APP_ID||''''P''''||:APP_PAGE_ID||'''':GEN_MRU: ''''||sqlerrm); raise;'' ');
   p('       ''end;'';');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''GEN_MRU of ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_sql_clob => s, ');
   p('      p_process_error_message=> ''GEN_MRU: Unable to Process Update/Insert.'',');
   --p('      p_process_when_button_id=>subb_id,');
   p('      p_process_when=>''(''''GOTO_FORM'''', ''''SUBMIT'''')'',');
   p('      p_process_when_type=>''REQUEST_IN_CONDITION'',');
   --
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''MULTI_ROW_DELETE'',');
   p('      p_process_name=> ''Apply MRD'',');
   p('      p_process_sql_clob => ''#OWNER#:' || upper(tbuff.name) || '_ACT:ID'', ');
   p('      p_process_error_message=> ''Apply_MRD: Unable to process delete.'',');
   p('      p_process_when=>''MULTI_ROW_DELETE'',');
   p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
   p('      p_process_success_message=> ''#MRD_COUNT# row(s) deleted.'',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      pseq := pseq + 1;
      p('   wwv_flow_api.create_page_process(');
      p('      p_id     => wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id => pnum,');
      p('      p_process_sequence=> ' || (pseq * 10) || ',');
      p('      p_process_point=> ''AFTER_SUBMIT'',');
      p('      p_process_type=> ''PLSQL'',');
      p('      p_process_name=> ''GEN_POP of ' || upper(tbuff.name) || '_ACT'',');
      p('      p_process_sql_clob => ''#OWNER#.' || tbuff.name || '_dml.pop(:P''||pnum||''_POP_ID);'', ');
      p('      p_process_error_message=> ''POP: Unable to pop ' || tbuff.name || '.'',');
      p('      p_process_when_button_id=> null,');
      p('      p_process_when=>''POP_REQUEST'',');
      p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
      p('      p_process_success_message=> '''',');
      p('      p_process_is_stateful_y_n=> ''N'',');
      p('      p_process_comment=>'''');');
   end if;
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''RESET_PAGINATION'',');
   p('      p_process_name=> ''Reset Pagination'',');
   p('      p_process_sql_clob => ''reset_pagination'', ');
   p('      p_process_error_message=> ''Reset Pagination: Unable to repaginate.'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ''f?p=&APP_ID.:''||(' ||
            (pnum2 + tbuff.seq) ||
            '+page_os)||'':&SESSION.::&DEBUG.&success_msg=#SUCCESS_MSG#'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> ' || (pseq * 10) || ',');
   p('      p_branch_condition_type=> ''REQUEST_EQUALS_CONDITION'',');
   p('      p_branch_condition=> ''GOTO_FORM'',');
   p('      p_save_state_before_branch_yn=>''N'',');
   p('      p_branch_comment=> '''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ');
   p('       ''f?p=&APP_ID.:''||pnum||'':&SESSION.&success_msg=#SUCCESS_MSG#'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> ' || (pseq * 10) || ',');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   p('');
   p('   if ts_name is not null');
   p('   then');
   p('      select count(tab_id)');
   p('       into  tab_cnt');
   p('       from  apex_application_tabs');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  tab_set          = ts_name');
   p('        and  tab_name         = pname;');
   p('      if tab_cnt = 0');
   p('      then');
   p('         dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('         wwv_flow_api.create_tab (');
   p('            p_id=> wwv_flow_id.next_val,');
   p('            p_flow_id=> wwv_flow.g_flow_id,');
   p('            p_tab_set=> ts_name,');
   p('            p_tab_sequence=> pnum,');
   p('            p_tab_name => pname,');
   p('            p_tab_text=> pname,');
   p('            p_tab_step => pnum,');
   p('            p_tab_also_current_for_pages => '''',');
   p('            p_tab_parent_tabset=>'''',');
   p('            p_tab_comment  => '''');');
   p('      end if;');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
   p('');
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- Abort the rest of this procedure
      return;
   end if;
   p('-----------------------------------------------------------------------');
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('');
   p('   -- Page Export Variables');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Report Type) Report Region Template ID');
   p('   rsarc_tid  number;          -- (Report Type) Standard, Alternating Row');
   p('                               --                      Colors Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   allp_id    number;          -- ALL View Plug ID');
   p('   irws_id   number;           -- Interactive Report Worksheet ID');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   rhist_id   number;          -- (Report Region) HIST View ID');
   p('   rpop_id    number;          -- (Report Region) POP_AUDIT ID');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('');
   p('   if sch_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: sch_name is null.'');');
   p('   end if;');
   p('   if ws_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_id is null.'');');
   p('   end if;');
   p('   if ws_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_name is null.'');');
   p('   end if;');
   p('   if app_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_id is null.'');');
   p('   end if;');
   p('   if app_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_name is null.'');');
   p('   end if;');
   p('');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rsarc_tid := get_template_id(''Report'',''Standard, Alternating Row Colors'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional%with Help'');');
   p('');
   p('   dbms_output.put_line(''' || tbuff.name || ' maint2, ' || tbuff.seq || ''');');
   p('   pnum     := ' || (pnum1 + tbuff.seq) || ' + page_os;');
   p('   pname    := ''' || initcap(replace(tbuff.name,'_',' ')) || ' Maint'';');
   p('   allp_id  := wwv_flow_id.next_val;');
   p('   irws_id  := wwv_flow_id.next_val;');
   p('   rhist_id := wwv_flow_id.next_val;');
   p('   rpop_id  := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   ----------------------------------------------------------
                              --  ...Create ALL Report'');');
   p('   dbms_output.put_line(''  ...Create ALL Report'');');
   pr('   s := ''select ID'' ');
   pr('              '',STAT'' ');
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if is_bigtext(buff)
      then
         pr('              '',''''<span style="display:block;' ||
            ' width:400px; white-space:normal">'''' || '' ');
         pr('              ''  cast (substr(' || upper(buff.name) ||
            ',1,200) as varchar2(200)) || '' ');
         pr('              ''  ''''</span>'''' ' || upper(buff.name) || ''' ');
      else
         pr('              '',' || upper(buff.name) || ''' ');
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('              '',' || upper(buff.fk_prefix) || 'ID_PATH'' ');
            pr('              '',' || upper(buff.fk_prefix) || 'NK_PATH'' ');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('              '',' || upper(buff.fk_prefix) ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_NK' || i || '''');
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',AUD_END_USR'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',AUD_END_DTM'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || '_ALL'' ');
   pr('        ''where (   (    :P'' || pnum || ''_ID_MIN is null'' ');
   pr('        ''           and :P'' || pnum || ''_ID_MAX is null'' ');
   pr('        ''          )'' ');
   pr('        ''       or (    id between nvl(:P'' || pnum || ''_ID_MIN,-1E125)'' ');
   pr('        ''                      and nvl(:P'' || pnum || ''_ID_MAX, 1E125)'' ');
   pr('        ''          )   )'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      create_search_where;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'id_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;   --5;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_search_where;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'nk_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;   --20;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_search_where;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_nk' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_search_where;
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('        '' and (   (    :P'' || pnum || ''_EFF_BEG_DTM_MIN is null'' ');
      pr('        ''          and :P'' || pnum || ''_EFF_BEG_DTM_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''      or (eff_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MIN,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
      pr('        ''                          and nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MAX,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
      pr('        ''          )   )'' ');
   end if;
   pr('        '' and (   :P'' || pnum || ''_AUD_BEG_USR is null'' ');
   pr('        ''      or aud_beg_usr like :P'' || pnum || ''_AUD_BEG_USR'' ');
                              -- NOTE: "Like" works with numbers and strings
   pr('        ''      )'' ');
   pr('        '' and (   (    :P'' || pnum || ''_AUD_BEG_DTM_MIN is null'' ');
   pr('        ''          and :P'' || pnum || ''_AUD_BEG_DTM_MAX is null'' ');
   pr('        ''          )'' ');
   pr('        ''      or (   aud_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MIN,'' ');
   pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
   pr('        ''                             and nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MAX,'' ');
   pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
   p('        ''          )   )'';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> allp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> ''All ' || initcap(replace(tbuff.name,'_',' ')) || ''',');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rrr_tid,');
   p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> s,');
   p('      p_plug_source_type=> ''DYNAMIC_QUERY'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_plug_query_show_nulls_as => ''-'',');
   p('      p_plug_display_condition_type => ''VAL_OF_ITEM_IN_COND_EQ_COND2'',');
   p('      p_plug_display_when_condition => ''P''||pnum||''_SHOW_HIST'',');
   p('      p_plug_display_when_cond2=>''SHOW_HISTORY'',');
   p('      p_pagination_display_position=>''BOTTOM_LEFT'',');
   p('      p_plug_customized=>''0'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_worksheet(');
   p('      p_id=> irws_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_region_id=> allp_id,');
   p('      p_name=> ''All ' || initcap(replace(tbuff.name,'_',' ')) || ''',');
   p('      p_folder_id=> null, ');
   p('      p_alias=> '''',');
   p('      p_report_id_item=> '''',');
   p('      p_max_row_count=> ''10000'',');
   p('      p_max_row_count_message=> ''This query returns more than #MAX_ROW_COUNT# rows, please filter your data to ensure complete results.'',');
   p('      p_no_data_found_message=> ''No data found.'',');
   p('      p_max_rows_per_page=>'''',');
   p('      p_search_button_label=>'''',');
   p('      p_page_items_to_submit=>'''',');
   p('      p_sort_asc_image=>'''',');
   p('      p_sort_asc_image_attr=>'''',');
   p('      p_sort_desc_image=>'''',');
   p('      p_sort_desc_image_attr=>'''',');
   p('      p_sql_query => s,');
   p('      p_status=>''AVAILABLE_FOR_OWNER'',');
   p('      p_allow_report_saving=>''Y'',');
   p('      p_allow_save_rpt_public=>''N'',');
   p('      p_allow_report_categories=>''N'',');
   p('      p_show_nulls_as=>''-'',');
   p('      p_pagination_type=>''ROWS_X_TO_Y'',');
   p('      p_pagination_display_pos=>''BOTTOM_LEFT'',');
   p('      p_show_finder_drop_down=>''Y'',');
   p('      p_show_display_row_count=>''N'',');
   p('      p_show_search_bar=>''Y'',');
   p('      p_show_search_textbox=>''Y'',');
   p('      p_show_actions_menu=>''Y'',');
   p('      p_report_list_mode=>''TABS'',');
   p('      p_show_detail_link=>''C'',');
   p('      p_show_select_columns=>''Y'',');
   p('      p_show_rows_per_page=>''Y'',');
   p('      p_show_filter=>''Y'',');
   p('      p_show_sort=>''Y'',');
   p('      p_show_control_break=>''Y'',');
   p('      p_show_highlight=>''Y'',');
   p('      p_show_computation=>''Y'',');
   p('      p_show_aggregate=>''Y'',');
   p('      p_show_chart=>''Y'',');
   p('      p_show_group_by=>''Y'',');
   p('      p_show_notify=>''N'',');
   p('      p_show_calendar=>''N'',');
   p('      p_show_flashback=>''Y'',');
   p('      p_show_reset=>''Y'',');
   p('      p_show_download=>''Y'',');
   p('      p_show_help=>''Y'',');
   p('      p_download_formats=>''CSV:HTML:EMAIL'',');
   p('      p_detail_link=>''f?p=&APP_ID.:''||pnum||'':&SESSION.::&DEBUG.:RP:''||');
   p('                     ''P''||pnum||''_POP_ID,P''||pnum||''_POP_STAT:''||');
   p('                     ''#ID#,#STAT#'',');
   p('      p_detail_link_text=>''<img src="#IMAGE_PREFIX#menu/pt_boxes_20.png" alt="">'',');
   p('      p_allow_exclude_null_values=>''N'',');
   p('      p_allow_hide_extra_columns=>''N'',');
   p('      p_icon_view_enabled_yn=>''N'',');
   p('      p_icon_view_columns_per_row=>1,');
   p('      p_detail_view_enabled_yn=>''N'',');
   p('      p_owner=>ws_name);');
   p('');
   p('');
   cnum       := 1;
   cbuff      := cbuf0;
   cbuff.name := 'id';
   cbuff.type := 'NUMBER';
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'stat';
   cbuff.type := 'VARCHAR2';
   cbuff.len  := 3;
   create_ws_col;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('');
      cbuff    := buff;
      cnum     := cnum + 1;
      create_ws_col;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'ID_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 1000;   --5;
            create_ws_col;
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'NK_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 4000;   --20;
            create_ws_col;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('');
            cbuff      := nk_aa(buff.fk_table_id).cbuff_va(i);
            cnum       := cnum + 1;
            cbuff.name := upper(buff.fk_prefix) ||
                    get_tabname(buff.fk_table_id) ||
                         '_NK' || i;
            cbuff.nk   := null;
            create_ws_col;
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_beg_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_end_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
   end if;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   p('');
   p('   wwv_flow_api.create_worksheet_rpt(');
   p('      p_id => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id => irws_id,');
   p('      p_session_id  => null,');
   p('      p_base_report_id  => null,');
   p('      p_application_user => ''APXWS_DEFAULT'',');
   p('      p_report_seq              =>10,');
   p('      p_report_alias            =>''All ' || initcap(replace(tbuff.name,'_',' ')) || ' Default'',');
   p('      p_status                  =>''PUBLIC'',');
   p('      p_category_id             =>null,');
   p('      p_is_default              =>''Y'',');
   p('      p_display_rows            =>15,');
   if tbuff.type = 'EFF'
   then
      p('      p_report_columns          =>''ID:STAT:' || upper(get_collist(tbuff.id,':')) ||
               ':EFF_BEG_DTM:EFF_END_DTM:AUD_BEG_USR:AUD_END_USR:AUD_BEG_DTM:AUD_END_DTM'',');
   elsif tbuff.type = 'LOG'
   then
      p('      p_report_columns          =>''ID:STAT:' || upper(get_collist(tbuff.id,':')) ||
               ':AUD_BEG_USR:AUD_END_USR:AUD_BEG_DTM:AUD_END_DTM'',');
   else
      p('      p_report_columns          =>''ID:STAT:' || upper(get_collist(tbuff.id,':')) ||
               ''',');
   end if;
   p('      p_flashback_enabled       =>''N'',');
   p('      p_calendar_display_column =>'''');');
   --------------------------------------------------------------
   p('');
                              --  ...Create History Report'');');
   p('   dbms_output.put_line(''  ...Create History Report'');');
   pr('   s := ''select ' || upper(tbuff.name) || '_ID'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',AUD_END_DTM'' ');
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('              '',' || upper(buff.name) || ''' ');
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',AUD_END_USR'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || HOA || ''' ');
   p('        ''where ' || tbuff.name || '_id = :P'' || pnum || ''_POP_ID'';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_report_region (');
   p('      p_id=> rhist_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_name=> ''' || initcap(replace(tbuff.name,'_',' ')) || ' History'',');
   p('      p_region_name=>'''',');
   p('      p_template=> rrr_tid,');
   p('      p_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_display_column=> 1,');
   p('      p_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_source=> s,');
   p('      p_source_type=> ''SQL_QUERY'',');
   p('      p_display_error_message=> ''#SQLERRM#'',');
   p('      p_display_when_condition=> ''P'' || pnum || ''_SHOW_HIST'',');
   p('      p_display_when_cond2=> ''SHOW_HISTORY'',');
   p('      p_display_condition_type=> ''VAL_OF_ITEM_IN_COND_EQ_COND2'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_customized=> ''0'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_ajax_enabled=> ''Y'',');
   p('      p_query_row_template=> rsarc_tid,');
   p('      p_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_query_options=> ''DERIVED_REPORT_COLUMNS'',');
   p('      p_query_show_nulls_as=> ''-'',');
   p('      p_query_break_cols=> ''0'',');
   p('      p_query_no_data_found=> ''no data found'',');
   p('      p_query_num_rows_type=> ''NEXT_PREVIOUS_LINKS'',');
   p('      p_pagination_display_position=> ''BOTTOM_LEFT'',');
   p('      p_csv_output=> ''N'',');
   p('      p_query_asc_image=> ''apex/builder/dup.gif'',');
   p('      p_query_asc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_query_desc_image=> ''apex/builder/ddown.gif'',');
   p('      p_query_desc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_plug_query_strip_html=> ''Y'',');
   p('      p_comment=>'''');');
   p('');
   cnum       := 1;
   cbuff      := cbuf0;
   cbuff.name := upper(tbuff.name) || '_ID';
   cbuff.type := 'NUMBER';
   create_rep_col('rhist_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   select min(COL.nk) into cbuff.nk
    from  tab_cols COL
    where COL.table_id = tbuff.id;
   create_rep_col('rhist_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_rep_col('rhist_id');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('');
      cbuff    := buff;
      cnum     := cnum + 1;
      cbuff.nk := null;
      create_rep_col('rhist_id');
   end loop;
   if tbuff.type = 'EFF'
   then
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_beg_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_rep_col('rhist_id');
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_end_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_rep_col('rhist_id');
   end if;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_rep_col('rhist_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_rep_col('rhist_id');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=>wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P''||pnum||''_POP_ID'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (cnum * 10) || ',');
   p('      p_item_plug_id => rhist_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>'''||initcap(replace(tbuff.name,'_',' '))||' ID:'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 50,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_lov_display_extra=>''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_help_text=> ''The '||initcap(replace(tbuff.name,'_',' '))||' ID that will be "POPPED".'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_attribute_02 => ''VALUE'',');
   p('      p_attribute_04 => ''Y'',');
   p('      p_show_quick_picks=>''N'',');
   p('      p_item_comment => '''');');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P''||pnum||''_POP_BUTTON'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (cnum * 10) || ',');
   p('      p_item_plug_id => rhist_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default=> ''POP_REQUEST'',');
   p('      p_prompt=>''POP '||initcap(replace(tbuff.name,'_',' '))||' ID'',');
   p('      p_source=>''POP_REQUEST'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''BUTTON'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> null,');
   p('      p_cMaxlength=> 2000,');
   p('      p_cHeight=> null,');
   p('      p_tag_attributes  => ''template:''||bb_tid,');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT'',');
   p('      p_display_when=>''return :P''||pnum||''_POP_ID is not null'' ||');
   p('                      '' and :P''||pnum||''_POP_STAT != ''''POP'''';'',');
   p('      p_display_when_type=>''FUNCTION_BODY'',');
   p('      p_is_persistent=> ''N'',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_item_comment => '''');');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_POP_STAT'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (cnum * 10) || ',');
   p('      p_item_plug_id => rhist_id,');
   p('      p_use_cache_before_default=> ''YES'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_source_type=> ''STATIC'',');
   p('      p_display_as=> ''NATIVE_HIDDEN'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> null,');
   p('      p_cMaxlength=> 4000,');
   p('      p_cHeight=> null,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''NO'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''LEFT'',');
   p('      p_field_alignment=> ''LEFT'',');
   p('      p_is_persistent=> ''Y'',');
   p('      p_attribute_01 => ''Y'',');
   p('      p_item_comment => '''');');
   ----------------------------------------------------------------
   p('');
                              --  ...Create POP_AUDIT Report'');');
   p('   dbms_output.put_line(''  ...Create POP_AUDIT Report'');');
   pr('   s := ''select ' || upper(tbuff.name) || '_ID'' ');
   pr('              '',POP_DML'' ');
   pr('              '',POP_DTM'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('              '',' || upper(buff.name) || ''' ');
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',EFF_PREV_BEG_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',AUD_PREV_BEG_USR'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',AUD_PREV_BEG_DTM'' ');
   pr('              '',POP_USR'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || '_PDAT'' ');
   p('        ''where ' || upper(tbuff.name) ||
                      '_ID = :P'' || pnum || ''_POP_ID'';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_report_region (');
   p('      p_id=> rpop_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_name=> ''Pop Audit'',');
   p('      p_region_name=>'''',');
   p('      p_template=> rrr_tid,');
   p('      p_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_display_column=> 1,');
   p('      p_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_source=> s,');
   p('      p_source_type=> ''SQL_QUERY'',');
   p('      p_display_error_message=> ''#SQLERRM#'',');
   p('      p_display_when_condition=> ''P''||pnum||''_SHOW_HIST'',');
   p('      p_display_when_cond2=> ''SHOW_HISTORY'',');
   p('      p_display_condition_type=> ''VAL_OF_ITEM_IN_COND_EQ_COND2'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_customized=> ''0'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_ajax_enabled=> ''Y'',');
   p('      p_query_row_template=> rsarc_tid,');
   p('      p_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_query_num_rows=> ''15'',');
   p('      p_query_options=> ''DERIVED_REPORT_COLUMNS'',');
   p('      p_query_show_nulls_as=> ''-'',');
   p('      p_query_break_cols=> ''0'',');
   p('      p_query_no_data_found=> ''no data found'',');
   p('      p_query_num_rows_type=> ''NEXT_PREVIOUS_LINKS'',');
   p('      p_pagination_display_position=> ''BOTTOM_LEFT'',');
   p('      p_csv_output=> ''N'',');
   p('      p_query_asc_image=> ''apex/builder/dup.gif'',');
   p('      p_query_asc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_query_desc_image=> ''apex/builder/ddown.gif'',');
   p('      p_query_desc_image_attr=> ''width="16" height="16" alt="" '',');
   p('      p_plug_query_strip_html=> ''Y'',');
   p('      p_comment=>'''');');
   p('');
   cnum       := 1;
   cbuff      := cbuf0;
   cbuff.name := tbuff.name || '_id';
   cbuff.type := 'NUMBER';
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'pop_dml';
   cbuff.type := 'VARCHAR2';
   cbuff.len  := 6;
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'pop_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   select min(COL.nk) into cbuff.nk
    from  tab_cols COL
    where COL.table_id = tbuff.id;
   create_rep_col('rpop_id');
   --
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('');
      cbuff    := buff;
      cnum     := cnum + 1;
      cbuff.nk := null;
      create_rep_col('rpop_id');
   end loop;
   --
   if tbuff.type = 'EFF'
   then
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_beg_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_rep_col('rpop_id');
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_PREV_BEG_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_rep_col('rpop_id');
   end if;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_PREV_BEG_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_PREV_BEG_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_rep_col('rpop_id');
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'pop_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_rep_col('rpop_id');
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
   -- NOTE: There is a conditional return about mid-way through this procedure
END maint_flow;
----------------------------------------
PROCEDURE form_flow
   -- To convert this from page generation to application generation,
   --   Templates like "wwv_flow_api.create_row_template" must be added
   --   to the export script, to include matching "p_id => 1283510651569179"
   --   references for every usage of the row_template in the export script.
IS
   rseq       number;          -- Region Sequence Number
   pseq       number;          -- Process Sequence Number
   fkfnd      number := 0;     -- Foreign Key Indicator Flag
BEGIN
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('');
   p('   -- Page Export Variables');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   ts_name    varchar2(30);    -- Tab Set Name');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Report Type) Report Region Template ID');
   p('   rsarc_tid  number;          -- (Report Type) Standard, Alternating Row');
   p('                               --                      Colors Template ID');
   p('   rfr_tid    number;          -- (Region Type) Form Region Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   irp_id     number;          -- Interactive Report Plug ID');
   p('   irws_id    number;          -- Interactive Report Worksheet ID');
   p('   subb_id    number;          -- Submit Button ID');
   p('   lov_id     number;          -- List of Values ID');
   p('   item_id    number;          -- Temporary Item ID for Validation');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   tab_cnt    number;          -- Number of Tab IDs found');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('');
   p('   if sch_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: sch_name is null.'');');
   p('   end if;');
   p('   if ws_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_id is null.'');');
   p('   end if;');
   p('   if ws_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_name is null.'');');
   p('   end if;');
   p('   if app_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_id is null.'');');
   p('   end if;');
   p('   if app_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_name is null.'');');
   p('   end if;');
   p('');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rsarc_tid := get_template_id(''Report'',''Standard, Alternating Row Colors'');');
   p('   rfr_tid   := get_template_id(''Region'',''Form Region'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional%with Help'');');
   p('');
   p('   dbms_output.put_line(''' || tbuff.name || ' form, ' || tbuff.seq || ''');');
   p('   pnum     := ' || (pnum2 + tbuff.seq) || ' + page_os;');
   p('   pname    := ''' || initcap(replace(tbuff.name,'_',' ')) || ' Form'';');
   p('   ts_name  := ''' || tbuff.group_name || '_FORM_TS'';');
   p('   irp_id   := wwv_flow_id.next_val;');
   p('   irws_id  := wwv_flow_id.next_val;');
   p('   subb_id  := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_allow_duplicate_submissions => ''Y''');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_first_item => ''AUTO_FIRST_ITEM''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_autocomplete_on_off => ''ON''');
   p('      ,p_javascript_code => ');
   p('       ''var htmldb_delete_message=''''"DELETE_CONFIRM_MSG"'''';''');
   p('      ,p_page_is_public_y_n => ''N''');
   p('      ,p_protection_level => ''N''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_cache_timeout_seconds => 21600');
   p('      ,p_cache_by_user_yn => ''N''');
   p('      ,p_help_text => ''' || replace(tbuff.description,SQ1,SQ2) || '''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   --------------------------------------------------------------
                              --  ...Create DML Form'');');
   p('   dbms_output.put_line(''  ...Create DML Form'');');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> irp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> pname,');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rfr_tid,');
   p('      p_plug_display_sequence=> 10,');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> '''',');
   p('      p_plug_source_type=> ''STATIC_TEXT'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_plug_query_row_count_max => 500,');
   p('      p_plug_display_condition_type => '''',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   p('');
   pseq := 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => irp_id,');
   p('      p_button_name    => ''CANCEL'',');
   p('      p_button_image_alt=> ''Cancel'',');
   p('      p_button_position=> ''RIGHT_OF_TITLE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ''f?p=&APP_ID.:'' || (' || (pnum1 + tbuff.seq) || ' + page_os) || '':&SESSION.::&DEBUG.:::'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => subb_id,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => irp_id,');
   p('      p_button_name    => ''DELETE'',');
   p('      p_button_image_alt=> ''Delete'',');
   p('      p_button_position=> ''RIGHT_OF_TITLE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ');
   p('       ''javascript:apex.confirm(htmldb_delete_message,''''DELETE'''');'',');
   p('      p_button_execute_validations=>''N'',');
   p('      p_button_condition=> ''P'' || pnum || ''_ID'',');
   p('      p_button_condition_type=> ''ITEM_IS_NOT_NULL'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => irp_id,');
   p('      p_button_name    => ''SAVE'',');
   p('      p_button_image_alt=> ''Apply Changes'',');
   p('      p_button_position=> ''RIGHT_OF_TITLE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> '''',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_button_condition=> ''P'' || pnum || ''_ID'',');
   p('      p_button_condition_type=> ''ITEM_IS_NOT_NULL'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => irp_id,');
   p('      p_button_name    => ''CREATE'',');
   p('      p_button_image_alt=> ''Create'',');
   p('      p_button_position=> ''RIGHT_OF_TITLE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> '''',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_button_condition=> ''P'' || pnum || ''_ID'',');
   p('      p_button_condition_type=> ''ITEM_IS_NULL'',');
   p('      p_required_patch => null);');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_button(');
   p('      p_id             => wwv_flow_id.next_val,');
   p('      p_flow_id        => wwv_flow.g_flow_id,');
   p('      p_flow_step_id   => pnum,');
   p('      p_button_sequence=> ' || (pseq * 10) || ',');
   p('      p_button_plug_id => irp_id,');
   p('      p_button_name    => ''CREATE_NEW'',');
   p('      p_button_image_alt=> ''Cancel Changes and Create NEW Record'',');
   p('      p_button_position=> ''RIGHT_OF_TITLE'',');
   p('      p_button_alignment=> ''RIGHT'',');
   p('      p_button_redirect_url=> ''f?p=&APP_ID.:'' || pnum || '':&SESSION.::&DEBUG.:'' || pnum || ''::'',');
   p('      p_button_execute_validations=>''Y'',');
   p('      p_button_condition=> ''P'' || pnum || ''_ID'',');
   p('      p_button_condition_type=> ''ITEM_IS_NOT_NULL'',');
   p('      p_required_patch => null);');
   p('');
   p('   wwv_flow_api.create_page_branch(');
   p('      p_id=> wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_branch_action=> ');
   p('       ''f?p=&APP_ID.:'' || (' || (pnum1 + tbuff.seq) || ' + page_os) || '':&SESSION.&success_msg=#SUCCESS_MSG#'',');
   p('      p_branch_point=> ''AFTER_PROCESSING'',');
   p('      p_branch_type=> ''REDIRECT_URL'',');
   p('      p_branch_sequence=> 10,');
   p('      p_save_state_before_branch_yn=>''Y'',');
   p('      p_branch_comment=> '''');');
   p('');
   pseq := 0;
   cnum := 1;
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=>wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_ID'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> ' || (cnum * 10) || ',');
   p('      p_item_plug_id => irp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>''ID'',');
   p('      p_source=>''ID'',');
   p('      p_source_type=> ''DB_COLUMN'',');
   p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 38,');
   p('      p_cMaxlength=> 45,');
   p('      p_cHeight=> 1,');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''RIGHT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_lov_display_extra=>''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_help_text=> ''Surrogate Key for this record'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_attribute_02 => ''VALUE'',');
   p('      p_attribute_04 => ''Y'',');
   p('      p_show_quick_picks=>''N'',');
   p('      p_item_comment => '''');');
   if tbuff.type = 'EFF'
   then
      cnum := cnum + 1;
      cbuff             := cbuf0;
      cbuff.name        := 'EFF_BEG_DTM';
      cbuff.type        := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len         := 9;
      cbuff.description := 'Beginning Effective Date/Time of this record';
      create_cpi(pseq, '');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cnum := cnum + 1;
      cbuff := buff;
      create_cpi(pseq, '');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'ID_PATH';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_cpi(pseq, '');
            cnum := cnum + 1;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'NK_PATH';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_cpi(pseq, '');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cnum := cnum + 1;
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_NK' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_cpi(pseq, '');
         end loop;
      end if;
   end loop;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=>wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_AUD_BEG_USR'',');
      p('      p_data_type=> ''VARCHAR'',');     -- usrdt
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || (cnum * 10) || ',');
      p('      p_item_plug_id => irp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''Aud Beg Usr:'',');
      p('      p_source=>''AUD_BEG_USR'',');
      p('      p_source_type=> ''DB_COLUMN'',');
      p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
      p('      p_lov_display_null=> ''NO'',');
      p('      p_lov_translated=> ''N'',');
      p('      p_cSize=> ' || usrcl/2 || ',');
      p('      p_cMaxlength=> ' || usrcl || ',');
      p('      p_cHeight=> 1,');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''RIGHT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_lov_display_extra=>''YES'',');
      p('      p_protection_level => ''N'',');
      p('      p_escape_on_http_output => ''Y'',');
      p('      p_help_text=> ''User that created this record'',');
      p('      p_attribute_01 => ''N'',');
      p('      p_attribute_02 => ''VALUE'',');
      p('      p_attribute_04 => ''Y'',');
      p('      p_show_quick_picks=>''N'',');
      p('      p_item_comment => '''');');
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_api.create_page_item(');
      p('      p_id=>wwv_flow_id.next_val,');
      p('      p_flow_id=> wwv_flow.g_flow_id,');
      p('      p_flow_step_id=> pnum,');
      p('      p_name=>''P'' || pnum || ''_AUD_BEG_DTM'',');
      p('      p_data_type=> ''VARCHAR'',');
      p('      p_is_required=> false,');
      p('      p_accept_processing=> ''REPLACE_EXISTING'',');
      p('      p_item_sequence=> ' || (cnum * 10) || ',');
      p('      p_item_plug_id => irp_id,');
      p('      p_use_cache_before_default=> ''NO'',');
      p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
      p('      p_prompt=>''Aud Beg Dtm:'',');
      p('      p_format_mask=>''DD-MON-YYYY HH24:MI:SS.FF9'',');
      p('      p_source=>''AUD_BEG_DTM'',');
      p('      p_source_type=> ''DB_COLUMN'',');
      p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
      p('      p_lov_display_null=> ''NO'',');
      p('      p_lov_translated=> ''N'',');
      p('      p_cSize=> 30,');
      p('      p_cMaxlength=> 30,');
      p('      p_cHeight=> 1,');
      p('      p_begin_on_new_line=> ''YES'',');
      p('      p_begin_on_new_field=> ''YES'',');
      p('      p_colspan=> 1,');
      p('      p_rowspan=> 1,');
      p('      p_label_alignment=> ''RIGHT'',');
      p('      p_field_alignment=> ''LEFT-CENTER'',');
      p('      p_field_template=> ilowh_tid,');
      p('      p_is_persistent=> ''Y'',');
      p('      p_lov_display_extra=>''YES'',');
      p('      p_protection_level => ''N'',');
      p('      p_escape_on_http_output => ''Y'',');
      p('      p_help_text=> ''Date/Time this record was created'',');
      p('      p_attribute_01 => ''N'',');
      p('      p_attribute_02 => ''VALUE'',');
      p('      p_attribute_04 => ''Y'',');
      p('      p_show_quick_picks=>''N'',');
      p('      p_item_comment => '''');');
   end if;
   p('');
                              --  ...Create Page Processing'');');
   p('   dbms_output.put_line(''  ...Create Page Processing'');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_HEADER'',');
   p('      p_process_type=> ''DML_FETCH_ROW'',');
   p('      p_process_name=> ''Fetch Row from ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_sql_clob => ''F|#OWNER#:' || upper(tbuff.name) || '_ACT:P'' || pnum || ''_ID:ID'',');
   p('      p_process_error_message=> ''Unable to fetch row of view ' || upper(tbuff.name) || '_ACT.'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   pr('   s := ''BEGIN'' ');
   pr('        ''   execute immediate ''''alter session set NLS_TIMESTAMP_FORMAT = ''''''''DD-MON-YYYY HH24:MI:SS.FF9'''''''''''';'' ');
   pr('        ''   #OWNER#.' || tbuff.name || '_dml.ins'' ');
   pr('        ''      (n_id => :P1212_ID'' ');
   if tbuff.type = 'EFF'
   then
      pr('        ''      ,n_eff_beg_dtm => :P1212_EFF_BEG_DTM'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('        ''      ,n_' || buff.name || ' => :P'' || pnum || ''_' ||
                            upper(buff.name) || ''' ');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('        ''      ,n_' || buff.fk_prefix ||
                                'id_path_in => :P'' || pnum || ''_' ||
                                  upper(buff.fk_prefix) || 'ID_PATH'' ');
            pr('        ''      ,n_' || buff.fk_prefix ||
                                'nk_path_in => :P'' || pnum || ''_' ||
                                  upper(buff.fk_prefix) || 'NK_PATH'' ');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('        ''      ,n_'
                              || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_NK' || i || '_in => :P'' || pnum || ''_' ||
                           upper(buff.fk_prefix) ||
               upper(get_tabname(buff.fk_table_id)) ||
                     '_NK' || i || ''' ');
         end loop;
      end if;
   end loop;
   pr('        ''      );'' ');
   p('        ''END;'';');
   p('');
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''GEN_INS of ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_sql_clob => s, ');
   p('      p_process_error_message=> ''Unable to insert row of view ' || upper(tbuff.name) || '_ACT.'',');
   p('      p_process_when=>''CREATE'',');
   p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   pr('   s := ''BEGIN'' ');
   pr('        ''   execute immediate ''''alter session set NLS_TIMESTAMP_FORMAT = ''''''''DD-MON-YYYY HH24:MI:SS.FF9'''''''''''';'' ');
   pr('        ''   #OWNER#.' || tbuff.name || '_dml.upd'' ');
   pr('        ''      (o_id_in => :P1212_ID'' ');
   if tbuff.type = 'EFF'
   then
      pr('        ''      ,n_eff_beg_dtm => :P1212_EFF_BEG_DTM'' ');
   end if;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      pr('        ''      ,n_' || buff.name || ' => :P'' || pnum || ''_' ||
                            upper(buff.name) || ''' ');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('        ''      ,n_' || buff.fk_prefix ||
                                'id_path_in => :P'' || pnum || ''_' ||
                                  upper(buff.fk_prefix) || 'ID_PATH'' ');
            pr('        ''      ,n_' || buff.fk_prefix ||
                                'nk_path_in => :P'' || pnum || ''_' ||
                                  upper(buff.fk_prefix) || 'NK_PATH'' ');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('        ''      ,n_'
                              || buff.fk_prefix ||
                     get_tabname(buff.fk_table_id) ||
                     '_NK' || i || '_in => :P'' || pnum || ''_' ||
                           upper(buff.fk_prefix) ||
               upper(get_tabname(buff.fk_table_id)) ||
                     '_NK' || i || ''' ');
         end loop;
         fkfnd := 1;
      end if;
   end loop;
-- nkdata_provided_in is now defaulted to 'Y'
--   if fkfnd = 1 then
--      pr('        ''      ,nkdata_provided_in => ''''Y'''''' ');
--   end if;
   pr('        ''      );'' ');
   p('        ''END;'';');
   p('');
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''GEN_UPD of ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_sql_clob => s, ');
   p('      p_process_error_message=> ''Unable to update row of view ' || upper(tbuff.name) || '_ACT.'',');
   p('      p_process_when=>''SAVE'',');
   p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   pr('   s := ''BEGIN'' ');
   pr('        ''   execute immediate ''''alter session set NLS_TIMESTAMP_FORMAT = ''''''''DD-MON-YYYY HH24:MI:SS.FF9'''''''''''';'' ');
   pr('        ''   if :P'' || pnum || ''_EFF_BEG_DTM = :P'' || pnum || ''_EFF_BEG_DTM_ORIG'' ');
   pr('        ''   then'' ');
   pr('        ''      :P'' || pnum || ''_EFF_BEG_DTM := null;'' ');
   pr('        ''   end if;'' ');
   pr('        ''   #OWNER#.' || tbuff.name || '_dml.del'' ');
   pr('        ''      (o_id_in => :P'' || pnum || ''_ID'' ');
   pr('        ''      ,x_eff_end_dtm => :P'' || pnum || ''_EFF_BEG_DTM'' ');
   pr('        ''      );'' ');
   p('        ''END;'';');
   p('');
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''GEN_DEL for ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_sql_clob => s,');
   p('      p_process_error_message=> ''Unable to delete row of view ' || upper(tbuff.name) || '_ACT'',');
   p('      p_process_when=>''DELETE'',');
   p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   pseq := pseq + 1;
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> ' || (pseq * 10) || ',');
   p('      p_process_point=> ''AFTER_SUBMIT'',');
   p('      p_process_type=> ''CLEAR_CACHE_FOR_PAGES'',');
   p('      p_process_name=> ''reset page'',');
   p('      p_process_sql_clob => pnum,');
   p('      p_process_error_message=> '''',');
   p('      p_process_when=>''DELETE'',');
   p('      p_process_when_type=>''REQUEST_EQUALS_CONDITION'',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   p('   if ts_name is not null');
   p('   then');
   p('      select count(tab_id)');
   p('       into  tab_cnt');
   p('       from  apex_application_tabs');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  tab_set          = ts_name');
   p('        and  tab_name         = pname;');
   p('      if tab_cnt = 0');
   p('      then');
   p('         dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('         wwv_flow_api.create_tab (');
   p('            p_id=> wwv_flow_id.next_val,');
   p('            p_flow_id=> wwv_flow.g_flow_id,');
   p('            p_tab_set=> ts_name,');
   p('            p_tab_sequence=> pnum,');
   p('            p_tab_name => pname,');
   p('            p_tab_text=> pname,');
   p('            p_tab_step => pnum,');
   p('            p_tab_also_current_for_pages => '''',');
   p('            p_tab_parent_tabset=>'''',');
   p('            p_tab_comment  => '''');');
   p('      end if;');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
END form_flow;
----------------------------------------
PROCEDURE omni_flow
   -- To convert this from page generation to application generation,
   --   Templates like "wwv_flow_api.create_row_template" must be added
   --   to the export script, to include matching "p_id => 1283510651569179"
   --   references for every usage of the row_template in the export script.
IS
   rseq       number;          -- Region Sequence Number
   pseq       number;          -- Process Sequence Number
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- This table has no OMNI
      return;
   end if;
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('');
   p('   -- Page Export Variables');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   ts_name    varchar2(30);    -- Tab Set Name');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Report Type) Report Region Template ID');
   p('   rsarc_tid  number;          -- (Report Type) Standard, Alternating Row');
   p('                               --                      Colors Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   irp_id     number;          -- Interactive Report Plug ID');
   p('   irws_id    number;          -- Interactive Report Worksheet ID');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   tab_cnt    number;          -- Number of Tab IDs found');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('');
   p('   if sch_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: sch_name is null.'');');
   p('   end if;');
   p('   if ws_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_id is null.'');');
   p('   end if;');
   p('   if ws_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_name is null.'');');
   p('   end if;');
   p('   if app_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_id is null.'');');
   p('   end if;');
   p('   if app_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_name is null.'');');
   p('   end if;');
   p('');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rsarc_tid := get_template_id(''Report'',''Standard, Alternating Row Colors'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional%with Help'');');
   p('');
   p('   dbms_output.put_line(''' || tbuff.name || ' omni, ' || tbuff.seq || ''');');
   p('   pnum     := ' || (pnum3 + tbuff.seq) || ' + page_os;');
   p('   pname    := ''' || initcap(replace(tbuff.name,'_',' ')) || ' OMNI'';');
   p('   ts_name  := ''' || tbuff.group_name || '_OMNI_TS'';');
   p('   irp_id   := wwv_flow_id.next_val;');
   p('   irws_id  := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_first_item => ''NO_FIRST_ITEM''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_javascript_code => ');
   p('       ''var htmldb_delete_message=''''"DELETE_CONFIRM_MSG"'''';''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''' || replace(tbuff.description,SQ1,SQ2) || '''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   --------------------------------------------------------------
   rseq := 0;
                              --  ...Create Interactive Report'');');
   p('   dbms_output.put_line(''  ...Create Interactive Report'');');
   pr('   s := ''select ID ' || upper(tbuff.name) ||'_ID'' ');
   pr('              '',''''ACT'''' STAT'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',null AUD_END_DTM'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if is_bigtext(buff)
      then
         pr('              '',''''<span style="display:block;' ||
            ' width:400px; white-space:normal">'''' || '' ');
         pr('              ''  cast (substr(' || upper(buff.name) ||
            ',1,200) as varchar2(200)) || '' ');
         pr('              ''  ''''</span>'''' ' || upper(buff.name) || ''' ');
      else
         pr('              '',' || upper(buff.name) || ''' ');
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',null EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',null AUD_END_USR'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || ''' ');
   pr('        ''union all'' ');
   pr('        ''select ' || upper(tbuff.name) ||'_ID'' ');
   pr('              '',''''HIST'''' STAT'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',AUD_END_DTM'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if is_bigtext(buff)
      then
         pr('              '',''''<span style="display:block;' ||
            ' width:400px; white-space:normal">'''' || '' ');
         pr('              ''  cast (substr(' || upper(buff.name) ||
            ',1,200) as varchar2(200)) || '' ');
         pr('              ''  ''''</span>'''' ' || upper(buff.name) || ''' ');
      else
         pr('              '',' || upper(buff.name) || ''' ');
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',AUD_END_USR'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || HOA || ''' ');
   pr('        ''union all'' ');
   pr('        ''select ' || upper(tbuff.name) ||'_ID'' ');
   pr('              '',''''POP'''' STAT'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',POP_DTM AUD_END_DTM'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if is_bigtext(buff)
      then
         pr('              '',''''<span style="display:block;' ||
            ' width:400px; white-space:normal">'''' || '' ');
         pr('              ''  cast (substr(' || upper(buff.name) ||
            ',1,200) as varchar2(200)) || '' ');
         pr('              ''  ''''</span>'''' ' || upper(buff.name) || ''' ');
      else
         pr('              '',' || upper(buff.name) || ''' ');
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',POP_DTM EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',POP_USR AUD_END_USR'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || '_PDAT'' ');
   p('        '';''; ');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> irp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> pname,');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rrr_tid,');
   p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> s,');
   p('      p_plug_source_type=> ''DYNAMIC_QUERY'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_plug_query_show_nulls_as => ''-'',');
   p('      p_plug_display_condition_type => '''',');
   p('      p_pagination_display_position=>''BOTTOM_LEFT'',');
   p('      p_plug_customized=>''0'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_worksheet(');
   p('      p_id=> irws_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_region_id=> irp_id,');
   p('      p_name=> pname,');
   p('      p_folder_id=> null, ');
   p('      p_alias=> '''',');
   p('      p_report_id_item=> '''',');
   p('      p_max_row_count=> ''10000'',');
   p('      p_max_row_count_message=> ''This query returns more than #MAX_ROW_COUNT# rows, please filter your data to ensure complete results.'',');
   p('      p_no_data_found_message=> ''No data found.'',');
   p('      p_max_rows_per_page=>'''',');
   p('      p_search_button_label=>'''',');
   p('      p_page_items_to_submit=>'''',');
   p('      p_sort_asc_image=>'''',');
   p('      p_sort_asc_image_attr=>'''',');
   p('      p_sort_desc_image=>'''',');
   p('      p_sort_desc_image_attr=>'''',');
   p('      p_sql_query => s,');
   p('      p_status=>''AVAILABLE_FOR_OWNER'',');
   p('      p_allow_report_saving=>''Y'',');
   p('      p_allow_save_rpt_public=>''N'',');
   p('      p_allow_report_categories=>''N'',');
   p('      p_show_nulls_as=>''-'',');
   p('      p_pagination_type=>''ROWS_X_TO_Y'',');
   p('      p_pagination_display_pos=>''BOTTOM_LEFT'',');
   p('      p_show_finder_drop_down=>''Y'',');
   p('      p_show_display_row_count=>''N'',');
   p('      p_show_search_bar=>''Y'',');
   p('      p_show_search_textbox=>''Y'',');
   p('      p_show_actions_menu=>''Y'',');
   p('      p_report_list_mode=>''TABS'',');
   p('      p_show_detail_link=>''C'',');
   p('      p_show_select_columns=>''Y'',');
   p('      p_show_rows_per_page=>''Y'',');
   p('      p_show_filter=>''Y'',');
   p('      p_show_sort=>''Y'',');
   p('      p_show_control_break=>''Y'',');
   p('      p_show_highlight=>''Y'',');
   p('      p_show_computation=>''Y'',');
   p('      p_show_aggregate=>''Y'',');
   p('      p_show_chart=>''Y'',');
   p('      p_show_group_by=>''Y'',');
   p('      p_show_notify=>''N'',');
   p('      p_show_calendar=>''N'',');
   p('      p_show_flashback=>''Y'',');
   p('      p_show_reset=>''Y'',');
   p('      p_show_download=>''Y'',');
   p('      p_show_help=>''Y'',');
   p('      p_download_formats=>''CSV:HTML:EMAIL'',');
   p('      p_detail_link=>''f?p=&APP_ID.:''||pnum||'':&SESSION.::&DEBUG.:RP:P''||pnum||''_POP_ID:#ID#'',');
   p('      p_detail_link_text=>''<img src="#IMAGE_PREFIX#menu/pt_boxes_20.png" alt="">'',');
   p('      p_allow_exclude_null_values=>''N'',');
   p('      p_allow_hide_extra_columns=>''N'',');
   p('      p_icon_view_enabled_yn=>''N'',');
   p('      p_icon_view_columns_per_row=>1,');
   p('      p_detail_view_enabled_yn=>''N'',');
   p('      p_owner=>ws_name);');
   p('');
   p('');
   cnum       := 1;
   cbuff      := cbuf0;
   cbuff.name := tbuff.name || '_id';
   cbuff.type := 'NUMBER';
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'stat';
   cbuff.type := 'VARCHAR2';
   cbuff.len  := 3;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('');
      cbuff    := buff;
      cnum     := cnum + 1;
      create_ws_col;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_beg_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_end_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
   end if;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   p('   wwv_flow_api.create_worksheet_rpt(');
   p('      p_id => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id => irws_id,');
   p('      p_session_id  => null,');
   p('      p_base_report_id  => null,');
   p('      p_application_user => ''APXWS_DEFAULT'',');
   p('      p_report_seq              =>10,');
   p('      p_report_alias            =>pname || '' Default'',');
   p('      p_status                  =>''PUBLIC'',');
   p('      p_category_id             =>null,');
   p('      p_is_default              =>''Y'',');
   p('      p_display_rows            =>15,');
   if tbuff.type = 'EFF'
   then
      p('      p_report_columns          =>''ID:STAT:AUD_BEG_DTM:AUD_END_DTM:' ||
               upper(get_collist(tbuff.id,':')) ||
               ':EFF_BEG_DTM:EFF_END_DTM:AUD_BEG_USR:AUD_END_USR'',');
   else
      p('      p_report_columns          =>''ID:STAT:AUD_BEG_DTM:AUD_END_DTM:' ||
               upper(get_collist(tbuff.id,':')) ||
               ':AUD_BEG_USR:AUD_END_USR'',');
   end if;
   p('      p_flashback_enabled       =>''N'',');
   p('      p_calendar_display_column =>'''');');
   p('');
   p('   if ts_name is not null');
   p('   then');
   p('      select count(tab_id)');
   p('       into  tab_cnt');
   p('       from  apex_application_tabs');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  tab_set          = ts_name');
   p('        and  tab_name         = pname;');
   p('      if tab_cnt = 0');
   p('      then');
   p('         dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('         wwv_flow_api.create_tab (');
   p('            p_id=> wwv_flow_id.next_val,');
   p('            p_flow_id=> wwv_flow.g_flow_id,');
   p('            p_tab_set=> ts_name,');
   p('            p_tab_sequence=> pnum,');
   p('            p_tab_name => pname,');
   p('            p_tab_text=> pname,');
   p('            p_tab_step => pnum,');
   p('            p_tab_also_current_for_pages => '''',');
   p('            p_tab_parent_tabset=>'''',');
   p('            p_tab_comment  => '''');');
   p('      end if;');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
END omni_flow;
----------------------------------------
PROCEDURE asof_flow
   -- To convert this from page generation to application generation,
   --   Templates like "wwv_flow_api.create_row_template" must be added
   --   to the export script, to include matching "p_id => 1283510651569179"
   --   references for every usage of the row_template in the export script.
IS
   rseq       number;          -- Region Sequence Number
   pseq       number;          -- Process Sequence Number
BEGIN
   if tbuff.type not in ('EFF', 'LOG')
   then
      -- This table has no ASOF
      return;
   end if;
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   page_os    number        := 0;');
   p('                               -- Page OffSet from table.seq');
   p('');
   p('   -- Page Export Variables');
   p('   pnum       number;          -- Page (Step) Number');
   p('   pname      varchar2(50);    -- Page Name');
   p('   ts_name    varchar2(30);    -- Tab Set Name');
   p('   rbr_tid    number;          -- (Region Type) Breadcrumb Region Template ID');
   p('   rrr_tid    number;          -- (Report Type) Report Region Template ID');
   p('   rsarc_tid  number;          -- (Report Type) Standard, Alternating Row');
   p('                               --                      Colors Template ID');
   p('   bb_tid     number;          -- (Button Type) Button Template ID');
   p('   bc_tid     number;          -- (Breadcrumb Type) Breadcrumb Template ID');
   p('   ilowh_tid  number;          -- (Item Label Type) Optional With Help Template ID');
   p('   irp_id     number;          -- Interactive Report Plug ID');
   p('   irws_id    number;          -- Interactive Report Worksheet ID');
   p('   mnu_id     number;          -- Navigation Menu ID');
   p('   mnu_name   varchar2(32767); -- Navigation Menu Name');
   p('   tab_cnt    number;          -- Number of Tab IDs found');
   p('   s          varchar2(32767); -- Temporary String');
   p('');

   func_flow;

   p('begin');
   p('');
   p('   -- Initialize and Error Check');
   p('');
   p('   if sch_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: sch_name is null.'');');
   p('   end if;');
   p('   if ws_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_id is null.'');');
   p('   end if;');
   p('   if ws_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: ws_name is null.'');');
   p('   end if;');
   p('   if app_id is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_id is null.'');');
   p('   end if;');
   p('   if app_name is null');
   p('   then');
   p('      raise_application_error(-20012, ''APEX: app_name is null.'');');
   p('   end if;');
   p('');
   p('   rbr_tid   := get_template_id(''Region'',''Breadcrumb Region'');');
   p('   rrr_tid   := get_template_id(''Region'',''Reports Region'');');
   p('   rsarc_tid := get_template_id(''Report'',''Standard, Alternating Row Colors'');');
   p('   bb_tid    := get_template_id(''Button'',''Button'');');
   p('   bc_tid    := get_template_id(''Breadcrumb'',''Breadcrumb'');');
   p('   ilowh_tid := get_template_id(''Item Label'',''Optional%with Help'');');
   p('');
   p('   dbms_output.put_line(''' || tbuff.name || ' asof, ' || tbuff.seq || ''');');
   p('   pnum     := ' || (pnum4 + tbuff.seq) || ' + page_os;');
   p('   pname    := ''' || initcap(replace(tbuff.name,'_',' ')) || ' ASOF'';');
   p('   ts_name  := ''' || tbuff.group_name || '_ASOF_TS'';');
   p('   irp_id  := wwv_flow_id.next_val;');
   p('   irws_id := wwv_flow_id.next_val;');
   p('   mnu_name := '' Breadcrumb'';');
   p('   mnu_id   := get_menu_id(mnu_name);');
   p('');
   p('   dbms_output.put_line(''  ...Remove page '' || pnum);');
   p('   wwv_flow_api.remove_page');
   p('      (p_flow_id=>wwv_flow.g_flow_id, p_page_id=> pnum);');
   p('');
   p('   dbms_output.put_line(''  ...Create page '' || pnum || '': '' || pname);');
   p('   wwv_flow_api.create_page');
   p('      (p_flow_id => wwv_flow.g_flow_id');
   p('      ,p_id => pnum');
   p('      ,p_tab_set => ts_name');
   p('      ,p_name => pname');
   p('      ,p_step_title => pname');
   p('      ,p_step_sub_title_type => ''TEXT_WITH_SUBSTITUTIONS''');
   p('      ,p_first_item => ''NO_FIRST_ITEM''');
   p('      ,p_include_apex_css_js_yn => ''Y''');
   p('      ,p_javascript_code => ');
   p('       ''var htmldb_delete_message=''''"DELETE_CONFIRM_MSG"'''';''');
   p('      ,p_cache_page_yn => ''N''');
   p('      ,p_help_text => ''' || replace(tbuff.description,SQ1,SQ2) || '''');
   p('      ,p_last_updated_by => ws_name');
   p('      ,p_last_upd_yyyymmddhh24miss => ''' ||
                              to_char(sysdate,'YYYYMMDDHH24MISS') || '''');
   p('      );');
   p('');
   p('   wwv_flow_api.create_page_plug (');
   p('     p_id=> wwv_flow_id.next_val,');
   p('     p_flow_id=> wwv_flow.g_flow_id,');
   p('     p_page_id=> pnum,');
   p('     p_plug_name=> ''Breadcrumb'',');
   p('     p_region_name=>'''',');
   p('     p_plug_template=> rbr_tid,');
   p('     p_plug_display_sequence=> 10,');
   p('     p_plug_display_column=> 1,');
   p('     p_plug_display_point=> ''REGION_POSITION_01'',');
   p('     p_plug_source=> s,');
   p('     p_plug_source_type=> ''M''||trim(to_char(mnu_id)),');
   p('     p_menu_template_id=> bc_tid,');
   p('     p_plug_display_error_message=> ''#SQLERRM#'',');
   p('     p_plug_query_row_template=> 1,');
   p('     p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('     p_plug_query_row_count_max => 500,');
   p('     p_plug_display_condition_type => '''',');
   p('     p_plug_caching=> ''NOT_CACHED'',');
   p('     p_plug_comment=> '''');');
   p('');
   --------------------------------------------------------------
   rseq := 0;
                              --  ...Create Interactive Report'');');
   p('   dbms_output.put_line(''  ...Create Interactive Report'');');
   pr('   s := ''select ID'' ');
   pr('              '',STAT'' ');
   -- Generate a column list for the view
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      if is_bigtext(buff)
      then
         pr('              '',''''<span style="display:block;' ||
            ' width:400px; white-space:normal">'''' || '' ');
         pr('              ''  cast (substr(' || upper(buff.name) ||
            ',1,200) as varchar2(200)) || '' ');
         pr('              ''  ''''</span>'''' ' || upper(buff.name) || ''' ');
      else
         pr('              '',' || upper(buff.name) || ''' ');
      end if;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            pr('              '',' || upper(buff.fk_prefix) || 'ID_PATH'' ');
            pr('              '',' || upper(buff.fk_prefix) || 'NK_PATH'' ');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            pr('              '',' || upper(buff.fk_prefix) ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_NK' || i || '''');
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('              '',EFF_BEG_DTM'' ');
      pr('              '',EFF_END_DTM'' ');
   end if;
   pr('              '',AUD_BEG_USR'' ');
   pr('              '',AUD_END_USR'' ');
   pr('              '',AUD_BEG_DTM'' ');
   pr('              '',AUD_END_DTM'' ');
   pr('        ''from "#OWNER#".' || upper(tbuff.name) || '_ASOF'' ');
   pr('        ''where (   (    :P'' || pnum || ''_ID_MIN is null'' ');
   pr('        ''           and :P'' || pnum || ''_ID_MAX is null'' ');
   pr('        ''          )'' ');
   pr('        ''       or (    id between nvl(:P'' || pnum || ''_ID_MIN,-1E125)'' ');
   pr('        ''                      and nvl(:P'' || pnum || ''_ID_MAX, 1E125)'' ');
   pr('        ''          )   )'' ');
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      create_search_where;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'id_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 1000;   --5;
            cbuff.description := 'Path of ancestor IDs hierarchy';
            create_search_where;
            cbuff             := cbuf0;
            cbuff.name        := buff.fk_prefix || 'nk_path';
            cbuff.type        := 'VARCHAR2';
            cbuff.len         := 4000;   --20;
            cbuff.description := 'Path of ancestor Natural Key Sets';
            create_search_where;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            cbuff             := nk_aa(buff.fk_table_id).cbuff_va(i);
            cbuff.name        := buff.fk_prefix ||
                                 get_tabname(buff.fk_table_id) ||
                                 '_nk' || i;
            cbuff.nk          := null;
            cbuff.description := upper( buff.fk_prefix ||
                                        get_tabname(buff.fk_table_id) ) ||
                                 ' Natural Key Value ' || i ||
                                 ': ' || cbuff.description;
            create_search_where;
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      pr('        '' and (   (    :P'' || pnum || ''_EFF_BEG_DTM_MIN is null'' ');
      pr('        ''          and :P'' || pnum || ''_EFF_BEG_DTM_MAX is null'' ');
      pr('        ''          )'' ');
      pr('        ''      or (eff_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MIN,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
      pr('        ''                          and nvl(to_timestamp(:P'' || pnum || ''_EFF_BEG_DTM_MAX,'' ');
      pr('        ''                                ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
      pr('        ''          )   )'' ');
   end if;
   pr('        '' and (   :P'' || pnum || ''_AUD_BEG_USR is null'' ');
   pr('        ''      or aud_beg_usr like :P'' || pnum || ''_AUD_BEG_USR'' ');
                              -- NOTE: "Like" works with numbers and strings
   pr('        ''      )'' ');
   pr('        '' and (   (    :P'' || pnum || ''_AUD_BEG_DTM_MIN is null'' ');
   pr('        ''          and :P'' || pnum || ''_AUD_BEG_DTM_MAX is null'' ');
   pr('        ''          )'' ');
   pr('        ''      or (   aud_beg_dtm between nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MIN,'' ');
   pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_first_dtm)'' ');
   pr('        ''                             and nvl(to_timestamp(:P'' || pnum || ''_AUD_BEG_DTM_MAX,'' ');
   pr('        ''                                   ''''DD-MON-YYYY HH24:MI:SS.FF9''''), "#OWNER#".util.get_last_dtm)'' ');
   p('        ''          )   )'';');
   p('');
   rseq := rseq + 1;
   p('   wwv_flow_api.create_page_plug (');
   p('      p_id=> irp_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_plug_name=> pname,');
   p('      p_region_name=>'''',');
   p('      p_plug_template=> rrr_tid,');
   p('      p_plug_display_sequence=> ' || (rseq * 10) || ',');
   p('      p_plug_display_column=> 1,');
   p('      p_plug_display_point=> ''AFTER_SHOW_ITEMS'',');
   p('      p_plug_source=> s,');
   p('      p_plug_source_type=> ''DYNAMIC_QUERY'',');
   p('      p_translate_title=> ''Y'',');
   p('      p_plug_display_error_message=> ''#SQLERRM#'',');
   p('      p_plug_query_row_template=> 1,');
   p('      p_plug_query_headings_type=> ''COLON_DELMITED_LIST'',');
   p('      p_plug_query_show_nulls_as => ''-'',');
   p('      p_plug_display_condition_type => '''',');
   p('      p_pagination_display_position=>''BOTTOM_LEFT'',');
   p('      p_plug_customized=>''0'',');
   p('      p_plug_caching=> ''NOT_CACHED'',');
   p('      p_plug_comment=> '''');');
   p('');
   p('   wwv_flow_api.create_worksheet(');
   p('      p_id=> irws_id,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_region_id=> irp_id,');
   p('      p_name=> pname,');
   p('      p_folder_id=> null, ');
   p('      p_alias=> '''',');
   p('      p_report_id_item=> '''',');
   p('      p_max_row_count=> ''10000'',');
   p('      p_max_row_count_message=> ''This query returns more than #MAX_ROW_COUNT# rows, please filter your data to ensure complete results.'',');
   p('      p_no_data_found_message=> ''No data found.'',');
   p('      p_max_rows_per_page=>'''',');
   p('      p_search_button_label=>'''',');
   p('      p_page_items_to_submit=>'''',');
   p('      p_sort_asc_image=>'''',');
   p('      p_sort_asc_image_attr=>'''',');
   p('      p_sort_desc_image=>'''',');
   p('      p_sort_desc_image_attr=>'''',');
   p('      p_sql_query => s,');
   p('      p_status=>''AVAILABLE_FOR_OWNER'',');
   p('      p_allow_report_saving=>''Y'',');
   p('      p_allow_save_rpt_public=>''N'',');
   p('      p_allow_report_categories=>''N'',');
   p('      p_show_nulls_as=>''-'',');
   p('      p_pagination_type=>''ROWS_X_TO_Y'',');
   p('      p_pagination_display_pos=>''BOTTOM_LEFT'',');
   p('      p_show_finder_drop_down=>''Y'',');
   p('      p_show_display_row_count=>''N'',');
   p('      p_show_search_bar=>''Y'',');
   p('      p_show_search_textbox=>''Y'',');
   p('      p_show_actions_menu=>''Y'',');
   p('      p_report_list_mode=>''TABS'',');
   p('      p_show_detail_link=>''C'',');
   p('      p_show_select_columns=>''Y'',');
   p('      p_show_rows_per_page=>''Y'',');
   p('      p_show_filter=>''Y'',');
   p('      p_show_sort=>''Y'',');
   p('      p_show_control_break=>''Y'',');
   p('      p_show_highlight=>''Y'',');
   p('      p_show_computation=>''Y'',');
   p('      p_show_aggregate=>''Y'',');
   p('      p_show_chart=>''Y'',');
   p('      p_show_group_by=>''Y'',');
   p('      p_show_notify=>''N'',');
   p('      p_show_calendar=>''N'',');
   p('      p_show_flashback=>''Y'',');
   p('      p_show_reset=>''Y'',');
   p('      p_show_download=>''Y'',');
   p('      p_show_help=>''Y'',');
   p('      p_download_formats=>''CSV:HTML:EMAIL'',');
   p('      p_detail_link=>''f?p=&APP_ID.:''||pnum||'':&SESSION.::&DEBUG.:RP:P''||pnum||''_POP_ID:#ID#'',');
   p('      p_detail_link_text=>''<img src="#IMAGE_PREFIX#menu/pt_boxes_20.png" alt="">'',');
   p('      p_allow_exclude_null_values=>''N'',');
   p('      p_allow_hide_extra_columns=>''N'',');
   p('      p_icon_view_enabled_yn=>''N'',');
   p('      p_icon_view_columns_per_row=>1,');
   p('      p_detail_view_enabled_yn=>''N'',');
   p('      p_owner=>ws_name);');
   p('');
   p('');
   cnum       := 1;
   cbuff      := cbuf0;
   cbuff.name := 'id';
   cbuff.type := 'NUMBER';
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'stat';
   cbuff.type := 'VARCHAR2';
   cbuff.len  := 3;
   create_ws_col;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      p('');
      cbuff    := buff;
      cnum     := cnum + 1;
      create_ws_col;
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'ID_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 1000;   --5;
            create_ws_col;
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'NK_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 4000;   --20;
            create_ws_col;
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('');
            cbuff      := nk_aa(buff.fk_table_id).cbuff_va(i);
            cnum       := cnum + 1;
            cbuff.name := upper(buff.fk_prefix) ||
                    get_tabname(buff.fk_table_id) ||
                         '_NK' || i;
            cbuff.nk   := null;
            create_ws_col;
         end loop;
      end if;
   end loop;
   if tbuff.type = 'EFF'
   then
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_beg_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
      p('');
      cnum       := cnum + 1;
      cbuff      := cbuf0;
      cbuff.name := 'eff_end_dtm';
      cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
      cbuff.len  := 9;
      create_ws_col;
   end if;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_usr';
   cbuff.type := 'VARCHAR2';     -- usrdt
   cbuff.len  := usrcl;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_beg_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   p('');
   cnum       := cnum + 1;
   cbuff      := cbuf0;
   cbuff.name := 'aud_end_dtm';
   cbuff.type := 'TIMESTAMP WITH LOCAL TIME ZONE';
   cbuff.len  := 9;
   create_ws_col;
   p('');
   p('   wwv_flow_api.create_worksheet_rpt(');
   p('      p_id => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_page_id=> pnum,');
   p('      p_worksheet_id => irws_id,');
   p('      p_session_id  => null,');
   p('      p_base_report_id  => null,');
   p('      p_application_user => ''APXWS_DEFAULT'',');
   p('      p_report_seq              =>10,');
   p('      p_report_alias            =>pname || '' Default'',');
   p('      p_status                  =>''PUBLIC'',');
   p('      p_category_id             =>null,');
   p('      p_is_default              =>''Y'',');
   p('      p_display_rows            =>15,');
   if tbuff.type = 'EFF'
   then
      p('      p_report_columns          =>''ID:STAT:' || upper(get_collist(tbuff.id,':')) ||
               ':EFF_BEG_DTM:EFF_END_DTM:AUD_BEG_USR:AUD_END_USR:AUD_BEG_DTM:AUD_END_DTM'',');
   else
      p('      p_report_columns          =>''ID:STAT:' || upper(get_collist(tbuff.id,':')) ||
               ':AUD_BEG_USR:AUD_END_USR:AUD_BEG_DTM:AUD_END_DTM'',');
   end if;
   p('      p_flashback_enabled       =>''N'',');
   p('      p_calendar_display_column =>'''');');
   p('');
   p('   wwv_flow_api.create_page_item(');
   p('      p_id=>wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id=> pnum,');
   p('      p_name=>''P'' || pnum || ''_ASOF_DTM'',');
   p('      p_data_type=> ''VARCHAR'',');
   p('      p_is_required=> false,');
   p('      p_accept_processing=> ''REPLACE_EXISTING'',');
   p('      p_item_sequence=> 10,');
   p('      p_item_plug_id => irp_id,');
   p('      p_use_cache_before_default=> ''NO'',');
   p('      p_item_default_type=> ''STATIC_TEXT_WITH_SUBSTITUTIONS'',');
   p('      p_prompt=>''The ASOF Date/Time for this report: '',');
   p('      p_source=>''P'' || (' || pnum4 || ' + page_os) || ''_ASOF_DTM'',');
   p('      p_source_type=> ''ITEM'',');
   p('      p_display_as=> ''NATIVE_DISPLAY_ONLY'',');
   p('      p_lov_display_null=> ''NO'',');
   p('      p_lov_translated=> ''N'',');
   p('      p_cSize=> 30,');
   p('      p_cMaxlength=> 4000,');
   p('      p_cHeight=> 1,');
   p('      p_cAttributes=> ''nowrap="nowrap"'',');
   p('      p_begin_on_new_line=> ''YES'',');
   p('      p_begin_on_new_field=> ''YES'',');
   p('      p_colspan=> 1,');
   p('      p_rowspan=> 1,');
   p('      p_label_alignment=> ''RIGHT'',');
   p('      p_field_alignment=> ''LEFT-CENTER'',');
   p('      p_field_template=> ilowh_tid,');
   p('      p_is_persistent=> ''Y'',');
   p('      p_help_text=> ''The ASOF Date/Time value can be changed using the ASOF Report Meny page.'',');
   p('      p_lov_display_extra=>''YES'',');
   p('      p_protection_level => ''N'',');
   p('      p_escape_on_http_output => ''Y'',');
   p('      p_attribute_01 => ''N'',');
   p('      p_attribute_02 => ''VALUE'',');
   p('      p_attribute_04 => ''Y'',');
   p('      p_show_quick_picks=>''N'',');
   p('      p_item_comment => '''');');
   p('');
   pr('   s := ''if :P' || pnum4 || '_ASOF_DTM is null'' ');
   pr('        ''then'' ');
   pr('        ''   :P' || pnum4 || '_ASOF_DTM := glob.get_asof_dtm;'' ');
   pr('        ''end if;'' ');
   p('        ''glob.set_asof_dtm(:P' || pnum4 || '_ASOF_DTM);'';');
   p('');
   p('   wwv_flow_api.create_page_process(');
   p('      p_id     => wwv_flow_id.next_val,');
   p('      p_flow_id=> wwv_flow.g_flow_id,');
   p('      p_flow_step_id => pnum,');
   p('      p_process_sequence=> 10,');
   p('      p_process_point=> ''BEFORE_HEADER'',');
   p('      p_process_type=> ''PLSQL'',');
   p('      p_process_name=> ''Set UTIL_ASOF_DATE'',');
   p('      p_process_sql_clob => s,');
   p('      p_process_error_message=> '''',');
   p('      p_process_success_message=> '''',');
   p('      p_process_is_stateful_y_n=>''N'',');
   p('      p_process_comment=>'''');');
   p('');
   p('   if ts_name is not null');
   p('   then');
   p('      select count(tab_id)');
   p('       into  tab_cnt');
   p('       from  apex_application_tabs');
   p('       where application_name = app_name');
   p('        and  workspace        = ws_name');
   p('        and  tab_set          = ts_name');
   p('        and  tab_name         = pname;');
   p('      if tab_cnt = 0');
   p('      then');
   p('         dbms_output.put_line(''  Adding '' || pname || '' Tab to '' || ts_name || '' ...'');');
   p('         wwv_flow_api.create_tab (');
   p('            p_id=> wwv_flow_id.next_val,');
   p('            p_flow_id=> wwv_flow.g_flow_id,');
   p('            p_tab_set=> ts_name,');
   p('            p_tab_sequence=> pnum,');
   p('            p_tab_name => pname,');
   p('            p_tab_text=> pname,');
   p('            p_tab_step => pnum,');
   p('            p_tab_also_current_for_pages => '''',');
   p('            p_tab_parent_tabset=>'''',');
   p('            p_tab_comment  => '''');');
   p('      end if;');
   p('   end if;');
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
END asof_flow;
----------------------------------------
PROCEDURE create_column_hint
      (dif_in  in  varchar2)
IS
   nkseq  number  := 0;
BEGIN
   p('');
   p('   col_id   := wwv_flow_id.next_val;');
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_hint.create_column_hint_priv(');
   p('      p_label => ''' || initcap(replace(cbuff.name,'_',' ')) || ''',');
   p('      p_help_text => ''' || replace(cbuff.description,SQ1,SQ2) || ''',');
   p('      p_display_seq_form => ' || cnum || ',');
   p('      p_display_seq_report => ' || cnum || ',');
   p('      p_display_in_form => ''' || dif_in || ''',');
   p('      p_display_in_report => ''Y'',');
   if cbuff.type = 'NUMBER'
   then
      p('      p_mask_form => ''' || get_colformat(cbuff) || ''',');
      p('      p_display_as_form => ''NATIVE_NUMBER_FIELD'',');
      p('      p_form_attribute_03 => ''right'',');
      p('      p_display_as_tab_form => ''TEXT'',');
      p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      p('      p_alignment => ''R'',');
      p('      p_display_width => ' || to_char(least(trunc((get_collen(cbuff)*0.5)+1),50)) || ',');
      p('      p_max_width => ' || to_char(get_collen(cbuff)) || ',');
      p('      p_searchable => ''Y'',');
   elsif cbuff.fk_table_id is not null
   then
      p('      p_display_as_form => ''NATIVE_POPUP_LOV'',');
      p('      p_form_attribute_01 => ''NOT_ENTERABLE'',');
      p('      p_form_attribute_02 => ''FIRST_ROWSET_FILTER'',');
      p('      p_display_as_tab_form => ''POPUP'',');
      p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      p('      p_lov_query => ''select ' || get_tabname(cbuff.fk_table_id) ||
                     '_dml.get_nk(id) ||''''(''''|| id  ||'''')'''' d''||chr(10)||');
      p('    ''      ,id r''||chr(10)||');
      p('    '' from  "#OWNER#".' || get_tabname(cbuff.fk_table_id) || '''||chr(10)||');
      p('    '' order by 1'',');
      p('      p_alignment => ''L'',');
      p('      p_display_width => 50,');
      p('      p_max_width => 50,');
      p('      p_searchable => ''N'',');
   elsif cbuff.d_domain_id is not null
   then
      p('      p_display_as_form => ''NATIVE_SELECT_LIST'',');
      p('      p_form_attribute_01 => ''NONE'',');
      p('      p_form_attribute_02 => ''N'',');
      p('      p_display_as_tab_form => ''SELECT_LIST_FROM_LOV'',');
      p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      p('      p_alignment => ''L'',');
      p('      p_display_width => ' || to_char(get_collen(cbuff)) || ',');
      p('      p_max_width => ' || to_char(get_collen(cbuff)) || ',');
      p('      p_searchable => ''Y'',');
   else  -- if buff.type = 'VARCHAR2'
      p('      p_display_as_form => ''NATIVE_TEXT_FIELD'',');
      p('      p_form_attribute_01 => ''N'',');
      p('      p_form_attribute_02 => ''N'',');
      if cbuff.len > 100
      then
         p('      p_display_as_tab_form => ''TEXTAREA'',');
      else
         p('      p_display_as_tab_form => ''TEXT'',');
      end if;
      p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      p('      p_alignment => ''L'',');
      p('      p_display_width => ' || to_char(least(trunc((get_collen(cbuff)*0.5)+1),50)) || ',');
      p('      p_max_width => ' || to_char(get_collen(cbuff)) || ',');
      p('      p_searchable => ''Y'',');
   end if;
   if cbuff.req is not null or
      cbuff.nk  is not null
   then
      p('      p_required => ''Y'',');
   else
      p('      p_required => ''N'',');
   end if;
   p('      p_height => 1,');
   p('      p_aggregate_by => ''N'',');
   p('      p_group_by => ''N'',');
   p('      p_column_id => col_id,');
   p('      p_table_id => tab_id,');
   p('      p_column_name => ''' || upper(cbuff.name) || ''');');
   for buff in (
      select * from domain_values DV
       where DV.domain_id = cbuff.d_domain_id
       order by DV.seq )
   loop
      p('');
      nkseq := nkseq + 1;
      p('   wwv_flow_hint.create_lov_data_priv(');
      p('      p_id => wwv_flow_id.next_val,');
      p('      p_column_id => col_id,');
      p('      p_lov_disp_sequence => ' || nkseq || ',');
      p('      p_lov_disp_value => ''' || replace(buff.description,SQ1,SQ2) || ''',');
      p('      p_lov_return_value => ''' || buff.value || ''');');
   end loop;
END create_column_hint;
----------------------------------------
PROCEDURE tuid_flow
IS
BEGIN
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   tab_id    number;          -- Table ID');
   p('   col_id    number;          -- Column ID');
   p('');
   p('begin');
   p('');
   p('   -- SET SCHEMA');
   p('');
   p('   wwv_flow_hint.g_schema := sch_name;');
   p('   wwv_flow_hint.check_schema_privs;');
   p('');
   p('   --------------------------------------------------------------------');
   p('   dbms_output.put_line(''SCHEMA '' || sch_name || '' - User Interface Defaults, Table Defaults'');');
   p('   --');
   p('   -- Import using sqlplus as the Oracle user: APEX_040000');
   p('   -- Created ' || to_char(sysdate, 'HH24 Day Month DD, YYYY'));
   p('   --');
   p('');
   p('   tab_id   := wwv_flow_id.next_val;');
   p('');
   p('   wwv_flow_hint.remove_hint_priv(wwv_flow_hint.g_schema');
   p('                                 ,''' || upper(tbuff.name) || '_ACT'');');
   p('');
   p('   wwv_flow_hint.create_table_hint_priv(');
   p('      p_table_id => tab_id,');
   p('      p_schema => wwv_flow_hint.g_schema,');
   p('      p_table_name  => ''' || upper(tbuff.name) || '_ACT'',');
   p('      p_report_region_title => ''' ||
               initcap(replace(tbuff.name,'_',' ')) || ''',');
   p('      p_form_region_title => ''' ||
               initcap(replace(tbuff.name,'_',' ')) || ''');');
   p('');
   cnum := 0;
   for buff in (
      select * from tab_cols COL
       where COL.table_id = tbuff.id
       order by COL.seq )
   loop
      cbuff := buff;
      create_column_hint('Y');
      if buff.fk_table_id is not null
      then
         if buff.fk_table_id = tbuff.id
         then
            -- Setup the path functions for the hierarchy
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'ID_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 1000;   --5;
            create_column_hint('Y');
            p('');
            cnum       := cnum + 1;
            cbuff      := cbuf0;
            cbuff.name := upper(buff.fk_prefix) || 'NK_PATH';
            cbuff.type := 'VARCHAR2';
            cbuff.len  := 4000;   --20;
            create_column_hint('Y');
         end if;
         for i in 1 .. nk_aa(buff.fk_table_id).cbuff_va.COUNT
         loop
            p('');
            cbuff      := nk_aa(buff.fk_table_id).cbuff_va(i);
            cnum       := cnum + 1;
            cbuff.name := upper(buff.fk_prefix) ||
                    get_tabname(buff.fk_table_id) ||
                         '_nk' || i;
            cbuff.nk   := null;
            create_column_hint('Y');
         end loop;
      end if;
   end loop;
   p('');
   cnum := cnum + 1;
   p('   wwv_flow_hint.create_column_hint_priv(');
   p('      p_label => ''ID'',');
   p('      p_help_text => ''Surrogate Primary Key for these ' || tbuff.name || ''',');
   p('      p_display_seq_form => ' || cnum || ',');
   p('      p_display_in_form => ''N'',');
   p('      p_display_as_form => ''NATIVE_NUMBER_FIELD'',');
   p('      p_form_attribute_03 => ''right'',');
   p('      p_display_as_tab_form => ''TEXT'',');
   p('      p_display_seq_report => 1,');
   p('      p_display_in_report => ''Y'',');
   p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
   p('      p_aggregate_by => ''N'',');
   p('      p_required => ''N'',');
   p('      p_alignment => ''R'',');
   p('      p_display_width => 12,');
   p('      p_max_width => 39,');
   p('      p_height => 1,');
   p('      p_group_by => ''N'',');
   p('      p_searchable => ''N'',');
   p('      p_column_id => wwv_flow_id.next_val,');
   p('      p_table_id => tab_id,');
   p('      p_column_name => ''ID'');');
   if tbuff.type = 'EFF'
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_hint.create_column_hint_priv(');
      P('      p_label => ''Date/Time Effective'',');
      P('      p_help_text => ''Date/Time this record became effective (must be in nanoseconds)'',');
      P('      p_mask_form => ''DD-MON-YYYY HH24.MI.SSXFF9'',');
      P('      p_display_seq_form => ' || cnum || ',');
      P('      p_display_in_form => ''N'',');
      P('      p_display_as_form => ''NATIVE_TEXT_FIELD'',');
      P('      p_form_attribute_01 => ''N'',');
      P('      p_form_attribute_02 => ''N'',');
      P('      p_display_as_tab_form => ''TEXT'',');
      P('      p_display_seq_report => ' || cnum || ',');
      P('      p_display_in_report => ''Y'',');
      P('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      P('      p_mask_report => ''DD-MON-YYYY HH24.MI.SSXFF9'',');
      P('      p_aggregate_by => ''N'',');
      P('      p_required => ''N'',');
      P('      p_alignment => ''L'',');
      P('      p_group_by => ''N'',');
      P('      p_searchable => ''N'',');
      P('      p_column_id => wwv_flow_id.next_val,');
      P('      p_table_id => tab_id,');
      P('      p_column_name => ''EFF_BEG_DTM'');');
   end if;
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_hint.create_column_hint_priv(');
      p('      p_label => ''Created By'',');
      p('      p_help_text => ''User that created this record'',');
      p('      p_display_seq_form => ' || cnum || ',');
      p('      p_display_in_form => ''N'',');
      p('      p_display_as_form => ''NATIVE_TEXT_FIELD'',');
      p('      p_form_attribute_01 => ''N'',');
      p('      p_form_attribute_02 => ''N'',');
      p('      p_display_as_tab_form => ''TEXT'',');     -- usrdt
      p('      p_display_seq_report => ' || cnum || ',');
      p('      p_display_in_report => ''Y'',');
      p('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      p('      p_aggregate_by => ''N'',');
      p('      p_required => ''N'',');
      p('      p_alignment => ''L'',');
      p('      p_display_width => ' || usrcl/2 || ',');
      p('      p_max_width => ' || usrcl || ',');
      p('      p_height => 1,');
      p('      p_group_by => ''N'',');
      p('      p_searchable => ''N'',');
      p('      p_column_id => wwv_flow_id.next_val,');
      p('      p_table_id => tab_id,');
      p('      p_column_name => ''AUD_BEG_USR'');');
      p('');
      cnum := cnum + 1;
      p('   wwv_flow_hint.create_column_hint_priv(');
      P('      p_label => ''Date/Time Created'',');
      P('      p_help_text => ''Date/Time this record was created (must be in nanoseconds)'',');
      P('      p_mask_form => ''DD-MON-YYYY HH24.MI.SSXFF9'',');
      P('      p_display_seq_form => ' || cnum || ',');
      P('      p_display_in_form => ''N'',');
      P('      p_display_as_form => ''NATIVE_TEXT_FIELD'',');
      P('      p_form_attribute_01 => ''N'',');
      P('      p_form_attribute_02 => ''N'',');
      P('      p_display_as_tab_form => ''TEXT'',');
      P('      p_display_seq_report => ' || cnum || ',');
      P('      p_display_in_report => ''Y'',');
      P('      p_display_as_report => ''WITHOUT_MODIFICATION'',');
      P('      p_mask_report => ''DD-MON-YYYY HH24.MI.SSXFF9'',');
      P('      p_aggregate_by => ''N'',');
      P('      p_required => ''N'',');
      P('      p_alignment => ''L'',');
      P('      p_group_by => ''N'',');
      P('      p_searchable => ''N'',');
      P('      p_column_id => wwv_flow_id.next_val,');
      P('      p_table_id => tab_id,');
      P('      p_column_name => ''AUD_BEG_DTM'');');
   end if;
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
END tuid_flow;
----------------------------------------
PROCEDURE auid_flow
IS
BEGIN
   p('');
   p('declare');
   p('');
   p('   -- application/set_environment');
   p('   sch_name   varchar2(30)  := wwv_flow_application_install.get_schema;');
   p('                               -- Schema (Database Table) Owner;');
   p('   ws_id      number        := wwv_flow_application_install.get_workspace_id;');
   p('                               -- Workspace (Security Group) ID');
   p('   ws_name    varchar2(30)  := apex_util.find_workspace (ws_id);');
   p('                               -- Workspace Name');
   p('   app_id     number        := wwv_flow_application_install.get_application_id;');
   p('                               -- Application (Flow) ID');
   p('   app_name   varchar2(30)  := wwv_flow_application_install.get_application_name;');
   p('                               -- Application Name');
   p('   col_id     number;          -- Column ID');
   p('');
   p('begin');
   p('');
   p('   --------------------------------------------------------------------');
   p('   dbms_output.put_line('' - User Interface Defaults, Attribute Dictionary'');');
   p('   --');
   p('   -- Created ' || to_char(sysdate, 'HH24:MI Day Month DD, YYYY'));
   p('   --');
   p('   -- SHOW EXPORTING WORKSPACE');
   p('');
   p('   wwv_flow_hint.g_exp_workspace := ws_name;');
   p('');
   p('   col_id := wwv_flow_id.next_val;');
   p('   wwv_flow_hint.remove_col_attr_by_name(''ID'');');
   p('   wwv_flow_hint.create_col_attribute(');
   p('      p_label => ''ID'',');
   p('      p_help_text => ''Surrogate Primary Key for this record.'',');
   p('      p_format_mask => ''9999999999999999999999999999999999999'',');
   p('      p_default_value => '''',');
   p('      p_form_format_mask => ''9999999999999999999999999999999999999'',');
   p('      p_form_display_width => 15,');
   p('      p_form_display_height => 1,');
   p('      p_form_data_type => ''NUMBER'',');
   p('      p_report_format_mask => ''9999999999999999999999999999999999999'',');
   p('      p_report_col_alignment => ''RIGHT'',');
   p('      p_column_id => col_id,');
   p('      p_column_name  => ''ID'');');
   p('   wwv_flow_hint.create_col_synonym(');
   p('     p_syn_id => wwv_flow_id.next_val,');
   p('     p_column_id => col_id,');
   p('     p_syn_name  => ''ID'');');
   p('');
   p('   col_id := wwv_flow_id.next_val;');
   p('   wwv_flow_hint.remove_col_attr_by_name(''EFF_BEG_DTM'');');
   p('   wwv_flow_hint.create_col_attribute(');
   p('      p_label => ''Effective Begin'',');
   p('      p_help_text => ''The Date/Time this record become effective.'',');
   p('      p_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_default_value => '''',');
   p('      p_form_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_form_display_width => 15,');
   p('      p_form_display_height => 1,');
   p('      p_form_data_type => ''VARCHAR'',');
   p('      p_report_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_report_col_alignment => ''LEFT'',');
   p('      p_column_id => col_id,');
   p('      p_column_name  => ''EFF_BEG_DTM'');');
   p('   wwv_flow_hint.create_col_synonym(');
   p('     p_syn_id => wwv_flow_id.next_val,');
   p('     p_column_id => col_id,');
   p('     p_syn_name  => ''EFF_BEG_DTM'');');
   p('');
   p('   col_id := wwv_flow_id.next_val;');
   p('   wwv_flow_hint.remove_col_attr_by_name(''EFF_END_DTM'');');
   p('   wwv_flow_hint.create_col_attribute(');
   p('      p_label => ''Effective End'',');
   p('      p_help_text => ''The Date/Time this record was no longer effective.'',');
   p('      p_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_default_value => '''',');
   p('      p_form_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_form_display_width => 15,');
   p('      p_form_display_height => 1,');
   p('      p_form_data_type => ''VARCHAR'',');
   p('      p_report_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
   p('      p_report_col_alignment => ''LEFT'',');
   p('      p_column_id => col_id,');
   p('      p_column_name  => ''EFF_END_DTM'');');
   p('   wwv_flow_hint.create_col_synonym(');
   p('     p_syn_id => wwv_flow_id.next_val,');
   p('     p_column_id => col_id,');
   p('     p_syn_name  => ''EFF_END_DTM'');');
   if tbuff.type in ('EFF', 'LOG')
   then
      p('');
      p('   col_id := wwv_flow_id.next_val;');
      p('   wwv_flow_hint.remove_col_attr_by_name(''AUD_BEG_USR'');');
      p('   wwv_flow_hint.create_col_attribute(');
      p('      p_label => ''User Begin'',');
      p('      p_help_text => ''The User that created this record.'',');
      p('      p_format_mask => '''',');
      p('      p_default_value => '''',');
      p('      p_form_format_mask => '''',');
      p('      p_form_display_width => ' || usrcl/2 || ',');
      p('      p_form_display_height => 1,');
      p('      p_form_data_type => ''VARCHAR'',');     -- usrdt
      p('      p_report_format_mask => '''',');
      p('      p_report_col_alignment => ''LEFT'',');
      p('      p_column_id => col_id,');
      p('      p_column_name  => ''AUD_BEG_USR'');');
      p('   wwv_flow_hint.create_col_synonym(');
      p('     p_syn_id => wwv_flow_id.next_val,');
      p('     p_column_id => col_id,');
      p('     p_syn_name  => ''AUD_BEG_USR'');');
      p('');
      p('   col_id := wwv_flow_id.next_val;');
      p('   wwv_flow_hint.remove_col_attr_by_name(''AUD_END_USR'');');
      p('   wwv_flow_hint.create_col_attribute(');
      p('      p_label => ''User End'',');
      p('      p_help_text => ''The user that updated/deleted this record.'',');
      p('      p_format_mask => '''',');
      p('      p_default_value => '''',');
      p('      p_form_format_mask => '''',');
      p('      p_form_display_width => ' || usrcl/2 || ',');
      p('      p_form_display_height => 1,');
      p('      p_form_data_type => ''VARCHAR'',');     -- usrdt
      p('      p_report_format_mask => '''',');
      p('      p_report_col_alignment => ''LEFT'',');
      p('      p_column_id => col_id,');
      p('      p_column_name  => ''AUD_END_USR'');');
      p('   wwv_flow_hint.create_col_synonym(');
      p('     p_syn_id => wwv_flow_id.next_val,');
      p('     p_column_id => col_id,');
      p('     p_syn_name  => ''AUD_END_USR'');');
      p('');
      p('   col_id := wwv_flow_id.next_val;');
      p('   wwv_flow_hint.remove_col_attr_by_name(''AUD_BEG_DTM'');');
      p('   wwv_flow_hint.create_col_attribute(');
      p('      p_label => ''Audit Begin'',');
      p('      p_help_text => ''The Date/Time this record was created.'',');
      p('      p_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_default_value => '''',');
      p('      p_form_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_form_display_width => 15,');
      p('      p_form_display_height => 1,');
      p('      p_form_data_type => ''VARCHAR'',');
      p('      p_report_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_report_col_alignment => ''LEFT'',');
      p('      p_column_id => col_id,');
      p('      p_column_name  => ''AUD_BEG_DTM'');');
      p('   wwv_flow_hint.create_col_synonym(');
      p('     p_syn_id => wwv_flow_id.next_val,');
      p('     p_column_id => col_id,');
      p('     p_syn_name  => ''AUD_BEG_DTM'');');
      p('');
      p('   col_id := wwv_flow_id.next_val;');
      p('   wwv_flow_hint.remove_col_attr_by_name(''AUD_END_DTM'');');
      p('   wwv_flow_hint.create_col_attribute(');
      p('      p_label => ''Audit End'',');
      p('      p_help_text => ''The Date/Time this record was update/deleted.'',');
      p('      p_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_default_value => '''',');
      p('      p_form_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_form_display_width => 15,');
      p('      p_form_display_height => 1,');
      p('      p_form_data_type => ''VARCHAR'',');
      p('      p_report_format_mask => ''DD-MON-YYYY HH24.MI.SSXFF TZR'',');
      p('      p_report_col_alignment => ''LEFT'',');
      p('      p_column_id => col_id,');
      p('      p_column_name  => ''AUD_END_DTM'');');
      p('   wwv_flow_hint.create_col_synonym(');
      p('     p_syn_id => wwv_flow_id.next_val,');
      p('     p_column_id => col_id,');
      p('     p_syn_name  => ''AUD_END_DTM'');');
      p('');
      p('   col_id := wwv_flow_id.next_val;');
      p('   wwv_flow_hint.remove_col_attr_by_name(''LAST_ACTIVE'');');
      p('   wwv_flow_hint.create_col_attribute(');
      p('      p_label => ''LA'',');
      p('      p_help_text => ''"Y" indicates that this record was deleted from the active table.'',');
      p('      p_format_mask => '''',');
      p('      p_default_value => '''',');
      p('      p_form_format_mask => '''',');
      p('      p_form_display_width => 2,');
      p('      p_form_display_height => 1,');
      p('      p_form_data_type => ''VARCHAR'',');
      p('      p_report_format_mask => '''',');
      p('      p_report_col_alignment => ''LEFT'',');
      p('      p_column_id => col_id,');
      p('      p_column_name  => ''LAST_ACTIVE'');');
      p('   wwv_flow_hint.create_col_synonym(');
      p('     p_syn_id => wwv_flow_id.next_val,');
      p('     p_column_id => col_id,');
      p('     p_syn_name  => ''LAST_ACTIVE'');');
   end if;
   p('');
   p('   ----------------------------------------');
   p('');
   p('end;');
   p('/');
END auid_flow;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
FUNCTION get_usr_dtype
   RETURN VARCHAR2
   -- From the application buffer, return the simple data type
   --   for the usr_datatype
IS
   pos number;
BEGIN
   if abuff.usr_datatype is null
   then
      return 'VARCHAR2';
   end if;
   pos := instr(abuff.usr_datatype,'(');
   if pos = 0 then
      return abuff.usr_datatype;
   else
      return substr(abuff.usr_datatype,1,pos-1);
   end if;
END get_usr_dtype;
----------------------------------------
FUNCTION get_usr_collen
   RETURN number
   -- From the application buffer, return the length
   --   of the usr_datatype
   -- It is assumed that the only valid datatypes are
   --   -) VARCHAR2(len)
   --   -) NUMBER(len.scale)
IS
   par_pos  number;
   dot_pos  number;
BEGIN
   if abuff.usr_datatype is null
   then
      return 30;
   end if;
   par_pos := instr(abuff.usr_datatype,'(');
   if upper(abuff.usr_datatype) like 'NUMBER%'
   then
      if par_pos = 0 then
         -- sign + 40 decimal digits + decimal point + 5 Exponential Digits
         return 47;
      end if;
      dot_pos := instr(abuff.usr_datatype,'.');
      if par_pos != 0 then
         -- Must be "NUMBER(len.scale)"
         -- (sign)len(decimal point)scale
         return 1 +
            to_number(substr(abuff.usr_datatype
                            ,par_pos + 1
                            ,dot_pos - par_pos - 1)) +
            1 +
            to_number(substr(abuff.usr_datatype
                            ,dot_pos + 1
                            ,length(abuff.usr_datatype) - dot_pos - 1));
      end if;
      return to_number(substr(abuff.usr_datatype
                             ,par_pos + 1
                             ,length(abuff.usr_datatype) - par_pos - 1));
   end if;
   if upper(abuff.usr_datatype) not like 'VARCHAR%' or
      par_pos = 0
   then
      raise_application_error (-20000, 'APPLICATION.USR_DATATYPE is invalid: ' ||
                                        abuff.usr_datatype);
   end if;
   return to_number(substr(abuff.usr_datatype
                          ,par_pos + 1
                          ,length(abuff.usr_datatype) - par_pos - 1));
END get_usr_collen;
----------------------------------------
PROCEDURE init
      (app_abbr_in  in  varchar2)
IS
   rec_cnt  number;
BEGIN
   -- Get the application record
   BEGIN
      select * into abuff from applications
       where abbr = upper(app_abbr_in);
   EXCEPTION
      when NO_DATA_FOUND then
         raise_application_error(-20000, 'There is no application for abbr "' ||
                                          app_abbr_in || '"');
   END;
   -- Applications must have tables
   select count(*) into rec_cnt from tables where application_id = abuff.id;
   if rec_cnt = 0 then
      abuff := null;
      raise_application_error(-20000, 'Application "' || app_abbr_in ||
                                      '" has no tables');
   end if;
   -- All tables must have columns
   for buff in (select id, name from tables where application_id = abuff.id)
   loop
      select count(*) into rec_cnt from tab_cols where table_id = buff.id;
      if rec_cnt = 0 then
         abuff := null;
         raise_application_error(-20000, 'Table "' || buff.name ||
                                         '" has no columns');
      end if;
   end loop;
   -- Multi-Tiered (Remote) LOBs are not allowed
   if abuff.dbid is null then
      if abuff.db_auth is not null then
         abuff := null;
         raise_application_error(-20000, 'DBID and DB_AUTH must both have values or both be NULL.');
      end if;
      for buff in (select name from tables
                    where MV_REFRESH_HR is not null
                     and  application_id = abuff.id
                    order by name)
      loop
         abuff := null;
         raise_application_error(-20000, 'No Mid-Tier to Create Materialized View for Table "' ||
                            buff.name || '".  Remove MV_REFRESH_HR or add DBID to APPLICATION');
      end loop;
   else
      if abuff.db_auth is null then
         abuff := null;
         raise_application_error(-20000, 'DBID and DB_AUTH must both have values or both be NULL.');
      end if;
      for buff in (select id, name from tables
                    where application_id = abuff.id
                    order by id)
      loop
         for buf2 in (select * from tab_cols
                       where table_id = buff.id
                       order by id)
         loop
            if get_dtype(buf2,'DB') = 'CLOB' then
               abuff := null;
               raise_application_error(-20000, 'Remote LOBs are not allowed: Column "' ||
                  buf2.name || '" in Table "' || buff.name ||
                  '" converts to CLOB storage and DBID is not null');
            end if;
         end loop;
      end loop;
   end if;
   fbuff.application_id := abuff.id;
   fbuff.type           := 'SQL';
   if substr(abuff.db_auth,length(abuff.db_auth),1) != '.'
   then
     abuff.db_auth := abuff.db_auth || '.';
   end if;
   usrfdt := lower(nvl(abuff.usr_datatype,'VARCHAR2(30)'));
   usrdt  := upper(get_usr_dtype);
   usrcl  := get_usr_collen;
   load_nk_aa;
   init_cr_nt;
   lo_opname := 'DTGen ' || abuff.abbr || ' File Generation';
   select count(id) + 1  -- Add one for util.end_longops
    into  lo_num_tables
    from  tables
    where application_id = abuff.id;
   sec_lines := sec_line0;
   sec_line  := 0;
   lbuff_apnd_aa.DELETE;
   lbuff_updt_aa.DELETE;
   lbuff_orig_aa.DELETE;
   lbuff_seq := 0;
END init;
----------------------------------------
PROCEDURE next_table
IS
BEGIN
   HOA := get_hoa(tbuff.type);
   -- Queries must start with the word "select" and can only return 1 string
   p('select ''***  '||tbuff.name||'  ***'' as TABLE_NAME from dual');
   p('/');
END next_table;
----------------------------------------
PROCEDURE drop_glob
IS
BEGIN
   fbuff.name           := 'drop_glob';
   fbuff.description    := 'Drop Globals using generated code';
   open_file;
   p('');
   drop_util;
   drop_globals;
   p('');
   close_file;
END drop_glob;
----------------------------------------
PROCEDURE create_glob
IS
BEGIN
   fbuff.name           := 'create_glob';
   fbuff.description    := 'Create Globals using generated code';
   open_file;
   p('');
   create_globals;
   create_util;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
END create_glob;
----------------------------------------
PROCEDURE drop_gdst
IS
BEGIN
   fbuff.name           := 'drop_gdst';
   fbuff.description    := 'Drop Distributed Globals using generated code';
   open_file;
   p('');
   if abuff.dbid IS NULL
   then
      p('   --');
      p('   -- DBID is not defined in APPLICATIONS');
      p('   --');
      p('');
   else
      drop_util;
      drop_gd;
      p('');
   end if;
   close_file;
END drop_gdst;
----------------------------------------
PROCEDURE create_gdst
IS
BEGIN
   fbuff.name           := 'create_gdst';
   fbuff.description    := 'Create Distributed Globals using generated code';
   open_file;
   p('');
   if abuff.dbid IS NULL
   then
      p('   --');
      p('   -- DBID is not defined in APPLICATIONS');
      p('   --');
      p('');
   else
      create_gd;
      create_util;
   end if;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
END create_gdst;
----------------------------------------
PROCEDURE drop_ods
IS
BEGIN
   fbuff.name           := 'drop_ods';
   fbuff.description    := 'Drop Online Data Store using generated code';
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq desc)
   LOOP
      tbuff := buff;
      next_table;
      drop_tp;
      drop_pop;
      drop_fk;    -- Required to prevent circular FK reference error
      drop_tab;
      p('');
   END LOOP;
   p('');
   close_file;
END drop_ods;
----------------------------------------
PROCEDURE create_ods
IS
BEGIN
   fbuff.name           := 'create_ods';
   fbuff.description    := 'Create Online Data Store using generated code';
   util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq)
   LOOP
      tbuff := buff;
      next_table;
      p('');
      create_pop_spec;
      create_tp_spec;
      create_tab_act;
      create_tab_hoa;
      create_fk;
      create_ind_act;
      create_ind_hoa;
      create_ind_pdat;
      create_pop_body;
      create_tp_body;
      util.add_longops (1);
   END LOOP;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
   util.end_longops;
END create_ods;
----------------------------------------
PROCEDURE drop_integ
IS
BEGIN
   fbuff.name           := 'drop_integ';
   fbuff.description    := 'Drop ODS integrity using generated code';
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq desc)
   LOOP
      tbuff := buff;
      next_table;
      drop_ttrig;
      drop_cons;
      p('');
   END LOOP;
   close_file;
END drop_integ;
----------------------------------------
PROCEDURE create_integ
IS
BEGIN
   fbuff.name           := 'create_integ';
   fbuff.description    := 'Create ODS integrity using generated code';
   util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq)
   LOOP
      tbuff := buff;
      next_table;
      p('');
      create_cons;
      create_ttrig;
      util.add_longops (1);
   END LOOP;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
   util.end_longops;
END create_integ;
----------------------------------------
PROCEDURE drop_dist
IS
BEGIN
   fbuff.name           := 'drop_dist';
   fbuff.description    := 'Drop distributed integrity using generated code';
   open_file;
   p('');
   if abuff.dbid IS NULL
   then
      p('   --');
      p('   -- DBID is not defined in APPLICATIONS');
      p('   --');
      p('');
   else
      for buff in (
         select * FROM tables TAB
          where TAB.application_id = abuff.id
          order by TAB.seq desc)
      LOOP
         tbuff := buff;
         next_table;
         drop_tp;
         drop_rem_all_asof;
         drop_rem;
         p('');
      END LOOP;
   end if;
   close_file;
END drop_dist;
----------------------------------------
PROCEDURE create_dist
IS
BEGIN
   fbuff.name           := 'create_dist';
   fbuff.description    := 'Create distributed integrity using generated code';
   open_file;
   p('');
   if abuff.dbid IS NULL
   then
      p('   --');
      p('   -- DBID is not defined in APPLICATIONS');
      p('   --');
      p('');
   else
      util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
      for buff in (
         select * FROM tables TAB
          where TAB.application_id = abuff.id
          order by TAB.seq)
      LOOP
         tbuff := buff;
         next_table;
         p('');
         create_tp_spec;
         create_rem;
         if tbuff.mv_refresh_hr IS NOT NULL
         then
            create_ind_act;
         end if;
         create_rem_all_asof;
         create_tp_body;
         util.add_longops (1);
      END LOOP;
      util.end_longops;
   end if;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
END create_dist;
----------------------------------------
PROCEDURE drop_oltp
IS
BEGIN
   fbuff.name           := 'drop_oltp';
   fbuff.description    := 'Drop Online Data Store using generated code';
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq desc)
   LOOP
      tbuff := buff;
      next_table;
      drop_act;
      drop_vp;
      drop_dp;
      p('');
   END LOOP;
   close_file;
END drop_oltp;
----------------------------------------
PROCEDURE create_oltp
IS
BEGIN
   fbuff.name           := 'create_oltp';
   fbuff.description    := 'Create Online Transaction Processing using generated code';
   util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq)
   LOOP
      tbuff := buff;
      next_table;
      p('');
      create_vp_spec;
      create_act;
      create_vtrig;
      create_dp_spec;  -- Must be after the "create view"
      create_vp_body;
      create_dp_body;
      util.add_longops (1);
   END LOOP;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
   util.end_longops;
END create_oltp;
----------------------------------------
PROCEDURE drop_aa
IS
BEGIN
   fbuff.name           := 'drop_aa';
   fbuff.description    := 'Drop _ALL and _ASOF Views and Package';
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq desc)
   LOOP
      tbuff := buff;
      next_table;
      drop_sh;
      drop_asof;
      drop_all;
      p('');
   END LOOP;
   close_file;
END drop_aa;
----------------------------------------
PROCEDURE create_aa
IS
BEGIN
   fbuff.name           := 'create_aa';
   fbuff.description    := 'Create _ALL and _ASOF Views and Package';
--   util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
   open_file;
   p('');
   for buff in (
      select * FROM tables TAB
       where TAB.application_id = abuff.id
       order by TAB.seq)
   LOOP
      tbuff := buff;
      next_table;
      p('');
      create_sh_spec;
      create_all;
      create_asof;
      create_sh_body;
--      util.add_longops (1);
   END LOOP;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
--   util.end_longops;
END create_aa;
----------------------------------------
PROCEDURE drop_mods
IS
BEGIN
   fbuff.name           := 'drop_mods';
   fbuff.description    := 'Drop Program Modules';
   open_file;
   p('');
   drop_prg;
   close_file;
END drop_mods;
----------------------------------------
PROCEDURE create_mods
IS
BEGIN
   fbuff.name           := 'create_mods';
   fbuff.description    := 'Create Program Modules';
   open_file;
   p('');
   create_prg;
   close_file;
   dump_sec_lines;  -- Performs an "open_file"
END create_mods;
----------------------------------------
PROCEDURE drop_gusr
IS
BEGIN
   fbuff.name           := 'drop_gusr';
   fbuff.description    := 'Drop Global User Synonyms';
   open_file;
   p('');
   IF abuff.db_schema IS NULL
   THEN
      p('   --');
      p('   -- DB_SCHEMA is not defined in APPICATIONS');
      p('   --');
      p('');
   ELSE
      drop_gsyn;
   END IF;
   close_file;
END drop_gusr;
----------------------------------------
PROCEDURE create_gusr
IS
BEGIN
   fbuff.name           := 'create_gusr';
   fbuff.description    := 'Create GLobal User Synonyms';
   open_file;
   p('');
   IF abuff.db_schema IS NULL
   THEN
      p('   --');
      p('   -- DB_SCHEMA is not defined in APPLICATIONS');
      p('   --');
      p('');
   ELSE
      create_gsyn;
   END IF;
   close_file;
END create_gusr;
----------------------------------------
PROCEDURE drop_usyn
IS
BEGIN
   fbuff.name           := 'drop_usyn';
   fbuff.description    := 'Drop Synonyms for Users';
   open_file;
   p('');
   IF abuff.db_schema IS NULL
   THEN
      p('   --');
      p('   -- DB_SCHEMA is not defined in APPICATIONS');
      p('   --');
      p('');
   ELSE
      drop_msyn;
      for buff in (
         select * FROM tables TAB
          where TAB.application_id = abuff.id
          order by TAB.seq desc)
      LOOP
         tbuff := buff;
         next_table;
         drop_tsyn;
      END LOOP;
   END IF;
   close_file;
END drop_usyn;
----------------------------------------
PROCEDURE create_usyn
IS
BEGIN
   fbuff.name           := 'create_usyn';
   fbuff.description    := 'Create Synonyms for Users';
   open_file;
   p('');
   IF abuff.db_schema IS NULL
   THEN
      p('   --');
      p('   -- DB_SCHEMA is not defined in APPLICATIONS');
      p('   --');
      p('');
   ELSE
      for buff in (
         select * FROM tables TAB
          where TAB.application_id = abuff.id
          order by TAB.seq)
      LOOP
         tbuff := buff;
         next_table;
         create_tsyn;
      END LOOP;
      create_msyn;  -- For the Modules/Programs
   END IF;
   close_file;
END create_usyn;
----------------------------------------
PROCEDURE create_flow
IS
BEGIN
   fbuff.name        := 'create_flow';
   fbuff.description := 'APEX flow export file used to create APEX objects';
   open_file;
   p('');
   IF abuff.apex_schema IS NULL
   THEN
      p('   ---');
      p('   --- APEX_SCHEMA is not defined in APPLICATIONS');
      p('   ---');
      p('');
   ELSIF abuff.apex_ws_name IS NULL
   THEN
      p('   ---');
      p('   --- APEX_WS_NAME is not defined in APPLICATIONS');
      p('   ---');
      p('');
   ELSIF abuff.apex_app_name IS NULL
   THEN
      p('   ---');
      p('   --- APEX_APP_NAME is not defined in APPLICATIONS');
      p('   ---');
      p('');
   ELSE
      util.init_longops(lo_opname, lo_num_tables, fbuff.name, 'tables');
      init_flow;
      app_flow;            -- Generate Application Shared Components
      p('');
      for buff in (
         select * FROM tables TAB
          where TAB.application_id = abuff.id
          order by TAB.seq)
      LOOP
         tbuff := buff;
         next_table;
         maint_flow;       -- Generate Main Maintenance Page
         form_flow;        -- Generate Table DML Form Page
         omni_flow;        -- Generate OMNI Report Page
         asof_flow;        -- Generate ASOF Report Page
         tuid_flow;        -- Generate Table User Interface Defaults
         util.add_longops (1);
      END LOOP;
      auid_flow;           -- Generate Attribute User Interface Defaults
      fin_flow;
      util.end_longops;
   END IF;
   close_file;
END create_flow;
----------------------------------------
begin
   sec_lines := sec_line0;
   sec_line  := 0;
end generate;
