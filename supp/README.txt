
DTGen "supp" (Supplemental Materials) README File
   Developed by DMSTEX (http://dmstex.com)


File descriptions in this directory
-----------------------------------
create_owner.sql - Sample script to creates the application schema owner with roles
                   (The name of the schema owner is the first parameter)
                   (schema owner is the "apex_app_name" for the application)
                   (The initial password is the same as the schema owner)
create_user.sql  - Sample script create the application user login with synonyms
                   (The name of the schema owner is the first parameter)
                   (The user login is the second parameter)
                   (The initial password is the same as the user login)
comp_file.sql    - Used by an alternaitve path in fullgen.sql
delete_ods.sql   - Sample script to delete all data from DTGen tables
fullgen.sql      - Sample script to generate all scripts for an application
                   (The ABBR of the application is the first parameter)
select_file.sql  - Used by an alternaitve path in fullgen.sql


Scripts created by fullgen.sql:
-------------------------------
install_db.sql     - Creates the schema objects needed for the database (data-tier)
                      -) GLOBal objects (Global Types, UTIL_LOG, and UTIL & GLOB Package)
                      -) ODS objects (Sequences, Tables, Indexes, and POP Packages)
					  -) INTEGrity objects (Table Constraints/Triggers and TAB Packages)
					  -) OLTP objects (Views, View Packages, and DML Packages)
					  -) MODuleS objects (Place holder for Tailored Packages)
dtgen_dataload.ctl - SQL*Loader control file to load data that will generate DTGen
install_db_sec.sql - Creates security for the schema objects needed for the database
install_mt.sql     - Creates the schema objects needed for the mid-tier
                      -) Global DIST objects (Global Synonyms, UTIL_LOG, and UTIL Package)
					  -) DISTribution objects (Distributed Synonyms, MVs, and TAB Packages)
					  -) OLTP objects (Views, View Packages, and DML Packages)
					  -) MODuleS objects (Place holder for Tailored Packages)
install_mt_sec.sql - Creates security for the schema objects needed for the mid-tier
install_usr.sql    - Creates synonyms for the application user
install_gui.sql    - Creates the Maintenance GUI (Forms, Reports, Menus, LOVs, and Preferences)
uninstall_usr.sql  - Drops synonyms for the application user
uninstall_mt.sql   - Drops the schema objects needed for the mid-tier
uninstall_db.sql   - Drops the schema objects needed for the database (data-tier)


Scripts created by an alternaitve path in fullgen.sql:
------------------------------------------------------
comp.sql             - Creates application specific COMPiled packages, functions, and procedures
create_dist.sql      - Creates the DISTribution objects (Distributed Synonyms, MVs, and TAB Packages)
create_dist_sec.sql  - Creates security for the DIST objects
create_flow.sql      - Creates the Maintenance GUI (Forms, Reports, Menus, LOVs, and Preferences)
create_gdst.sql      - Creates the Global DIST objects (Global Synonyms, UTIL_LOG, and UTIL Package)
create_gdst_sec.sql  - Creates security for the Global DIST objects
create_glob.sql      - Creates the GLOBal objects (Global Types, UTIL_LOG, and UTIL & GLOB Package)
create_glob_sec.sql  - Creates security for the GlOB objects
create_integ.sql     - Creates the INTEGrity objects (Table Constraints/Triggers and TAB Packages)
create_integ_sec.sql - Creates security for the INTEG objects
create_mods.sql      - Creates the MODuleS objects (Place holder for Tailored Packages)
create_mods_sec.sql  - Creates security for the MODS objects
create_ods.sql       - Creates the ODS objects (Sequences, Tables, Indexes, and POP Packages)
create_ods_sec.sql   - Creates security for the ODS objects
create_oltp.sql      - Creates the OLTP objects (Views, View Packages, and DML Packages)
create_oltp_sec.sql  - Creates security for the OLTP objects
create_usyn.sql      - Creates synonyms for the application user
delete_ods.sql       - Deletes all data from the application schema
drop_dist.sql        - Drops the DISTribution objects
drop_gdst.sql        - Drops the Global DIST objects
drop_glob.sql        - Drops the GLOBal objects
drop_integ.sql       - Drops the INTEGrity objects
drop_mods.sql        - Drops the MODuleS objects
drop_ods.sql         - Drops the ODS objects
drop_oltp.sql        - Drops the OLTP objects
drop_usyn.sql        - Drops synonyms for the application user


Create an application in APEX to use "create_flow.sql":
-------------------------------------------------------
1) Create the APEX application
   -) Login to APEX as an administrator
   -) Create a workspace using the "apex_ws_name" for the application
   -) Login to APEX using the new workspace
   -) Create a new application
   -) Application Type: Database
   -) Create Application from Scratch
   -) Name: (Use the "apex_app_name" for the application)
   -) Application: (Any number will work)
   -) Create Application: From scratch
   -) Schema: (Use the "owner" for the application)
   -) Next button
   -) Page Type: Blank
   -) Page Name: Home
   -) Add Page button
   -) Next button
   -) Tabs: One Level of Tabs
   -) Next button
   -) Copy shared Components: No
   -) Next button
   -) Authentication Scheme: Application Express Authentication
   -) Language: English
   -) User Language Preference Derived From: Application Primary Language
   -) Date Format: DD-MON-YYYY HH24:MI:SS
   -) Next button
   -) Theme 21
   -) Save this definition as a design model for reuse
   -) Create button
2) Load the Maintenance GUI with Menu, LOVs, and Prefs
   -) In another window, run the command:
      sqlplus (owner)/(password)
      SQL> spool install_gui
	  SQL> @install_gui
	  SQL> exit
3) Add the Navigation List to Page 1
   -) Edit Page 1
   -) Click "Shared Components" (It's the gear icon on the toolbar)
   -) Click the "Lists" link in the "Navigation" Group
   -) Click on "Utility Menu"
      (Note: "Page 1" should be displayed in the toolbar next to the "stoplight" icon)
   -) Click the "Add this list to the current page" at the bottom of the page.
   -) Click "Next" and "Create List Region" (All the defaults work correctly).
4) Add Page 1 to the Breadcrumb
   -) Edit Page 1
   -) Click "Shared Components" (It's the gear icon on the toolbar)
   -) Click the "Breadcrumbs" link in the "Navigation" Group
   -) Click on "Breadcrumb" (It may be the only entry)
   -) Click on the Pencil ICON next to "Maintenance Manu"
   -) Change "Parent Entry" from "Select Parent" to "Page 1(Page 1)"
   -) Click "Apply Changes"
   -) Click on the Pencil ICON next to "Utility Log Report"
   -) Change "Parent Entry" from "Select Parent" to "Page 1(Page 1)"
   -) Click "Apply Changes"
   -) Click on the Pencil ICON next to "OMNI Reports Menu"
   -) Change "Parent Entry" from "Select Parent" to "Page 1(Page 1)"
   -) Click "Apply Changes"
   -) Click on the Pencil ICON next to "ASOF Reports Menu"
   -) Change "Parent Entry" from "Select Parent" to "Page 1(Page 1)"
   -) Click "Apply Changes"
