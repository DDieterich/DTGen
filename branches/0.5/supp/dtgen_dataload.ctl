--
-- DTGen SQL*Loader Control File
--
-- sqlldr username/password CONTROL=FILENAME
--
load data infile *
into table APPLICATIONS_ACT APPEND when key = 'APPLICATIONS                  ' fields terminated by ''
   (key FILLER position(1:31), abbr CHAR, name CHAR, db_schema CHAR, apex_schema CHAR, apex_ws_name CHAR, apex_app_name CHAR, dbid CHAR, db_auth CHAR, description CHAR)
into table DOMAINS_ACT APPEND when key = 'DOMAINS                       ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR, abbr CHAR, name CHAR, fold CHAR, len NUMERIC, description CHAR)
into table EXCEPTIONS_ACT APPEND when key = 'EXCEPTIONS                    ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR, code NUMERIC, name CHAR, message CHAR, cause CHAR, action CHAR)
into table PROGRAMS_ACT APPEND when key = 'PROGRAMS                      ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR, name CHAR, type CHAR, description CHAR)
into table TABLES_ACT APPEND when key = 'TABLES                        ' fields terminated by ''
   (key FILLER position(1:31), applications_nk1 CHAR, abbr CHAR, name CHAR, seq NUMERIC, type CHAR, group_name CHAR, mv_refresh_hr NUMERIC, ts_onln_data CHAR, ts_onln_indx CHAR, ts_hist_data CHAR, ts_hist_indx CHAR, description CHAR)
into table CHECK_CONS_ACT APPEND when key = 'CHECK_CONS                    ' fields terminated by ''
   (key FILLER position(1:31), tables_nk1 CHAR, tables_nk2 CHAR, seq NUMERIC, text CHAR, description CHAR)
into table DOMAIN_VALUES_ACT APPEND when key = 'DOMAIN_VALUES                 ' fields terminated by ''
   (key FILLER position(1:31), domains_nk1 CHAR, domains_nk2 CHAR, seq NUMERIC, value CHAR, description CHAR)
into table TAB_COLS_ACT APPEND when key = 'TAB_COLS                      ' fields terminated by ''
   (key FILLER position(1:31), tables_nk1 CHAR, tables_nk2 CHAR, name CHAR, seq NUMERIC, nk NUMERIC, req CHAR, fk_prefix CHAR, fk_tables_nk1 CHAR, fk_tables_nk2 CHAR, d_domains_nk1 CHAR, d_domains_nk2 CHAR, type CHAR, len NUMERIC, scale NUMERIC, fold CHAR, default_value CHAR, description CHAR)
into table INDEXES_ACT APPEND when key = 'INDEXES                       ' fields terminated by ''
   (key FILLER position(1:31), tab_cols_nk1 CHAR, tab_cols_nk2 CHAR, tab_cols_nk3 CHAR, tag CHAR, seq NUMERIC, uniq CHAR)
