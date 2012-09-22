create or replace package body test_rig
is

current_global_set  global_parms.global_set%TYPE := null;
tparms              test_parms%ROWTYPE;
key_txt             varchar2(60);
sql_txt             varchar2(1994);
res_txt             varchar2(4000);

-- Define an exception that occurs when the DML
--   speed exceeds the resolution of systimestamp
--too_quick  EXCEPTION;

-- 20009: The new %s date must be greater than %s
-- The new date value of the data item precedes its previous value.
-- Ensure the new data value for the data occurs after its current date/time value.
--PRAGMA EXCEPTION_INIT (too_quick, -20009);

procedure get_tparms
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
is
   owner        varchar2(30);
   prog_name    varchar2(30);
   line_num     number;
   caller_type  varchar2(30);
   cursor curs is
      select * from test_parms
       where parm_set = parm_set_in
        and  parm_seq = parm_seq_in;
begin
   open curs;
   fetch curs into tparms;
   close curs;
   OWA_UTIL.WHO_CALLED_ME(owner, prog_name, line_num, caller_type);
   key_txt := upper(USER)               || ':' ||
              upper(current_global_set) || ':' ||
              upper(prog_name)          || ':' ||
              to_char(line_num)         || ':' ||
              upper(parm_set_in)        ;
end get_tparms;

procedure basic_test
is
   junk  dual.dummy%TYPE;
begin
   select dummy into junk from dual;
end basic_test;

procedure num_plain_rows_non
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
end num_plain_rows_non;

procedure num_plain_rows_log
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
end num_plain_rows_log;

procedure num_plain_rows_eff
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
end num_plain_rows_eff;

