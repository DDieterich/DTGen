The following procedures are found in README.txt in the "test" directory:
  * Installation Instructions
  * Testing Instructions
  * Un-Install Instructions

> # Functional Testing #
    1. ## Fundamental Database Features ##
      1. _**DTC**_: Datatype Support for Columns
        1. NUMBER
        1. VARCHAR2
        1. VARCHAR2(4001) conversion to CLOB
        1. DATE
        1. TIMESTAMP WITH TIME ZONE
        1. TIMESTAMP WITH LOCAL TIME ZONE
      1. _**EDDC**_: Enforced Discrete Domains (no FK) for Columns
      1. _**NNCC**_: Not NULL Constraints for Columns
      1. _**CCCT**_: Custom Check Constraints for Tables
        1. _Equality/Inequality:_ =, !=, ^=, <>, >, <, >=, <=
        1. _Logical Conditions:_ NOT, AND, OR, BETWEEN, EXISTS, IN, LIKE
        1. _NULL Conditions:_ IS NULL, IS NOT NULL
        1. _Compound Conditions:_ (, )
        1. _Operators:_ , `*`, /, +, -, 
      1. _**CIT**_: Custom Indexes for Tables
        1. UNIQUE
        1. Non-UNIQUE
      1. Comment Generation
        1. _**CGC**_: Column Comments
        1. _**CGT**_: Table Comments
        1. _**CGV**_: View Comments
      1. _**TST**_: Tablespace Storage for Tables
        1. Application Default Tablespace for ACTIVE tables
        1. Application Default Tablespace for History/Audit tables
        1. Application Default Tablespace for ACTIVE indexes
        1. Application Default Tablespace for History/Audit indexes
        1. Table Specific Tablespace for ACTIVE tables
        1. Table Specific Tablespace for History/Audit tables
        1. Table Specific Tablespace for ACTIVE indexes
        1. Table Specific Tablespace for History/Audit indexes
    1. ## Augmented Application Functionality ##
      1. _**NKUV**_: Natural Key Update-able Views
        1. INSERT with/without Primary Key
        1. INSERT with/without EFF\_START\_DTM
        1. INSERT with Foreign Key
          1. Primary Key
          1. Natural Key(s)
          1. PK Full Path
          1. NK Full Path
        1. UPDATE with/without EFF\_START\_DTM
        1. UPDATE with Foreign Key
          1. Primary Key
          1. Natural Key(s)
          1. PK Full Path
          1. NK Full Path
        1. DELETE
      1. _**APIT**_: Full Procedural APIs for each Table
        1. INSERT
          1. Column List
          1. Table Record
          1. View Record
        1. INSERT with/without Primary Key
        1. INSERT with/without EFF\_START\_DTM
        1. INSERT with Foreign Key
          1. Primary Key
          1. Natural Key(s)
          1. PK Full Path
          1. NK Full Path
        1. UPDATE
          1. Column List
          1. Table Record
          1. View Record
        1. UPDATE with/without EFF\_START\_DTM
        1. UPDATE with nkdata\_provided\_in
          1. TRUE
          1. FALSE
          1. NULL
        1. UPDATE with Foreign Key
          1. Primary Key
          1. Natural Key(s)
          1. PK Full Path
          1. NK Full Path
        1. DELETE with/without EFF\_END\_DTM
      1. _**DMLIT**_: DML SQL Integrity Enforcement for Tables/Views
        1. INSERT with/without Primary Key
        1. INSERT with/without EFF\_START\_DTM
        1. UPDATE with/without EFF\_START\_DTM
        1. DELETE
      1. _**FPHC**_: Full Path Hierarchical Data for Columns
        1. Primary Key Full Path
        1. Natural Key Full Path
      1. _**CFC**_: Enforced Case Folding for Columns
        1. UPPER
        1. LOWER
        1. INITCAP
      1. _**HAT**_: History and Audit for Tables
        1. Optional Effectivity
        1. Point-in-Time **_ASOF_** View
      1. _**POPT**_: Audited **_POP_** Function for Tables
        1. Pop Deleted Record
        1. Replace an Active Record
        1. Pop Active Record
    1. ## Augmented Schema Functionality ##
      1. _**AIT**_: Automatic Indexes for Tables
        1. Foreign Keys
        1. Natural Keys
      1. _**PFT**_: Calculated PCTFREE for Tables
        1. Datatype storage size
        1. Default PCTFREE for required columns
        1. Default PCTFREE for non-required columns
      1. _**MTD**_: Multi-Tiered Deployment
        1. Database Tier, Schema Owner
        1. Database Tier, Application User
        1. Middle Tier, Schema Owner
        1. Middle Tier, Application User
      1. _**MMV**_: Middle Tier Materialized View
    1. ## Cross-Cutting Concerns ##
      1. Lock Helper for Global Single Threaded Logic
      1. Debug Logging using Autonomous Transaction
      1. Error Logging using Autonomous Transaction
      1. Long Operations Tracking
      1. Self-Reporting Version Number
    1. ## Source code Generation Specifics ##
      1. Copyright in File Header
      1. Always over-writes previous file
      1. Database object compilation results reporting
    1. ## Default Maintenance User Interface ##
      1. Data Domain Filterable Grid Edit
      1. Generated PL/SQL for CLOB DML
      1. Comprehensive **_OMNI_** View Forms
      1. GUI Query-able Reporting
        1. **_ASOF_**
        1. **_OMNI_**

