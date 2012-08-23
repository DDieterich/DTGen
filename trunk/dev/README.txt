
DTGen "dev" README File
   Developed by DMSTEX (http://dmstex.com)

Because DTGen is used to create DTGen, development is a little tricky.  Somehow, a current version of DTGen must be "morphed" into a newer version of DTGen.  This directory provides scripts to facilitate that morphing process.  The full procedure is decribed in the DTGen Wiki Page "https://code.google.com/p/dtgen/wiki/DTGenModificationProcedure"

Files and Directories:
----------------------
cleanup.sh  - Linux Script to remove new DTGen objects from database
d.env       - Defines environment variables
d.sh        - Main script that runs other scripts
              Usage: d.sh (setup|test|cleanup|remove)
load.sh     - Loads the new DTGen environment.
remove.sh   - Removes new DTGen logins
setup.sh    - Creates new DTGen logins

F900 Update
-----------
To update the F900 APEX GUI Application, see "How to create an application in APEX that uses the generated GUI" in the top-level README.TXT document.
