# Introduction #

Since DTGen generates DTGen, there is a need for 2 DTGen(s) during development:

  * DTGen to generate DTGen\_Dev
  * DTGen\_Dev to test prior to overwriting DTGen

The following procedure uses the "dev" directory to accomplish that effort.  The following environment is assumed for the procedure:

  * The "trunk" directory is up-to-date from Sub-Version
  * DTGen is installed in schema "dtgen" in an Oracle database
  * "dtgen\_dataload.dat" has been loaded into the "dtgen" schema.
  * The DTGen GUI (f900) is installed in the same Oracle database.


# Details #

## Complete Changes to DTGen ##

Ensure that the changes to DTGen are as complete as possible.  Do not make any changes that will cause it not to work.  DTGen will be copied to the "dev" directory.  Any changes to DTGen, after the copy is made, will need to be duplicated in the "dev" directory.

With this step complete, commit changes to Sub-Version.


## Setup the DTGen\_Dev Environment ##

If a previous DTGen\_Dev environment remains, run this command in the "dev" directory to remove it.

  * ./d.sh remove

Review and modify as necessary the following scripts:

  * dev/d.sh
  * dev/d.env
  * dev/setup.sh
  * dev/test.sh
  * dev/cleanup.sh
  * dev/remove.sh

Review the Supplemental Scripts for required changes in the "supp" directory.

Run this command in the "dev" directory to setup the DTGen\_Dev environment.

  * ./d.sh setup


## Set the APEX Configuration for Testing ##

Run APEX and add the DTGen\_Dev environment schema (dtgen\_dev) to the workspace that contains the DTGen APEX application (ID 900).

Run the DTGen GUI and change the "Schema Name" for the DTGen application to the DTGen\_Dev environment (dtgen\_dev).  _(With care, the "Schema Name" can be set to "&1".  The DTGen\_Dev environment schema name would need to be passed to the "@install\_gui" as the first parameter.)_


## Load DTGen\_Dev ##

This step will use the old DTGen environment to generate a new version of DTGen\_Dev.

  * ./d.sh load

_Note: If this command needs to be run repeatedly, run "./d.sh cleanup" from the "dev" directory to remove the DTGen\_Dev database objects before re-running "./d.sh load"_

_Note: If this command needs to be run repeatedly, the SQL\*Loader control file "dtgen\_dataload2.ctl" can be created.  The "dev/d.sh load" script will not overwrite "dtgen\_dataload2.ctl".  The "dev/d.sh load" command will use "dtgen\_dataload2.ctl", instead of "dtgen\_dataload.ctl", if "dtgen\_dataload2.ctl" exists.  Otherwise, "dev/d.sh load" will use "dtgen\_dataload2.ctl"._


## Copy Program/Module Source to DTGen\_Dev ##

Copy the following Program/Module Sources from "src" to "dev":

  * comp.sql
  * dtgen\_util.pkb
  * dtgen\_util.pks
  * generate.pkb
  * generate.pks
  * gui/gui\_app\_tree\_vw.sql
  * gui/gui\_util.pkb
  * gui/gui\_util.pks


## Complete Changes to DTGen\_Dev ##

The above listed Program/Module Sources can be compiled and tested using DTGen\_Dev.  Additionally, the dtgen\_dataload.ctl can be modified and tested.  With this step complete, the DTGen\_Dev should be fully available in the database with all source compiled and dtgen\_dataload.ctl loaded.


## Regression Test DTGen\_Dev ##

The following procedures are found in README.txt in the "test" directory.  (The test environment can be switched between DTGen and DTGen\_Dev):

  * Installation Instructions
  * Testing Instructions
  * Un-Install Instructions


## Update APEX GUI ##

Switch the compile schema for APEX application 900 to the dev environment.  Install the new APEX GUI forms:

  * sqlplus (owner)/(password)
  * SQL> spool install\_gui
  * SQL> @install\_gui
  * SQL> exit

Open the DTGen APEX application (f900) in the APEX editor and review the page numbers below 1000 for changes.

Export the "f900" application to "trunk/test/dtgen".


## Overwrite Old DTGen Program/Module Source ##

Copy the following Program/Module Sources from "dev" to "src":

  * comp.sql
  * dtgen\_util.pkb
  * dtgen\_util.pks
  * generate.pkb
  * generate.pks

Copy the following Program/Module Sources from "dev/gui" to "gui":

  * gui\_app\_tree\_vw.sql
  * gui\_util.pkb
  * gui\_util.pks

Copy one of the following SQL\*Loader control files from "dev" to "supp/dtgen\_dataload.ctl":

  * dtgen\_dataload.ctl
  * dtgen\_dataload2.ctl (This is usually the choice, if it exists)

Review and update files in the following directories:

  * src
  * supp

NOTE: Wait until the next step to review and modify "trunk/uninstall.sql"

## Re-Install DTGen ##

Un-Install the DTgen by running the "uninstall.sql" script in the "trunk" directory.

After a successful uninstall, review and update the "uninstall.sql" file so it is compatible with the "new" DTGen.

Install the DTgen\_Dev by running the "install.sql" script in the "trunk" directory.

Load the DTGen data into the new installation using the following command in the "supp" directory:

  * sqlldr dtgen/dtgen CONTROL=dtgen\_dataload.ctl


## Reset the APEX Configuration ##

Reload the GUI scripts using gui/gui\_comp.sql

Run the DTGen GUI and change the "Schema Name" for the DTGen application to the normal environment (dtgen).


## Review and Test Demo ##

If a previous version of the demo is installed, remove it with the "drop\_demo\_users.sql" script in the "trunk/demo" directory.

Review and test all demonstration scripts in the "trunk/demo" directory.


## Update Documentation ##

Review and update as needed the "README.txt" documents in the following directories:

  * src
  * demo
  * demo/asof
  * demo/basics
  * demo/gui
  * demo/tiers

Review and update as needed the documents in "docs"


## Cleanup ##

Run "./d.sh remove" from the "dev" directory to remove testing objects from the database and file system.