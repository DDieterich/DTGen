create or replace package generate
as

/************************************************************
DTGEN "generate" Package Specification

Copyright (c) 2011, Duane.Dieterich@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************************/

   TYPE line_rec_type is RECORD
      (value varchar2(100)
      );
   TYPE line_t_type IS TABLE
      OF line_rec_type;
   FUNCTION exception_lines
      RETURN line_t_type PIPELINED;

   TYPE tab_col_va_type IS VARRAY(10)
      OF tab_cols%rowtype;

   TYPE nk_aa_rec_type IS RECORD
      (tbuff     tables%rowtype
      ,cbuff_va  tab_col_va_type
      );
   TYPE nk_aa_type IS TABLE
      OF nk_aa_rec_type
      INDEX BY PLS_INTEGER;

   nk_aa  nk_aa_type;

   TYPE sec_lines_type IS TABLE
      OF VARCHAR2(4000) INDEX BY PLS_INTEGER;

   procedure init
         (app_abbr_in  in  varchar2);

   -- Drop/Delete Scripts
   procedure drop_usyn;
   procedure drop_mods;
   procedure drop_oltp;
   procedure drop_dist;
   procedure drop_integ;
   procedure delete_ods;
   procedure drop_ods;
   procedure drop_gdst;
   procedure drop_glob;

   -- Create Scripts
   procedure create_glob;
   procedure create_gdst;
   procedure create_ods;
   procedure create_integ;
   procedure create_dist;
   procedure create_oltp;
   procedure create_mods;
   procedure create_usyn;

   -- Create GUI Script
   procedure create_flow;

end generate;
