create or replace package dtgen_util as

/************************************************************
DTGEN "utility" Package Specification

Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/

   type vc2_list_type
      is table of varchar2(30);
   vc2_list  vc2_list_type;
   type aa_vc2_type
      is table of vc2_list_type
      index by varchar2(15);
   aa_vc2  aa_vc2_type;
   
   rclob   clob;

   procedure assemble_script
      (app_abbr_in  in  varchar2
      ,action_in    in  varchar2
      ,own_key_in   in  varchar2
      ,suffix_in    in  varchar2 default '');
   function assemble_script
      (app_abbr_in  in  varchar2
      ,action_in    in  varchar2
      ,own_key_in   in  varchar2
      ,suffix_in    in  varchar2 default '')
   return clob;

   procedure data_script
         (app_abbr_in  in  varchar2);
   function data_script
         (app_abbr_in  in  varchar2)
      return clob;

   function delete_app
      (app_abbr_in  in  varchar2)
   return number;
   procedure delete_files
      (app_abbr_in  in  varchar2);

end dtgen_util;
