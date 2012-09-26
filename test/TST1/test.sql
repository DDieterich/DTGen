
--
-- Test Script
--
-- These executes are run individually to allow the
--   serveroutput buffer to dump between executions
--

set echo on
set serveroutput on format wrapped

execute test_rig.run_global_set('A');
execute test_rig.run_global_set('B');
execute test_rig.run_global_set('C');
execute test_rig.run_global_set('D');
execute test_rig.run_global_set('E');
execute test_rig.run_global_set('F');
execute test_rig.run_global_set('G');
execute test_rig.run_global_set('H');

commit;
