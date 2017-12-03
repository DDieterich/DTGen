# Pre-Release 0.12 #

## New Features ##

  * Issue 29: Allow %ROWTYPE record for "DML" ins and upd procedures
  * Issue 34: Add Custom Copyright Notice to PL/SQL Generated Code
  * Issue 44: Add an Option to Constrain Audited Users Against SYS.USR$
  * Issue 45: Add Tablespace Storage for Individual Tables
  * Issue 46: Add an Update Reserve Percentage for each Column to set PCTFREE
  * Issue 54: Cache GLOB Settings at Mid-Tier
  * Issue 73: Cache SQL Script Changes in Generate and Only Save Differences
  * Issue 78: Read-Only Views Need Trigger Errors
  * Issue 7: Specify storage name for (and drop) LOB columns

## Open Issues ##

  * Issue 2: Need Temporal Continuity Test with "select for update" on FKs
  * Issue 31: Can't Generate Table with more than 10 Natural Key Columns
  * Issue 35: Par\_NK\_Path needs to be CLOB
  * Issue 55: Need a Temporal Quantization for Date/Time Data
  * Issue 57: Need an Application Version Number Field
  * Issue 59: Need a Foreign Key Constraint from AUD/HIST Table to NON Table
  * Issue 68: Allow CLOB Distribution to Mid-Tier Using Materialized Views
  * Issue 69: DML Package _ACT%ROWTYPE needs FK and Paths Updated before call return
  * Issue 40: Need Regresion Testing
  * Issue 41: Need Performance Testing
  * Issue 3]: Add CLOB Datatype (longer than 32K)
  * Issue 38: Add GeoLocation (Locator) Datatype
  * Issue 4]: Add Image Datatype
  * Issue 5]: Add/Change tab\_cols default to accept single value select statement
  * Issue 6]: Change DOMAIN Descriptions
  * Issue 14: Need Entity Sub-Types
  * Issue 11: Reduction of Redundant Indexes
  * Issue 56: Maximum Number of Tables for GUI is 200
  * Issue 42: Convert SQL FOR Loops to Associative Arrays
  * Issue 16: Limited generation and assembly in the GUI.
  * Issue 21: More than 99 columns in a generated table
  * Issue 52: Index Organized Tables and Table Clusters
  * Issue 65: Add result-caching to DML functions for a materialized view
  * Issue 66: Remove "when others then raise" from generator
  * Issue 94: Speed-Up GUI Generation for DTGEN
  * Issue 25: DTGen Notes is Out-of-Date
  * Issue 64: Mid-Tier SQL on Base (Active) Table Doesn't Work
  * Issue 13: Extra Button on OMNI and AS\_OF records
  * Issue 95: SQL\*Loader Won't Recognize Last Null Column
  * Issue 17: Add application packages to the FILES table
  * Issue 28: Convert Maintenance Forms to JQGrid
  * Issue 36: Code around Oracle Bug 4771052
  * Issue 51: Deal with (PL/SQL and SQL) (Reserved Words and Keywords)
  * Issue 58: Need a DOD Audit Parameter for Application Generation
  * Issue 67: Replace '' with new q' syntax
  * Issue 71: dbid and db\_auth have changed functions
  * Issue 72: Change Unit/Regression Testing to use UTP Application
  * Issue 88: Is the GENERATE.allow\_add\_row function necessary?
  * Issue 90: Change FILE\_LINES and FILES from LOG to NON Tables
  * Issue 96: Remove Potential Database Schema Object Name Conflicts
  * Issue 9]: Automatic Re-direct for Multi-Tier Deployment
  * Issue 23: Allow generated scripts to be run with APEX
  * Issue 8]: Develop Sample Generation Exercise
  * Issue 15: Need Application Copy Function
  * Issue 39: Interface with Oracle DataModeler
  * Issue 37: Generate Performance Test Dataloads_

