------------------------------------------------------------
REM Test User

describe user_tables
select table_name, tablespace_name from user_tables;
describe user_indexes

execute glob.set_usr('Duane');

insert into t1a_non(id, key, seq, tstamp_tz_plain, tstamp_ltz_plain) values(1000, 'Duane', 1,
   to_timestamp_tz('31-DEC-9999 AD 23:59:59.999 UTC','DD-MON-YYYY AD HH24:MI:SS.FF3 TZR'),
   to_timestamp('31-DEC-9999 AD 23:59:59.999','DD-MON-YYYY AD HH24:MI:SS.FF3'));

select to_char(tstamp_tz_plain, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZD'),
       to_char(tstamp_ltz_plain, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZD')
 from  t1a_non where id = 1000;

execute test_rig.run_all;
execute test_rig.run_test('A','BTT_SQLTAB_NON_NUM_PLAIN');
execute dbms_output.put_line(test_rig.BTT_SQLTAB_NON_NUM_PLAIN('BTT_NUM_PASS',2));

------------------------------------------------------------
REM dtgen_test:

drop table test_sets;
drop table test_parms;
drop table parm_sets;
drop table global_parms;

purge recyclebin;

------------------------------------------------------------
REM dtgen_dev:

execute dtgen_util.data_script('DTGEN')

select regexp_instr('The last white space in this string is at position 51.'
                   ,'[   ][^  ]*$') from dual;
select substr('Testing',7,-1) from dual;


execute glob.set_usr('Test');
execute gui_util.gen_all('TST1');

-- copy columns
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description)
   select tables_nk1, 'T1AL', name, seq, nk, type, len, description
    from  tab_cols_act where tables_nk1 = 'TST1' and tables_nk2 = 'T1AN'
    and   seq > 20;
insert into tab_cols_act (tables_nk1, tables_nk2, name, seq, nk, type, len, description)
   select tables_nk1, 'T1AE', name, seq, nk, type, len, description
    from  tab_cols_act where tables_nk1 = 'TST1' and tables_nk2 = 'T1AN'
    and   seq > 20;
