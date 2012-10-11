create or replace package body tr_btt_str_owner
is

-- Basic Table Test for Number Datatypes
--   Running as owner privileges

-- Only Owners can run SQL against the base table

-- Define an exception that occurs when the DML
--   speed exceeds the resolution of systimestamp
--too_quick  EXCEPTION;

-- 20009: The new %s date must be greater than %s
-- The new date value of the data item precedes its previous value.
-- Ensure the new data value for the data occurs after its current date/time value.
--PRAGMA EXCEPTION_INIT (too_quick, -20009);

-----------------------------------------------------------
function SQLTAB_NON_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  varchar2(4000);
   upd_val  varchar2(4000);
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   tr_btt_str.char_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := trc.tparms.val1;
   insert into t1a_non (id, key, seq, char_max)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   tr_btt_str.char_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := trc.tparms.val2;
   update t1a_non set char_max = upd_val
    where id = rec_id;
   tr_btt_str.char_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non where id = rec_id;
   tr_btt_str.char_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLTAB_NON_char_max;
-----------------------------------------------------------
function SQLTAB_LOG_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   unique_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (unique_constraint, -00001);
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   too_quick  EXCEPTION;
   PRAGMA EXCEPTION_INIT (too_quick, -20009);
   success  boolean;
   tab_seq  number;
   ins_val  varchar2(4000);
   upd_val  varchar2(4000);
   loc_txt  varchar2(30);
   rec_id   number;
   gusr     t1a_log.aud_beg_usr%TYPE;
   gdtm     t1a_log.aud_beg_dtm%TYPE;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   tr_btt_str.char_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := trc.tparms.val1;
   -- These must be set here and passed into the SQL Insert Statement
   --   Otherwise, a permission error will occur for some unknown reason.
   gusr := glob.get_usr;
   gdtm := glob.get_dtm;
   --  When db_constraints=FALSE on DB server, AUD_BEG_USR and AUD_BEG_DTM must be set
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log (id, key, seq, char_max, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, gusr, gdtm);
   tr_btt_str.char_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := trc.tparms.val2;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log set char_max = upd_val
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then
         if sqlerrm like '%_EF1) violated%' then rollback to TEST_RIG_UPDATE; end if;
      when unique_constraint then
         if sqlerrm like '%_PK) violated%' then rollback to TEST_RIG_UPDATE; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   tr_btt_str.char_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   tr_btt_str.char_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then
         if sqlerrm like '%_EF1) violated%' then rollback to TEST_RIG_DELETE; end if;
      when unique_constraint then
         if sqlerrm like '%_PK) violated%' then rollback to TEST_RIG_DELETE; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   tr_btt_str.char_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   tr_btt_str.char_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLTAB_LOG_char_max;
-----------------------------------------------------------
function SQLTAB_EFF_char_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   unique_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (unique_constraint, -00001);
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   too_quick  EXCEPTION;
   PRAGMA EXCEPTION_INIT (too_quick, -20009);
   success  boolean;
   tab_seq  number;
   ins_val  varchar2(4000);
   upd_val  varchar2(4000);
   loc_txt  varchar2(30);
   rec_id   number;
   gusr     t1a_log.aud_beg_usr%TYPE;
   gdtm     t1a_log.aud_beg_dtm%TYPE;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   tr_btt_str.char_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := trc.tparms.val1;
   -- These must be set here and passed into the SQL Insert Statement
   --   Otherwise, a permission error will occur for some unknown reason.
   gusr := glob.get_usr;
   gdtm := glob.get_dtm;
   --  When db_constraints=FALSE on DB server, AUD_BEG_USR and AUD_BEG_DTM must be set
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF (id, key, seq, char_max, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, gdtm, gusr, gdtm);
   tr_btt_str.char_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := trc.tparms.val2;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      gdtm := glob.get_dtm;
      update t1a_eff set char_max = upd_val, eff_beg_dtm = gdtm
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then
         if sqlerrm like '%_EF1) violated%' then rollback to TEST_RIG_UPDATE; end if;
      when unique_constraint then
         if sqlerrm like '%_PK) violated%' then rollback to TEST_RIG_UPDATE; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   tr_btt_str.char_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   tr_btt_str.char_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then
         if sqlerrm like '%_EF1) violated%' then rollback to TEST_RIG_DELETE; end if;
      when unique_constraint then
         if sqlerrm like '%_PK) violated%' then rollback to TEST_RIG_DELETE; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   tr_btt_str.char_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   tr_btt_str.char_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLTAB_EFF_char_max;
-----------------------------------------------------------
end tr_btt_str_owner;
/
