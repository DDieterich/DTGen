create or replace
package gui_util
AS 

/************************************************************
DTGEN "GUI_Util" Package Specification

Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/

function is_number
      (str_in  in  varchar2)
   return number;

function get_lockname
      (app_abbr_in  in  varchar2)
   return varchar2;

function index_desc
      (app_abbr_in  in  varchar2
      ,tab_abbr_in  in  varchar2
      ,ind_tag_in   in  varchar2)
   return varchar2;

function create_index
      (column_string_in  in  varchar2
      ,tables_nk1_in     in  varchar2
      ,tables_nk2_in     in  varchar2
      ,uniq_in           in  varchar2)
   return number;

function update_index
      (column_string_in  in  varchar2
      ,tables_nk1_in     in  varchar2
      ,tables_nk2_in     in  varchar2
      ,uniq_in           in  varchar2
      ,tagname_io    in out  varchar2)
   return number;

procedure gen_all
      (app_abbr_in  in  varchar2
      ,job_num_in   in  number default null);

procedure asm_all
      (app_abbr_in  in  varchar2
      ,job_num_in   in  number default null
      ,flow_id_in   in  number default null);

end gui_util;