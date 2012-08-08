
DTGen "test" README File
   Developed by DMSTEX (http://dmstex.com)


Files and Directories:
----------------------
asof        - Directory with ASOF DEMO testing
basics      - Directory with BASICS DEMO testing
cleanup.sh  - Linux Script to remove test objects from database
dtgen       - Directory for DTGEN installation and generation testing
gui         - Directory with GUI DEMO testing
remove.sh   - Removes all test logins from the TNS_ALIAS database
setup.sh    - Creates all test logins in the TNS_ALIAS database
test.sh     - Main test script for testing DTGEN
tiers       - Directory with TIERS DEMO testing


Each test directory contains the following scripts that are called
from the script with the same name in this directory:
  -) setup.sh
  -) test.sh
  -) cleanup.sh
  -) remove.sh
