
--
-- Test Script
--
-- These executes are run individually to allow the
--   serveroutput buffer to dump between executions
--

set echo on
set serveroutput on format wrapped

execute trc.run_global_set('A');
execute trc.run_global_set('B');
execute trc.run_global_set('C');
execute trc.run_global_set('D');
execute trc.run_global_set('E');
execute trc.run_global_set('F');
execute trc.run_global_set('G');
execute trc.run_global_set('H');

commit;
