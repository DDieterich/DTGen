
--
--  Uninstall User Synonym Scripts for DTGEN
--
--  The 1 scripts included are:
--    -) drop_usyn
--


select ' -) drop_usyn  ' as FILE_NAME from dual;


-- Script File "drop_usyn"
--    Drop User Synonyms
--
--    Generated by DTGen (http://code.google.com/p/dtgen)
--    August    09, 2012  04:59:25 PM

--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--


----------------------------------------
select '***  exceptions  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym exceptions_act;
drop synonym exceptions_dml;
drop synonym exceptions;
--drop synonym exceptions_seq;

----------------------------------------
select '***  programs  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym programs_act;
drop synonym programs_dml;
drop synonym programs;
--drop synonym programs_seq;

----------------------------------------
select '***  check_cons  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym check_cons_act;
drop synonym check_cons_dml;
drop synonym check_cons;
--drop synonym check_cons_seq;

----------------------------------------
select '***  tab_inds  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym tab_inds_act;
drop synonym tab_inds_dml;
drop synonym tab_inds;
--drop synonym tab_inds_seq;

----------------------------------------
select '***  tab_cols  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym tab_cols_act;
drop synonym tab_cols_dml;
drop synonym tab_cols;
--drop synonym tab_cols_seq;

----------------------------------------
select '***  tables  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym tables_act;
drop synonym tables_dml;
drop synonym tables;
--drop synonym tables_seq;

----------------------------------------
select '***  domain_values  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym domain_values_act;
drop synonym domain_values_dml;
drop synonym domain_values;
--drop synonym domain_values_seq;

----------------------------------------
select '***  domains  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym domains_act;
drop synonym domains_dml;
drop synonym domains;
--drop synonym domains_seq;

----------------------------------------
select '***  file_lines  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym file_lines_act;
drop synonym file_lines_dml;
drop synonym file_lines;
--drop synonym file_lines_seq;

----------------------------------------
select '***  files  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym files_act;
drop synonym files_dml;
drop synonym files;
--drop synonym files_seq;

----------------------------------------
select '***  applications  ***' as TABLE_NAME from dual;
----------------------------------------
drop synonym applications_act;
drop synonym applications_dml;
drop synonym applications;
--drop synonym applications_seq;

drop synonym gui_util;
drop synonym generate;
drop synonym dtgen_util;

drop synonym glob;
drop synonym util_log;
drop synonym util;

select substr(object_name,1,30), object_type, status
 from  user_objects;

