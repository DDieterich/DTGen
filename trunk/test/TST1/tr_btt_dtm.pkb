create or replace package body tr_btt_dtm
is

-- Basic Table Test for Number Datatypes

-- Define an exception that occurs when the DML
--   speed exceeds the resolution of systimestamp
--too_quick  EXCEPTION;

-- 20009: The new %s date must be greater than %s
-- The new date value of the data item precedes its previous value.
-- Ensure the new data value for the data occurs after its current date/time value.
--PRAGMA EXCEPTION_INIT (too_quick, -20009);

------------------------------------------------------------
procedure date_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  date default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end date_rows_non;
-----------------------------------------------------------
procedure date_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  date default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_log row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_aud
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != aud_rows_in then
      raise_application_error (-20000, 't1a_log_aud row_cnt is not ' || aud_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_pdat
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end date_rows_log;
-----------------------------------------------------------
procedure date_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  date default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_eff row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_hist
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != hist_rows_in then
      raise_application_error (-20000, 't1a_eff_hist row_cnt is not ' || hist_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_pdat
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (date_plain is null and val_in is null)
                               or date_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end date_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   date_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   insert into t1a_non_act (id, key, seq, date_plain)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   date_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   update t1a_non_act set date_plain = upd_val
    where id = rec_id;
   date_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   date_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_date;
-----------------------------------------------------------
function SQLACT_LOG_date
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
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   date_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, date_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   date_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set date_plain = upd_val
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
   date_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   date_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log_act where id = rec_id;
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
   date_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   date_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_date;
-----------------------------------------------------------
function SQLACT_EFF_date
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
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   date_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, date_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   date_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set date_plain = upd_val, eff_beg_dtm = glob.get_dtm
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
   date_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   date_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff_act where id = rec_id;
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
   date_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   date_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   date_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   date_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   date_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   date_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   date_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   date_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   date_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   date_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   date_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_date;
-----------------------------------------------------------
function APITAB_NON_date
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   date_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   rec.date_plain := ins_val;
   t1a_non_dml.ins(rec);
   date_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   rec.date_plain := upd_val;
   t1a_non_dml.upd(rec);
   date_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   date_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_date;
-----------------------------------------------------------
function APITAB_LOG_date
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
   rec      t1a_LOG%ROWTYPE;
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   date_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.date_plain   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   date_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   rec.date_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.upd(rec);
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
   date_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   date_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.del(rec.id);
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
   date_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   date_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_date;
-----------------------------------------------------------
function APITAB_EFF_date
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
   rec      t1a_EFF%ROWTYPE;
   ins_val  date;
   upd_val  date;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   date_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_date(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.date_plain   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   date_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_date(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS');
   rec.date_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.upd(rec);
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
   date_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   date_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.del(rec.id, rec.eff_beg_dtm);
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
   date_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   date_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_date;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure tst_tz_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  timestamp with time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_tz_rows_non;
-----------------------------------------------------------
procedure tst_tz_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_log row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_aud
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != aud_rows_in then
      raise_application_error (-20000, 't1a_log_aud row_cnt is not ' || aud_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_pdat
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_tz_rows_log;
-----------------------------------------------------------
procedure tst_tz_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_eff row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_hist
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != hist_rows_in then
      raise_application_error (-20000, 't1a_eff_hist row_cnt is not ' || hist_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_pdat
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_tz_plain is null and val_in is null)
                               or tstamp_tz_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_tz_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   tst_tz_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   insert into t1a_non_act (id, key, seq, tstamp_tz_plain)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   tst_tz_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   update t1a_non_act set tstamp_tz_plain = upd_val
    where id = rec_id;
   tst_tz_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   tst_tz_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_tst_tz;
-----------------------------------------------------------
function SQLACT_LOG_tst_tz
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
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   tst_tz_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, tstamp_tz_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   tst_tz_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set tstamp_tz_plain = upd_val
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
   tst_tz_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_tz_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log_act where id = rec_id;
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
   tst_tz_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   tst_tz_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_tst_tz;
-----------------------------------------------------------
function SQLACT_EFF_tst_tz
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
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   tst_tz_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, tstamp_tz_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   tst_tz_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set tstamp_tz_plain = upd_val, eff_beg_dtm = glob.get_dtm
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
   tst_tz_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_tz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff_act where id = rec_id;
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
   tst_tz_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   tst_tz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   tst_tz_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_tz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   tst_tz_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   tst_tz_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   tst_tz_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   tst_tz_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   tst_tz_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   tst_tz_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   tst_tz_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_tst_tz;
-----------------------------------------------------------
function APITAB_NON_tst_tz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_tz_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   rec.tstamp_tz_plain := ins_val;
   t1a_non_dml.ins(rec);
   tst_tz_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   rec.tstamp_tz_plain := upd_val;
   t1a_non_dml.upd(rec);
   tst_tz_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   tst_tz_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_tst_tz;
-----------------------------------------------------------
function APITAB_LOG_tst_tz
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
   rec      t1a_LOG%ROWTYPE;
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_tz_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.tstamp_tz_plain   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   tst_tz_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   rec.tstamp_tz_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.upd(rec);
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
   tst_tz_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   tst_tz_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.del(rec.id);
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
   tst_tz_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   tst_tz_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_tst_tz;
-----------------------------------------------------------
function APITAB_EFF_tst_tz
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
   rec      t1a_EFF%ROWTYPE;
   ins_val  timestamp with time zone;
   upd_val  timestamp with time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_tz_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp_tz(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.tstamp_tz_plain   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   tst_tz_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp_tz(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3 TZR');
   rec.tstamp_tz_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.upd(rec);
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
   tst_tz_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   tst_tz_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.del(rec.id, rec.eff_beg_dtm);
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
   tst_tz_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   tst_tz_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_tst_tz;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure tst_ltz_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  timestamp with local time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_ltz_rows_non;
-----------------------------------------------------------
procedure tst_ltz_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with local time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_log row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_aud
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != aud_rows_in then
      raise_application_error (-20000, 't1a_log_aud row_cnt is not ' || aud_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_log_pdat
    where t1a_log_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_ltz_rows_log;
-----------------------------------------------------------
procedure tst_ltz_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  timestamp with local time zone default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_eff row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_hist
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != hist_rows_in then
      raise_application_error (-20000, 't1a_eff_hist row_cnt is not ' || hist_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
   select count(*)
    into  row_cnt
    from  t1a_eff_pdat
    where t1a_eff_id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (tstamp_ltz_plain is null and val_in is null)
                               or tstamp_ltz_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end tst_ltz_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   tst_ltz_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   insert into t1a_non_act (id, key, seq, tstamp_ltz_plain)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   tst_ltz_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   update t1a_non_act set tstamp_ltz_plain = upd_val
    where id = rec_id;
   tst_ltz_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   tst_ltz_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_tst_ltz;
-----------------------------------------------------------
function SQLACT_LOG_tst_ltz
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
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   tst_ltz_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, tstamp_ltz_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   tst_ltz_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set tstamp_ltz_plain = upd_val
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
   tst_ltz_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_ltz_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log_act where id = rec_id;
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
   tst_ltz_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   tst_ltz_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_tst_ltz;
-----------------------------------------------------------
function SQLACT_EFF_tst_ltz
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
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   tst_ltz_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, tstamp_ltz_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   tst_ltz_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set tstamp_ltz_plain = upd_val, eff_beg_dtm = glob.get_dtm
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
   tst_ltz_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_ltz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff_act where id = rec_id;
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
   tst_ltz_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   tst_ltz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   tst_ltz_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   tst_ltz_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   tst_ltz_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   tst_ltz_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   tst_ltz_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   tst_ltz_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   tst_ltz_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   tst_ltz_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   tst_ltz_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_tst_ltz;
-----------------------------------------------------------
function APITAB_NON_tst_ltz
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_ltz_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   rec.tstamp_ltz_plain := ins_val;
   t1a_non_dml.ins(rec);
   tst_ltz_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   rec.tstamp_ltz_plain := upd_val;
   t1a_non_dml.upd(rec);
   tst_ltz_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   tst_ltz_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_tst_ltz;
-----------------------------------------------------------
function APITAB_LOG_tst_ltz
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
   rec      t1a_LOG%ROWTYPE;
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_ltz_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.tstamp_ltz_plain   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   tst_ltz_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   rec.tstamp_ltz_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.upd(rec);
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
   tst_ltz_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   tst_ltz_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.del(rec.id);
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
   tst_ltz_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   tst_ltz_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_tst_ltz;
-----------------------------------------------------------
function APITAB_EFF_tst_ltz
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
   rec      t1a_EFF%ROWTYPE;
   ins_val  timestamp with local time zone;
   upd_val  timestamp with local time zone;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   tst_ltz_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_timestamp(trc.tparms.val1, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.tstamp_ltz_plain   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   tst_ltz_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_timestamp(trc.tparms.val2, 'DD-MON-YYYY AD HH24:MI:SS.FF3');
   rec.tstamp_ltz_plain := upd_val;
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.upd(rec);
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
   tst_ltz_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   tst_ltz_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   savepoint TEST_RIG_DELETE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.del(rec.id, rec.eff_beg_dtm);
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
   tst_ltz_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   tst_ltz_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_tst_ltz;
-----------------------------------------------------------
end tr_btt_dtm;
/
