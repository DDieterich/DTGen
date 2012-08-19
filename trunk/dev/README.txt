
DTGen "dev" README File
   Developed by DMSTEX (http://dmstex.com)

Because DTGen is used to create DTGen, development is a little tricky.  Somehow, a current version of DTGen must be "morphed" into a newer version of DTGen.  This directory provides scripts to facilitate that morphing process.  The full procedure is decribed in the DTGen Wiki Page "https://code.google.com/p/dtgen/wiki/DTGenModificationProcedure"

Files and Directories:
----------------------
cleanup.sh  - Linux Script to remove new DTGen objects from database
load.sh     - Main script that loads new DTGen environment.
remove.sh   - Removes all new DTGen logins from the TNS_ALIAS database
setup.sh    - Creates all new DTGen logins in the TNS_ALIAS database