## Closed Issues ##

  * Issue 32 Defect (Fixed): Foreign Key Prefixes in _ACT view join needs to be Unique
  * Issue 33 Defect (Fixed): Need more than 100,000 lines in FILE\_LINES
  * Issue 50 Defect (Fixed): ORU-10027: buffer overflow
  * Issue 82 Defect (Fixed): POP INSERT throws no aud\_prev\_beg\_usr data error
  * Issue 92 Defect (Fixed): Can't Generate New Files in DTGen GUI
  * Issue 91 Defect (Fixed): GUI File Assembly Replaces Files in Other Applications
  * Issue 12 Defect (Fixed): Date Format Incorrect on ASOF Reports Menu
  * Issue 26 Defect (Fixed): Column Name Too Long Throws UnHandled Exception
  * Issue 60 Defect (Fixed): LOG/EFF Table Views Won't Join with NON Table Views
  * Issue 61 Defect (Fixed): New AUD\_BEG\_USR and AUD\_BEG\_DTM not set when IGNORE\_NO\_CHANGE and there are not changes
  * Issue 62 Defect (Fixed): UTIL.ERR is not capturing Error Location
  * Issue 63 Defect (Fixed): Missing Error Checking for Incomplete Schema
  * Issue 86 Defect (Fixed): Mid-Tier Sequence Does Not Work
  * Issue 27 Enhancement (WontFix): Some Columns Nullable in a Multi-Column Natural Key
  * Issue 29 Enhancement (Fixed): Allow %ROWTYPE record for "_DML" ins and upd procedures
  * Issue 30 Enhancement (Fixed): Reduce Exception Masking of Location of Other Errors
  * Issue 34 Enhancement (Fixed): Add Custom Copyright Notice to PL/SQL Generated Code
  * Issue 43 Enhancement (Fixed): Remove Circular FK Reference Limit
  * Issue 44 Enhancement (Fixed): Add an Option to Constrain Audited Users Against SYS.USR$
  * Issue 45 Enhancement (Fixed): Add Tablespace Storage for Individual Tables
  * Issue 46 Enhancement (Fixed): Add an Update Reserve Percentage for each Column to set PCTFREE
  * Issue 47 Enhancement (WontFix): Need to explicitly define schema owner during database object creation
  * Issue 48 Enhancement (Fixed): Need to Change Single Column Table Constraints to Column Constraints
  * Issue 49 Enhancement (Fixed): IS NOT NULL not required in APPLICATIONS table constraints
  * Issue 53 Enhancement (Fixed): Change DELETE\_TAB script to UTIL.DELETE\_TAB function
  * Issue 54 Enhancement (Fixed): Cache GLOB Settings at Mid-Tier
  * Issue 70 Enhancement (Fixed): application.db\_schema\_exp is no longer used
  * Issue 73 Enhancement (Fixed): Cache SQL Script Changes in Generate and Only Save Differences
  * Issue 74 Enhancement (Fixed): Header Comments Need to be Consolidated in Generate
  * Issue 75 Enhancement (Fixed): Don't Update Created\_DT in FILES when generating
  * Issue 76 Enhancement (Fixed): SQL Scripts Need Consistent Use of "/"
  * Issue 77 Enhancement (Fixed): ORA-20013: load\_nk\_aa() is not a Generated Error
  * Issue 78 Enhancement (Fixed): Read-Only Views Need Trigger Errors
  * Issue 79 Enhancement (Fixed): vtrig\_fksets has varchar parameters instead of varchar2
  * Issue 80 Enhancement (Duplicate): Delete\_ODS Script Needs to be Procedure
  * Issue 81 Enhancement (Fixed): DB Link Too Complicated to Create with DTGen
  * Issue 83 Enhancement (Fixed): POP Audit using local time instead of GLOB time
  * Issue 84 Enhancement (Fixed): POP UPDATE using HOA data instead of Active data
  * Issue 85 Enhancement (Fixed): POP Function is missing Exception Handler
  * Issue 87 Enhancement (Fixed): update active view trigger missing _ACT in name
  * Issue 89 Enhancement (Fixed): Remove Database Object Reports from Drop SQL Scripts
  * Issue 93 Enhancement (WontFix): Faster returning FK NK lookups in_VIEW.ins and 