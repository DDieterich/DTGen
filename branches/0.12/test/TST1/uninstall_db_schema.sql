
--
-- UnInstall Database Schema
--
--  &1 - ${DB_SCHEMA_CONNECT}
--

spool uninstall_db_schema.log
connect &1.
ALTER SESSION SET recyclebin = OFF;

@uninstall_test_rig_owner
@uninstall_test_rig

@drop_mods
@drop_aa
@drop_oltp

------------------------------------------------------------
@drop_integ
select table_name   || ': ' ||
       trigger_type || ' - ' ||
       trigger_name   as remaining_table_triggers
 from  user_triggers
 where base_object_type = 'TABLE'
  and  trigger_name not like '%~_BU' escape '~'
 order by table_name
      ,trigger_type;
select table_name      || ': ' ||
       constraint_type || ' = ' ||
       substr(owner    || '.' ||
              constraint_name, 1, 40)  as remaining_constraints
 from  user_constraints
 where constraint_type not in ('P','U','R')
  and  constraint_name not like '%~_NN_' escape '~'
  and  constraint_name not like '%~_NN__' escape '~'
  and  constraint_name not like '%~_NN___' escape '~'
 order by table_name
      ,constraint_type
      ,owner
      ,constraint_name;

------------------------------------------------------------
@drop_ods
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
select object_type              || ': ' ||
       substr(object_name,1,30) || '(' ||
       status                   || ')'  as remaining_objects
 from  user_objects
 where object_type = 'PACKAGE BODY'
  and  object_name not in ('GLOB', 'UTIL')
 order by object_type
      ,object_name;
select table_name      || ' (tablespace ' ||
       tablespace_name || ')'  as remaining_tables
 from  user_tables
 where table_name != 'UTIL_LOG'
 order by table_name;
select sequence_name || ' min:' ||
       min_value     || ' max:' ||
       max_value     || ' last:' ||
       last_number  as remaining_sequences
 from  user_sequences
 order by sequence_name;

------------------------------------------------------------
@drop_glob
select object_type              || ': ' ||
       substr(object_name,1,30) || '(' ||
       status                   || ')'  as remaining_objects
 from  user_objects
 order by object_type
      ,object_name;

spool off
