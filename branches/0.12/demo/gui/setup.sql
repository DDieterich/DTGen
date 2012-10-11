
REM
REM GUI Demonstration, Setup Script
REM   (sqlplus system/password @setup)
REM
REM Copyright (c) 2012, Duane.Dieterich@gmail.com
REM All rights reserved.
REM
REM Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
REM
REM Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
REM Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
REM THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
REM

spool setup
set define '&'

REM Configure SQL*Plus
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT

set linesize 80
set termout on
set define on
set serveroutput on format wrapped

declare
   UNAME  varchar2(30) := 'DTGEN_DB_DEMO';
begin
   APEX_INSTANCE_ADMIN.ADD_WORKSPACE
      (p_workspace_id       => null
      ,p_workspace          => UNAME
      ,p_primary_schema     => UNAME
      ,p_additional_schemas => null
      );
   APEX_UTIL.SET_SECURITY_GROUP_ID(APEX_UTIL.FIND_SECURITY_GROUP_ID(UNAME));
   APEX_UTIL.CREATE_USER
      (p_user_id                      => null
      ,p_user_name                    => UNAME
      ,p_first_name                   => 'Demo'
      ,p_last_name                    => 'DTGen'
      ,p_description                  => 'DTGen GUI Demonstration Administrator'
      ,p_email_address                => 'dtgen_demo@dmstex.com'
      ,p_web_password                 => 'dtgen'
      ,p_web_password_format          => 'CLEAR_TEXT'
      ,p_group_ids                    => null
      ,p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL'
      ,p_default_schema               => UNAME
      ,p_allow_access_to_schemas      => null
      ,p_account_expiry               => null
      ,p_account_locked               => 'N'
      ,p_failed_access_attempts       => 0
      ,p_change_password_on_first_use => 'N'
      ,p_first_password_use_occurred  => 'N'
      ,p_attribute_01                 => null
      ,p_attribute_02                 => null
      ,p_attribute_03                 => null
      ,p_attribute_04                 => null
      ,p_attribute_05                 => null
      ,p_attribute_06                 => null
      ,p_attribute_07                 => null
      ,p_attribute_08                 => null
      ,p_attribute_09                 => null
      ,p_attribute_10                 => null
	  );
   DBMS_OUTPUT.PUT_LINE('Workspace and APEX User '||UNAME||' have been setup.');
end;
/

spool off
exit
