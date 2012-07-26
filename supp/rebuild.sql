
spool rebuild

@fullgen DTGEN
@../install/uninstall_db
@../install/install_db
@../install/comp

spool off

host sqlldr dtgen/dtgen@XE2 CONTROL=dtgen_dataload.ctl
host fgrep -e " Rows not loaded due to data errors." -e " Rows not loaded because all fields were null." -e "Total logical records skipped: " -e "Total logical records rejected: " -e "Total logical records discarded: " dtgen_dataload.log
host fgrep -i -e err -e fail -e warn -e ora- -e sp2- -e pls- rebuild.LST
