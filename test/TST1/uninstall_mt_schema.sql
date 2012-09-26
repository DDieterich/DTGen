
--
-- UnInstall Mid-Tier Schema
--
--  &1 - ${MT_SCHEMA_CONNECT}
--  &2 - ${DB_LINK_NAME}
--

spool uninstall_mt_schema.log
connect &1.
ALTER SESSION SET recyclebin = OFF;

@uninstall_test_rig

@drop_mods
@drop_oltp

------------------------------------------------------
@drop_dist
select view_type_owner || ': ' ||
       view_name       || '(len ' ||
       text_length     || ')'   as remaining_views
 from  user_views
 order by view_type_owner
      ,view_name;
select object_type              || ': ' ||
       substr(object_name,1,30) || '(' ||
       status                   || ')'   as remaining_objects
 from  user_objects
 where object_type = 'PACKAGE BODY'
  and  object_name not like '%_POP'
  and  object_name not like '%_TAB'
  and  object_name not in ('GLOB', 'UTIL')
 order by object_type
      ,object_name;
select table_name   || ': ' ||
       trigger_type || ' - ' ||
       trigger_name   as remaining_table_triggers
 from  user_triggers
 where base_object_type = 'TABLE'
 order by table_name
      ,trigger_type;
select table_name      || ': ' ||
       constraint_type || ' = ' ||
       substr(owner    || '.' ||
              constraint_name, 1, 40)  as remaining_constraints
 from  user_constraints
 where constraint_type not in ('P','U','R')
 order by table_name
      ,constraint_type
      ,owner
      ,constraint_name;

------------------------------------------------------
@drop_gdst
select object_type              || ': ' ||
       substr(object_name,1,30) || '(' ||
       status                   || ')'  as remaining_objects
 from  user_objects
 where object_type != 'DATABASE LINK'
 order by object_type
      ,object_name;

drop database link &2.;

spool off
