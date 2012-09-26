
-) _ACT%ROWTYPE insert and update need the foriegn keys and hierarchies queried before returning call.
-) Check testing results

DTGen "test" README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
TST1                  - Directory for Testing TST1 Application
cleanup.sh            - Called by "t.sh cleanup"
clear_test_parms.sql  - Used to clear the TESTOWNER's tables
create_tspaces_linux.sql - Used to create example tablespaces in Linux
create_tspaces_windows.sql - Used to create example tablespaces in Windows
create_ut_objs.sql    - Run as "dtgen_test" to create Unit Test Objects
                        &1. - Generator Schema Object Owner Name
create_ut_owner.sql   - Run as sys to create Unit Test Repository Owner
                        &1. - Generator Schema Object Owner Name
create_ut_syns.sql    - Called by "t.sh setup"
drop_ut_owner.sql     - Run as sys to drop Unit Test Repository Owner
g.sql                 - Creates some GUI stuff
load.sh               - Called by "t.sh load"
remove.sh             - Called by "t.sh remove"
setup.sh              - Called by "t.sh setup"
                        Uses supp/create_owner script
                        Uses supp/create_user script
                        Uses supp/grant_app_roles.sql
t.sh                  - Script to test the DTGen application
                        t.sh (setup|test|cleanup|remove|-p) {test directory}
test.sh               - Called by "t.sh test"
tspace_quotas.sql     - Called by "t.sh setup"
ut_dataload.ctl       - SQL*Loader control file to load unit test data


Files in Sub-Directories
------------------------
NOTE: Each file listed is contained in each of the following sub-directories:
   -) TST1
   -) TST2
dtgen_dataload.ctl      - SQL*Loader control file to load the TST1 application into DTGen
install_db_schema.gold  - Gold file for "t.sh load" logging
install_db_schema.sql   - SQL script called by load.sql
install_db_user.gold    - Gold file for "t.sh load" logging
install_mt_schema.gold  - Gold file for "t.sh load" logging
install_mt_schema.sql   - SQL script called by load.sql
install_mt_user.gold    - Gold file for "t.sh load" logging
install_test_rig.sql    - SQL script called by load.sql
install_user.sql        - SQL script called by load.sql
load.sql                - SQL script called by "t.sh load"
t.env                   - Environment Variable Settings for t.sh
test_rig.pkb            - SQL script called by install_test_rig.sql
test_rig.pks            - SQL script called by install_test_rig.sql
test_T1DBS.gold         - Gold file for "t.sh test" logging
test_T1DBU.gold         - Gold file for "t.sh test" logging
test_T1MTS.gold         - Gold file for "t.sh test" logging
test_T1MTU.gold         - Gold file for "t.sh test" logging
uninstall_db_schema.gold - Gold file for "t.sh cleanup" logging
uninstall_db_schema.sql - SQL script called by cleanup.sql
uninstall_db_user.gold  - Gold file for "t.sh cleanup" logging
uninstall_mt_schema.gold - Gold file for "t.sh cleanup" logging
uninstall_mt_schema.sql - SQL script called by cleanup.sql
uninstall_mt_user.gold  - Gold file for "t.sh cleanup" logging
uninstall_test_rig.sql  - SQL script called by cleanup.sql
uninstall_user.sql      - SQL script called by cleanup.sql


Installation Instructions:
--------------------------
NOTE: Due to an apperent bug in Oracle11g Express Edition regarding
      privileges with private fixed user database links, extra grants
      have been added to the load.sh script to allow successful testing
      of the multi-tier architecture

1) Create the Unit Test Repository Owner
   sqlplus system/password@tns_alias @create_ut_owner dtgen
     - OR -
   sqlplus system/password@tns_alias @create_ut_owner dtgen_dev

2) Create the Unit Test Tablespaces
   sqlplus system/password@tns_alias @create_tspaces_windows
     - OR -
   sqlplus system/password@tns_alias @create_tspaces_linux

3) Run SQL*Developer and Create a Unit Test Repository
   -) Tools -> Unit Test -> Select Current Repository: dtgen_test
   -) Tools -> Unit Test -> Create/Update Repository: (answer questions as needed)

   Share the Unit Test Repository: Yes

4) Install Unit Test Repository Owner Objects
   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen
     - OR -
   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen_dev

5) Load Test Parameters
   sqlldr dtgen_test/dtgen_test control=ut_dataload.ctl

6) Run SQL*Developer and Load Unit Tests
   -) Tools -> Import from File -> ???

7) Set the names as needed in t.sh
   export GUI_DIR=../../gui
   export DEVNAME=dtgen
   export DEVPASS=dtgen
     - OR -
   export GUI_DIR=../../dev/gui
   export DEVNAME=dtgen_dev
   export DEVPASS=dtgen_dev

8) Confirm Test Settings
   ./t.sh -p

9) Setup the Unit Test Environments
   ./t.sh setup


Testing Instructions:
---------------------
1) Load for the next test
   ./t.sh load

2) Run SQL*Developer Unit Tests

3) Modify code as needed

4) Cleanup from Testing
   ./t.sh cleanup

5) Repeat steps 1-4 as necessary


Un-Install Instructions:
------------------------
1) Remove the Unit Test Environments
   ./t.sh remove

2) Remove the Unit Test Repository Owner
   sqlplus system/password@tns_alias @drop_ut_owner


File Created During Testing
---------------------------
NOTE: Each file listed is contained in each of the following sub-directories:
   -) DB_Integ
   -) DB_NoInteg
   -) DODMT_Integ
   -) DODMT_NoInteg
   -) MT_Integ
   -) MT_NoInteg
cleanup.log          - Log file for "t.sh cleanup"
install_owner.log    - Log file for "t.sh load"
install_user.log     - Log file for "t.sh load"
load.log             - Log file for "t.sh load"
remove.log           - Log file for "t.sh remove"
setup.log            - Log file for "t.sh setup"
uninstall_owner.log  - Log file for "t.sh cleanup"
uninstall_user.log   - Log file for "t.sh cleanup"


Co-Locating DTGen Applications:
-------------------------------
This test setup co-locates multiple DTGen applications in the same owner/user environments.  The global objects from one application are created for all other applications to use.  This is configured in the array loading found at the bottom of "test_gen.pkb"
