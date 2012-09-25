
ROOT_LIST="install_owner install_user"
#ROOT_LIST="uninstall_owner uninstall_user"

TDIR_LIST="DB_Integ MT_Integ DB_NoInteg MT_NoInteg"

for TDIR in ${TDIR_LIST}
do
   cd ${TDIR}
   for ROOT in ${ROOT_LIST}
   do
      mv ${ROOT}.gold ${ROOT}.old
      mv ${ROOT}.log ${ROOT}.gold
   done
   cd ${OLDPWD}
done
