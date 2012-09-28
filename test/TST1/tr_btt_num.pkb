create or replace package body tr_btt_num
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
procedure plain_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end plain_rows_non;
-----------------------------------------------------------
procedure plain_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
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
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
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
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end plain_rows_log;
-----------------------------------------------------------
procedure plain_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
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
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
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
          or (seq = seq_in and ( (num_plain is null and val_in is null)
                               or num_plain = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end plain_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   plain_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_plain)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   plain_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_plain = upd_val
    where id = rec_id;
   plain_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   plain_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_PLAIN;
-----------------------------------------------------------
function SQLACT_LOG_PLAIN
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   plain_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   plain_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_plain = upd_val
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
   plain_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   plain_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_PLAIN;
-----------------------------------------------------------
function SQLACT_EFF_PLAIN
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   plain_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   plain_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_plain = upd_val, eff_beg_dtm = glob.get_dtm
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
   plain_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   plain_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   plain_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   plain_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   plain_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   plain_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   plain_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   plain_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   plain_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   plain_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_PLAIN;
-----------------------------------------------------------
function APITAB_NON_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   plain_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_plain := ins_val;
   t1a_non_dml.ins(rec);
   plain_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_plain := upd_val;
   t1a_non_dml.upd(rec);
   plain_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   plain_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_PLAIN;
-----------------------------------------------------------
function APITAB_LOG_PLAIN
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   plain_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_plain   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   plain_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_plain := upd_val;
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
   plain_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   plain_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   plain_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   plain_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_PLAIN;
-----------------------------------------------------------
function APITAB_EFF_PLAIN
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   plain_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_plain   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   plain_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_plain := upd_val;
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
   plain_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   plain_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   plain_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   plain_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_PLAIN;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure min_len_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_len_rows_non;
-----------------------------------------------------------
procedure min_len_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
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
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
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
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_len_rows_log;
-----------------------------------------------------------
procedure min_len_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
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
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
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
          or (seq = seq_in and ( (num_min_len is null and val_in is null)
                               or num_min_len = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_len_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   min_len_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_min_len)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   min_len_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_min_len = upd_val
    where id = rec_id;
   min_len_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   min_len_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_min_len;
-----------------------------------------------------------
function SQLACT_LOG_min_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   min_len_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_min_len, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   min_len_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_min_len = upd_val
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
   min_len_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   min_len_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_len_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   min_len_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_min_len;
-----------------------------------------------------------
function SQLACT_EFF_min_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   min_len_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_min_len, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   min_len_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_min_len = upd_val, eff_beg_dtm = glob.get_dtm
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
   min_len_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_len_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   min_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   min_len_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   min_len_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   min_len_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_len_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   min_len_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   min_len_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_len_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   min_len_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_min_len;
-----------------------------------------------------------
function APITAB_NON_min_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_len_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_min_len := ins_val;
   t1a_non_dml.ins(rec);
   min_len_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_len := upd_val;
   t1a_non_dml.upd(rec);
   min_len_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   min_len_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_min_len;
-----------------------------------------------------------
function APITAB_LOG_min_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_len_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_len   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   min_len_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_len := upd_val;
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
   min_len_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   min_len_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_len_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   min_len_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_min_len;
-----------------------------------------------------------
function APITAB_EFF_min_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_len_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_len   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   min_len_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_len := upd_val;
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
   min_len_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   min_len_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_len_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   min_len_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_min_len;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure min_min_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_min_rows_non;
-----------------------------------------------------------
procedure min_min_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
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
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
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
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_min_rows_log;
-----------------------------------------------------------
procedure min_min_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
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
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
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
          or (seq = seq_in and ( (num_min_min is null and val_in is null)
                               or num_min_min = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_min_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   min_min_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_min_min)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   min_min_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_min_min = upd_val
    where id = rec_id;
   min_min_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   min_min_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_min_min;
-----------------------------------------------------------
function SQLACT_LOG_min_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   min_min_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_min_min, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   min_min_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_min_min = upd_val
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
   min_min_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   min_min_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_min_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   min_min_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_min_min;
-----------------------------------------------------------
function SQLACT_EFF_min_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   min_min_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_min_min, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   min_min_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_min_min = upd_val, eff_beg_dtm = glob.get_dtm
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
   min_min_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_min_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   min_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   min_min_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   min_min_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   min_min_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_min_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   min_min_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   min_min_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_min_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   min_min_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_min_min;
-----------------------------------------------------------
function APITAB_NON_min_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_min_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_min_min := ins_val;
   t1a_non_dml.ins(rec);
   min_min_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_min := upd_val;
   t1a_non_dml.upd(rec);
   min_min_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   min_min_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_min_min;
-----------------------------------------------------------
function APITAB_LOG_min_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_min_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_min   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   min_min_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_min := upd_val;
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
   min_min_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   min_min_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_min_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   min_min_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_min_min;
-----------------------------------------------------------
function APITAB_EFF_min_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_min_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_min   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   min_min_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_min := upd_val;
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
   min_min_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   min_min_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_min_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   min_min_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_min_min;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure min_max_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_max_rows_non;
-----------------------------------------------------------
procedure min_max_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
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
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
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
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_max_rows_log;
-----------------------------------------------------------
procedure min_max_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
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
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
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
          or (seq = seq_in and ( (num_min_max is null and val_in is null)
                               or num_min_max = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end min_max_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   min_max_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_min_max)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   min_max_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_min_max = upd_val
    where id = rec_id;
   min_max_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   min_max_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_min_max;
-----------------------------------------------------------
function SQLACT_LOG_min_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   min_max_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_min_max, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   min_max_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_min_max = upd_val
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
   min_max_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   min_max_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_max_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   min_max_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_min_max;
-----------------------------------------------------------
function SQLACT_EFF_min_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   min_max_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_min_max, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   min_max_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_min_max = upd_val, eff_beg_dtm = glob.get_dtm
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
   min_max_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   min_max_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   min_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   min_max_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   min_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   min_max_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   min_max_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_max_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   min_max_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   min_max_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   min_max_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   min_max_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_min_max;
-----------------------------------------------------------
function APITAB_NON_min_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_max_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_min_max := ins_val;
   t1a_non_dml.ins(rec);
   min_max_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_max := upd_val;
   t1a_non_dml.upd(rec);
   min_max_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   min_max_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_min_max;
-----------------------------------------------------------
function APITAB_LOG_min_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_max_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_max   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   min_max_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_max := upd_val;
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
   min_max_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   min_max_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_max_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   min_max_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_min_max;
-----------------------------------------------------------
function APITAB_EFF_min_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   min_max_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_min_max   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   min_max_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_min_max := upd_val;
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
   min_max_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   min_max_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   min_max_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   min_max_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_min_max;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure max_len_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_len_rows_non;
-----------------------------------------------------------
procedure max_len_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
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
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
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
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_len_rows_log;
-----------------------------------------------------------
procedure max_len_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
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
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
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
          or (seq = seq_in and ( (num_max_len is null and val_in is null)
                               or num_max_len = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_len_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   max_len_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_max_len)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   max_len_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_max_len = upd_val
    where id = rec_id;
   max_len_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   max_len_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_max_len;
-----------------------------------------------------------
function SQLACT_LOG_max_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   max_len_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_max_len, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   max_len_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_max_len = upd_val
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
   max_len_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   max_len_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_len_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   max_len_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_max_len;
-----------------------------------------------------------
function SQLACT_EFF_max_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   max_len_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_max_len, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   max_len_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_max_len = upd_val, eff_beg_dtm = glob.get_dtm
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
   max_len_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_len_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   max_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   max_len_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_len_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   max_len_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   max_len_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_len_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   max_len_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   max_len_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_len_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   max_len_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_max_len;
-----------------------------------------------------------
function APITAB_NON_max_len
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_len_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_max_len := ins_val;
   t1a_non_dml.ins(rec);
   max_len_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_len := upd_val;
   t1a_non_dml.upd(rec);
   max_len_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   max_len_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_max_len;
-----------------------------------------------------------
function APITAB_LOG_max_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_len_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_len   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   max_len_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_len := upd_val;
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
   max_len_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   max_len_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_len_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   max_len_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_max_len;
-----------------------------------------------------------
function APITAB_EFF_max_len
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_len_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_len   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   max_len_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_len := upd_val;
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
   max_len_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   max_len_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_len_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   max_len_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_max_len;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure max_min_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_min_rows_non;
-----------------------------------------------------------
procedure max_min_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
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
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
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
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_min_rows_log;
-----------------------------------------------------------
procedure max_min_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
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
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
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
          or (seq = seq_in and ( (num_max_min is null and val_in is null)
                               or num_max_min = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_min_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   max_min_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_max_min)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   max_min_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_max_min = upd_val
    where id = rec_id;
   max_min_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   max_min_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_max_min;
-----------------------------------------------------------
function SQLACT_LOG_max_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   max_min_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_max_min, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   max_min_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_max_min = upd_val
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
   max_min_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   max_min_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_min_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   max_min_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_max_min;
-----------------------------------------------------------
function SQLACT_EFF_max_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   max_min_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_max_min, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   max_min_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_max_min = upd_val, eff_beg_dtm = glob.get_dtm
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
   max_min_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_min_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   max_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   max_min_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_min_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   max_min_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   max_min_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_min_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   max_min_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   max_min_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_min_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   max_min_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_max_min;
-----------------------------------------------------------
function APITAB_NON_max_min
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_min_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_max_min := ins_val;
   t1a_non_dml.ins(rec);
   max_min_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_min := upd_val;
   t1a_non_dml.upd(rec);
   max_min_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   max_min_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_max_min;
-----------------------------------------------------------
function APITAB_LOG_max_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_min_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_min   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   max_min_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_min := upd_val;
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
   max_min_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   max_min_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_min_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   max_min_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_max_min;
-----------------------------------------------------------
function APITAB_EFF_max_min
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_min_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_min   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   max_min_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_min := upd_val;
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
   max_min_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   max_min_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_min_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   max_min_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_max_min;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
procedure max_max_rows_non
      (rows_in  in  number
      ,id_in    in  number
      ,seq_in   in  number default null
      ,val_in   in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_non
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
          );
   if row_cnt != rows_in then
      raise_application_error (-20000, 't1a_non row_cnt is not ' || rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_max_rows_non;
-----------------------------------------------------------
procedure max_max_rows_log
      (rows_in       in  number
      ,aud_rows_in   in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_log
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
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
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
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
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_log_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_max_rows_log;
-----------------------------------------------------------
procedure max_max_rows_eff
      (rows_in       in  number
      ,hist_rows_in  in  number
      ,pdat_rows_in  in  number
      ,id_in         in  number
      ,seq_in        in  number default null
      ,val_in        in  number default null)
is
   row_cnt  number;
begin
   select count(*)
    into  row_cnt
    from  t1a_eff
    where id = id_in
     and  (  seq_in is null
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
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
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
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
          or (seq = seq_in and ( (num_max_max is null and val_in is null)
                               or num_max_max = val_in )) 
          );
   if row_cnt != pdat_rows_in then
      raise_application_error (-20000, 't1a_eff_pdat row_cnt is not ' || pdat_rows_in ||
                                                            ': ' || row_cnt ||
                                                   ' for id_in ' || id_in   ||
                                                  ' and seq_in ' || seq_in  ||
                                                  ' and val_in ' || val_in);
   end if;
end max_max_rows_eff;
-----------------------------------------------------------
function SQLACT_NON_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   tab_seq  number;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   max_max_rows_non(0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   insert into t1a_non_act (id, key, seq, num_max_max)
      values (rec_id, trc.key_txt, tab_seq, ins_val);
   max_max_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   update t1a_non_act set num_max_max = upd_val
    where id = rec_id;
   max_max_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   max_max_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_NON_max_max;
-----------------------------------------------------------
function SQLACT_LOG_max_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   max_max_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_max_max, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   max_max_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_max_max = upd_val
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
   max_max_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   max_max_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_max_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   max_max_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_LOG_max_max;
-----------------------------------------------------------
function SQLACT_EFF_max_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
   rec_id   number;
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   max_max_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(trc.tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_max_max, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, trc.key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   max_max_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   success := FALSE;
   savepoint TEST_RIG_UPDATE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_max_max = upd_val, eff_beg_dtm = glob.get_dtm
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
   max_max_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
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
   max_max_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   max_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   max_max_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   max_max_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   max_max_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   max_max_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_max_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   max_max_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   max_max_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   max_max_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   max_max_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end SQLACT_EFF_max_max;
-----------------------------------------------------------
function APITAB_NON_max_max
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
   check_constraint  EXCEPTION;
   PRAGMA EXCEPTION_INIT (check_constraint, -02290);
   rec      t1a_non%ROWTYPE;
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_max_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   rec.num_max_max := ins_val;
   t1a_non_dml.ins(rec);
   max_max_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_max := upd_val;
   t1a_non_dml.upd(rec);
   max_max_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   max_max_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_NON_max_max;
-----------------------------------------------------------
function APITAB_LOG_max_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_max_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_max   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   max_max_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_max := upd_val;
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
   max_max_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   max_max_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_max_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   max_max_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_LOG_max_max;
-----------------------------------------------------------
function APITAB_EFF_max_max
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
   ins_val  number;
   upd_val  number;
   loc_txt  varchar2(30);
begin
   loc_txt := 'STARTUP';
   trc.get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := trc.key_txt;
   rec.seq := to_number(trc.tparms.val0);
   max_max_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(trc.tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_max_max   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   max_max_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(trc.tparms.val2);
   rec.num_max_max := upd_val;
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
   max_max_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   max_max_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
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
   max_max_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   max_max_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end APITAB_EFF_max_max;
-----------------------------------------------------------
end tr_btt_num;
/
