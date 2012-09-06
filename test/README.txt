
DTGen "test" README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
create_ut_objs.sql    - Run as "dtgen_test" to create Unit Test Objects
                        &1. - Generator Schema Object Owner Name
create_ut_owner.sql   - Run as sys to create Unit Test Repository Owner
                        &1. - Generator Schema Object Owner Name
create_ut_syns.sql    - Called by "t.sh setup"
drop_ut_owner.sql     - Run as sys to drop Unit Test Repository Owner
g.sql                 - Creates some GUI stuff
t.sh                  - Script to test the DTGen application
                        t.sh (setup|test|cleanup|remove|-p) {test directory}
test_gen.pkb          - Called by create_ut_objs to create TEST_GEN package
test_gen.pks          - Called by create_ut_objs to create TEST_GEN package
test_rig.pkb          - Called by create_ut_objs to create TEST_RIG package
test_rig.pks          - Called by create_ut_objs to create TEST_RIG package

Obsoleted:
----------
create_ut_logins.sql  - Run as sys to create Test Environments
                        Calls supp/create_owner and supp/create_user
drop_ut_logins.sql    - Run as sys to drop the Test Environments
                        Calls supp/drop_owner and supp/drop_user
install_usyn.sql      - Dummy User Synonym Script for supp/create_user.sql
                        Note: The user synonyms are created by test_gen.gen_load

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

In-Install Instructions:
------------------------
1) Remove the Unit Test Environments
   ./t.sh remove

2) Remove the Unit Test Repository Owner
   sqlplus system/password@tns_alias @drop_ut_owner


Testing Notes:
--------------
After Dropping User Synonyms:
      p('select substr(object_name,1,30), object_type, status');
      p(' from  user_objects');
      p('/');
After Dropping OLTP:
   p('select view_name, text_length, view_type_owner');
   p(' from  user_views');
   p('/');
   p('select substr(object_name,1,30), object_type, status');
   p(' from  user_objects');
   p(' where object_type = ''PACKAGE BODY''');
   p('  and  object_name not like ''%_POP''');
   p('/');
After Dropping DIST:
      p('select trigger_name, trigger_type, table_name');
      p(' from  user_triggers where base_object_type = ''TABLE''');
      p('/');
      p('select substr(owner||''.''||constraint_name,1,40)');
      p('      ,constraint_type, table_name');
      p(' from  user_constraints');
      p(' where constraint_type not in (''P'',''U'',''R'')');
      p('/');
After Dropping INTEG:
   p('select trigger_name, trigger_type, table_name');
   p(' from  user_triggers where base_object_type = ''TABLE''');
   p('/');
   p('select substr(owner||''.''||constraint_name,1,40)');
   p('      ,constraint_type, table_name');
   p(' from  user_constraints');
   p(' where constraint_type not in (''P'',''U'',''R'')');
   p('/');
After Dropping ODS:
   p('select substr(object_name,1,30), object_type, status');
   p(' from  user_objects where object_type = ''PACKAGE BODY''');
   p('/');
   p('select table_name, tablespace_name');
   p(' from  user_tables');
   p('/');
   p('select sequence_name, min_value, max_value, last_number');
   p(' from  user_sequences');
   p('/');
After Dropping GDST:
   p('select substr(object_name,1,30), object_type, status');
   p(' from  user_objects');
   p('/');
After Dropping GLOB:
   p('select substr(object_name,1,30), object_type, status');
   p(' from  user_objects');
   p('/');
