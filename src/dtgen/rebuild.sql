
REM  fullgen does spooling
@../fullgen DTGEN

spool rebuild
--@uninstall_db
--@install_db
@comp

spool off