function BTT_SQLTAB_NON_NUM_PLAIN
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   num_plain_rows_non(0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   insert into t1a_non (id, key, seq, num_plain)
      values (rec_id, key_txt, tab_seq, ins_val);
   num_plain_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   update t1a_non set num_plain = upd_val
    where id = rec_id;
   num_plain_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non where id = rec_id;
   num_plain_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLTAB_NON_NUM_PLAIN;

function BTT_SQLTAB_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   num_plain_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=FALSE on DB server, AUD_BEG_USR and AUD_BEG_DTM must be set
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log (id, key, seq, num_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   num_plain_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   success := FALSE;
   for i in 1 .. 1000 loop begin
      update t1a_log set num_plain = upd_val
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLTAB_LOG_NUM_PLAIN;

function BTT_SQLTAB_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   num_plain_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=FALSE on DB server, AUD_BEG_USR and AUD_BEG_DTM must be set
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF (id, key, seq, num_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   success := FALSE;
   for i in 1 .. 1000 loop begin
      update t1a_eff set num_plain = upd_val, eff_beg_dtm = glob.get_dtm
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLTAB_EFF_NUM_PLAIN;

function BTT_SQLACT_NON_NUM_PLAIN
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_non_dml.get_next_id;
   num_plain_rows_non(0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   insert into t1a_non_act (id, key, seq, num_plain)
      values (rec_id, key_txt, tab_seq, ins_val);
   num_plain_rows_non(1, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   update t1a_non_act set num_plain = upd_val
    where id = rec_id;
   num_plain_rows_non(1, rec_id, tab_seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   delete from t1a_non_act where id = rec_id;
   num_plain_rows_non(0, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLACT_NON_NUM_PLAIN;

function BTT_SQLACT_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_log_dml.get_next_id;
   num_plain_rows_log(0, 0, 0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_log_act (id, key, seq, num_plain, aud_beg_usr, aud_beg_dtm)
      values (rec_id, key_txt, tab_seq, ins_val, glob.get_usr, glob.get_dtm);
   num_plain_rows_log(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   success := FALSE;
   for i in 1 .. 1000 loop begin
      update t1a_log_act set num_plain = upd_val
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(1, 0, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      delete from t1a_log_act where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLACT_LOG_NUM_PLAIN;

function BTT_SQLACT_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec_id  := t1a_eff_dml.get_next_id;
   num_plain_rows_eff(0, 0, 0, rec_id);
   tab_seq := to_number(tparms.val0);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   insert into t1a_EFF_act (id, key, seq, num_plain, eff_beg_dtm, aud_beg_usr, aud_beg_dtm)
      values (rec_id, key_txt, tab_seq, ins_val, glob.get_dtm, glob.get_usr, glob.get_dtm);
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   success := FALSE;
   for i in 1 .. 1000 loop begin
      update t1a_eff_act set num_plain = upd_val, eff_beg_dtm = glob.get_dtm
       where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      delete from t1a_eff_act where id = rec_id;
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   ----------------------------------------
   loc_txt := 'POP DELETE';
   t1a_eff_pop.at_server(rec_id);
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 1, 0, rec_id, tab_seq, ins_val);
   num_plain_rows_eff(1, 1, 1, rec_id);
   ----------------------------------------
   loc_txt := 'POP UPDATE';
   t1a_eff_pop.at_server(rec_id);
   num_plain_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(1, 0, 0, rec_id, tab_seq, ins_val);
   num_plain_rows_eff(1, 0, 2, rec_id);
   ----------------------------------------
   loc_txt := 'POP INSERT';
   t1a_eff_pop.at_server(rec_id);
   num_plain_rows_eff(0, 0, 1, rec_id, tab_seq, upd_val);
   num_plain_rows_eff(0, 0, 1, rec_id, tab_seq, ins_val);
   num_plain_rows_eff(0, 0, 3, rec_id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_SQLACT_EFF_NUM_PLAIN;

function BTT_APITAB_NON_NUM_PLAIN
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
   get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_non_dml.get_next_id;
   rec.key := key_txt;
   rec.seq := to_number(tparms.val0);
   num_plain_rows_non(0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   rec.num_plain := ins_val;
   t1a_non_dml.ins(rec);
   num_plain_rows_non(1, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   rec.num_plain := upd_val;
   t1a_non_dml.upd(rec);
   num_plain_rows_non(1, rec.id, rec.seq, upd_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   t1a_non_dml.del(rec.id);
   num_plain_rows_non(0, rec.id);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_APITAB_NON_NUM_PLAIN;

function BTT_APITAB_LOG_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_LOG_dml.get_next_id;
   rec.key := key_txt;
   rec.seq := to_number(tparms.val0);
   num_plain_rows_log(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_plain   := ins_val;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_LOG_dml.ins(rec);
   num_plain_rows_log(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   rec.num_plain := upd_val;
   success := FALSE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.upd(rec);
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(1, 0, 0, rec.id, rec.seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      t1a_LOG_dml.del(rec.id);
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_log(0, 1, 0, rec.id, rec.seq, upd_val);
   num_plain_rows_log(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_APITAB_LOG_NUM_PLAIN;

function BTT_APITAB_EFF_NUM_PLAIN
      (parm_set_in  in  varchar2
      ,parm_seq_in  in  number)
   return varchar2
is
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
   get_tparms(parm_set_in, parm_seq_in);
   rec.id  := t1a_EFF_dml.get_next_id;
   rec.key := key_txt;
   rec.seq := to_number(tparms.val0);
   num_plain_rows_EFF(0, 0, 0, rec.id);
   ----------------------------------------
   loc_txt := 'INSERT';
   ins_val := to_number(tparms.val1);
   --  When db_constraints=TRUE on DB server and NoInteg, AUD_BEG_USR and AUD_BEG_DTM must be set
   rec.num_plain   := ins_val;
   rec.eff_beg_dtm := glob.get_dtm;
   rec.aud_beg_usr := glob.get_usr;
   rec.aud_beg_dtm := glob.get_dtm;
   t1a_eff_dml.ins(rec);
   num_plain_rows_EFF(1, 0, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'UPDATE';
   upd_val := to_number(tparms.val2);
   rec.num_plain := upd_val;
   success := FALSE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.upd(rec);
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_EFF(1, 0, 0, rec.id, rec.seq, upd_val);
   num_plain_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   loc_txt := 'DELETE';
   success := FALSE;
   for i in 1 .. 1000 loop begin
      rec.eff_beg_dtm := glob.get_dtm;
      t1a_EFF_dml.del(rec.id, rec.eff_beg_dtm);
      success := TRUE; EXIT;
   exception when too_quick then null;
      when check_constraint then if sqlerrm like '%_EF1) violated%' then null; end if;
   end; end loop;
   if not success then
      raise_application_error (-20000, 'failed to successfully exit the "too_quick" loop');
   end if;
   num_plain_rows_EFF(0, 1, 0, rec.id, rec.seq, upd_val);
   num_plain_rows_EFF(0, 1, 0, rec.id, rec.seq, ins_val);
   ----------------------------------------
   return 'SUCCESS';
exception
   when others then
      return substr('FAILURE at ' || loc_txt ||
                             ': ' || sqlerrm ||
                             '. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,4000);
end BTT_APITAB_EFF_NUM_PLAIN;

function bool_to_str
      (bool_in in boolean)
   return varchar2
is
begin
   if bool_in then
      return 'TRUE';
   end if;
   return 'FALSE';
end bool_to_str;

procedure set_global_parms
      (global_set_in  in  varchar2)
is
begin
   if global_set_in = current_global_set then
      return;
   end if;
   for buff in (
      select * from global_parms
       where global_set = global_set_in)
   loop
      case buff.db_constraints
      when 'T' then
         glob.set_db_constraints(TRUE);
      else
         glob.set_db_constraints(FALSE);
      end case;
      case buff.fold_strings
      when 'T' then
         glob.set_fold_strings(TRUE);
      else
         glob.set_fold_strings(FALSE);
      end case;
      case buff.ignore_no_change
      when 'T' then
         glob.set_ignore_no_change(TRUE);
      else
         glob.set_ignore_no_change(FALSE);
      end case;
   end loop;
   current_global_set := global_set_in;
   dbms_output.put_line('');
   dbms_output.put_line('============================================================');
   DBMS_OUTPUT.PUT_LINE('   Global_Set is ' || current_global_set);
   DBMS_OUTPUT.PUT_LINE('      glob.get_db_constraints   is ' ||
                   bool_to_str(glob.get_db_constraints));
   DBMS_OUTPUT.PUT_LINE('      glob.get_fold_strings     is ' ||
                   bool_to_str(glob.get_fold_strings));
   DBMS_OUTPUT.PUT_LINE('      glob.get_ignore_no_change is ' ||
                   bool_to_str(glob.get_ignore_no_change));
end set_global_parms;

procedure run_test
      (test_name_in  in  varchar2)
is
   LF  constant varchar2(1) := CHR(10);
   sql_txt  varchar2(4000);
   ret_txt  varchar2(4000);
begin
   glob.set_usr(USER);
   dbms_output.put_line('');
   dbms_output.put_line('Running Test ' || test_name_in);
   for buff in (
      select test_sets.parm_set, test_parms.parm_seq, test_parms.result_txt
       from  test_parms, test_sets
       where test_parms.parm_set  = test_sets.parm_set
        and  test_sets.test_name  = test_name_in
        and  test_sets.global_set = current_global_set
        and  test_sets.user_name  = USER
       order by test_sets.parm_set, test_parms.parm_seq )
   loop
      sql_txt := 'begin :a := test_rig.' || test_name_in  ||
                                   '(''' || buff.parm_set ||
                                   ''',' || buff.parm_seq || '); end;';
      --dbms_output.put_line('SQL> ' || sql_txt);
      execute immediate sql_txt using out ret_txt;
      if ret_txt like buff.result_txt then
         dbms_output.put_line('   Parm_Set ' || buff.parm_set ||
                                    ', SEQ ' || buff.parm_seq);
      else
         dbms_output.put_line('***Parm_Set ' || buff.parm_set ||
                                    ', SEQ ' || buff.parm_seq);
         dbms_output.put_line('---Expected: ' || replace(buff.result_txt,LF,LF||'---          '));
         dbms_output.put_line('---Received: ' || replace(ret_txt,LF,LF||'---          '));
      end if;
   end loop;
end run_test;

procedure run_global_set
      (global_set_in  in  varchar2)
is
begin
   test_rig.set_global_parms(global_set_in);
   for buff in (
      select test_name from test_sets
       where test_sets.global_set = current_global_set
        and  test_sets.user_name  = USER
       group by test_name
       order by test_name desc)
   loop
      run_test(buff.test_name);
   end loop;
end run_global_set;

procedure run_all
is
begin
   --glob.delete_all_data;
   for buff in (
      select global_set from global_parms
       order by global_set)
   loop
      run_global_set(buff.global_set);
   end loop;
   commit;
end run_all;

end test_rig;
/
