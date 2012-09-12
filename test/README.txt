
DTGen "test" README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
cleanup.sh            - Called by "t.sh cleanup"
comp.sql              - Called by "t.sh load"
create_app_roles.sql  - Called by "create_ut_owner.sql"
create_ut_objs.sql    - Run as "dtgen_test" to create Unit Test Objects
                        &1. - Generator Schema Object Owner Name
create_ut_owner.sql   - Run as sys to create Unit Test Repository Owner
                        &1. - Generator Schema Object Owner Name
create_ut_syns.sql    - Called by "t.sh setup"
DB_Integ              - Directory for TDBST and TDBUT Test Scripts
DB_NoInteg            - Directory for TDBSN and TDBUN Test Scripts
DODMT_Integ           - Directory for TMTSTDOD and TMTUTDOD Test Scripts
DODMT_NoInteg         - Directory for TMTSNDOD and TMTUNDOD Test Scripts
drop_app_roles.sql    - Called by "t.sh remove"
drop_ut_owner.sql     - Run as sys to drop Unit Test Repository Owner
dtgen_tst1_dataload.ctl - SQL*Loader control file to load the TST1 application
dtgen_tst2_dataload.ctl - SQL*Loader control file to load the TST2 application
g.sql                 - Creates some GUI stuff
grant_app_roles.sql   - Called by "t.sh setup"
load.sh               - Called by "t.sh load"
MT_Integ              - Directory for TMTST and TMTUT Test Scripts
MT_NoInteg            - Directory for TMTSN and TMTUN Test Scripts
remove.sh             - Called by "t.sh remove"
setup.sh              - Called by "t.sh setup"
                        Uses supp/create_owner script
                        Uses supp/create_user script
t.sh                  - Script to test the DTGen application
                        t.sh (setup|test|cleanup|remove|-p) {test directory}
test_gen.pkb          - Called by create_ut_objs to create TEST_GEN package
test_gen.pks          - Called by create_ut_objs to create TEST_GEN package
test_rig.pkb          - Called by create_ut_objs to create TEST_RIG package
test_rig.pks          - Called by create_ut_objs to create TEST_RIG package
ut_dataload.ctl       - SQL*Loader control file to load unit test data
XE2_All.xml           - SQL*Developer Unit Test Export


Files in Sub-Directories
------------------------
NOTE: Each file listed is contained in each of the following sub-directories:
   -) DB_Integ
   -) DB_NoInteg
   -) DODMT_Integ
   -) DODMT_NoInteg
   -) MT_Integ
   -) MT_NoInteg
install_owner.gold      - Gold file for "t.sh load" logging
install_user.gold       - Gold file for "t.sh load" logging
t.env                   - Environment Variable Settings for t.sh
uninstall_owner.gold    - Gold file for "t.sh cleanup" logging
uninstall_user.gold     - Gold file for "t.sh cleanup" logging


Installation Instructions:
--------------------------
1) Create the Unit Test Repository Owner
   sqlplus system/password@tns_alias @create_ut_owner dtgen
     - OR -
   sqlplus system/password@tns_alias @create_ut_owner dtgen_dev

2) Run SQL*Developer and Create a Unit Test Repository
   -) Tools -> Unit Test -> Select Current Repository: dtgen_test
   -) Tools -> Unit Test -> Create/Update Repository: (answer questions as needed)

   Share the Unit Test Repository?

3) Install Unit Test Repository Owner Objects
   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen
     - OR -
   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen_dev

4) Load Test Parameters
   sqlldr dtgen/dtgen control=test_parms_dataload.ctl
     - OR -
   sqlldr dtgen_dev/dtgen_dev control=test_parms_dataload.ctl

4) Run SQL*Developer and Load Unit Tests
   -) Tools -> Import from File -> ???

5) Set the names as needed in t.sh
   export GUI_DIR=../../gui
   export DEVNAME=dtgen
   export DEVPASS=dtgen
     - OR -
   export GUI_DIR=../../dev/gui
   export DEVNAME=dtgen_dev
   export DEVPASS=dtgen_dev

6) Confirm Test Settings
   ./t.sh -p

7) Setup the Unit Test Environments
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