BEGINDATA
APPLICATIONS                  GENOracle GeneratorGENGENGENGEN_01&1.&2.Generates Oracle PL/SQL code and APEX User Interfaces
DOMAINS                       GENTTYPETable TypeU3An effectivity table type with begin and end timestamps
DOMAINS                       GENCTYPEColumn TypeU30Column Data type (number, varchar2, etc...)
DOMAINS                       GENFOLDCase FoldU1Upper case character fold
DOMAINS                       GENYNYes NoU1Yes, true, correct, or affirmative
DOMAINS                       GENFLAGFlagU1Flagged
DOMAINS                       GENFTYPEFile TypeU3Type of File
DOMAINS                       GENPTYPEProgram TypeU30Type of Program
EXCEPTIONS                    GEN-20001gen_pop_updatepop_audit_bu(): Updates are not allowed.An attempt was made to update data in the POP_AUDIT table.Updates to POP_AUDIT data are not allowed.
EXCEPTIONS                    GEN-20002gen_no_userCurrent user has not been set in the %s Package.A call to UTIL.GET_USR was made before a call to UTIL.SET_USR gave a value for the username.Set the username by calling UTIL.SET_USR with a valid value.
EXCEPTIONS                    GEN-20003gen_bad_case%s.check_rec(): %s must be %s case.The letter case of a string has failed to meet the requirement listed.Modifiy the string to conform to the letter case requirement.
EXCEPTIONS                    GEN-20004gen_null_found%s.check_rec(): %s cannot be null.The data item cannot be null.Provide a value for this data item.
EXCEPTIONS                    GEN-20005gen_not_in%s.check_rec(): %s must be one of (%s).The data item does not have a value from the list provided.Provide a value from the list for the this data item.
EXCEPTIONS                    GEN-20006gen_cust_cons%s.check_rec(): %sCustom ConstraintComply with Constraint
EXCEPTIONS                    GEN-20007gen_future_date%s.check_rec(): %s cannot be in the future.The data item cannot have a date value that is in the future.Change the date value of the data item to an earlier date/time.
EXCEPTIONS                    GEN-20008gen_no_change%s.upd(): Must update one of %s.An attempt was made to update data in a table, but the minimum requirement to change one data value was not met (EFF_BEG_DTM is not considered a data value).Modify the data value of another data item before attempting the update.
EXCEPTIONS                    GEN-20009gen_early_date%s.%s(): The new %s date must be greater than %sThe new date value of the data item precedes its previous value.Ensure the new data value for the data occurs after its current date/time value.
EXCEPTIONS                    GEN-20010gen_mv_dml%s not allowed on materialized view %sData Modification Language (Insert, Update, or Delete) cannot be performed on a Materialized View.Attempt the Data Modification Language (DML) on the database node instead of a Mid-Tier node.
EXCEPTIONS                    GEN-20011gen_apex_nfndAPEX: Unable to find %sAPEX data was not found during an import.Import parameter values could be incorrect, or APEX has not been properly loaded on target system.
EXCEPTIONS                    GEN-20012gen_apex_initAPEX: %s is null.Initialization data was not found during an APEX import.Initialization values could be incorrect, or APEX has not been properly loaded on target system.
EXCEPTIONS                    GEN-20013gen_tseq_orderload_nk_aa(): %s must precede %s in ascending table sequence.A Foreign Key Table with a larger sequence number has been referenced by a Table.Correct the table sequence order.
EXCEPTIONS                    GEN-20014gen_many_updatesGEN_MRU updated %i rows for ID %iGenerated Multi-Row Update updated more than 1 row for a given IDCorrect the duplicate primary key ID.
PROGRAMS                      GENgeneratePACKAGEMain Generation Program Unit
PROGRAMS                      GENassemblePACKAGEAssembles Install/Uninstall Scripts from Generated Scripts
TABLES                        GENAPPapplications1NONEXTRAApplications to be generated
TABLES                        GENFfiles2NONEXTRAFiles for capturing scripts and logs
TABLES                        GENFLfile_lines3NONEXTRALines for files
TABLES                        GENDOMdomains4NONMAINData domains to be generated as check constraints and/or lists of values for selected columns
TABLES                        GENDVdomain_values5NONMAINData domains values for the data domains
TABLES                        GENTABtables6NONMAINTables to be generated for each application
TABLES                        GENCOLtab_cols7NONMAINColumns to be generated for each table
TABLES                        GENINDindexes8NONMAINUnique and non-unique indexes for this table
TABLES                        GENCKcheck_cons9NONMAINCheck constraints to be generated for each table
TABLES                        GENPRGprograms10NONEXTRAPrograms Registered to Run with the Application
TABLES                        GENEXCexceptions11NONEXTRAApplication Exceptions for Error Trapping
CHECK_CONS                    GENAPP1instr(db_schema,' ') = 0 or db_schema is nullDB schema name cannot have spaces
CHECK_CONS                    GENAPP2instr(apex_schema,' ') = 0 or apex_schema is nullAPEX schema name cannot have spaces
CHECK_CONS                    GENAPP3instr(dbid,' ') = 0 or dbid is nullDatabase ID cannot have spaces
CHECK_CONS                    GENAPP4db_auth is null or dbid is not nullDatabase ID must not be NULL if Database Authentication is not NULL
CHECK_CONS                    GENDOM1len > 0Domain data value length must be greater than 0
CHECK_CONS                    GENDV1seq > 0Domain data value sequence number must be greater than 0
CHECK_CONS                    GENTAB1instr(abbr,' ') = 0Table abbreviation cannot have spaces
CHECK_CONS                    GENTAB2instr(name,' ') = 0Table name cannot have spaces
CHECK_CONS                    GENTAB3seq > 0Table sequence number must be greater than 0
CHECK_CONS                    GENTAB4seq < 200Table sequence number must be less than 200 because of the �pnum� offsets in the generator package
CHECK_CONS                    GENTAB5mv_refresh_hr > 0Materialized View Refresh Hours must be greater than 0
CHECK_CONS                    GENTAB6instr(ts_onln_data,' ') = 0On-line data table space name cannot have spaces for a table
CHECK_CONS                    GENTAB7instr(ts_onln_indx,' ') = 0On-line index table space name cannot have spaces for a table
CHECK_CONS                    GENTAB8instr(ts_hist_data,' ') = 0History data table space name cannot have spaces for a table
CHECK_CONS                    GENTAB9instr(ts_hist_indx,' ') = 0History index table space name cannot have spaces for a table
CHECK_CONS                    GENCOL1instr(name,' ') = 0Column name cannot have spaces
CHECK_CONS                    GENCOL2name not in ('id', 'eff_beg_dtm', 'eff_end_dtm', 'aud_beg_usr', 'aud_end_usr', 'aud_beg_dtm', 'aud_end_dtm', 'last_active')Column name cannot be one of 'id', 'eff_beg_dtm', 'eff_end_dtm', 'aud_beg_usr', 'aud_end_usr', 'aud_beg_dtm', 'aud_end_dtm', or 'last_active'
CHECK_CONS                    GENCOL3seq > 0Column sequence must be greater than 0
CHECK_CONS                    GENCOL4nk > 0Column natural key must be greater than 0
CHECK_CONS                    GENCOL5fk_table_id is not null or d_domain_id is not null or type is not nullOne of FK_TABLE_ID, D_DOMAIN_ID, or TYPE must have a value in columns
CHECK_CONS                    GENCOL6fk_table_id is null or d_domain_id is nullFK_TABLE_ID and D_DOMAIN_ID cannot both have a value in columns
CHECK_CONS                    GENCOL7d_domain_id is null or type is nullD_DOMAIN_ID and TYPE cannot both have a value in columns
CHECK_CONS                    GENCOL8fk_table_id is null or type is nullFK_TABLE_ID and TYPE cannot both have a value in columns
CHECK_CONS                    GENCOL9fk_prefix is null or (fk_prefix is not null and fk_table_id is not null)Column fk_prefix must be null unless column fk_table_id has a value
CHECK_CONS                    GENCOL10len is not null or type != 'VARCHAR2'Len cannot be NULL if type is VARCHAR2
CHECK_CONS                    GENCOL11len is null or (len between 1 and 39 and type = 'NUMBER') or type != 'NUMBER'Len (NUMBER precision) must be between 1 and 39
CHECK_CONS                    GENCOL12len is null or (len between 1 and 32767 and type = 'VARCHAR2') or type != 'VARCHAR2'Len (VARCHAR2 length) must be between 1 and 32767
CHECK_CONS                    GENCOL13len is null or (len between 0 and 9 and type in ('TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE')) or type not in ('TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE')Len (TIMESTAMP fractional seconds digits) must be between 0 and 9
CHECK_CONS                    GENCOL14scale is null or (type = 'NUMBER' and len is not null)Scale must be null unless column type is NUMBER and len is not NULL
CHECK_CONS                    GENCOL15scale is null or scale between -84 and 127Scale must be between -84 and 127, or NULL
CHECK_CONS                    GENCOL16fold is null or (type = 'VARCHAR2' and type is not null)Column fold must be null unless type is VARCHAR2
CHECK_CONS                    GENCOL17nk is null or fk_table_id != table_idSelf-referencing foreign keys (hierarchies) cannot be part of the natural key
CHECK_CONS                    GENIND1seq > 0Index column sequence must be greater than 0
CHECK_CONS                    GENCK1seq > 0Check constraint sequence must be greater than 0
CHECK_CONS                    GENPRG1instr(name,' ') = 0Stored Program Unit Name cannot have spaces
CHECK_CONS                    GENEXC1code between -20999 and -20000Exception code must be between -20999 and -20000
CHECK_CONS                    GENEXC2instr(name,' ') = 0Exception name cannot have spaces
DOMAIN_VALUES                 GENTTYPE1EFFAn effectivity table type with begin and end timestamps
DOMAIN_VALUES                 GENTTYPE2LOGA log table type without begin and end timestamps
DOMAIN_VALUES                 GENTTYPE3NONNo table type (without begin/end timestamps)
DOMAIN_VALUES                 GENCTYPE1NUMBERA numeric data type
DOMAIN_VALUES                 GENCTYPE2VARCHAR2A character data type
DOMAIN_VALUES                 GENCTYPE3DATEA date/time data type
DOMAIN_VALUES                 GENCTYPE4TIMESTAMP WITH TIME ZONEA date/time data type with time zone
DOMAIN_VALUES                 GENCTYPE5TIMESTAMP WITH LOCAL TIME ZONEA date/time data type with local time zone
DOMAIN_VALUES                 GENFOLD1UUpper case character fold
DOMAIN_VALUES                 GENFOLD2LLower case character fold
DOMAIN_VALUES                 GENFOLD3IInitial capital case character fold
DOMAIN_VALUES                 GENYN1YYes, true, correct, or affirmative
DOMAIN_VALUES                 GENYN2NNo, false, incorrect, or negative
DOMAIN_VALUES                 GENFLAG1XFlagged
DOMAIN_VALUES                 GENFTYPE1SQLSQL Script
DOMAIN_VALUES                 GENFTYPE2LOGLog File
DOMAIN_VALUES                 GENPTYPE1PACKAGEIncludes Package Specification and Package Body
DOMAIN_VALUES                 GENPTYPE2FUNCTIONStored Function outside of a Package
DOMAIN_VALUES                 GENPTYPE3PROCEDUREStored Procedure outside of a Package
TAB_COLS                      GENAPPabbr11XVARCHAR25UAbbreviation for this application
TAB_COLS                      GENAPPname2XVARCHAR230IName of this application
TAB_COLS                      GENAPPdb_schema3VARCHAR230UName of the database schema objects owner.  Used for user synonym and DB Link creation.
TAB_COLS                      GENAPPapex_schema4VARCHAR230UName of the APEX parsing schema owner for the generated APEX pages
TAB_COLS                      GENAPPapex_ws_name5VARCHAR230UWorkspace name (Upper Case) for the generated APEX pages
TAB_COLS                      GENAPPapex_app_name6VARCHAR230Application name (Mixed Case) for the generated APEX pages
TAB_COLS                      GENAPPdbid7VARCHAR28UDatabase link connect string for mid-tier connections to the centralized database server
TAB_COLS                      GENAPPdb_auth8VARCHAR2100Database link authorization for mid-tier connections to the centralized database server
TAB_COLS                      GENAPPdescription9VARCHAR21000Description of this application
TAB_COLS                      GENFapplication_id11XGENAPPSurrogate Key for the application of this file
TAB_COLS                      GENFname22XVARCHAR230Name of this file
TAB_COLS                      GENFtype3XGENFTYPEType for this file
TAB_COLS                      GENFdescription4VARCHAR21000Description for this file
TAB_COLS                      GENFLfile_id11XGENFSurrogate Key for the file of this line
TAB_COLS                      GENFLseq22XNUMBER5Sequence number for this line in the file
TAB_COLS                      GENFLvalue3VARCHAR21000Value or contents of this line in the file
TAB_COLS                      GENDOMapplication_id11XGENAPPSurrogate Key for the application of this data domain
TAB_COLS                      GENDOMabbr22XVARCHAR25UName of this data domain
TAB_COLS                      GENDOMname3XVARCHAR220IName of this data domain
TAB_COLS                      GENDOMfold4XGENFOLDValue of this sequence in this data domain
TAB_COLS                      GENDOMlen5XNUMBER2Value of this sequence in this data domain
TAB_COLS                      GENDOMdescription6VARCHAR21000Description of this data domain value
TAB_COLS                      GENDVdomain_id11XGENDOMSurrogate Key for the application of this data domain
TAB_COLS                      GENDVseq3XNUMBER2Sequence number for this value in this data domain
TAB_COLS                      GENDVvalue42XVARCHAR2100Value of this sequence in this data domain
TAB_COLS                      GENDVdescription5VARCHAR21000Description of this data domain value
TAB_COLS                      GENTABapplication_id11XGENAPPSurrogate Key for the application of this table
TAB_COLS                      GENTABabbr22XVARCHAR25UAbbreviation for this table
TAB_COLS                      GENTABname3XVARCHAR215LName of this table
TAB_COLS                      GENTABseq4XNUMBER2Report order for this table
TAB_COLS                      GENTABtype5XGENTTYPEType of this table
TAB_COLS                      GENTABgroup_name6VARCHAR230UGroup Name for this table.
TAB_COLS                      GENTABmv_refresh_hr7NUMBER31Number of Hours between Materialized View Refresh
TAB_COLS                      GENTABts_onln_data8VARCHAR230LName for the on-line data table space for this table
TAB_COLS                      GENTABts_onln_indx9VARCHAR230LName for the on-line index table space for this table
TAB_COLS                      GENTABts_hist_data10VARCHAR230LName for the history data table space for this table
TAB_COLS                      GENTABts_hist_indx11VARCHAR230LName for the history index table space for this table
TAB_COLS                      GENTABdescription12VARCHAR21000Description of this table
TAB_COLS                      GENCOLtable_id11XGENTABSurrogate Key for the table of this column
TAB_COLS                      GENCOLname22XVARCHAR225LName of this column
TAB_COLS                      GENCOLseq3XNUMBER2Sequence number for this column
TAB_COLS                      GENCOLnk4NUMBER1Natural key sequence number for this column.  Implies this column requires data (not null).
TAB_COLS                      GENCOLreq5GENFLAGFlag to indicate if this column is required
TAB_COLS                      GENCOLfk_prefix6VARCHAR24LForeign key prefix for multiple foreign keys to the same table
TAB_COLS                      GENCOLfk_table_id7fk_GENTABSurrogate Key for the foreign key table of this column
TAB_COLS                      GENCOLd_domain_id8d_GENDOMSurrogate Key for the domain of this column
TAB_COLS                      GENCOLtype9GENCTYPEType for this column
TAB_COLS                      GENCOLlen10NUMBER5The total number of significant decimal digits in a number, or the length of a string, or the number of digits for fractional seconds in a timestamp
TAB_COLS                      GENCOLscale11NUMBER3The number of digits from the decimal point to the least significant digit
TAB_COLS                      GENCOLfold12GENFOLDFlag to indicate if this column should be character case folded
TAB_COLS                      GENCOLdefault_value13VARCHAR21000Default Value if no value is provided for this column
TAB_COLS                      GENCOLdescription14VARCHAR21000Description for this column
TAB_COLS                      GENINDtab_col_id11XGENCOLSurrogate Key for the column for this index
TAB_COLS                      GENINDtag22XVARCHAR24LTag attached to the table name for this column that uniquely identifies this index
TAB_COLS                      GENINDseq33XNUMBER1Sequence number for this column for this index
TAB_COLS                      GENINDuniq4GENFLAGFlag to indicate if this index is unique (any column with this flag indicates the entire index is unique)
TAB_COLS                      GENCKtable_id11XGENTABSurrogate Key for the table of this check constraint
TAB_COLS                      GENCKseq22XNUMBER2Sequence number of this check constraint
TAB_COLS                      GENCKtext3XVARCHAR21000Execution (PL/SQL) text for this check constraint
TAB_COLS                      GENCKdescription4VARCHAR21000Description of this check constraint
TAB_COLS                      GENPRGapplication_id11XGENAPPSurrogate Key for the application of this Shared Program Unit
TAB_COLS                      GENPRGname22XVARCHAR230LName of this Stored Program Unit
TAB_COLS                      GENPRGtype3XGENPTYPEType of this Stored Program Unit
TAB_COLS                      GENPRGdescription4VARCHAR21000Description of this Stored Program Unit
TAB_COLS                      GENEXCapplication_id11XGENAPPSurrogate Key for the application of this exception
TAB_COLS                      GENEXCcode22XNUMBER5RAISE_APPLICATION_ERROR Code for this exception
TAB_COLS                      GENEXCname3XVARCHAR230LPRAGMA EXCEPTION_INIT Name for this exception
TAB_COLS                      GENEXCmessage4VARCHAR22048Error Message for this exception
TAB_COLS                      GENEXCcause5VARCHAR22048Error Cause for this exception
TAB_COLS                      GENEXCaction6VARCHAR22048Possible Solution for this exception
INDEXES                       GENAPPnameux11X
INDEXES                       GENDOMapplication_idux11X
INDEXES                       GENDOMnameux12X
INDEXES                       GENDVdomain_idux11X
INDEXES                       GENDVsequx12X
INDEXES                       GENTABapplication_idux11X
INDEXES                       GENTABnameux12X
INDEXES                       GENTABapplication_idux21X
INDEXES                       GENTABsequx22X
INDEXES                       GENCOLtable_idux11X
INDEXES                       GENCOLsequx12X
INDEXES                       GENEXCapplication_idux21X
INDEXES                       GENEXCnameux22X