> # Global Parameter Options #
| **Test Set** | **DB Integrity** | **Case Correction** | **Ignore No Change** |
|:-------------|:-----------------|:--------------------|:---------------------|
| A (Default) | Yes | Yes | Yes |
| B | Yes | Yes | No |
| C | Yes | No | Yes |
| D | Yes | No | No |
| E | No | Yes | Yes |
| F | No | Yes | No |
| G | No | No | Yes |
| H | No | No | No |

**Note:** "NK\_SEP" and "PATH\_SEP" parameters are not tested.

> # Unit Test Configurations #
| DB Account Names     | **DB Schema** | **DB User**    | **MT Schema** | **MT User** |
|:---------------------|:--------------|:---------------|:--------------|:------------|
| **Application Test 1** | T1DBS       | T1DBU        | T1MTS       | T1MTU     |
| **Application Test 2** | T2DBS       | T2DBU        | T2MTS       | T2MTU     |
| **Application Test 3** | T3DBS       | T3DBU        |             |           |
| **DTGen**              | DTGEN(_dev)_| DTGENU(_dev)_|             |           |

**Note:** Multiple Oracle Owners/Schema are created in a single database.  The special database link "loopback" is used to simulate the connection between the database and the mid-tier.

| **v From v \ To -->** | **DB Schema** | **MT Schema** |
|:----------------------|:--------------|:--------------|
| **DB User**           | Synonym     |             |
| **MT Schema**         | DB Link     |             |
| **MT User**           |             | Synonym     |

> # Boundary Condition Testing #
| **Condition Name**                               | **Lowest** | **Highest** | **Nullable** |
|:-------------------------------------------------|:-----------|:------------|:-------------|
| Number of Tables                               | 1        | 200       | No         |
| Number of Columns in a Table                   | 1        | 99        | No         |
| Number of Natural Key Columns                  | 1        | 99        | No         |
| NUMBER Datatype Length                         | 1        | 38        | Yes        |
| NUMBER Datatype Scale                          | -84      | 127       | Yes        |
| NUMBER Absolute Value                          | 10<sup>-130</sup> | 10<sup>126</sup>   | N/A        |
| VARCHAR2 Datatype Length                       | 1        | 32767     | No         |
| DATE Absolute Value                            | 4712 BC  | 4713 AD   | N/A        |
| TIMESTAMP WITH TIME ZONE Datatype Length       | 0        | 9         | Yes        |
| TIMESTAMP WITH LOCAL TIME ZONE Datatype Length | 0        | 9         | Yes        |
| TIMESTAMP Absolute Value                       | 4712 BC  | 9999 AD   | N/A        |
| Exception Code                                 | -20999   | -20000    | No         |

> # Implementation #

> ## TST1: Application Test 1 ##

  * TST: Override Default Tablespace and Table Defined Tablespaces
  * MTD: Multi-Tiered Deployment

> ### Tables: T1A\_NON, T1A\_LOG, and T1A\_EFF ###

  * DTC: Datatype Support for Columns
    * NUMBER Datatype Length Boundary Test
    * NUMBER Datatype Scale Boundary Test
    * VARCHAR2 Datatype Length Boundary Test (No CLOB)
    * TIMESTAMP WITH TIME ZONE Datatype Length Boundary Test
    * TIMESTAMP WITH LOCAL TIME ZONE Datatype Length Boundary Test
  * POPT: Audited POP Function for Tables (Effectivity and Basic Data Movement)
  * HAT: History and Audit for Tables (Effectivity and Basic Data Movement)
  * APIT: Full Procedural APIs for each Table (Table ROWTYPE and Active View ROWTYPE API)
  * DMLIT: DML SQL Integrity Enforcement for Tables/Views (with Primary Key and Effective Start Date/Time)

> ## TST2: Application Test 2 ##

  * TST: Default Tablespaces, Table Defined Tablespaces
  * NTC: No Triggers/Constraints Installed
  * MTD: Multi-Tiered Deployment

> ### Tables: T2A\_NON, T2A\_LOG, and T2A\_EFF ###

  * NNCC: Not NULL Constraints for Columns
  * CIT: Custom Indexes for Tables
  * AIT: Automatic Indexes for Tables
  * PFT: Calculated PCTFREE for Tables
  * CGC: Column Comments
  * CGT: Table Comments
  * CGV: View Comments

> ### Tables: T2B\_NON, T2B\_LOG, and T2B\_EFF ###

  * POPT: Audited POP Function for Tables (All View)
  * HAT: History and Audit for Tables (Point In Time ASOF)
  * APIT: Full Procedural APIs for each Table (Column Oriented API)
  * DMLIT: DML SQL Integrity Enforcement for Tables/Views (without Primary Key or Effective Start Date/Time)
  * CCCT: Custom Check Constraints for Tables
  * CFC: Enforced Case Folding for Columns (Values Returned through all 3 APIs)
  * EDDC: Enforced Discrete Domains (no FK) for Columns
  * FPHC: Full Path Hierarchical Data for Columns
  * NKUV: Natural Key Update-able Views

> ## TST3: Application Test 3 ##

  * ???

> ### Tables: T3A\_NON, T3A\_LOG, and T3A\_EFF ###

  * DTC: Datatype Support for Columns
    * VARCHAR2 Datatype Length Boundary Test (CLOB)