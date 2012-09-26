--
-- UnInstall Database User
--
--  &1 - ${DB_USER_CONNECT}
--  &2 - Type of User ("db" or "mt")
--

spool uninstall_&2._user.log
connect &1.
ALTER SESSION SET recyclebin = OFF;

@uninstall_test_rig

@drop_usyn
@drop_gusr
select object_type              || ': ' ||
       substr(object_name,1,30) || '(' ||
       status                   || ')'  as remaining_objects
 from  user_objects
 order by object_type
      ,object_name;

spool off
