
DTGen "demo" (Demonstration Exercises) README File
   Developed by DMSTEX (http://dmstex.com)

File Descriptions in this directory:
------------------------------------
asof                   - Directory for ASOF Demonstration Exercises
basics                 - Directory for Basic Demonstration Exercises
create_demo_users.sql  - Script to create Database users for Exercises
drop_demo_users.sql    - Script to drop Database users for Exercises
gui                    - Directory for GUI Demonstration Exercises
tier                   - Directory for Tier Demonstration Exercises
vars.sql               - Variable Declarations for scripts

Introduction:
-------------
  Each demonstration directory contains several exercises.  The exercises are numbered and must be executed in sequential order.  The demo users must be created with the "create_demo_users.sql" script before the first exercise is run in any demonstration directory.  The demo users must be dropped with the "drop_demo_users.sql" script before the "create_demo_users.sql" script can be re-used.  The exercises also assume that the default username/password (dtgen/dtgen) is still in use for the generator.  Names and passwords are set at the top of each script and can be modified, if necessary.


Example Demonstration Procedure:
--------------------------------
sqlplus sys/password as sysdba @create_demo_user
cd basics
sqlplus /nolog @e1
sqlplus /nolog @e2
sqlplus /nolog @e3
sqlplus /nolog @e4
sqlplus /nolog @e5
sqlplus /nolog @e6
sqlplus /nolog @e7
sqlplus /nolog @e8
sqlplus /nolog @e9
cd ..
sqlplus system/password @drop_demo_user
