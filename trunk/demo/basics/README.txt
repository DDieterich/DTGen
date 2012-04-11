
DTGen Demonstration #1
   Developed by DMSTEX (http://dmstex.com)


Table of Contents:
------------------
 -) Introduction
 -) Exercise #1: Basic Generation
 -) Exercise #2: Sequences and Surrogate Primary Keys
 -) Exercise #3: Indexed Foreign Keys and Natural Keys
 -) Exercise #4: Natural Key Updatable Views
 -) Exercise #5: Full Path Hierarchy Data
 -) Exercise #6: Enforced Descrete Domains
 -) Exercise #7: Enforced Case Folding
 -) Exercise #8: Full Procedural APIs
 -) Exercise #9: Custom Check Constraints


File Descriptions in this directory:
------------------------------------
assemble.pkb       - Used by install.sql
assemble.pks       - Used by install.sql
f900.sql           - APEX export of the GUI source for DTGen
generate.pkb       - Used by install.sql
generate.pks       - Used by install.sql
install.sql        - Installs DTGen in an Oracle database
install_db.sql     - Used by install.sql
uninstall.sql      - Uninstalls DTGen


Introduction:
-------------
  The set of exercises in this demonstration is focused on basic DTGen functionality.  All functionality in this demonstration is available through both command line and graphical user interface (GUI) forms.  For simplicity in understanding the under-lying workings of DTGen, this demonstration is conducted entirely by command-line.  No GUIs were injured in the production of this demonstration.
  
  The "create_demo_users.sql" script must be run before these exercises.  The "drop_demo_users.sql" script will remove all demonstration objects from the database.
  
  The DTGen database objects must be installed in the database and ready to generate code.


Exercise #1: Basic Generation
-----------------------------
  Based on Oracle's demobld.sql script, this exercise implements the EMP and DEPT tables using DTGen.
