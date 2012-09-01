create or replace package body test_rig
is

function DTC_INSERT_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'insert into ' || table_name_in ||
               ' (seq, ' || column_name_in ||
            ') values (' || tab_seq_in ||
                    ', ' || value_in || ')';
end DTC_INSERT_SQL;

function DTC_UPDATE_SQL
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'update ' || table_name_in ||
            ' set ' || column_name_in ||
              ' = ' || value_in ||
    ' where seq = ' || tab_seq_in;
end DTC_UPDATE_SQL;

function DTC_INSERT_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'declare buff ' || table_name_in || '%ROWTYPE; begin' ||
          ' buff.seq := ' || tab_seq_in ||
                '; buff.' || column_name_in ||
                   ' := ' || value_in ||
                     '; ' || table_name_in ||
           '.ins(buff)';
end DTC_INSERT_API;

function DTC_INSERT_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'declare buff ' || table_name_in ||
   '_ACT%ROWTYPE; begin ' || table_name_in ||
           '.ins(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' || value_in || ')';
end DTC_INSERT_API2;

function DTC_UPDATE_API
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'declare buff ' || table_name_in ||
       '%ROWTYPE; begin ' || table_name_in ||
           '.upd(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' ||value_in || ')';
end DTC_UPDATE_API;

function DTC_UPDATE_API2
      (table_name_in   in  varchar2
      ,column_name_in  in  varchar2
      ,tab_seq_in      in  varchar2
      ,value_in        in  varchar2)
   return varchar2
is
begin
   return 'declare buff ' || table_name_in ||
   '_ACT%ROWTYPE; begin ' || table_name_in ||
           '.upd(seq => ' || tab_seq_in ||
                     ', ' || column_name_in ||
                   ' => ' || value_in || ')';
end DTC_UPDATE_API2;

end test_rig;
/
