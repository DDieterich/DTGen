
DTGen "test" README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
create_ut_logins.sql  - Run as sys to create Test Environments
                        Calls supp/create_owner and supp/create_user
create_ut_objs.sql    - Run as "dtgen_test" to create Unit Test Objects
                        &1. - Generator Schema Object Owner Name
create_ut_owner.sql   - Run as sys to create Unit Test Repository Owner
                        &1. - Generator Schema Object Owner Name
create_ut_syns.sql    - Called by create_ut_logins.sql
drop_ut_logins.sql    - Run as sys to drop the Test Environments
                        Calls supp/drop_owner and supp/drop_user
drop_ut_owner.sql     - Run as sys to drop Unit Test Repository Owner
g.sql                 - Creates some GUI stuff
install_usyn.sql      - Dummy User Synonym Script for supp/create_user.sql
                        Note: The user synonyms are created by test_gen.gen_load
test_gen.pkb          - Called by create_ut_objs to create TEST_GEN package
test_gen.pks          - Called by create_ut_objs to create TEST_GEN package
test_rig.pkb          - Called by create_ut_objs to create TEST_RIG package
test_rig.pks          - Called by create_ut_objs to create TEST_RIG package


Installation Instructions:
--------------------------
1) Create the Unit Test Repository Owner

   sqlplus system/password@tns_alias @create_ut_owner dtgen
     - OR -
   sqlplus system/password@tns_alias @create_ut_owner dtgen_dev

2) Run SQL*Developer and Create a Unit Test Repository

   -) Tools -> Unit Test -> Select Current Repository: dtgen_test
   -) Tools -> Unit Test -> Create/Update Repository: (answer questions as needed)

3) Install Unit Test Repository Owner Objects

   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen
     - OR -
   sqlplus dtgen_test/dtgen_test@tns_alias @create_ut_objs dtgen_dev

4) Run SQL*Developer and Load Unit Tests

   -) Tools -> Import from File -> ???

4) Install the Unit Test Environments

   sqlplus system/password@tns_alias @create_ut_logins


Removal Instructions:
---------------------
sqlplus system/password@tns_alias
 SQL> @drop_ut_logins
 SQL> @drop_ut_owner
 SQL> exit
